package Client.Exceptions;

public class DownloadChunkFailedException extends Exception {
    private Integer from;
    private Integer to;
    
    public Integer getFrom() {
        return from;
    }

    public Integer getTo() {
        return to;
    }

    public DownloadChunkFailedException(String errMessage, Integer from, Integer to){
        super(errMessage);
        this.from = from;
        this.to = to;
    }
}
