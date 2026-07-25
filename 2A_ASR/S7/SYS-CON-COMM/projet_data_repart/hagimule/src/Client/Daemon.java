package Client;

import java.net.Socket;
import java.util.AbstractMap.SimpleEntry;
import java.util.Set;

public interface Daemon {

    void init();

    void register();

    void watchDirectory();

    void startFileServer();

    void handleFileRequest(Socket socket);

    public Set<SimpleEntry<String,SimpleEntry<Integer, Integer>>> getLocalFiles();

    void heartBeat();
}