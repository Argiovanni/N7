package Server.Exceptions;

public class PortNotOpenException extends Exception {
    public PortNotOpenException(String errMessage) {
        super(errMessage);
    }
}
