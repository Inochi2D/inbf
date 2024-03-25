/*
    Copyright © 2020, Inochi2D Project
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module source.inbf.writer;
import inbf.value;
import numem.all;

@nogc nothrow:

private {
    void writeValueTo(ref InbfValue value, ref Stream stream) {
        if (value.isArray()) {
            ubyte[1] dt = [value.getType()];
            stream.write(dt);
        }

        // switch(value.getType()) {

        // }
    }
}

/**
    Writes INBF value to stream
*/
void writeTo(ref InbfValue value, ref Stream stream) {
    
}