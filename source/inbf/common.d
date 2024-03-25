/*
    Copyright © 2020, Inochi2D Project
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module inbf.common;
import numem.all;

/**
    An error
*/
struct InbfError {
@nogc nothrow:
    nstring msg;

    this(string str) {
        msg = nstring(str);
    }

    this(nstring str) {
        msg = str;
    }
}

/**
    Very basic option type
*/
struct Option(T) {
private:
    bool errored;

public:
    InbfError err;

    @disable this();

    /// Constructor for error input
    this(InbfError err) {
        this.err = err;
        errored = true;
    }

    static if (!is(T == void)) {
        T value;

        /// Constructor for non-error value input
        this(T value) {
            this.value = value;
            errored = false;
        }
    } else {

        /// Constructor for non-error null input
        this(void* input) {
            if (input == null) {
                errored = false;
            } else {
                errored = true;
            }
        }
    }

    /**
        Whether the option result is valid.
    */
    bool valid() {
        return !errored;
    }
}

/**
    Expect the value to be valid, otherwise throw an unrecoverable error
*/
T unwrap(T)(Option!T input) {
    debug {
        assert(input.valid, input.err.msg.toString());
    } else {
        if (!input.valid()) {
            throw nogc_new!Error(input.err.msg.toString);
        }
    }

    static if (!is(T == void)) return input.value;
}