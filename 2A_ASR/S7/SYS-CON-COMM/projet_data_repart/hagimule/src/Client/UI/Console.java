package Client.UI;

import java.util.Scanner;
import java.util.Set;
import java.util.AbstractMap.SimpleEntry;

import Client.Exceptions.InvalidInputException;
import Client.Utils.Action;

public class Console {
    Scanner scanner;
    Action input;

    public Console() {
        this.scanner = new Scanner(System.in);
    }

    public Action askUser(boolean inErr){
        clearConsole();
        if(inErr){
            System.out.println("Error : Select a valid action...");
        }
        displayMenu();
        Integer userChoice = scanner.nextInt();
        scanner.nextLine(); 
        try {
            return selectMenu(userChoice);
        } catch(InvalidInputException e) {
            return askUser(true);
        }
        
    }

    public void download(String n) {
        clearConsole();
        System.out.println("======== WAITING ========");
        System.out.println("Downloading " + n + "...");

    }

    public SimpleEntry<String, SimpleEntry<Integer,Integer>> chooseFile(Set<SimpleEntry<String, SimpleEntry<Integer,Integer>>> files) {
        int pageSize = 5;
        int currentPage = 0;
        int totalPages = (int) Math.ceil(files.size() / (double) pageSize);
    
        while (true) {
            clearConsole();
            System.out.println("========= File Selection =========");
    
            // Show files for the current page
            int start = currentPage * pageSize;
            int end = Math.min(start + pageSize, files.size());
            int index = 0;
            for (SimpleEntry<String, SimpleEntry<Integer,Integer>> file : files) {
                if (index >= start && index < end) {
                    System.out.println((index + 1) + " - " + file.getKey() + " (" + file.getValue().getKey() + " bytes, " + file.getValue().getValue() + " bytes compressed)");
                }
                index++;
            }
    
            System.out.println("\nPage " + (totalPages != 0 ? currentPage + 1 : 0) + " of " + totalPages);
            String option = "b - back ";
            if (totalPages > 1) {
                if (currentPage + 1 > 1) {
                    option += "| p - previous ";
                } else if (currentPage + 1 < totalPages) {
                    option += "| n - next ";
                } else {
                    option += "| n - next | p - previous ";
                }
                option += "| Select a file by number : ";
            } else {
                option += ": ";
            }
            System.out.print(option);
    
            // Get user input for file selection or navigation
            String choice = scanner.next();
    
            if (choice.equalsIgnoreCase("n") && currentPage < totalPages - 1) {
                currentPage++;
            } else if (choice.equalsIgnoreCase("p") && currentPage > 0) {
                currentPage--;
            } else if (choice.equalsIgnoreCase("b")) {
                return null;
            } else {
                try {
                    int selectedIndex = Integer.parseInt(choice) - 1;
                    // Iterate again to get the actual file based on the user's selection
                    index = 1;
                    SimpleEntry<String, SimpleEntry<Integer,Integer>> selectedFile = null;
                    for (SimpleEntry<String, SimpleEntry<Integer,Integer>> file : files) {
                        if (index == selectedIndex + 1) {
                            selectedFile = file;
                            break;
                        }
                        index++;
                    }
    
                    // Return the selected file if found
                    if (selectedFile != null) {
                        return selectedFile;
                    } else {
                        System.out.println("Invalid selection, please try again.");
                    }
                } catch (NumberFormatException e) {
                    System.out.println("Invalid input, please try again.");
                }
            }
        }
    }

    public Integer askNumberOfProviders(Integer maxProviders) {
        while (true) {
            clearConsole();
            System.out.println("========== PROVIDERS ==========");
            System.out.println(maxProviders + " providers founded.");
            System.out.println("");
            System.out.print("Number of providers: ");
            try {
                Integer numberOfProviders = scanner.nextInt();
                scanner.nextLine(); 
                if (numberOfProviders >= 1 && numberOfProviders <= maxProviders) {
                    return numberOfProviders;
                } else {
                    System.out.println("Invalid input. The number must be between 1 and " + maxProviders + ".");
                }
            } catch (Exception e) {
                System.out.println("Invalid input. Please enter a valid number.");
                scanner.nextLine();  // Clear the buffer
            }
        }
    }

    public Integer askMode() {
        while (true) {
            clearConsole();
            System.out.println("============ MODE =============");
            System.out.println("0 - No compression");
            System.out.println("1 - Compressed chunks");
            System.out.println("2 - Compressed full file");
            System.out.println(" ");
            System.out.print("Select mode: ");
            try {
                Integer numberOfProviders = scanner.nextInt();
                scanner.nextLine(); 
                    return numberOfProviders;
            } catch (Exception e) {
                System.out.println("Invalid input. Please enter a valid option (0-2).");
                scanner.nextLine();  // Clear the buffer
            }
        }
    }

    private void displayMenu() {
        System.out.println("========= HAGIMULE =========");
        System.out.println("1 - Download menu");
        System.out.println("2 - Exit");
        System.out.println("");
        System.out.print("Select an action (1-2) : ");
    }

    public void downloadFinish() {
        System.out.println("");
        System.out.println("Download completed successfully.");
        System.out.println("--------------------------------");
        System.out.println("");
        System.out.print("Press enter to return to menu...");
        scanner.nextLine();
    }

    public void canceledDownload() {
        System.out.println("");
        System.out.println("Download canceled.");
        System.out.println("--------------------------------");
        System.out.println("");
        System.out.print("Press enter to return to menu...");
        scanner.nextLine();
    }

    private Action selectMenu(Integer choice) throws InvalidInputException {
        if(choice != null) {
            switch (choice) {
                case 1:
                   return Action.MENU_DOWNLOAD;
                case 2:
                    return Action.EXIT;
                default:
                    throw new InvalidInputException("This action does not exist.");
            }
        }
        throw new InvalidInputException("This action does not exist.");
    }

    private void clearConsole() {
        System.out.print("\033[H\033[2J");
        System.out.flush();
    }
}
