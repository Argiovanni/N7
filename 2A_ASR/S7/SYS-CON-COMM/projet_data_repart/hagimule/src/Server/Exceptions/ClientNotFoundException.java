package Server.Exceptions;

public class ClientNotFoundException extends Exception{
    public ClientNotFoundException(String errMessage) {
        super(errMessage);
    }
}
