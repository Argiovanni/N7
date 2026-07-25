/*
 * Copyright (C) 2011-2014 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * This file is auto-generated. DO NOT MODIFY!
 * The source Renderscript file: /Users/kjaffres/Documents/MarioKart/mariokart-24/sjsk-app/app/src/main/rs/rbgaToNv21.rs
 */

package fr.enseeiht.superjumpingsumokart.arpack;

import android.support.v8.renderscript.*;
import android.content.res.Resources;

/**
 * @hide
 */
public class ScriptC_rbgaToNv21 extends ScriptC {
    private static final String __rs_resource_name = "rbgatonv21";
    // Constructor
    public  ScriptC_rbgaToNv21(RenderScript rs) {
        this(rs,
             rs.getApplicationContext().getResources(),
             rs.getApplicationContext().getResources().getIdentifier(
                 __rs_resource_name, "raw",
                 rs.getApplicationContext().getPackageName()));
    }

    public  ScriptC_rbgaToNv21(RenderScript rs, Resources resources, int id) {
        super(rs, resources, id);
        __ALLOCATION = Element.ALLOCATION(rs);
        __I32 = Element.I32(rs);
    }

    private Element __ALLOCATION;
    private Element __I32;
    private FieldPacker __rs_fp_ALLOCATION;
    private FieldPacker __rs_fp_I32;
    private final static int mExportVarIdx_nv21ByteArray = 0;
    private Allocation mExportVar_nv21ByteArray;
    public synchronized void set_nv21ByteArray(Allocation v) {
        setVar(mExportVarIdx_nv21ByteArray, v);
        mExportVar_nv21ByteArray = v;
    }

    public Allocation get_nv21ByteArray() {
        return mExportVar_nv21ByteArray;
    }

    public Script.FieldID getFieldID_nv21ByteArray() {
        return createFieldID(mExportVarIdx_nv21ByteArray, null);
    }

    private final static int mExportVarIdx_r = 1;
    private int mExportVar_r;
    public synchronized void set_r(int v) {
        setVar(mExportVarIdx_r, v);
        mExportVar_r = v;
    }

    public int get_r() {
        return mExportVar_r;
    }

    public Script.FieldID getFieldID_r() {
        return createFieldID(mExportVarIdx_r, null);
    }

    private final static int mExportVarIdx_g = 2;
    private int mExportVar_g;
    public synchronized void set_g(int v) {
        setVar(mExportVarIdx_g, v);
        mExportVar_g = v;
    }

    public int get_g() {
        return mExportVar_g;
    }

    public Script.FieldID getFieldID_g() {
        return createFieldID(mExportVarIdx_g, null);
    }

    private final static int mExportVarIdx_b = 3;
    private int mExportVar_b;
    public synchronized void set_b(int v) {
        setVar(mExportVarIdx_b, v);
        mExportVar_b = v;
    }

    public int get_b() {
        return mExportVar_b;
    }

    public Script.FieldID getFieldID_b() {
        return createFieldID(mExportVarIdx_b, null);
    }

    private final static int mExportVarIdx_c = 4;
    private int mExportVar_c;
    public synchronized void set_c(int v) {
        setVar(mExportVarIdx_c, v);
        mExportVar_c = v;
    }

    public int get_c() {
        return mExportVar_c;
    }

    public Script.FieldID getFieldID_c() {
        return createFieldID(mExportVarIdx_c, null);
    }

    private final static int mExportVarIdx_l = 5;
    private int mExportVar_l;
    public synchronized void set_l(int v) {
        setVar(mExportVarIdx_l, v);
        mExportVar_l = v;
    }

    public int get_l() {
        return mExportVar_l;
    }

    public Script.FieldID getFieldID_l() {
        return createFieldID(mExportVarIdx_l, null);
    }

    private final static int mExportVarIdx_Y = 6;
    private int mExportVar_Y;
    public synchronized void set_Y(int v) {
        setVar(mExportVarIdx_Y, v);
        mExportVar_Y = v;
    }

    public int get_Y() {
        return mExportVar_Y;
    }

    public Script.FieldID getFieldID_Y() {
        return createFieldID(mExportVarIdx_Y, null);
    }

    //private final static int mExportForEachIdx_root = 0;
    private final static int mExportForEachIdx_convertToNV21 = 1;
    public Script.KernelID getKernelID_convertToNV21() {
        return createKernelID(mExportForEachIdx_convertToNV21, 41, null, null);
    }

    public void forEach_convertToNV21(Allocation ain) {
        forEach_convertToNV21(ain, null);
    }

    public void forEach_convertToNV21(Allocation ain, Script.LaunchOptions sc) {
        // check ain
        if (!ain.getType().getElement().isCompatible(__I32)) {
            throw new RSRuntimeException("Type mismatch with I32!");
        }
        forEach(mExportForEachIdx_convertToNV21, ain, null, null, sc);
    }

}

