/*
    Copyright © 2020, Inochi2D Project
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module source.inbf.writer;
import inbf.value;
import numem.all;

@nogc:

private {

    void writeValueHeader(ref InbfValue value, ref Stream stream) {
        
        // Write type
        {
            ubyte[1] dt = [value.getRawType()];
            stream.write(dt);
        }
    }

    void writeBasicValueTo(ref InbfValue value, ref Stream stream) {

    }

    void writeValueTo(bool withHeader=true)(ref InbfValue value, ref Stream stream) {

        // Arrays will not write headers since the array implictly has them
        static if (withHeader)
            writeValueHeader(value, stream);

        // Arrays are a special case
        if (value.isArray()) {
            ubyte[4] dt = toEndian(cast(int)value.length, Endianess.littleEndian);
            stream.write(dt);
            foreach(i; 0..value.length()) {
                switch(value.getType()) {
                    case InbfValueType.i8:
                        writeValueTo!false(value.get!ubyte(i).unwrap(), stream);
                }
            }
        }

        switch(value.getType()) {
            case InbfValueType.f32:
                break;
            default:
                break;
        }
    }
}

/**
    Writes INBF value to stream
*/
void writeTo(ref InbfValue value, ref Stream stream) {
    
}