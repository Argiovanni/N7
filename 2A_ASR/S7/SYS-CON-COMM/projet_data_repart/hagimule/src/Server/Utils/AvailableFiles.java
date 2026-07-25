package Server.Utils;

import java.util.Set;
import java.util.AbstractMap.SimpleEntry;

import Server.Exceptions.FileNotRegisteredException;
import Server.Exceptions.ProviderNotFoundException;

public interface AvailableFiles {
    public void registerProvider(Integer provider, String name, Integer bytesSize, Integer compressed);
    public Set<Integer> getProviders(Integer id) throws FileNotRegisteredException;
    public Integer getIdFile(String name) throws FileNotRegisteredException;
    public void updateProviders(Set<Integer> providers) throws FileNotRegisteredException, ProviderNotFoundException;
    public void updateFilesOfProvider(Integer id, Set<SimpleEntry<String,SimpleEntry<Integer,Integer>>> files);
    public Set<SimpleEntry<String,SimpleEntry<Integer, Integer>>> getAvailableFiles();
}
