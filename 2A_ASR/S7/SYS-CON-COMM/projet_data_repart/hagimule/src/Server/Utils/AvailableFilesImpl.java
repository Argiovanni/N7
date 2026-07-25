package Server.Utils;

import java.util.AbstractMap.SimpleEntry;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import Server.Exceptions.FileNotRegisteredException;
import Server.Exceptions.ProviderNotFoundException;

public class AvailableFilesImpl implements AvailableFiles{
    
    private Map<Integer, InfoFile> registeredFiles;

    public AvailableFilesImpl() {
        this.registeredFiles = new HashMap<Integer, InfoFile>();
    }

    public void registerProvider(Integer provider, String name, Integer bytesSize, Integer compressed) {
        try {
            Integer id = this.getIdFile(name);
            this.registeredFiles.get(id).addProvider(provider);
        } catch (FileNotRegisteredException e) {
            InfoFile f = new InfoFileImpl(name, bytesSize, compressed);
            f.addProvider(provider);
            Integer id = getUniqueId();
            this.registeredFiles.put(id, f);
        }
    }

    public Set<Integer> getProviders(Integer id) throws FileNotRegisteredException{
        InfoFile f =this.registeredFiles.get(id);
        if (f != null) {
            return f.getProviders();
        } else {
            throw new FileNotRegisteredException("File n°" + id + "not found.");
        }
    }

    public void updateProviders(Set<Integer> providers) throws FileNotRegisteredException, ProviderNotFoundException {
        Iterator<Map.Entry<Integer, InfoFile>> iterator = this.registeredFiles.entrySet().iterator();
        while (iterator.hasNext()) {
            Map.Entry<Integer, InfoFile> entry = iterator.next();
            InfoFile f = entry.getValue();
            Set<Integer> currentProviders = f.getProviders();
            Set<Integer> missingProviders = currentProviders.stream()
                                            .filter(provider -> !providers.contains(provider))
                                            .collect(Collectors.toSet());
            for (Integer p : missingProviders) {
                try {
                    f.removeProvider(p);
                } catch (ProviderNotFoundException e) {
                    System.err.println(e);
                }
            }
            if (f.getProviders().isEmpty()) {
                iterator.remove();
            }
        }       
    }

    public void updateFilesOfProvider(Integer id, Set<SimpleEntry<String,SimpleEntry<Integer, Integer>>> files) {
        Set<String> filesNames = files.stream()
        .map(SimpleEntry::getKey)
        .collect(Collectors.toSet());

        this.registeredFiles.values().stream()
        .filter(f -> f.getProviders().contains(id) && !filesNames.contains(f.getName()) )
        .forEach(f -> {
            try {
                f.removeProvider(id);
            } catch (ProviderNotFoundException e) {
                System.err.println(e);
            }
        } );

        files.stream()
        .map(SimpleEntry::getKey)
        .filter(n -> {
            try {
                getIdFile(n);
                return false;
            } catch (FileNotRegisteredException e) {
                return true;
            }
        })
        .forEach(n -> {
                files.stream()
                .filter(entry -> entry.getKey().equals(n)) 
                .map(SimpleEntry::getValue)
                .findFirst().ifPresent(s -> registerProvider(id, n, s.getKey(), s.getValue()));
        });
    }


    public Integer getIdFile(String name) throws FileNotRegisteredException{
        for (Map.Entry<Integer,InfoFile> f : this.registeredFiles.entrySet()) {
            if (f.getValue().getName().equals(name)){
                return f.getKey();
            }
        }
        throw new FileNotRegisteredException("File " + name + " not registered");
    }

    public Set<SimpleEntry<String,SimpleEntry<Integer, Integer>>> getAvailableFiles() {
        Set<SimpleEntry<String,SimpleEntry<Integer, Integer>>> files = new HashSet<>();
        for (InfoFile f : this.registeredFiles.values()){
            SimpleEntry<Integer,Integer> entry = new SimpleEntry<Integer,Integer>(f.getBytesSize(), f.getCompressedSize());
            files.add(new SimpleEntry<String,SimpleEntry<Integer,Integer> >(f.getName(), entry));
        }
        return files;
    }

    private Integer getUniqueId() {
        return this.registeredFiles.size();
    }

    @Override
    public String toString() {
        return registeredFiles.toString();
    }
}
