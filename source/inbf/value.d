/*
    Copyright © 2024, Inochi2D Project
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/

/**
    Inbf Value container
*/
module inbf.value;
import inbf.ex;
import numem.all;
import std.traits;

enum InbfValueType : ubyte {
    unk         = 0,    /// UNKNOWN
    i8          = 1,    /// 8 bit integer
    i16         = 2,    /// 16 bit integer
    i32         = 3,    /// 32 bit integer
    i64         = 4,    /// 64 bit integer
    f32         = 9,    /// 32 bit float
    f64         = 10,   /// 64 bit float
    str         = 11,   /// UTF-8 string
    bin         = 12,   /// Binary data
    compound    = 13,   /// Compound
    array       = 128,  /// Array
}

/**
    A value in the INBF tree
*/
class InbfValue {
@nogc:
private:
    
    InbfValueType cType;
    union {
        ulong iNum;
        double fNum;
        nstring tVal;
        vector!InbfValue arrVal;
        map!(nstring, InbfValue) compVal;
        vector!ubyte bVal;
    }

public:

    /**
        Constructs a INBF value
    */
    this(T)(T val) if (isIntegral!T) {
        static if (T.sizeof == 1) cType = InbfValueType.i8;
        else static if (T.sizeof == 2) cType = InbfValueType.i16;
        else static if (T.sizeof == 4) cType = InbfValueType.i32;
        else static if (T.sizeof == 8) cType = InbfValueType.i64;

        this.iNum = cast(ulong)val;
    }

    /**
        Constructs a INBF value
    */
    this(T)(T val) if (isFloatingPoint!T) {
        static if (T.sizeof == 4) cType = InbfValueType.f32;
        else static if (T.sizeof == 8) cType = InbfValueType.f64;

        fNum = cast(double)val;
    }

    /**
        Constructs a INBF value
    */
    this(T)(T val) if (is(T == nstring)) {
        cType = InbfValueType.str;
        tVal = val;
    }

    /**
        Constructs a INBF value
    */
    this(T)(T val) if (is(T == string)) {
        cType = InbfValueType.str;
        tVal = nstring(val);
    }

    /**
        Constructs a INBF value
    */
    this(T)(T val) if (is(T == vector!ubyte)) {
        cType = InbfValueType.bin;
        bVal = val;
    }

    /**
        Constructs a INBF compound value
    */
    static InbfValue createCompound() {
        auto val = nogc_new!InbfValue();
        val.cType = InbfValueType.compound;
        return val;
    }

    /**
        Constructs a INBF array value
    */
    static InbfValue createArray(InbfValueType type) {
        auto val = nogc_new!InbfValue();
        val.cType = cast(InbfValueType)(type | InbfValueType.array);
        return val;
    }

    /**
        Gets the raw type id
    */
    ubyte getRawType() {
        return cType;
    }

    /**
        Gets the type of the value
    */
    InbfValueType getType() {
        return cast(InbfValueType)(cType & 0b0000_1111);
    }

    /**
        Gets whether the value is an array.
    */
    bool isArray() {
        return (cType & InbfValueType.array) == InbfValueType.array;
    }

    /**
        Gets whether this value can contain multiple values inside of it.
    */
    bool isContainer() {
        return 
            isArray() || 
            getType() == InbfValueType.bin || 
            getType() == InbfValueType.compound;
    }

    /**
        Gets whether this value is a compound
    */
    bool isCompound() {
        return getType() == InbfValueType.compound;
    }

    /**
        Gets whether this value is a binary stream
    */
    bool isBinary() {
        return getType() == InbfValueType.bin;
    }

    /**
        Gets whether the value is an integer.
    */
    bool isInteger() {
        auto t = cast(ubyte)getType();
        return t > 0 && t <= InbfValueType.i64;
    }

    /**
        Gets whether the value is a floating point number
    */
    bool isFloating() {
        auto t = getType();
        return t == InbfValueType.f32 || t == InbfValueType.f64;
    }

    /**
        Gets whether the value is a basic type.
    */
    bool isBasicType() {
        return !isContainer();
    }

    /**
        Gets whether this value contains a string of UTF-8 encoded text
    */
    bool isString() {
        return getType() == InbfValueType.str;
    }

    /**
        Gets the amount of elements stored in this value

        If the length is 1
    */
    size_t length() {
        switch(cType) {
            case InbfValueType.bin:         return bVal.size();
            case InbfValueType.str:         return tVal.size();
            case InbfValueType.compound:    return compVal.length();
            default:
                if (isArray()) {
                    return arrVal.size();
                }
                return 1;
        }
    }

    vector!ubyte get(T)() if (is(T == vector!ubyte)) {
        enforce(this.isBinary(), nogc_new!InbfTypeMismatchException("vector!ubyte", T.stringof));

        return bVal;
    }

    /**
        Gets the basic value stored in this value
    */
    T get(T)() if (isIntegral!T) {
        enforce(this.isInteger(), nogc_new!InbfTypeMismatchException("int", T.stringof));

        return cast(T)iNum;
    }

    /**
        Gets the basic value stored in this value
    */
    T get(T)() if (isFloatingPoint!T) {
        enforce(this.isFloating(), nogc_new!InbfTypeMismatchException("float", T.stringof));

        return cast(T)fNum;
    }

    /**
        Gets the basic value stored in this value
    */
    T get(T)() if (is(T == nstring)) {
        enforce(this.isString(), nogc_new!InbfTypeMismatchException("nstring", T.stringof));

        return tVal;
    }

    /**
        Gets the basic value stored at the key in this value
    */
    T get(T)(nstring key) {
        enforce(this.isCompound(), nogc_new!InbfInvalidOperation("value can not be indexed."));
        enforce(key in compVal, nogc_new!InbfInvalidOperation("Key was not found in compound!"));

        static if (is(T == InbfValue)) {
            return compVal[key];
        } else {
            return compVal[key].get!T();
        }
    }

    /**
        Gets the compound map
    */
    map!(nstring, InbfValue)* getCompound() {
        enforce(this.isCompound(), nogc_new!InbfInvalidOperation("value can not be indexed."));
        return &compVal;
    }

    /**
        Gets the basic value stored at the key in this value
    */
    T get(T)(size_t i) {
        enforce(this.isArray(), nogc_new!InbfInvalidOperation("value can not be indexed."));
        enforce(i < arrVal.size(), nogc_new!InbfInvalidOperation("Index out of range"));

        static if (is(T == InbfValue)) {
            return arrVal[i];
        } else {
            return arrVal[i].get!T();
        }
    }

    /**
        Sets a value in the compound
    */
    void set(nstring key, InbfValue val) {
        import core.stdc.stdlib : malloc;
        enforce(this.isCompound(), nogc_new!InbfInvalidOperation("value can not be indexed."));

        // Remove old value
        if (key in compVal) {
            compVal.remove(key);
        }

        compVal[key] = val;
    }

    /**
        Adds a value to the array
    */
    auto opOpAssign(string op = "~")(InbfValue value) {
        if (this.isArray()) {
            arrVal ~= value;
        }
        return this;
    }

    /**
        Gets whether this compound value contains a string key

        If the value is not a compound false is always returned.
    */
    bool has(nstring key) {
        if (!this.isCompound()) return false;

        return (key in compVal) !is null;
    }

    /**
        Removes value from compound
    */
    void remove(nstring key) {
        if (!this.isCompound()) return;

        if (key in compVal) {
            compVal.remove(key);
        }
    }
}

@("Creating integer")
unittest {
    InbfValue val = nogc_new!InbfValue(42);
    assert(val.get!uint() == 42);
}

@("Creating float")
unittest {
    InbfValue val = nogc_new!InbfValue(42.0);
    assert(val.get!float() == 42.0);
}

@("Creating string")
unittest {
    InbfValue val = nogc_new!InbfValue(nstring("Hello, world!"));
    assert(val.get!nstring().toString() == "Hello, world!");
}

@("Adding elements to compound")
unittest {
    InbfValue val = nogc_new!InbfValue(42);

    InbfValue compound = InbfValue.createCompound();
    compound.set(nstring("a"), val);

    uint v = compound.get!uint(nstring("a"));
    assert(v == 42);
}

@("Catching exception")
unittest {
    try {
        InbfValue val = nogc_new!InbfValue(42);
        val.get!float(nstring("uwu"));

        assert(0, "Should've thrown!");
    } catch (NuException ex) {

    }
}