package Client.Exceptions;

public class InvalidRequestException extends Exception {
    public InvalidRequestException(String errMessage) {
        super(errMessage);
    }
}
