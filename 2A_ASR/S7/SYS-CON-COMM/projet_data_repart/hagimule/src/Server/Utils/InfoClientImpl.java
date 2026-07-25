package Server.Utils;

import java.util.HashSet;
import java.util.Set;

import Server.Exceptions.PortAlreadyInUseException;
import Server.Exceptions.PortNotOpenException;

public class InfoClientImpl implements InfoClient {

    private String addr;
    private Set<Integer> availablePorts;
    private Set<Integer> ports;
    private float usageRate;
    private Integer lastHeartbeatTime;

    public InfoClientImpl(String addr) {
        this.addr = addr;
        this.ports = new HashSet<Integer>();
        this.availablePorts = new HashSet<Integer>();
        this.usageRate = 0;
        this.lastHeartbeatTime = 0;
    }

    public void openPort(Integer port) {
        this.ports.add(port);
        this.availablePorts.add(port);
        this.updateRate();
    }

    public void closePort(Integer port) throws PortNotOpenException {
        if (this.availablePorts.contains(port)) {
            this.availablePorts.remove(port);
        }
        if (this.ports.contains(port)) {
            this.ports.remove(port);
            this.updateRate();
        } else {
            throw new PortNotOpenException("On " + addr + ", close port " + port + " failed (port is not open).");
        }

    }

    public void usePort(Integer port) throws PortAlreadyInUseException, PortNotOpenException {
        if (this.ports.contains(port)) {
            if (this.availablePorts.contains(port)) {
                this.availablePorts.remove(port);
                this.updateRate();
            } else {
                throw new PortAlreadyInUseException("On " + addr + ", port " + port + " already in use.");
            }
        } else {
            throw new PortNotOpenException("On " + addr + ", port " + port + " is not open.");
        }
    }

    public void releasePort(Integer port) throws PortNotOpenException {
        if (this.ports.contains(port)) {
            this.availablePorts.add(port);
            this.updateRate();
        } else {
            throw new PortNotOpenException("On  " + addr + ", port " + port + " can not be released (not opened).");
        }
    }

    public void incrLastHeartbeatTime() {
        this.lastHeartbeatTime++;
    }

    public void resetHeartBeatTime() {
        this.lastHeartbeatTime = 0;
    }

    public String getAddr() {
        return addr;
    }

    public Set<Integer> getAvailablePorts() {
        return availablePorts;
    }

    public Set<Integer> getPorts() {
        return ports;
    }

    public float getUsageRate() {
        return usageRate;
    }

    public Integer getLastHeartbeatTime() {
        return lastHeartbeatTime;
    }

    @Override
    public String toString() {
        return "[" + addr + "]:{" + ports.toString() + "} | Rate: " + usageRate
                + "% | Available ports: {" + availablePorts + "} | "
                + "Last seen: " + lastHeartbeatTime + " sec \n\t";
    }

    private void updateRate() {
        this.usageRate = (((float) this.ports.size() - (float) this.availablePorts.size()) / (float) this.ports.size())
                * (float) 100;
    }
}
