package Server.Exceptions;

public class NoPortAvailableException extends Exception {
    public NoPortAvailableException(String errMessage) {
        super(errMessage);
    }
}
