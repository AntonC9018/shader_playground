module shaderplayground.string;

struct NullTerminatedString
{
    string _underlyingString;

    this(R)(R str)
    {
        opAssign(str);
    }

    string opAssign(const(char)[] str)
    {
        _underlyingString = cast(string) str.dup ~ 0;
        return get();
    }

    string opAssign(string str)
    {
        if (str.length > 0 && str[$ - 1] == '\0')
            _underlyingString = str;
        else
            _underlyingString = str ~ 0; 
        return get();
    }

    immutable (char)* nullTerminated() 
    { 
        return _underlyingString.ptr; 
    }

    @property string get()
    {
        if (_underlyingString) 
            return _underlyingString[0..$-1];
        return "";
    }

    alias get this;

    auto opCmp(NullTerminatedString t) const
    {
        return t._underlyingString > _underlyingString;
    }
}