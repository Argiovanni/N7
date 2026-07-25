package Server.Utils;

import Server.Exceptions.ProviderNotFoundException;
import java.util.HashSet;
import java.util.Set;

public class InfoFileImpl implements InfoFile {

    private String name;
    private Integer bytesSize;
    private Integer compressedBytesSize;
    private Set<Integer> providers;
    
    public InfoFileImpl(String name, Integer bytesSize, Integer compressedBytesSize) {
        this.name = name;
        this.bytesSize = bytesSize;
        this.compressedBytesSize = compressedBytesSize;
        this.providers = new HashSet<Integer>();
    }
    
    public void addProvider(Integer id) {
        this.providers.add(id);
    }
    
    public void removeProvider(Integer id) throws ProviderNotFoundException {
        if (this.providers.contains(id)) {
            this.providers.remove(id);
        } else {
            throw new ProviderNotFoundException(
                "Can not remove provide n°" + id + ", it not a provider for file " + name);
            }
        }
        
    public Set<Integer> getProviders() {
        return this.providers;
    }
    
    public String getName() {
        return name;
    }
        
    public Integer getCompressedSize() {
        return compressedBytesSize;
    }

    public Integer getBytesSize() {
        return bytesSize;
    }

    @Override
    public String toString() {
        return name + " (" + bytesSize + " bytes) | "
                + "providers: " + providers + "\n\t";
    }

}
