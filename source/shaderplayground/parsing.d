module shaderplayground.parsing;

enum Qualifier
{
    In = "in", 
    Out = "out", 
    Uniform = "uniform" 
}

// string QualifierToString(Qualifier qualifier)
// {
//     final switch (qualifier)
//     {
//     case Qualifier.inQualifier: return "in";
//     case Qualifier.outQualifier: return "out";
//     case Qualifier.uniformQualifier: return "uniform";
//     }
// }

struct CTVariable
{
    int location;
    Qualifier qualifier;
    string type;
    string name;
}

import std.ascii;
import std.range;
import std.string : startsWith;

string tryMatchIdentifier(ref string source)
{
    auto s = source;
    if (s.empty) return null;
    if (!isAlpha(s.front) && s.front != '_') return null;
    s.popFront();
    while (!s.empty && (isAlphaNum(s.front) || s.front == '_'))
    {
        s.popFront();
    }
    string ident = source[0..$-s.length];
    source = s;
    return ident;
}

unittest
{
    string s;
    s = "123";
    assert(tryMatchIdentifier(s) == null);
    assert(s == "123");
    s = "abc";
    assert(tryMatchIdentifier(s) == "abc");
    assert(s == "");
    s = "_ab1";
    assert(tryMatchIdentifier(s) == "_ab1");
    assert(s == "");
    s = " a1";
    assert(tryMatchIdentifier(s) == null);
    assert(s == " a1");
}

bool tryMatchUint(ref string source, out uint number)
{
    auto s = source;
    while (!s.empty && s.front >= '0' && s.front <= '9')
    {
        s.popFront();
    }
    if (s.length == source.length) return false;

    import std.conv : to;
    number = to!uint(source[0..$-s.length]);
    source = s;
    return true;
}
unittest
{
    string s;
    uint number;
    s = "123";
    assert(tryMatchUint(s, number));
    assert(number == 123);
    assert(s == "");
    s = "a";
    assert(!tryMatchUint(s, number));
    assert(s == "a");
}

void skipWhitespace(ref string source)
{
    while (!source.empty && isWhite(source.front))
    {
        source.popFront();
    }
}
unittest
{
    string s;
    s = "  a";
    s.skipWhitespace();
    assert(s == "a");
    s.skipWhitespace();
    assert(s == "a");
}

string tryMatchEitherOf(ref string input, string[] options)
{
    foreach (option; options)
    {
        if (input.startsWith(option))
        {
            input = input[option.length..$];
            return option;
        }
    }
    return null;
}
unittest
{
    string s;
    s = "123";
    assert(tryMatchEitherOf(s, ["123", "234"]) == "123");
    assert(s == "");
    s = "234";
    assert(tryMatchEitherOf(s, ["123", "234"]) == "234");
    assert(s == "");
    assert(tryMatchEitherOf(s, ["123"]) == null);
    assert(s == "");
}

bool tryMatch(string str, ref string input)
{
    if (input.startsWith(str))
    {
        input = input[str.length..$];
        return true;
    }
    return false;
}
unittest
{
    string s;
    s = "1231";
    assert(tryMatch("123", s));
    assert(s == "1");
}

bool tryMaybeMatchLayout(ref string source, out int location)
{
    location = -1;
    auto s = source;
    s.skipWhitespace();
    if (!tryMatch("layout", s))     { source = s; return true; }
    s.skipWhitespace();
    if (!tryMatch("(", s))          return false;
    s.skipWhitespace();
    if (!tryMatch("location", s))   return false;
    s.skipWhitespace();
    if (!tryMatch("=", s))          return false;
    s.skipWhitespace();
    
    uint number;
    if (!tryMatchUint(s, number))   return false;
    location = cast(int) number;

    s.skipWhitespace();
    if (!tryMatch(")", s))          return false;

    source = s;
    return true;
}
unittest
{
    string s;
    int location;
    s = " layout";
    assert(!tryMaybeMatchLayout(s, location));
    assert(s == " layout");
    assert(location == -1);

    s = "1";
    assert(tryMaybeMatchLayout(s, location));
    assert(s == "1");
    assert(location == -1);

    s = "layout (location = 4)";
    assert(tryMaybeMatchLayout(s, location));
    assert(s == "");
    assert(location == 4);
}

bool tryMatchVariable(string input, out CTVariable variable)
{
    if (!tryMaybeMatchLayout(input, variable.location)) return false;

    input.skipWhitespace();
    variable.qualifier = cast(Qualifier) tryMatchEitherOf(input, ["in", "out", "uniform"]);
    if (variable.qualifier is null) return false;
    
    if (!tryMatch(" ", input)) return false;
    input.skipWhitespace();

    variable.type = tryMatchIdentifier(input);
    if (variable.type is null) return false;
    if (!tryMatch(" ", input)) return false;
    input.skipWhitespace();

    variable.name = tryMatchIdentifier(input);
    if (variable.name is null) return false;

    return true;
}
unittest
{
    auto input = "layout (location = 7) in a b";
    CTVariable variable;
    assert(tryMatchVariable(input, variable));
    assert(variable.location == 7);
    assert(variable.qualifier == Qualifier.In);
    assert(variable.type == "a");
    assert(variable.name == "b");
}

/// Checks for `bool function(TIn, out TOut)`.
template isMapFunc(alias Func)
{
    import std.traits : ParameterStorageClassTuple, ParameterStorageClass, ReturnType;
    alias type = typeof(Func);
    alias psct = ParameterStorageClassTuple!type;
    enum isMapFunc = psct[1] == ParameterStorageClass.out_ && is(ReturnType!Func == bool);
}

/// Takes in a `bool function(TIn, out TOut)` and an input range.
/// Constructs a new input range, which consists of elements of type TOut.
/// Only those elements are kept for which the function returned true.
template mapFilter(alias Func)
if (isMapFunc!Func)
{
    import std.traits : Parameters;
    alias TOut = Parameters!(typeof(Func))[1];

    // TODO: deduce T from Func
    auto mapFilter(R)(R range)
    if (isInputRange!R)
    {
        return MapFilter!(R)(range);
    }

    struct MapFilter(R)
    {
        R range;
        TOut front;
        bool empty;

        this(R range) 
        { 
            this.range = range; 
            popFront(); 
        }
        
        void popFront() 
        {
            while (!range.empty)
            {
                const rangeFront = range.front;
                range.popFront();
                // front gets value via `out`
                if (Func(rangeFront, front)) return;
            }
            empty = true;
        }
    }
}
unittest
{
    static bool thing(int source, out uint output)
    {
        if (source >= 0)
        {
            output = cast(uint) source;
            return true;
        }
        return false;
    }
    import std.algorithm.comparison : equal;
    auto result = [1, 2, -1, -2].mapFilter!(thing);
    assert(equal(result, [1u, 2u]));
}

auto getVariables(string input)
{
    import std.range;
    import std.algorithm;
    import std.string : lineSplitter;

    return input.lineSplitter()
         .mapFilter!tryMatchVariable
         .array();
}