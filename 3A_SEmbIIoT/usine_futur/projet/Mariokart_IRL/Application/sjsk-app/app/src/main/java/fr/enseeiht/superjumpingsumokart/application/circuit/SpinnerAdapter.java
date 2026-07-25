package fr.enseeiht.superjumpingsumokart.application.circuit;

import android.content.Context;
import android.widget.ArrayAdapter;

import java.util.ArrayList;

/**
 * {@link android.widget.Adapter} for {@link GUICreateCircuit#symbolSpinner} and {@link GUIModifyCircuit#symbolSpinner}.
 * @author Vivian Guy.
 */

class SpinnerAdapter extends ArrayAdapter<String> {

    /**
     * Constructor for {@link SpinnerAdapter}.
     * @param theContext The context for the spinner.
     * @param objects The list of objects displayed on the spinner.
     * @param theLayoutResId The layout used to display the objects.
     */
    SpinnerAdapter(Context theContext, ArrayList<String> objects, int theLayoutResId) {
        super(theContext, theLayoutResId, objects);
    }

    @Override
    public int getCount() {
        // don't display last item. It is used as hint.
        int count = super.getCount();
        return count > 0 ? count - 1 : count;
    }
}