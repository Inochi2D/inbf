/*
    Copyright © 2020, Inochi2D Project
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module inbf.value;
import inbf.common;
import numem.mem.vector;
import numem.mem.map;
import numem.all;
import std.traits;

enum InbfValueType : ubyte {
    unk         = 0, /// UNKNOWN
    i8          = 1,
    i16         = 2,
    i32         = 3,
    i64         = 4,
    u8          = 5,
    u16         = 6,
    u32         = 7,
    u64         = 8,
    f32         = 9,
    f64         = 10,
    str         = 11,
    bin         = 12,
    compound    = 13,
    compressed  = 64,
    array       = 128,
}

/**
    A value in the INBF tree
*/
class InbfValue {
@nogc nothrow:
private:
    
    InbfValueType cType;
    union {
        ulong uNum;
        long iNum;
        double fNum;
        nstring tVal;
        vector!InbfValue arrVal;
        map!(string, InbfValue) compVal;
        vector!ubyte bVal;
    }

public:

    /**
        Constructs a INBF value
    */
    this(T)(T val) if (isIntegral!T) {
        static if (isSigned!T) {
            static if (T.sizeof == 1) cType = InbfValueType.i8;
            else static if (T.sizeof == 2) cType = InbfValueType.i16;
            else static if (T.sizeof == 4) cType = InbfValueType.i32;
            else static if (T.sizeof == 8) cType = InbfValueType.i64;

            this.uNum = cast(long)val;
        } else {
            static if (T.sizeof == 1) cType = InbfValueType.u8;
            else static if (T.sizeof == 2) cType = InbfValueType.u16;
            else static if (T.sizeof == 4) cType = InbfValueType.u32;
            else static if (T.sizeof == 8) cType = InbfValueType.u64;

            this.uNum = cast(ulong)val;
        }
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
        Gets whether the value is compressed with LZMA.
    */
    bool isCompressed() {
        return (cType & InbfValueType.compressed) == InbfValueType.compressed;
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
            case InbfValueType.compound:    return compVal.length();
            default:
                if (isArray()) {
                    return arrVal.size();
                }
                return 1;
        }
    }

    /**
        Gets the basic value stored in this value
    */
    Option!T get(T)() if (isIntegral!T) {

        // Value error
        if (!this.isInteger()) {
            return Option!T(InbfError(nstring("Value is not an integer!")));
        }

        static if (isSigned!T) {
            return Option!T(cast(T)iNum);
        } else {
            return Option!T(cast(T)uNum);
        }
    }

    /**
        Gets the basic value stored in this value
    */
    Option!T get(T)() if (isFloatingPoint!T) {

        // Value error
        if (!this.isFloating()) {
            return Option!T(InbfError(nstring("Value is not a floating point number!")));
        }

        return Option!T(cast(T)fNum);
    }

    /**
        Gets the basic value stored in this value
    */
    Option!T get(T)() if (is(T == nstring)) {

        // Value error
        if (!this.isString()) {
            return Option!T(InbfError(nstring("Value is not a string!")));
        }

        return Option!T(tVal);
    }

    /**
        Gets the basic value stored at the key in this value
    */
    Option!T get(T)(nstring key) {

        // Value error
        if (!this.isCompound()) {
            return Option!T(InbfError("Value is not a compound!"));
        }

        // Index error
        if (key.toString() !in compVal) {
            nstring err = key;
            err ~= " was not found in compound!";
            return Option!T(InbfError(err));
        }

        static if (is(T == InbfValue)) {
            return Option!T(compVal[key.toString()]);
        } else {
            Option!InbfValue val = this.get!InbfValue(key);
            if (val.valid()) {
                return val.value.get!T();
            } else {
                return Option!T(val.err);
            }
        }
    }

    /**
        Gets the basic value stored at the key in this value
    */
    Option!T get(T)(size_t i) {
        if (!this.isArray()) {
            return Option!T(InbfError("Value is not a compound!"));
        }

        if (i > arrVal.size()) {
            return Option!T(InbfError("Index out of range!"));
        }

        static if (is(T == InbfValue)) {
            return Option!T(arrVal[i]);
        } else {
            return Option!T(arrVal[i]);
        }
    }

    /**
        Sets a value in the compound
    */
    Option!void set(nstring key, InbfValue val) {
        import core.stdc.stdlib : malloc;
        if (!this.isCompound()) {
            return Option!void(InbfError("Value is not a compound!"));
        }

        string str = cast(string)(malloc(key.size())[0..key.size()]);
        (cast(char[])str[0..key.size()]) = key[0..$];

        // Remove old value
        if (str in compVal) {
            compVal.remove(str);
        } 

        compVal[str] = val;
        return Option!void(null);
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

        return (key.toString() in compVal) !is null;
    }

    /**
        Removes value from compound
    */
    void remove(nstring key) {
        if (!this.isCompound()) return;

        if (key.toString() in compVal) {
            compVal.remove(key.toString());
        }
    }
}

@("Creating integer")
unittest {
    InbfValue val = nogc_new!InbfValue(42);
    assert(val.get!uint().unwrap() == 42);
}

@("Creating float")
unittest {
    InbfValue val = nogc_new!InbfValue(42.0);
    assert(val.get!float().unwrap() == 42.0);
}

@("Creating string")
unittest {
    InbfValue val = nogc_new!InbfValue(nstring("Hello, world!"));
    assert(val.get!nstring().unwrap().toString() == "Hello, world!");
}

@("Adding elements to compound")
unittest {
    InbfValue val = nogc_new!(InbfValue)(42);

    InbfValue compound = InbfValue.createCompound();
    compound.set(nstring("a"), val);

    uint v = 
        compound.get!uint(nstring("a"))
        .unwrap();

    assert(v == 42);
}