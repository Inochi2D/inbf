/*
    Copyright © 2020, Inochi2D Project
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module inbf.writer;
import inbf.ex;
import inbf.value;
import numem.all;

@nogc:

private {

    alias SWriteType = StreamWriter!(Endianess.littleEndian);

    void writeValue(bool withHeader=true)(ref InbfValue value, ref SWriteType stream) {

        // Arrays will not write headers since the array implictly has them
        static if (withHeader)
            stream.write(value.getRawType());

        // Arrays are a special case
        if (value.isArray()) {
            stream.write(cast(int)value.length);
            foreach(i; 0..value.length()) {
                InbfValue val = value.get!InbfValue(i);
                writeValue!false(val, stream);
            }
            return;
        }

        switch(value.getType()) {
            case InbfValueType.i8:
                stream.write(value.get!ubyte());
                break;
            case InbfValueType.i16:
                stream.write(value.get!ushort());
                break;
            case InbfValueType.i32:
                stream.write(value.get!uint());
                break;
            case InbfValueType.i64:
                stream.write(value.get!ulong());
                break;
            case InbfValueType.f32:
                stream.write(value.get!float());
                break;
            case InbfValueType.f64:
                stream.write(value.get!double());
                break;
            case InbfValueType.str:
                stream.write(value.length());
                stream.write(value.get!nstring());
                break;
            case InbfValueType.bin:
                stream.write(value.length());
                stream.write(value.get!(vector!ubyte)());
                break;
            case InbfValueType.compound:
                auto compound = value.getCompound();
                stream.write(cast(int)compound.length());
                foreach(entry; compound.byKeyValue) {

                    // TODO: Add string slice support to StreamWriter
                    stream.write(cast(int)entry.key.length);
                    stream.write(entry.key);

                    entry.value.writeValue(stream);
                }
                break;
            default:
                throw nogc_new!InbfInvalidOperation("Unknown type recieved.");
        }
    }
}

/**
    Writes INBF value to stream
*/
void writeTo(ref InbfValue value, ref Stream stream) {
    SWriteType writer = nogc_new!(SWriteType)(stream);

    value.writeValue(writer);

    // Done writing
    nogc_delete(writer);
}

@("Test writing")
unittest {
    
    InbfValue val = nogc_new!InbfValue(42);

    InbfValue compound = InbfValue.createCompound();
    compound.set(nstring("a"), val);
    
    Stream s = openFile(nstring("test.inbf"), "wb");

    compound.writeTo(s);
}