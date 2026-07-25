package Server.Exceptions;

public class AddressAlreadyRegisteredException extends Exception {
    public AddressAlreadyRegisteredException(String errMessage) {
        super(errMessage);
    }
}
