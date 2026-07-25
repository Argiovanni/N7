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

import java.io.File;
import java.io.FileOutputStream;
import java.util.ArrayList;

import fr.enseeiht.superjumpingsumokart.R;

/**
 * {@link Activity} to create a new Circuit.
 * @author Vivian Guy.
 */

public class GUICreateCircuit extends Activity {

    /**
     * The logging tag. Useful for debugging.
     */
    private static String GUI_CREATE_CIRCUIT_TAG = "GUICreateCircuit";

    /*
     * Buttons in the GUI.
     */
    private EditText circuitNameText;
    private EditText lapsText;
    private EditText checkPointToCheckText;
    private ListView listMarkers;
    private Spinner symbolSpinner;

    /**
     * {@link fr.enseeiht.superjumpingsumokart.application.items.Item} selected in the ListView listMarkers.
     */
    private Integer itemSelected;

    /**
     * The list of markers of the circuit.
     */
    private static ArrayList<String> markers;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_guicreatecircuit);

        // Get the objects from the layout
        circuitNameText = (EditText) findViewById(R.id.circuitNameText);
        lapsText = (EditText) findViewById(R.id.lapsText);
        checkPointToCheckText = (EditText) findViewById(R.id.nbCheckPointTxt);
        listMarkers = (ListView) findViewById(R.id.listMarkers);
        symbolSpinner = (Spinner) findViewById(R.id.symbolText);
        Button addMarkerBtn = (Button) findViewById(R.id.addMarkerBtn);
        Button confirmBtn = (Button) findViewById(R.id.confirmBtn);
        Button deleteMarkerBtn = (Button) findViewById(R.id.deleteMarkerBtn);

        // Initialize the list of markers for the circuit
        markers = new ArrayList<>();

        // Adapter for the listView
        final ArrayAdapter adapter = new MarkerAdapter(GUICreateCircuit.this, markers);
        LayoutInflater inflater = getLayoutInflater();
        ViewGroup header = (ViewGroup)inflater.inflate(R.layout.header_markers, listMarkers, false);
        listMarkers.addHeaderView(header, null, false);
        listMarkers.setAdapter(adapter);

        // List of symbols for the spinner
        final ArrayList<String> listSymbols = new ArrayList<>();
        listSymbols.add("B");
        listSymbols.add("C");
        listSymbols.add("D");
        listSymbols.add("F");
        listSymbols.add("G");
        listSymbols.add("Select a type of marker"); // hint for the user

        // Adapter for the spinner
        final SpinnerAdapter spinnerAdapter = new SpinnerAdapter(GUICreateCircuit.this, listSymbols, android.R.layout.simple_spinner_item);
        spinnerAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        symbolSpinner.setAdapter(spinnerAdapter);

        // Show the hint
        symbolSpinner.setSelection(spinnerAdapter.getCount());

        // BUTTONS LISTENERS
        /*
         * Button to add a marker to the list of markers.
         */
        addMarkerBtn.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                Log.d(GUI_CREATE_CIRCUIT_TAG, "addMarkerBtn pressed");
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        // Get the texts from the EditTexts objects
                        String symbol = symbolSpinner.getSelectedItem().toString();
                        if (!symbol.equals("Select a type of marker")) { // if a symbol is selected
                            // Add the marker to the end of markers list (before 2 end markers)
                            adapter.add(symbol);
                            // Remove the symbol from the list (symbols can appear only one time in the circuit)
                            spinnerAdapter.remove(symbol);
                            Log.d(GUI_CREATE_CIRCUIT_TAG, "marker " + symbol + " added to the list");

                            // Reset the EditTexts
                            symbolSpinner.setSelection(spinnerAdapter.getCount());
                            Log.d(GUI_CREATE_CIRCUIT_TAG, "Spinner reset");

                            // Inform the user that the marker is added
                            Toast.makeText(GUICreateCircuit.this, "Marker added", Toast.LENGTH_SHORT).show();
                        }
                        else { // no symbol is selected
                            Toast.makeText(GUICreateCircuit.this, "You must select a type of marker first !", Toast.LENGTH_SHORT).show();
                        }
                        break;
                }
                return true;
            }
        });

        /*
         * Button to the confirm the circuit. It instanced to circuit with the markers described in the list.
         */
        confirmBtn.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                Log.d(GUI_CREATE_CIRCUIT_TAG, "confirmBtn pressed");
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        // Create the file for the circuit and instanced it
                        createCircuitFile();
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
                Log.d(GUI_CREATE_CIRCUIT_TAG, "deleteMarker pressed");
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        if (itemSelected != null) { // if an item is selected
                            // Remove the selected marker
                            adapter.remove(markers.get(itemSelected-1));
                            // Add it to the list of symbols available
                            spinnerAdapter.add(markers.get(itemSelected-1));
                            // Reset itemSelected
                            itemSelected = null;
                        }
                        else { // if the user hasn't selected an item
                            Toast.makeText(GUICreateCircuit.this, "You must select a marker first", Toast.LENGTH_SHORT).show();
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
                Log.d(GUI_CREATE_CIRCUIT_TAG, "item " + i + " selected");
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
     * Creates the circuit file and instantiates it.
     */
    protected void createCircuitFile() {
        // Create the directory if it doesn't exist
        File CircuitsDir = new File(GUICreateCircuit.this.getFilesDir() + "/Circuits");
        if (!CircuitsDir.exists()) { // create the folder if it doesn't exist
            boolean isCreated = CircuitsDir.mkdir();
            if (isCreated) {
                Log.d(GUI_CREATE_CIRCUIT_TAG, "file created");
            }
        }

        String path = GUICreateCircuit.this.getFilesDir() + "/Circuits";

        // Get the info about the circuit
        String txtName = circuitNameText.getText().toString();
        String lapTxt = lapsText.getText().toString();
        String checkPointTxt = checkPointToCheckText.getText().toString();

        // Create the file if the EditTexts are correctly filled
        if (!txtName.isEmpty() && !lapTxt.equals("0") && !lapTxt.isEmpty() && !checkPointTxt.equals("0") && !checkPointTxt.isEmpty()) { // if the user has put a circuit name, a number of lap different from 0 and checkpoint different from 0
            // Create the file
            File circuitFile = new File(path, circuitNameText.getText().toString());
            if (!circuitFile.exists()) { // if a file with the same name doesn't exist
                FileOutputStream outputStream;
                String stringToWrite;
                try {
                    // Creating the file  of the circuit
                    outputStream = new FileOutputStream(circuitFile);
                    String firstLine = txtName + "/" + lapTxt + "/" + checkPointTxt + "\n";
                    outputStream.write(firstLine.getBytes());
                    for (String s : markers) {
                        stringToWrite = s + "\n";
                        outputStream.write(stringToWrite.getBytes());
                    }
                    outputStream.close();
                    Log.d(GUI_CREATE_CIRCUIT_TAG, "Circuit file created");

                    // Inform the user that the file has been created
                    Toast.makeText(GUICreateCircuit.this, "Circuit created!", Toast.LENGTH_SHORT).show();

                    // Go back to GUIWelcome Activity
                    //Intent i = new Intent(GUICreateCircuit.this, GUIWelcome.class);
                    Log.d(GUI_CREATE_CIRCUIT_TAG, "Launching a GUIWelcome Activity...");
                    //startActivity(i);
                    finish();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            else { // A circuit with the same name already exists
                Toast.makeText(GUICreateCircuit.this, "A circuit with this name already exists !", Toast.LENGTH_SHORT).show();
            }
        } else { // The user's input aren't correct
            if (lapTxt.equals("0")) {
                Toast.makeText(GUICreateCircuit.this, "Lap number must be different to 0 !", Toast.LENGTH_SHORT).show();
            } else {
                Toast.makeText(GUICreateCircuit.this, "You have to put a circuit name and a lap number !", Toast.LENGTH_SHORT).show();
            }
        }

    }
}
