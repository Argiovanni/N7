package Server;

import java.rmi.Remote;
import java.rmi.RemoteException;
import java.util.AbstractMap.SimpleEntry;
import java.util.List;
import java.util.Set;

/**
 * Interface Diary : une interface pour gérer l'enregistrement
 * et la récupération des fichiers des clients connectés via RMI.
 */
public interface Diary extends Remote {

    public Integer registerClient(String addr, Set<Integer> ports, Set<SimpleEntry<String, SimpleEntry<Integer, Integer>>> files)
            throws RemoteException;

    public List<SimpleEntry<String, Integer>> getProviders(String file) throws RemoteException;

    public Set<SimpleEntry<String,SimpleEntry<Integer, Integer>>> getFiles() throws RemoteException;

    public void updateClient(Integer id, Set<SimpleEntry<String,SimpleEntry<Integer, Integer>>> files) throws RemoteException;

    public void usePortSignal(Integer id, Integer port) throws RemoteException;

    public void releasePortSignal(Integer id, Integer port) throws RemoteException;

    public void heartbeatSignal(Integer id) throws RemoteException;
}
