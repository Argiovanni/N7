package fr.enseeiht.superjumpingsumokart.application.circuit;

import android.content.Context;


import android.view.LayoutInflater;

import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import androidx.annotation.NonNull;

import java.util.ArrayList;

import fr.enseeiht.superjumpingsumokart.R;

/**
 * {@link android.widget.Adapter} for {@link GUICreateCircuit#listMarkers} and {@link GUIModifyCircuit#listMarkers}.
 * @author Vivian Guy.
 */

class MarkerAdapter extends ArrayAdapter<String> {

    /**
     * Constructor for {@link MarkerAdapter}.
     * @param context The context for the adapter.
     * @param markers The list of markers to display.
     */
    MarkerAdapter(Context context, ArrayList<String> markers) {
        super(context, 0, markers);
    }

    @NonNull
    @Override
    public View getView(int position, View convertView, @NonNull ViewGroup parent) {

        // Set the layout for the View
        if(convertView == null){
            convertView = LayoutInflater.from(getContext()).inflate(R.layout.row_marker,parent, false);
        }

        // Set the viewHolder
        MarkerViewHolder viewHolder= (MarkerViewHolder) convertView.getTag();
        if(viewHolder == null){
            viewHolder = new MarkerViewHolder();
            viewHolder.id = (TextView) convertView.findViewById(R.id.id);
            convertView.setTag(viewHolder);
        }

        // Set viewHolder display
        viewHolder.id.setHeight(50);
        viewHolder.id.setMinHeight(50);

        // Get the item [position] of the listView
        String st = getItem(position);

        // Fill the View
        viewHolder.id.setText(st);

        return convertView;
    }

    /**
     * @author Vivian Guy.
     * ViewHolder for {@link MarkerAdapter}.
     */
    private class MarkerViewHolder{
        public TextView id;
    }
}
