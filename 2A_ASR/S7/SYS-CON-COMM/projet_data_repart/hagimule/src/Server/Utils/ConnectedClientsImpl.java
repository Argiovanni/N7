package Server.Utils;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.AbstractMap.SimpleEntry;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import Server.Exceptions.AddressAlreadyRegisteredException;
import Server.Exceptions.ClientNotFoundException;
import Server.Exceptions.NoPortAvailableException;
import Server.Exceptions.PortAlreadyInUseException;
import Server.Exceptions.PortNotOpenException;

public class ConnectedClientsImpl implements ConnectedClients {

    private Map<Integer, InfoClient> registeredClients;

    public ConnectedClientsImpl() {
        this.registeredClients = new HashMap<>();

        ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);

        // Launch the heartbeat monitor
        scheduler.scheduleAtFixedRate(new Runnable() {
            @Override
            public void run() {
                heartbeatMonitor();
            }
        }, 0, 1, TimeUnit.SECONDS);
    }

    public Integer registerClient(String addr, Set<Integer> ports) throws AddressAlreadyRegisteredException {
        if (!isRegistered(addr)) {
            InfoClient info = new InfoClientImpl(addr);
            ports.forEach(port -> info.openPort(port));
            Integer id = this.getUniqueId();
            this.registeredClients.put(id, info);
            return id;
        } else {
            throw new AddressAlreadyRegisteredException(
                    "Can not register " + addr + ", address is already registered.");
        }
    }

    public SimpleEntry<String, Integer> getClient(Integer id) throws NoPortAvailableException, ClientNotFoundException {
        InfoClient client = this.registeredClients.get(id);
        if (client != null) {
            String addr = client.getAddr();
            Integer port = client.getAvailablePorts().stream().findFirst().orElse(null);
            if (port != null) {
                return new SimpleEntry<>(addr, port);
            } else {
                throw new NoPortAvailableException("Can not use [" + addr + "], no port available.");
            }
        } else {
            throw new ClientNotFoundException("Can not use client n°" + id + ", client not registered.");
        }
    }

    public void usePort(Integer id, Integer port)
            throws ClientNotFoundException, PortAlreadyInUseException, PortNotOpenException {
        InfoClient client = this.registeredClients.get(id);
        if (client != null) {
            client.usePort(port);
        } else {
            throw new ClientNotFoundException("Can not close port on client n°" + id + ", client not registered.");
        }
    }

    public void releasePort(Integer id, Integer port) throws PortNotOpenException, ClientNotFoundException {
        InfoClient client = this.registeredClients.get(id);
        if (client != null) {
            client.releasePort(port);
        } else {
            throw new ClientNotFoundException("Can not release port on client n°" + id + ", client not registered.");
        }
    }

    public Set<Integer> getClientsRegistered() {
        return this.registeredClients.keySet();
    }

    public void receiveHearbeat(Integer id) throws ClientNotFoundException {
        InfoClient client = this.registeredClients.get(id);
        if (client != null) {
            client.resetHeartBeatTime();
        } else {
            throw new ClientNotFoundException(
                    "Can not receive heartbeat from client n°" + id + ", client not registered.");
        }
    }

    public InfoClient getClientByAddr(String addr) throws ClientNotFoundException {
        for (InfoClient c : this.registeredClients.values()) {
            if (c.getAddr().equals(addr)) {
                return c;
            }
        }
        throw new ClientNotFoundException(
                "Can not client at " + addr + ", client not registered.");
    }

    private boolean isRegistered(String addr) {
        for (InfoClient c : this.registeredClients.values()) {
            if (c.getAddr().equals(addr)) {
                return true;
            }
        }
        return false;
    }

    private Integer getUniqueId() {
        return this.registeredClients.size();
    }

    private void heartbeatMonitor() {
        Iterator<Map.Entry<Integer, InfoClient>> iterator = this.registeredClients.entrySet().iterator();
        while (iterator.hasNext()) {
            InfoClient client = iterator.next().getValue();
            client.incrLastHeartbeatTime();
            if (client.getLastHeartbeatTime() > 2) {
                iterator.remove();
            }
        }
    }

    @Override
    public String toString() {
        return registeredClients.toString();
    }
}
