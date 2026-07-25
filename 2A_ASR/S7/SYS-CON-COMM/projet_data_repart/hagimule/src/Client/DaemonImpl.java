package Client;

import Server.*;
import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.rmi.Naming;
import java.util.HashSet;
import java.util.Set;
import java.util.AbstractMap.SimpleEntry;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import java.util.zip.GZIPOutputStream;

import Client.Exceptions.InvalidRequestException;

/**
 * Classe ClientDaemon : Un démon qui connecte un client à l'annuaire RMI,
 * surveille
 * un répertoire pour les modifications et accepte les téléchargements de
 * fichiers.
 */
public class DaemonImpl implements Daemon {

    private final String adresse;
    private final Set<Integer> ports;
    private final File repertoire;
    private Integer id;
    private Diary diary;
    private final Integer PACKET_SIZE; // in byte
    private final Integer LATENCY; // in usec

    public DaemonImpl(String adresse, Set<Integer> ports, String cheminRepertoire, String annuaireUrl, Integer packetSize, Integer latency) {
        this.adresse = adresse;
        this.ports = ports;
        this.repertoire = new File(cheminRepertoire);
        this.PACKET_SIZE = packetSize;
        this.LATENCY = latency;
        try {
            this.diary = (Diary) Naming.lookup("//" + annuaireUrl + "/DiaryService");
        } catch (Exception e) {
            System.err.println("Diary connexion failed : " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }

    public void init() {
        try {

            new Thread(this::watchDirectory).start();
            new Thread(this::startFileServer).start();
            register();

            ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
            scheduler.scheduleAtFixedRate(new Runnable() {
                @Override
                public void run() {
                    heartBeat();
                }
            }, 0, 1, TimeUnit.SECONDS);
        } catch (Exception e) {
            System.err.println("Error while starting daemon : " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }

    public void register() {
        try {
            Set<SimpleEntry<String, SimpleEntry<Integer,Integer>>> files = getLocalFiles();
            this.id = diary.registerClient(adresse, ports, files);
        } catch (Exception e) {
            System.err.println("Error while registering in diary server : " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }

    public void watchDirectory() {
        try {
            WatchService watchService = FileSystems.getDefault().newWatchService();
            Path path = repertoire.toPath();
            path.register(watchService, StandardWatchEventKinds.ENTRY_CREATE, StandardWatchEventKinds.ENTRY_DELETE);

            while (true) {
                WatchKey key = watchService.take();
                for (WatchEvent<?> event : key.pollEvents()) {
                    WatchEvent.Kind<?> kind = event.kind();
                    if (kind == StandardWatchEventKinds.ENTRY_CREATE || kind == StandardWatchEventKinds.ENTRY_DELETE) {
                        diary.updateClient(this.id, getLocalFiles());
                    }
                    key.reset();
                }
            }
        } catch (Exception e) {
            System.err.println("Error while watching the source folder : " + e.getMessage());
            e.printStackTrace();
        }
    }

    public void startFileServer() {
        ExecutorService pool = Executors.newCachedThreadPool();
        try {
            for (Integer port : ports) {
                pool.execute(() -> {
                    try (ServerSocket serverSocket = new ServerSocket(port)) {
                        while (true) {
                            Socket socket = serverSocket.accept();
                            pool.execute(() -> handleFileRequest(socket));
                        }
                    } catch (Exception e) {
                        System.err
                                .println("Error while listening  " + port + " : " + e.getMessage());
                        e.printStackTrace();
                        System.exit(1);
                    }
                });
            }
        } catch (Exception e) {
            System.err.println("Error : " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }

    public void handleFileRequest(Socket socket) {
        try {
            System.out.println("New request from : " + socket);
            OutputStream client_output = socket.getOutputStream();
            InputStream client_input = socket.getInputStream();
            this.diary.usePortSignal(this.id, socket.getLocalPort());
            byte[] buff = new byte[1024];
            client_input.read(buff);
            String request = new String(buff, StandardCharsets.UTF_8);
            System.out.println(request);
            String[] args = request.split(" ");
            if (args.length != 4) {
                throw new InvalidRequestException("Request must be : <file_name> <offset_start> <offset_end>");
            }
            String fileName = args[0].trim();
            Integer start = Integer.parseInt(args[1].trim());
            Integer end = Integer.parseInt(args[2].trim());
            Integer mode = Integer.parseInt(args[3].trim());
            // Select the file
            File selectedFile = new File(repertoire, fileName);
            if (selectedFile.exists() && selectedFile.isFile()) {
                BufferedInputStream fileInputStream = new BufferedInputStream(new FileInputStream(selectedFile));
                if (start < selectedFile.length()) {
                    if (end > selectedFile.length()) {
                        end = (int) selectedFile.length();
                    }
            
                        // Depending on the mode, apply compression or just transfer data
                    switch (mode) {
                        case 0:
                            // Mode 0: No compression, just send the raw data
                            fileInputStream.skip(start);
                            sendFileChunk(client_output, fileInputStream, end - start);
                            break;
                        case 1:
                            // Mode 1: Compress from start to end and send the compressed chunk
                            fileInputStream.skip(start);
                            sendCompressedChunk(client_output, fileInputStream, end - start);
                            break;
                        case 2:
                            // Mode 2: Compress the entire file and then send the chunk from start to end TODO: not working
                            byte[] compressedData = compressFile(selectedFile);
                            ByteArrayInputStream compressedStream = new ByteArrayInputStream(compressedData);
                            compressedStream.skip(start); // Skip the start offset in the compressed data
                            sendFileChunk(client_output, compressedStream, end - start);
                            break;
                        default:
                            System.err.println("Invalid mode.");
                            break;
                    }
                } else {
                    System.err.println("Invalid chunk: Chunk start after the end of file.");
                }
            }
        } catch (Exception e) {
            System.err.println("Error while handling file request : " + e.getMessage() + "\n");
            e.printStackTrace();
        } finally {
            try {
                this.diary.releasePortSignal(this.id, socket.getLocalPort());
                socket.close();
            } catch (Exception e) {
                e.printStackTrace();
                System.exit(1);
            }
        }
    }

    public void heartBeat() {
        try {
            diary.heartbeatSignal(this.id);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public Set<SimpleEntry<String,SimpleEntry<Integer, Integer>>> getLocalFiles() {
        Set<SimpleEntry<String,SimpleEntry<Integer, Integer>>> files = new HashSet<>();
        File[] listFiles = repertoire.listFiles();
        if (listFiles != null) {
            for (File file : listFiles) {
                if (file.isFile()) {
                    try {
                        Integer length = Files.readAllBytes(file.toPath()).length;
                        SimpleEntry<Integer,Integer> entry = new SimpleEntry<Integer,Integer>(length, compressFile(file).length);
                        files.add(new SimpleEntry<String, SimpleEntry<Integer,Integer>>(file.getName(), entry));
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        }
        return files;
    }


    // Helper method to send raw file chunk
    private void sendFileChunk(OutputStream clientOutput, InputStream fileInputStream, int size) throws IOException {
        byte[] buffer = new byte[PACKET_SIZE];
        int bytesRead;
        int bytesRemaining = size;
        
        while (bytesRemaining > 0) {
            int toRead = Math.min(buffer.length, bytesRemaining);
            bytesRead = fileInputStream.read(buffer, 0, toRead);
            if (bytesRead == -1) break; // End of file
            clientOutput.write(buffer, 0, bytesRead);
            bytesRemaining -= bytesRead;
            try {
                Thread.sleep(LATENCY); // Pause for LATENCY seconds
            } catch (InterruptedException e) {
                System.err.println("Error while faking latency : " + e.getMessage());
            }
            
        }
    }

    // Helper method to send compressed chunk
    private void sendCompressedChunk(OutputStream clientOutput, InputStream fileInputStream, int size) throws IOException {
        byte[] buffer = new byte[PACKET_SIZE];
        int bytesRead;
        int bytesRemaining = size;
        
        try (ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
            GZIPOutputStream gzipOutputStream = new GZIPOutputStream(byteArrayOutputStream)) {
            // Read and compress the data in the specified range
            while (bytesRemaining > 0) {
                int toRead = Math.min(buffer.length, bytesRemaining);
                bytesRead = fileInputStream.read(buffer, 0, toRead);
                if (bytesRead == -1) break; // End of file
                gzipOutputStream.write(buffer, 0, bytesRead);
                bytesRemaining -= bytesRead;
            }
            
            gzipOutputStream.finish();

            // Get the compressed data as a byte array
            byte[] compressedData = byteArrayOutputStream.toByteArray();
            bytesRemaining = compressedData.length; // Set bytesRemaining to the size of the compressed data

            // Prepare to send the compressed data in chunks
            int offset = 0;
            while (bytesRemaining > 0) {
                int toRead = Math.min(buffer.length, bytesRemaining);
                System.arraycopy(compressedData, offset, buffer, 0, toRead);
                bytesRead = toRead; // Number of bytes read into the buffer
                offset += bytesRead; // Move the offset to the next chunk
                bytesRemaining -= bytesRead;

                // Write the chunk to the client output stream
                clientOutput.write(buffer, 0, bytesRead);

                try {
                    Thread.sleep(LATENCY); // Pause for LATENCY seconds
                } catch (InterruptedException e) {
                    System.err.println("Error while faking latency: " + e.getMessage());
                }
            }
        }
    }

    // Helper method to compress the entire file
    private byte[] compressFile(File file) throws IOException {
        try (BufferedInputStream fileInputStream = new BufferedInputStream(new FileInputStream(file));
            ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
            GZIPOutputStream gzipOutputStream = new GZIPOutputStream(byteArrayOutputStream)) {
            
            byte[] buffer = new byte[PACKET_SIZE];
            int bytesRead;
            
            while ((bytesRead = fileInputStream.read(buffer)) != -1) {
                gzipOutputStream.write(buffer, 0, bytesRead);
            }
            
            gzipOutputStream.finish();
            return byteArrayOutputStream.toByteArray();
        }
    }


    public static void main(String[] args) {
        if (args.length != 6) {
            System.out.println("Bad usage : java ClientDaemon <address> <ports> <storage_path> <diary_address> <packet_size> <latency>");
            System.exit(1);
        }

        String address = args[0];
        String portsString = args[1];
        String storagePath = args[2];
        String diaryAddr = args[3];
        Integer packetSize = Integer.parseInt(args[4]);
        Integer latency = Integer.parseInt(args[5]);

        Set<Integer> ports;
        try {
            ports = Stream.of(portsString.split(":"))
                    .map(Integer::parseInt)
                    .collect(Collectors.toSet());
        } catch (NumberFormatException e) {
            System.err.println("Error : Ports must be separed by ':'.");
            System.exit(1);
            return;
        }

        Daemon d = new DaemonImpl(address, ports, storagePath, diaryAddr, packetSize, latency);
        d.init();
    }
}
