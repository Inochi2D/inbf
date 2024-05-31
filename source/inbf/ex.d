module inbf.ex;
import numem.all;

/**
    Base exception of all INBF exceptions
*/
class InbfException : NuException {
@nogc:
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(nstring(msg), null, file, line);
    }

    this(nstring msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, null, file, line);
    }
}

/**
    Exception indicating a type-mismatch
*/
class InbfTypeMismatchException : InbfException {
@nogc:
    this(string expected, string got, string file = __FILE__, size_t line = __LINE__) {
        nstring str;
        str ~= nstring("Expected ");
        str ~= nstring(expected);
        str ~= nstring(" but got ");
        str ~= nstring(got);
        str ~= nstring("!");
        super(str, file, line);
    }
}

/**
    Exception indicating a type-mismatch
*/
class InbfInvalidOperation : InbfException {
@nogc:
    this(string op, string file = __FILE__, size_t line = __LINE__) {
        super(nstring(op), file, line);
    }

    this(nstring op, string file = __FILE__, size_t line = __LINE__) {
        super(op, file, line);
    }
}