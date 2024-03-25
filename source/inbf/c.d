/**
    Inochi2D Binary Format

    Copyright © 2020, Inochi2D Project
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module inbf.c;
import inbf.common;
import inbf.value;
import numem.all;

nothrow @nogc extern(C) export:

private {
    __gshared bool errored;
    __gshared InbfError error;

    void setError(InbfError err) {
        if (errored) {
            nogc_delete(error);
        }

        error = err;
    }

    void unsetError() {
        if (errored) {
            nogc_delete(error);
        }
    }
}

enum {
    INBF_ERROR = 0,
    INBF_SUCCESS = 1,
}

/**
    INBF Value
*/
struct inbf_value_t;

/**
    Returns the current error string
*/
const(char)* inbf_error_get() {
    return error.msg.toCString();
}

/**
    Gets signed 8 bit value
*/
int inbf_value_get_i8(inbf_value_t* value, byte* target) {
    auto result = (cast(InbfValue)value).get!byte();

    if (result.valid) {
        *target = result.value;
        unsetError();
        return INBF_SUCCESS;
    }

    setError(result.err);
    return INBF_ERROR;
}

/**
    Gets signed 16 bit value
*/
int inbf_value_get_i16(inbf_value_t* value, short* target) {
    auto result = (cast(InbfValue)value).get!short();

    if (result.valid) {
        *target = result.value;
        unsetError();
        return INBF_SUCCESS;
    }

    setError(result.err);
    return INBF_ERROR;
}

/**
    Gets signed 32 bit value
*/
int inbf_value_get_i32(inbf_value_t* value, int* target) {
    auto result = (cast(InbfValue)value).get!int();

    if (result.valid) {
        *target = result.value;
        unsetError();
        return INBF_SUCCESS;
    }

    setError(result.err);
    return INBF_ERROR;
}

/**
    Gets signed 64 bit value
*/
int inbf_value_get_i64(inbf_value_t* value, long* target) {
    auto result = (cast(InbfValue)value).get!long();

    if (result.valid) {
        *target = result.value;
        unsetError();
        return INBF_SUCCESS;
    }

    setError(result.err);
    return INBF_ERROR;
}

/**
    Gets unsigned 8 bit value
*/
int inbf_value_get_u8(inbf_value_t* value, ubyte* target) {
    auto result = (cast(InbfValue)value).get!ubyte();

    if (result.valid) {
        *target = result.value;
        unsetError();
        return INBF_SUCCESS;
    }

    setError(result.err);
    return INBF_ERROR;
}

/**
    Gets unsigned 16 bit value
*/
int inbf_value_get_u16(inbf_value_t* value, ushort* target) {
    auto result = (cast(InbfValue)value).get!ushort();

    if (result.valid) {
        *target = result.value;
        unsetError();
        return INBF_SUCCESS;
    }

    setError(result.err);
    return INBF_ERROR;
}

/**
    Gets unsigned 32 bit value
*/
int inbf_value_get_u32(inbf_value_t* value, uint* target) {
    auto result = (cast(InbfValue)value).get!uint();

    if (result.valid) {
        *target = result.value;
        unsetError();
        return INBF_SUCCESS;
    }

    setError(result.err);
    return INBF_ERROR;
}

/**
    Gets unsigned 64 bit value
*/
int inbf_value_get_u64(inbf_value_t* value, ulong* target) {
    auto result = (cast(InbfValue)value).get!ulong();

    if (result.valid) {
        *target = result.value;
        unsetError();
        return INBF_SUCCESS;
    }

    setError(result.err);
    return INBF_ERROR;
}


/**
    Gets unsigned 32 bit value
*/
int inbf_value_get_f32(inbf_value_t* value, float* target) {
    auto result = (cast(InbfValue)value).get!float();

    if (result.valid) {
        *target = result.value;
        unsetError();
        return INBF_SUCCESS;
    }

    setError(result.err);
    return INBF_ERROR;
}

/**
    Gets unsigned 64 bit value
*/
int inbf_value_get_f64(inbf_value_t* value, double* target) {
    auto result = (cast(InbfValue)value).get!double();

    if (result.valid) {
        *target = result.value;
        unsetError();
        return INBF_SUCCESS;
    }

    setError(result.err);
    return INBF_ERROR;
}

/**
    Gets string value

    Value needs to be freed manually
*/
int inbf_value_get_string(inbf_value_t* value, const(char)** target) {
    import core.stdc.stdlib : malloc;
    import core.stdc.string : memcpy;
    auto result = (cast(InbfValue)value).get!nstring();

    if (result.valid) {
        nstring str = result.value;

        *target = cast(const(char)*)malloc(str.length());
        memcpy(cast(void*)*target, cast(void*)str.toCString(), str.length());
        unsetError();
        return INBF_SUCCESS;
    }

    setError(result.err);
    return INBF_ERROR;
}

/**
    Gets compound value by key
*/
int inbf_value_get_compoundv(inbf_value_t* compound, const(char)* key, inbf_value_t** target) {
    import core.stdc.string : strlen;
    nstring keyv = nstring(key[0..strlen(key)]);
    auto result = (cast(InbfValue)compound).get!InbfValue(keyv);

    if (result.valid) {
        *target = cast(inbf_value_t*)result.value;
        unsetError();
        return INBF_SUCCESS;
    }

    setError(result.err);
    return INBF_ERROR;
}

/**
    Gets compound value by key
*/
int inbf_value_set_compoundv(inbf_value_t* compound, const(char)* key, inbf_value_t* value) {
    import core.stdc.string : strlen;
    nstring keyv = nstring(key[0..strlen(key)]);
    unsetError();

    if (value && compound) {
        (cast(InbfValue)compound).set(keyv, cast(InbfValue)value);
        return INBF_SUCCESS;
    }

    return INBF_ERROR;
}

/**
    Gets compound value by key
*/
int inbf_value_remove_compoundv(inbf_value_t* target, const(char)* key) {
    import core.stdc.string : strlen;
    nstring keyv = nstring(key[0..strlen(key)]);
    unsetError();

    if (target) {
        (cast(InbfValue)target).remove(keyv);
        return INBF_SUCCESS;
    }

    return INBF_ERROR;
}

/**
    Gets array value by index
*/
int inbf_value_get_arrayv(inbf_value_t* value, size_t i, inbf_value_t** target) {
    import core.stdc.string : strlen;
    auto result = (cast(InbfValue)value).get!InbfValue(i);

    if (result.valid) {
        *target = cast(inbf_value_t*)result.value;
        unsetError();
        return INBF_SUCCESS;
    }

    setError(result.err);
    return INBF_ERROR;
}

/**
    Destroys a value
*/
int inbf_value_destroy(inbf_value_t* value) {
    if (value) {
        InbfValue val = cast(InbfValue)value;
        nogc_delete(val);

        unsetError();
        return INBF_SUCCESS;
    }

    unsetError();
    return INBF_ERROR;
}

/**
    Creates a new value
*/
inbf_value_t* inbf_value_create_i8(byte value) {
    return cast(inbf_value_t*)nogc_new!InbfValue(value);
}

/**
    Creates a new value
*/
inbf_value_t* inbf_value_create_i16(short value) {
    return cast(inbf_value_t*)nogc_new!InbfValue(value);
}

/**
    Creates a new value
*/
inbf_value_t* inbf_value_create_i32(int value) {
    return cast(inbf_value_t*)nogc_new!InbfValue(value);
}

/**
    Creates a new value
*/
inbf_value_t* inbf_value_create_i64(long value) {
    return cast(inbf_value_t*)nogc_new!InbfValue(value);
}

/**
    Creates a new value
*/
inbf_value_t* inbf_value_create_u8(ubyte value) {
    return cast(inbf_value_t*)nogc_new!InbfValue(value);
}

/**
    Creates a new value
*/
inbf_value_t* inbf_value_create_u16(ushort value) {
    return cast(inbf_value_t*)nogc_new!InbfValue(value);
}

/**
    Creates a new value
*/
inbf_value_t* inbf_value_create_u32(uint value) {
    return cast(inbf_value_t*)nogc_new!InbfValue(value);
}

/**
    Creates a new value
*/
inbf_value_t* inbf_value_create_u64(ulong value) {
    return cast(inbf_value_t*)nogc_new!InbfValue(value);
}


/**
    Creates a new value
*/
inbf_value_t* inbf_value_create_f32(float value) {
    return cast(inbf_value_t*)nogc_new!InbfValue(value);
}

/**
    Creates a new value
*/
inbf_value_t* inbf_value_create_f64(double value) {
    return cast(inbf_value_t*)nogc_new!InbfValue(value);
}

/**
    Creates a new value
*/
inbf_value_t* inbf_value_create_string(const(char)* value) {
    import core.stdc.string : strlen;
    return cast(inbf_value_t*)nogc_new!InbfValue(nstring(value[0..strlen(value)]));
}

/**
    Creates a new value
*/
inbf_value_t* inbf_value_create_compound() {
    return cast(inbf_value_t*)InbfValue.createCompound();
}

/**
    Creates a new value
*/
inbf_value_t* inbf_value_create_array(inbf_value_t* content) {
    if (content) {
        auto val = InbfValue.createArray((cast(InbfValue)content).getType());
        val ~= cast(InbfValue)content;
        return cast(inbf_value_t*)val;
    }
    return null;
}