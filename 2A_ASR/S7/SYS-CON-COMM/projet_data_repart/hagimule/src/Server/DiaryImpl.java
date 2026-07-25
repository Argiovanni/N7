package Server;

import java.util.List;
import java.util.Scanner;
import java.util.Set;
import java.rmi.Naming;
import java.rmi.RemoteException;
import java.rmi.registry.LocateRegistry;
import java.rmi.server.UnicastRemoteObject;
import java.util.AbstractMap.SimpleEntry;
import java.util.ArrayList;

import Server.Exceptions.AddressAlreadyRegisteredException;
import Server.Exceptions.ClientNotFoundException;
import Server.Exceptions.FileNotRegisteredException;
import Server.Exceptions.PortAlreadyInUseException;
import Server.Exceptions.PortNotOpenException;
import Server.Exceptions.ProviderNotFoundException;
import Server.Utils.AvailableFiles;
import Server.Utils.AvailableFilesImpl;
import Server.Utils.ConnectedClients;
import Server.Utils.ConnectedClientsImpl;

public class DiaryImpl extends UnicastRemoteObject implements Diary {
    private AvailableFiles files;
    private ConnectedClients clients;

    public static void main(String[] args) {
        try {
            // Création de l'instance du service distant
            DiaryImpl diary = new DiaryImpl();

            // Démarrage du registre RMI sur le port 1099 (par défaut)
            LocateRegistry.createRegistry(1099);

            // Enregistrement de l'objet distant dans le registre avec le nom "DiaryService"
            Naming.rebind("DiaryService", diary);

            // Afficher l'addresse du registry
            System.out.println("Server Diary started, waiting for connexions...");
            Scanner scanner = new Scanner(System.in);
            String input;
            do {
                input = scanner.nextLine();
                System.out.println(diary);
            } while (!input.equals("q")); // Doesn't work TODO:
            scanner.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public DiaryImpl() throws RemoteException {
        this.files = new AvailableFilesImpl();
        this.clients = new ConnectedClientsImpl();
    }

    public Integer registerClient(String addr, Set<Integer> ports, Set<SimpleEntry<String,SimpleEntry<Integer, Integer>>> files)
            throws RemoteException {
        try {
            Integer id = this.clients.registerClient(addr, ports);
            for (SimpleEntry<String, SimpleEntry<Integer, Integer>> entry : files) {
                String name = entry.getKey();
                Integer bytesSyze = entry.getValue().getKey();
                Integer compressed = entry.getValue().getValue();
                this.files.registerProvider(id, name, bytesSyze, compressed);
            }
            return id;
        } catch (AddressAlreadyRegisteredException e) {
            System.err.println(e);
            return null;
        }
    }

    public List<SimpleEntry<String, Integer>> getProviders(String file) throws RemoteException {
        try {
            this.updateFilesProviders();
            Integer fileId = this.files.getIdFile(file);
            Set<Integer> providersId = this.files.getProviders(fileId);

            List<SimpleEntry<String, Integer>> providersList = new ArrayList<>();
            for (Integer providerId : providersId) {
                SimpleEntry<String, Integer> entry = this.clients.getClient(providerId);
                providersList.add(entry);
            }

            // Sorting outside a TreeSet for serialization
            providersList.sort((entry1, entry2) -> {
                try {
                    float usageRate1 = clients.getClientByAddr(entry1.getKey()).getUsageRate();
                    float usageRate2 = clients.getClientByAddr(entry2.getKey()).getUsageRate();
                    return Float.compare(usageRate1, usageRate2);
                } catch (Exception e) {
                    e.printStackTrace();
                    return 0;
                }
            });

            return providersList;
        } catch (Exception e) {
            System.err.println(e);
            return null;
        }
    }

    public void updateClient(Integer id, Set<SimpleEntry<String,SimpleEntry<Integer, Integer>>> files) throws RemoteException {
        this.files.updateFilesOfProvider(id, files);
    }

    public Set<SimpleEntry<String,SimpleEntry<Integer, Integer>>> getFiles() throws RemoteException {
        this.updateFilesProviders();
        return this.files.getAvailableFiles();
    }

    public void usePortSignal(Integer id, Integer port) throws RemoteException {
        try {
            this.clients.usePort(id, port);
        } catch (ClientNotFoundException e) {
            System.err.println(e);
        } catch (PortAlreadyInUseException e) {
            System.err.println(e);
        } catch (PortNotOpenException e) {
            System.err.println(e);
        }
    }

    public void releasePortSignal(Integer id, Integer port) throws RemoteException {
        try {
            this.clients.releasePort(id, port);
        } catch (ClientNotFoundException e) {
            System.err.println(e);
        } catch (PortNotOpenException e) {
            System.err.println(e);
        }
    }

    public void heartbeatSignal(Integer id) throws RemoteException {
        try {
            this.clients.receiveHearbeat(id);
        } catch (ClientNotFoundException e) {
            System.err.println(e);
        }
    }

    private void updateFilesProviders() {
        Set<Integer> providers = this.clients.getClientsRegistered();
        try {
            this.files.updateProviders(providers);
        } catch (FileNotRegisteredException e) {
            System.err.println(e);
        } catch (ProviderNotFoundException e) {
            System.err.println(e);
        }
    }

    @Override
    public String toString() {
        return "Infos files :\n\t" + files + "\n"
                + "Infos clients :\n\t" + clients;
    }
}