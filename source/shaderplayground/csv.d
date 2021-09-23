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

Csv loadCsv(string csvPath)
{
    import std.stdio;
    import std.algorithm;
    import std.range;
    import std.array;

    auto file = File(csvPath, "r");
    auto lines = file.byLine;

    char[] convertEntry(char[] entry)
    {
        if (entry.length >= 2 && entry[0] == '"' && entry[$-1] == '"')
            entry = entry[1..$-1];
        return entry;
    }

    Csv result;
    
    auto firstLine = lines.front;
    // Remove BOM
    if (firstLine.length > 3 && firstLine[0..3] == [0xEF,0xBB,0xBF])
        firstLine = firstLine[3..$];

    foreach (i, header; firstLine.split(','))
    {
        result.header ~= NullTerminatedString(convertEntry(header));
    }
    result.data = new NullTerminatedString[][](result.header.length);
    lines.popFront();
    
    auto otherLines = lines.map!(l => l.dup).array;
    auto numLines = otherLines.length;
    foreach(ref v; result.data)
        v = new NullTerminatedString[](numLines);
    
    foreach (lineIndex, line; otherLines)
    {
        auto elements = line.split(",");
        import std.exception;
        // if (elements.length > result.header.length) 
        //     g_Logger.log("One of the lines is longer than the header");
        foreach (i, thing; elements)
        {
            // Wtf?
            if (i >= result.header.length)
                break;
            result.data[i][lineIndex] = convertEntry(thing);
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