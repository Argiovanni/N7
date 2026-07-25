package Server.Utils;

import java.util.AbstractMap.SimpleEntry;
import java.util.Set;

import Server.Exceptions.AddressAlreadyRegisteredException;
import Server.Exceptions.ClientNotFoundException;
import Server.Exceptions.NoPortAvailableException;
import Server.Exceptions.PortAlreadyInUseException;
import Server.Exceptions.PortNotOpenException;

public interface ConnectedClients {

    public Integer registerClient(String addr, Set<Integer> ports) throws AddressAlreadyRegisteredException;

    public SimpleEntry<String, Integer> getClient(Integer id) throws NoPortAvailableException, ClientNotFoundException;

    public void usePort(Integer id, Integer port)
            throws ClientNotFoundException, PortAlreadyInUseException, PortNotOpenException;

    public void releasePort(Integer id, Integer port) throws ClientNotFoundException, PortNotOpenException;

    public Set<Integer> getClientsRegistered();

    public void receiveHearbeat(Integer id) throws ClientNotFoundException;

    public InfoClient getClientByAddr(String addr) throws ClientNotFoundException;
}
