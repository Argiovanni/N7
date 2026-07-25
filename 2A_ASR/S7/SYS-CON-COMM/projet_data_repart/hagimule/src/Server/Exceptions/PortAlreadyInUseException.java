package Server.Exceptions;

public class PortAlreadyInUseException extends Exception{
    public PortAlreadyInUseException(String errMessage) {
        super(errMessage);
    }
}
