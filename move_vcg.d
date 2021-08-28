module move_vcg;

import std.file;
import std.string;
import std.path;
import std.range;
import std.algorithm;
import std.conv : to;

void moveFile(string from, string to)
{
    if (exists(to)) remove(to);
    else            mkdirRecurse(dirName(to));
    rename(from, to);
}

void main()
{
    foreach (string name; dirEntries("source", "*.cg", SpanMode.depth))
    {
        auto newName = buildPath("vcg_ast", name.findSplitAfter(`source\`)[1].to!string());
        moveFile(name, newName);
    }
}