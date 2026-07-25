package Server.Utils;

import java.util.Set;

import Server.Exceptions.PortAlreadyInUseException;
import Server.Exceptions.PortNotOpenException;

/**
 * TODO: commentez
 */
public interface InfoClient {

    public void openPort(Integer port);

    public void closePort(Integer port) throws PortNotOpenException;

    public void usePort(Integer port) throws PortAlreadyInUseException, PortNotOpenException;

    public void releasePort(Integer port) throws PortNotOpenException;

    public void incrLastHeartbeatTime();

    public void resetHeartBeatTime();

    public String getAddr();

    public Set<Integer> getAvailablePorts();

    public Set<Integer> getPorts();

    public float getUsageRate();

    public Integer getLastHeartbeatTime();
}