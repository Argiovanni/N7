package Client.Utils;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;

public class Logger {

    private PrintWriter writer;

    // Constructor that takes a filename
    public Logger(String filename) throws IOException {
        // Open a FileWriter in append mode
        this.writer = new PrintWriter(new FileWriter(filename, true), true);
    }

    // Utility method to get the current timestamp in a specific format
    private String getCurrentTimestamp() {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        return sdf.format(new Date());
    }

    // Method to log the start of the download
    public long startDownload(String file) {
        String timestamp = getCurrentTimestamp();
        writer.printf("[INFO] - %s : Start download (%s)%n", timestamp, file);
         // Capture the start time (in milliseconds)
        long startTime = System.currentTimeMillis();
        
        // Return the start time so it can be used to calculate the download duration later
        return startTime;
    }

    // Method to log the completion of the download
    public void finishDownload(String file, int nbTotalBytes, long startTime, int nbProviders) {
        String timestamp = getCurrentTimestamp();
        long endTime = System.currentTimeMillis();
        long deltaTime = endTime - startTime;
        writer.printf("[INFO] - %s : Download of (%s) (%d bytes) completed in %d ms with %d providers %n",
                timestamp, file, nbTotalBytes, deltaTime, nbProviders);
    }

    // Method to log a warning when a chunk download fails
    public void warningChunk(String file, int byteStart, int byteEnd, String host, int port) {
        String timestamp = getCurrentTimestamp();
        writer.printf("[WARN] - %s : Download of chunk of (%s) from (%d) to (%d) canceled (connexion to [%s:%d] closed).%n",
                timestamp, file, byteStart, byteEnd, host, port);
    }

    // Method to log the retrying of a chunk download
    public void retryDownloadChunk(String file, int byteStart, int byteEnd, int nbRetries) {
        String timestamp = getCurrentTimestamp();
        writer.printf("[INFO] - %s : Retrying (%d times) to download chunk of (%s) from (%d) to (%d)%n",
                timestamp, nbRetries, file, byteStart, byteEnd);
    }

    // Method to log a cancellation of the download due to no available providers
    public void cancelDownload(String file) {
        String timestamp = getCurrentTimestamp();
        writer.printf("[ERROR] - %s : Download of (%s) canceled, no providers to complete the download%n",
                timestamp, file);
    }
}
