package Client;

import java.io.*;
import java.net.ConnectException;
import java.net.Socket;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.rmi.Naming;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.zip.GZIPInputStream;

import Client.Utils.Logger;
import java.util.AbstractMap.SimpleEntry;
import java.util.ArrayList;
import java.util.List;
import java.util.Queue;

import Client.Exceptions.DownloadChunkFailedException;
import Client.UI.Console;
import Client.Utils.Action;
import Server.Diary;

public class DownloaderImpl implements Downloader {

    private List<SimpleEntry<String, Integer>> hosts;
    private String fileName;
    private String savePath;
    private Diary diary;
    private Logger logger;
    private Integer nbProviders;
    private Integer mode;
    private Integer size;
    private Integer compressedSize;
    private long startTime;
    private Console c;
    Queue<Future<Void>> futures;
    private static final int MAX_PACKET_SIZE = 1024;

    public DownloaderImpl(List<SimpleEntry<String, Integer>> hosts, String fileName, String savePath,
            Diary diary, Console c, Integer nbProviders, Integer mode, Integer size, Integer compressed) {
        this.hosts = hosts;
        this.fileName = fileName;
        this.savePath = savePath;
        this.diary = diary;
        this.c = c;
        this.nbProviders = nbProviders;
        this.mode = mode;
        this.size = size;
        this.compressedSize = compressed;
        this.futures = new ConcurrentLinkedQueue<>();
        try {
            this.logger = new Logger("../logs/debug.log");
        } catch (IOException e) {
            e.printStackTrace();
            System.exit(1);
        }
        
    }

    public void download() {
        this.downloadFile(nbProviders, 0, (mode == 2) ? compressedSize : size, 0, mode);
        try {
            while (!futures.isEmpty()) {
                Future<Void> future = futures.poll(); // Poll tasks from the queue
                if (future != null) {
                    future.get();  // This will block until each future completes
                }
            }
            if (mode == 2) {
                this.decompressFile();
            }
            logger.finishDownload(fileName, size, startTime, nbProviders);
            c.downloadFinish();
        } catch (InterruptedException | ExecutionException e) {
            System.err.println("Error completing downloads: " + e.getMessage());
            e.printStackTrace();
        }
    
    }

    private void decompressFile() {
        try {
            File f = new File(this.savePath);
            byte[] compressedData = Files.readAllBytes(f.toPath());
            ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(compressedData);
            GZIPInputStream gzipInputStream = new GZIPInputStream(byteArrayInputStream);
            BufferedOutputStream fileOutputStream = new BufferedOutputStream(new FileOutputStream(f));

            byte[] buffer = new byte[1024];
            int bytesRead;

            // Decompress the data and write it to the output file
            while ((bytesRead = gzipInputStream.read(buffer)) != -1) {
                fileOutputStream.write(buffer, 0, bytesRead);
            }
            fileOutputStream.close();
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(1);
        }
    }

    private void downloadFile(Integer nbProviders, Integer from, Integer to, Integer retryTimes, Integer mode) {
        ExecutorService executorService = Executors.newFixedThreadPool(nbProviders);
        
        // Calculate chunk size based on the number of hosts
        int numHosts = nbProviders;
        int chunkSize = (int) Math.ceil((double) (to - from) / numHosts);
        if (retryTimes != 0) {
            logger.retryDownloadChunk(fileName, from, to, retryTimes);
        } else {
            this.startTime = logger.startDownload(fileName);
            c.download(fileName);
        }
        int offset = from; // The starting point for each host's chunk
        try {
            this.hosts = this.diary.getProviders(fileName);
            if (hosts != null && hosts.size() >= nbProviders) {
                List<SimpleEntry<String, Integer>> hostsList = new ArrayList<>(hosts);
                for (int i = 0; i < nbProviders; i++) {
                    // For each host, submit a task to download a portion of the file
                    String hostAddress = hostsList.get(i).getKey();
                    int port = hostsList.get(i).getValue();
                    hosts.remove(hostsList.get(i));
                    // Determine the range of the file this host will download
                    int start = offset;
                    int end = Math.min(offset + chunkSize, to); // Ensure we do not exceed the file size
                    offset = end; // Update offset for the next chunk
                    futures.add(executorService.submit(() -> {
                        try {
                            downloadChunk(hostAddress, port, start, end, mode);
                        } catch (DownloadChunkFailedException e) {
                            logger.warningChunk(fileName, start, end, hostAddress, port);
                            if (retryTimes <= 5) {
                                TimeUnit.SECONDS.sleep(1);
                                downloadFile(1, e.getFrom(), e.getTo(), retryTimes+1, mode);
                            } else {
                                logger.cancelDownload(fileName);
                                c.canceledDownload();
                            }
                        } catch (IOException e) {
                            System.err.println(
                                    "Error downloading chunk from " + hostAddress + ":" + port + " - "
                                            + e.getMessage());
                            e.printStackTrace();
                            System.exit(1);
                        }
                        return null;
                    }));
                }
            } else {
                if (retryTimes <= 5) {
                    TimeUnit.SECONDS.sleep(1);
                    logger.retryDownloadChunk(fileName, from, to, retryTimes);
                    downloadFile(nbProviders, from, to, retryTimes + 1, mode);
                } else {
                    logger.cancelDownload(fileName);
                    c.canceledDownload();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(1);
        } finally {
            executorService.shutdown();
        }
    }

    private void downloadChunk(String hostAddress, int port, int start, int end, Integer mode)
            throws IOException, DownloadChunkFailedException {
        try {
            Socket server = new Socket(hostAddress, port);
            InputStream serverInput = server.getInputStream();
            OutputStream serverOutput = server.getOutputStream();

            // Prepare the request for the chunk
            byte[] request = (fileName + " " + start + " " + end + " " + mode).getBytes(StandardCharsets.UTF_8);
            serverOutput.write(request);

            // Create buffer to store the chunk data
            byte[] buffer = new byte[MAX_PACKET_SIZE];

            // Use RandomAccessFile to write to specific positions in the file
            try (RandomAccessFile outputFile = new RandomAccessFile(savePath, "rw")) {
                // Set the file pointer to the 'start' position where we want to write
                outputFile.seek(start);

                if (mode == 0) {
                    // Mode 0: No compression, download raw data
                    downloadRawData(serverInput, outputFile, buffer, start, end);
                } else if (mode == 1) {
                    // Mode 1: Download compressed chunk and decompress
                    downloadCompressedData(serverInput, outputFile, buffer, start, end);
                } else if (mode == 2) {
                    // Mode 2: Download the entire compressed file and then extract the chunk
                    downloadRawData(serverInput, outputFile, buffer, start, end);
                } else {
                    throw new IllegalArgumentException("Unsupported mode: " + mode);
                }
                server.close();
            }
        } catch (ConnectException e) {
            String err = "Warning: Incomplete download for chunk " + start + "-" + end;
            throw new DownloadChunkFailedException(err, start, end);
        }
    }


    // Method for downloading raw data (mode 0)
    private void downloadRawData(InputStream serverInput, RandomAccessFile outputFile, byte[] buffer, int start, int end) throws IOException, DownloadChunkFailedException {
        Integer totalBytesRead = 0;
        while (totalBytesRead < (end - start)) {
            int bytesRead = serverInput.read(buffer);
            if (bytesRead == -1) {
                break;
            }
            outputFile.write(buffer, 0, bytesRead);
            totalBytesRead += bytesRead;
        }
        checkDownloadCompletion(totalBytesRead, start, end);
    }

        // Method for downloading compressed data (mode 1)
    private void downloadCompressedData(InputStream serverInput, RandomAccessFile outputFile, byte[] buffer, int start, int end) throws IOException, DownloadChunkFailedException {
        Integer totalBytesRead = 0;
        try {
            GZIPInputStream gzipInputStream = new GZIPInputStream(serverInput);
            while (totalBytesRead < (end - start)) {
                int bytesRead = gzipInputStream.read(buffer);
                if (bytesRead == -1) {
                    break;
                }
                outputFile.write(buffer, 0, bytesRead);
                totalBytesRead += bytesRead;
            }
        } catch (Exception e) {
            String err = "Warning: Incomplete download for chunk " + start + "-" + end;
            System.err.println(err);
            throw new DownloadChunkFailedException(err, start + totalBytesRead, end);
        }   
        checkDownloadCompletion(totalBytesRead, start, end);
    }

    private void checkDownloadCompletion(int totalBytesRead, int start, int end) throws DownloadChunkFailedException {
        if (totalBytesRead != (end - start)) {
            String err = "Warning: Incomplete download for chunk " + start + "-" + end;
            System.err.println(err);
            throw new DownloadChunkFailedException(err, start + totalBytesRead, end);
        }
    }

    public static void main(String[] args) {
        if (args.length != 2) {
            System.err.println("Bad usage of downloader : java Client.DownloaderImpl <server_address> <storage_path>.");
            System.exit(1);
        }
        String serverAddr = args[0];
        String storagePath = args[1];
        try {
            Diary diary = (Diary) Naming.lookup("//" + serverAddr + "/DiaryService");
            Console c = new Console();
            boolean isRunning = true;
            while (isRunning) {
                Action action = c.askUser(false);
                switch (action) {
                    case MENU_DOWNLOAD:
                        SimpleEntry<String, SimpleEntry<Integer,Integer>> entry = c.chooseFile(diary.getFiles());
                        if (entry != null) {
                            String fileName = entry.getKey();
                            Integer fileSize = entry.getValue().getKey();
                            Integer compressed = entry.getValue().getValue();
                            List<SimpleEntry<String, Integer>> providers = diary.getProviders(fileName);
                            Integer nb_providers = c.askNumberOfProviders(providers.size());
                            Integer mode = c.askMode();
                            // Demander les parametres de download
                            Downloader d = new DownloaderImpl(providers, fileName,
                                    storagePath + fileName, diary, c, nb_providers, mode, fileSize, compressed);
                            d.download();
                        }
                        break;
                    case EXIT:
                        isRunning = false;
                        break;
                    default:
                        break;
                }
            }
        } catch (Exception e) {
            System.err.println("Diary connexion failed : " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }

    }
}
