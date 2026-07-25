package Server.Utils;

import java.util.Set;

import Server.Exceptions.ProviderNotFoundException;

/**
 * TODO: commentez
 */
public interface InfoFile {

    public String getName();
    public Integer getBytesSize();
    public void addProvider(Integer id);
    public void removeProvider(Integer id) throws ProviderNotFoundException;
    public Set<Integer> getProviders();
    public Integer getCompressedSize();
}
