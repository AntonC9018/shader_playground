module shaderplayground.csv;

import shaderplayground.string;
import std.range;
import std.algorithm;
import std.conv : to;

struct Csv
{
    NullTerminatedString[] header;
    ValueType[] inferredTypes;
    NullTerminatedString[][] data;

    auto getNumericIndices()
    {
        return iota(header.length).filter!(
            i => inferredTypes[i] == ValueType.Double || inferredTypes[i] == ValueType.Int);
    }

    size_t numRows() { return data[0].length; }
    size_t numColumns() { return header.length; }
}

enum ValueType
{
    Double, Int, Other
}

int toIntZero(string str)
{
    if (str.empty) 
        return 0;
    return to!int(str);
}

double toFloatZero(string str)
{
    if (str.empty)
        return 0;
    return to!double(str);
}

auto splitEntries(string str)
{
    struct Splitter
    {
        string _source;
        string front;
        bool empty;

        this(string source)
        {
            _source = source;
            popFront();
        }
        
        void popFront()
        {
            if (_source.empty)
                empty = true;
            else
                front = advanceFront();
        }
        
        string advanceFront()
        {
            int endIndex = 0;
            string copy = _source;

            assert(!_source.empty);

            if (_source.front == '"')
            {
                endIndex++;
                _source.popFront();
                // skip all non "
                while (_source.front != '"')
                {
                    endIndex++;
                    _source.popFront();
                }
                _source.popFront();

                if (_source.empty)
                {
                    return copy[1..endIndex];
                }
                assert(_source.front == ',');
                _source.popFront();
                return copy[1..endIndex];
            }
            while (_source.front != ',')
            {
                endIndex++;
                _source.popFront();
                
                if (_source.empty)
                    return copy[0..endIndex];
            }

            assert(_source.front == ',');
            _source.popFront();

            return copy[0..endIndex];
        }
    }

    return Splitter(str);
}
unittest
{
    import std.stdio;
    auto things = splitEntries(`"","","Hello",k,"123",`).array;
    assert(things[] == ["", "", "Hello", "k", "123"]);
}

Csv loadCsv(string csvPath)
{
    import std.stdio;
    import std.algorithm;
    import std.range;
    import std.array;

    auto file = File(csvPath, "r");
    auto lines = file.byLine;

    Csv result;
    
    auto firstLine = lines.front;
    // Remove BOM
    if (firstLine.length > 3 && firstLine[0..3] == [0xEF,0xBB,0xBF])
        firstLine = firstLine[3..$];
    
    foreach (i, header; splitEntries(firstLine.idup).enumerate)
    {
        result.header ~= NullTerminatedString(header);
    }
    result.data = new NullTerminatedString[][](result.header.length);
    lines.popFront();
    
    auto otherLines = lines.map!(l => l.idup).array;
    auto numLines = otherLines.length;
    foreach(ref v; result.data)
        v = new NullTerminatedString[](numLines);
    
    foreach (lineIndex, line; otherLines)
    {
        auto elements = splitEntries(line);
        import std.exception;
        // if (elements.length > result.header.length) 
        //     g_Logger.log("One of the lines is longer than the header");
        foreach (i, thing; elements.enumerate)
        {
            // Wtf?
            if (i >= result.header.length)
                break;
            result.data[i][lineIndex] = thing;
        }
    }

    result.inferredTypes = new ValueType[result.header.length];

    foreach (i; 0..result.header.length)
    {
        bool canBe(T)()
        {
            foreach (j, it; result.data[i])
            {
                // Empty is fine
                if (it.empty) 
                    continue;
                try it.get.to!T(); 
                catch (Exception)
                {
                    return false;
                }
            }
            return true;
        }

        if (canBe!double)
            result.inferredTypes[i] = ValueType.Double;
        else if (canBe!int)
            result.inferredTypes[i] = ValueType.Int;
        else
            result.inferredTypes[i] = ValueType.Other;
    }

    return result;
}