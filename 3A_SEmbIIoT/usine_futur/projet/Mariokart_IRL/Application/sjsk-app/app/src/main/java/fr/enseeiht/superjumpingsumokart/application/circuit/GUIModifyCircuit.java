package fr.enseeiht.superjumpingsumokart.application.circuit;

import android.app.Activity;
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
import android.widget.EditText;
import android.widget.ListView;
import android.widget.Spinner;
import android.widget.Toast;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;

import fr.enseeiht.superjumpingsumokart.R;

/**
 * Activity to modify a circuit.
 * @author Vivian Guy.
 */

public class GUIModifyCircuit extends Activity {

    /**
     * The logging tag. Useful for debugging.
     */
    private static String GUI_MODIFY_CIRCUIT_TAG = "GUIModifyCircuit";

    /**
     * Item selected in the ListView listMarkers.
     */
    private Integer itemSelected;

    /**
     * The list of markers for the circuit.
     */
    private static ArrayList<String> markers;

    /**
     * The adapter for the listView listMarkers.
     */
    private ArrayAdapter adapter;

    /**
     * The adapter for the {@link GUIModifyCircuit#symbolSpinner}.
     */
    private SpinnerAdapter spinnerAdapter;

    /*
     * Buttons of the GUI
     */
    private EditText circuitNameText;
    private EditText lapsText;
    private EditText checkPointToCheckTxt;
    private ListView listMarkers;
    private Spinner symbolSpinner;


    @Override
    protected void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_guimodify_circuit);

        // Get the objects of the layout
        circuitNameText = (EditText) findViewById(R.id.circuitNameText);
        lapsText = (EditText) findViewById(R.id.lapsText);
        checkPointToCheckTxt = (EditText) findViewById(R.id.nbCheckPointTxt);
        listMarkers = (ListView) findViewById(R.id.listMarkers);
        symbolSpinner = (Spinner) findViewById(R.id.symbolText);
        Button addMarkerBtn = (Button) findViewById(R.id.addMarkerBtn);
        Button confirmBtn = (Button) findViewById(R.id.confirmBtn);
        Button deleteMarkerBtn = (Button) findViewById(R.id.deleteMarkerBtn);

        // List of markers for the circuit
        markers = new ArrayList<>();

        // Adapter for the listView
        adapter = new MarkerAdapter(GUIModifyCircuit.this, markers);
        LayoutInflater inflater = getLayoutInflater();
        ViewGroup header = (ViewGroup)inflater.inflate(R.layout.header_markers, listMarkers, false);
        listMarkers.addHeaderView(header, null, false);
        listMarkers.setAdapter(adapter);

        // List of symbols for the spinner
        ArrayList<String> listSymbols = new ArrayList<>();
        listSymbols.add("B");
        listSymbols.add("C");
        listSymbols.add("D");
        listSymbols.add("F");
        listSymbols.add("G");
        listSymbols.add("Select a type of marker"); // hint for the user

        // Adapter for the spinner
        spinnerAdapter = new SpinnerAdapter(GUIModifyCircuit.this, listSymbols, android.R.layout.simple_spinner_item);
        spinnerAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        symbolSpinner.setAdapter(spinnerAdapter);

        // Show hint
        symbolSpinner.setSelection(spinnerAdapter.getCount());

        // Set the circuit's markers
        final String circuitName = (String) getIntent().getExtras().get("circuitName");
        setMarkersList(circuitName);

        // BUTTONS LISTENERS
        /*
         * Button to add a marker to the list of markers.
         */
        addMarkerBtn.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                Log.d(GUI_MODIFY_CIRCUIT_TAG, "addMarkerBtn pressed");
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        // Get the texts from the Spinner
                        String symbol = symbolSpinner.getSelectedItem().toString();
                        if (!symbol.equals("Select a type of marker")) { // if a symbol is selected
                            // Add the marker to markers list
                            adapter.add(symbol);
                            // Remove the symbol from the list (symbols can appear only one time in the circuit)
                            spinnerAdapter.remove(symbol);
                            Log.d(GUI_MODIFY_CIRCUIT_TAG, "marker added to the list");
                            // Reset the Spinner
                            symbolSpinner.setSelection(spinnerAdapter.getCount());
                            Log.d(GUI_MODIFY_CIRCUIT_TAG, "Spinner reset");
                            // Inform the user that the marker is added
                            Toast.makeText(GUIModifyCircuit.this, "Marker added", Toast.LENGTH_SHORT).show();
                        }
                        else { // no symbol is selected
                            Toast.makeText(GUIModifyCircuit.this, "You must select a type of marker first !", Toast.LENGTH_SHORT).show();
                        }
                        break;
                }
                return true;
            }
        });

        /*
         * Button to the confirm and modify the circuit. It instanced to circuit with the markers described in the list.
         */
        confirmBtn.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                Log.d(GUI_MODIFY_CIRCUIT_TAG, "confirmBtn pressed");
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        // Modify the file corresponding to the circuit circuitName
                        modifyCircuitFile(circuitName);
                        break;
                }
                return true;
            }
        });

        /*
         * Button to delete the selected marker.
         */
        deleteMarkerBtn.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                Log.d(GUI_MODIFY_CIRCUIT_TAG, "deleteMarker pressed");
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        if (itemSelected != null) { // if an item is selected
                            // Remove the selected item
                            adapter.remove(markers.get(itemSelected-1));
                            // Add it to the list of symbols
                            spinnerAdapter.add(markers.get(itemSelected-1));
                            // Reset the item selected
                            listMarkers.getChildAt(itemSelected).setBackgroundColor(Color.TRANSPARENT);
                            itemSelected = null;

                        }
                        else { // if no item is selected
                            Toast.makeText(GUIModifyCircuit.this, "You must select a marker first", Toast.LENGTH_SHORT).show();
                        }
                        break;
                }
                return true;
            }
        });

        /*
         * Listener to select an item of the listView listMarkers.
         */
        listMarkers.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
                Log.d(GUI_MODIFY_CIRCUIT_TAG, "item " + i + " selected");
                if (itemSelected != null) { // if an item was previously selected
                    if (itemSelected == i) { // if the the previous selected item is the same as the selected
                        // Deselect the item by setting its color to none
                        listMarkers.getChildAt(i).setBackgroundColor(Color.TRANSPARENT);
                        // Reset itemSelected
                        itemSelected = null;
                    }
                    else { // if the previous selected item isn't the same as the selected
                        // Set the previous selected item's color to none
                        listMarkers.getChildAt(itemSelected).setBackgroundColor(Color.TRANSPARENT);
                        // Select the item selected and color it in red
                        itemSelected = i;
                        listMarkers.getChildAt(i).setBackgroundColor(Color.RED);
                    }
                }
                else { // if no item was previously selected
                    // Select the item and set its color to red
                    itemSelected = i;
                    listMarkers.getChildAt(i).setBackgroundColor(Color.RED);
                }
            }
        });
    }

    /**
     * Modify a file when an existing {@link Circuit} is edited.
     * It deletes the old file and create a brand new one with updated markers, laps and/or checkpoints.
     * @param circuitName The name of the circuit to modify.
     */
    protected void modifyCircuitFile(String circuitName) {
        // Get the file
        String filePath = GUIModifyCircuit.this.getFilesDir() + "/Circuits/" + circuitName;
        File oldCircuitFile = new File(filePath);

        // Delete the file
        boolean delete = oldCircuitFile.delete();
        if (delete) {
            Log.d(GUI_MODIFY_CIRCUIT_TAG, oldCircuitFile.getName() + " deleted sucessfully.");
        } else {
            Log.e(GUI_MODIFY_CIRCUIT_TAG, oldCircuitFile.getName() + " couldn't be deleted.");
        }

        // Create a file with the new markers, name and laps number
        String path = GUIModifyCircuit.this.getFilesDir() + "/Circuits";
        String txtName = circuitNameText.getText().toString();
        String lapTxt = lapsText.getText().toString();
        String checkPointTxt = checkPointToCheckTxt.getText().toString();
        if (!txtName.isEmpty() && !lapTxt.equals("0") && !lapTxt.isEmpty() && !checkPointTxt.equals("0") && !checkPointTxt.isEmpty()) { // if the user has put a circuit name, a number of lap different from 0 and checkpoint different from 0
            File circuitFile = new File(path, circuitNameText.getText().toString());
            if (!circuitFile.exists()) { // if a file with the same name doesn't exist
                FileOutputStream outputStream;
                String stringToWrite;
                try {
                    // Create the file of the circuit
                    outputStream = new FileOutputStream(circuitFile);
                    String firstLine = txtName + "/" + lapTxt + "/" + checkPointTxt + "\n";
                    outputStream.write(firstLine.getBytes());
                    for (String s : markers) {
                        stringToWrite = s + "\n";
                        outputStream.write(stringToWrite.getBytes());
                    }
                    outputStream.close();
                    Log.d(GUI_MODIFY_CIRCUIT_TAG, "Circuit file created.");

                    // Inform the user that the circuit file has been created (and so modified)
                    Toast.makeText(GUIModifyCircuit.this, "Circuit modified!", Toast.LENGTH_SHORT).show();

                    // Go back to GUIWelcome Activity
                    //Intent i = new Intent(GUIModifyCircuit.this, GUIWelcome.class);
                    Log.d(GUI_MODIFY_CIRCUIT_TAG, "Launching a GUIWelcome Activity...");
                    //startActivity(i);
                    finish();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            else { // A circuit with the same name already exists
                Toast.makeText(GUIModifyCircuit.this, "A circuit with this name already exists !", Toast.LENGTH_SHORT).show();
            }
        } else {// The user's input aren't correct
            if (lapTxt.equals("0")) {
                Toast.makeText(GUIModifyCircuit.this, "Lap number must be different to 0 !", Toast.LENGTH_SHORT).show();
            }
            else {
                Toast.makeText(GUIModifyCircuit.this, "You have to put a circuit name and a lap number !", Toast.LENGTH_SHORT).show();
            }
        }
    }

    /**
     * Set the list of markers for the circuit with name circuitName.
     * @param circuitName the game of the circuit.
     */
    private void setMarkersList(String circuitName) {
        Log.d(GUI_MODIFY_CIRCUIT_TAG, "setting markers list");

        // Get the file
        String filePath = GUIModifyCircuit.this.getFilesDir() + "/Circuits/" + circuitName;
        File circuitFile = new File(filePath);

        // Read the file
        try {
            FileInputStream fis = new FileInputStream(circuitFile);
            InputStreamReader isr = new InputStreamReader(fis);
            BufferedReader bufferedReader = new BufferedReader(isr);
            String line;
            String[] lineSplit;

            // First line
            line = bufferedReader.readLine();
            lineSplit = line.split("/");
            circuitNameText.setText(lineSplit[0]);
            lapsText.setText(lineSplit[1]);
            checkPointToCheckTxt.setText(lineSplit[2]);


            // Other line (markers)
            while ((line = bufferedReader.readLine()) != null) {
                // Add the marker to markers list
                adapter.add(line);
                // Remove the marker from the list of symbols (symbols are uniques)
                spinnerAdapter.remove(line);
                Log.d(GUI_MODIFY_CIRCUIT_TAG, line + " deleted from spinner");
                Log.d(GUI_MODIFY_CIRCUIT_TAG, "Marker " + line + " added");
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

    }

}
