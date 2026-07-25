package fr.enseeiht.superjumpingsumokart.application.circuit;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.Toast;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;

import fr.enseeiht.superjumpingsumokart.R;
import fr.enseeiht.superjumpingsumokart.application.GUIWelcome;
import fr.enseeiht.superjumpingsumokart.arpack.DetectionTask;

/**
 * The activity used for handling circuits. From this activity, the user can chose/modify/delete
 * a existing circuit or create a new one.
 * @author Vivian Guy.
 */

public class GUICircuit extends Activity {

    /**
     * The logging tag. Useful for debugging.
     */
    private static String GUI_CIRCUIT_TAG = "GUICircuit";

    /**
     * The {@link View} holding  the existing {@link Circuit} stored on the phone.
     */
    private ListView existingCircuitsListView;

    /**
     * List of existing circuit in the folder Circuits of the internal storage saved as a {@link String} array [name, lap].
     */
    private ArrayList<String[]> existingCircuits;

    /**
     * The {@link CircuitAdapter} for the {@link GUICircuit#existingCircuitsListView}.
     */
    private ArrayAdapter adapter;

    /**
     * The item on the existingCircuitsListView selected by the user and the one previously selected.
     */
    private int selectedItem = -1;
    private int oldSelectedItem = -1;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_guicircuit);

        // Buttons in the GUI.
        Button createNewCircuitBtn = (Button) findViewById(R.id.createCircuitButton);
        Button choseSelectedBtn = (Button) findViewById(R.id.choseSelectedButton);
        this.existingCircuitsListView = (ListView) findViewById(R.id.existingCircuitsList);
        Button modifyCircuitBtn = (Button) findViewById(R.id.modifyCircuitBtn);
        Button deleteCircuitBtn = (Button) findViewById(R.id.deleteCircuitBtn);

        // Initialisation of the existingCircuits list
        existingCircuits = new ArrayList<>();

        // Adapter for the listView
        adapter = new CircuitAdapter(GUICircuit.this, existingCircuits);
        LayoutInflater inflater = getLayoutInflater();
        ViewGroup header = (ViewGroup) inflater.inflate(R.layout.header_circuit, existingCircuitsListView, false);
        existingCircuitsListView.addHeaderView(header, null, false);
        existingCircuitsListView.setAdapter(adapter);


        //  BUTTONS LISTENERS

        /**
         * Button to launch the activity allowing the user to create a new circuit.
         */
        createNewCircuitBtn.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        Log.d(GUI_CIRCUIT_TAG, "Create new circuit pressed");
                        Intent i = new Intent(GUICircuit.this, GUICreateCircuit.class);
                        Log.d(GUI_CIRCUIT_TAG, "Launching a GUICreateCircuit Activity...");
                        startActivity(i);
                        break;
                }
                return true;
            }
        });

         /*
         *  Button to select and instanced the selected circuit.
         */
        choseSelectedBtn.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                Log.d(GUI_CIRCUIT_TAG, "Chose selected circuit pressed");
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        if (CircuitAdapter.selectedPos >= 0) { // If a item was previously selected (colored in red), we set its color to none
                            existingCircuitsListView.getChildAt(CircuitAdapter.selectedPos).setBackgroundColor(Color.TRANSPARENT);
                        }
                        if (selectedItem >= 0) { // if an item has been selected
                            // Set the color of the instanced circuit to blue
                            existingCircuitsListView.getChildAt(selectedItem).setBackgroundColor(Color.BLUE);
                            CircuitAdapter.selectedPos = selectedItem;

                            // Get the selected circuit
                            String[] circuitSelected = (String[]) existingCircuitsListView.getItemAtPosition(selectedItem);
                            String circuitName = circuitSelected[0];
                            Log.d(GUI_CIRCUIT_TAG, "Name circuit selected: " + circuitName);


                            // Get the corresponding file
                            String filePath = GUICircuit.this.getFilesDir() + "/Circuits/" + circuitName;
                            File circuitFile = new File(filePath);
                            try {
                                // Read the file to add corresponding markers to the instanced circuit
                                FileInputStream fis = new FileInputStream(circuitFile);
                                InputStreamReader isr = new InputStreamReader(fis);
                                BufferedReader bufferedReader = new BufferedReader(isr);
                                String line;
                                line = bufferedReader.readLine(); // Get the number of checkpoint to complete a lap and the number of lap
                                String[] lineSplit = line.split("/");
                                int laps = Integer.parseInt(circuitSelected[1]);
                                int nbChecKPoint = Integer.parseInt(lineSplit[2]);
                                Circuit.initInstance(laps, nbChecKPoint);
                                Circuit.getInstance().setName(circuitName);
                                while ((line = bufferedReader.readLine()) != null) {
                                    Circuit.getInstance().addMarker(DetectionTask.Symbol.valueOf(line));
                                    Log.d(GUI_CIRCUIT_TAG, "Marker " + line + " added");
                                }
                            } catch (IOException ex) {
                                ex.printStackTrace();
                            }

                            // Inform the user that the circuit is selected and instanced
                            Toast.makeText(GUICircuit.this, "Circuit selected", Toast.LENGTH_SHORT).show();

                            // Go Back to GUIWelcome activity
                            Intent i = new Intent(GUICircuit.this, GUIWelcome.class);
                            i.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                            Log.d(GUI_CIRCUIT_TAG, "Launching a GUIWelcome Activity...");
                            startActivity(i);
                            finish();



                        } else { // if no item has been selected before
                            Toast.makeText(GUICircuit.this, "You must select a circuit first !", Toast.LENGTH_SHORT).show();
                        }
                        break;
                }
                return true;
            }
        });

        /*
         * Listener to select an item on the existingCircuitsListView.
         */
        existingCircuitsListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
                // Set the selectedItem to the item clicked by the user
                selectedItem = i;
                if (oldSelectedItem != CircuitAdapter.selectedPos && oldSelectedItem >= 0) { // if there was a previously selected item and it wasn't the instanced circuit (color blue)
                    // Set the color of the oldSelectedItem to none
                    existingCircuitsListView.getChildAt(oldSelectedItem).setBackgroundColor(Color.TRANSPARENT);
                }
                // Color the selected item in red
                view.setBackgroundColor(Color.RED);

                // Set the oldSelectedItem as the the selectedItem
                oldSelectedItem = selectedItem;

                // Color the instanced circuit in blue (if it exists)
                if (CircuitAdapter.selectedPos >= 0) {
                    existingCircuitsListView.getChildAt(CircuitAdapter.selectedPos).setBackgroundColor(Color.BLUE);
                }
            }
        });

        /*
         * Button to delete the selected circuit.
         */
        deleteCircuitBtn.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                Log.d(GUI_CIRCUIT_TAG, "deleteCircuit pressed");
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        if(selectedItem >=0) { // if an item is selected
                            // Get the circuit
                            String[] circuitSelected = (String[]) existingCircuitsListView.getItemAtPosition(selectedItem);
                            String circuitName = circuitSelected[0];

                            // Get the corresponding file
                            String filePath = GUICircuit.this.getFilesDir() + "/Circuits/" + circuitName;
                            File circuitFile = new File(filePath);

                            // Delete the file
                            boolean isDeleted = circuitFile.delete();
                            if (isDeleted) {
                                adapter.remove(circuitSelected);
                                adapter.notifyDataSetChanged();
                                Log.d(GUI_CIRCUIT_TAG, "Circuit " + circuitName + " deleted");
                            }
                        }
                        else { // no item is selected
                            Toast.makeText(GUICircuit.this, "You must select a circuit first !", Toast.LENGTH_SHORT).show();
                        }
                        break;
                }
                return true;
            }
        });

        /*
         * Button to modify the selected circuit. Launch a GUIModifyCircuit Activity.
         */
        modifyCircuitBtn.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                Log.d(GUI_CIRCUIT_TAG, "modifyCircuit pressed");
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        if (selectedItem >=0) { // if an item is selected
                            // Start a GUIModifyCircuit Activity with the name of the selected circuit
                            Intent i = new Intent(GUICircuit.this, GUIModifyCircuit.class);
                            String[] circuitSelected = (String[]) existingCircuitsListView.getItemAtPosition(selectedItem);
                            String circuitName = circuitSelected[0];
                            i.putExtra("circuitName", circuitName);
                            Log.d(GUI_CIRCUIT_TAG, "Launching a GUIModifyCircuit Activity...");
                            startActivity(i);
                        }
                        else { // no item is selected
                            Toast.makeText(GUICircuit.this, "You must select a circuit first !", Toast.LENGTH_SHORT).show();
                        }
                        break;
                }
                return true;
            }
        });

    }

    /**
     * Set the existingCircuit list with the files in the Circuits folder.
     */
    private void setExistingCircuitsList() {

        // Create the directory if it doesn't exist
        File CircuitsDir = new File(GUICircuit.this.getFilesDir() + "/Circuits");
        if (!CircuitsDir.exists()) { // create the folder if it doesn't exist
            boolean isCreated = CircuitsDir.mkdir();
            if (isCreated) {
                Log.d(GUI_CIRCUIT_TAG, "file created");
            }
        }

        // Get the files of the folder Circuits in the internal storage
        String path = GUICircuit.this.getFilesDir() + "/Circuits";
        File directory = new File(path);
        File[] files = directory.listFiles();
        Log.d(GUI_CIRCUIT_TAG, "Number of files found: " + files.length);

        // Add each file to the list of circuits
        for (File file : files) {
            try {
                // Read the file
                FileInputStream fis = new FileInputStream(file);
                InputStreamReader isr = new InputStreamReader(fis);
                BufferedReader bufferedReader = new BufferedReader(isr);
                String line;
                line = bufferedReader.readLine();
                String[] lineSplit = line.split("/");

                // Check if the file is not in the list
                boolean found = false;
                int k = 0;
                while (!found && k < existingCircuits.size()) {
                    if (file.getName().equals(existingCircuits.get(k)[0])) {
                        found = true;
                    }
                    k++;
                }
                if (!found) { // if the file is not on the list, add it to the list
                    adapter.add(new String[]{lineSplit[0], lineSplit[1]});
                    Log.d(GUI_CIRCUIT_TAG, "Circuit " + file.getName() + " added to the list");
                }
                fis.close();
            } catch (IOException e) {
                e.printStackTrace();
            }

        }
    }


    @Override
    protected void onResume(){
        super.onResume();
        // Reset the list of existing circuits list
        existingCircuitsListView.setAdapter(adapter);
        setExistingCircuitsList();
    }
}
