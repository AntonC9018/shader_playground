module shaderplayground.logger;
import std.stdio;

enum LogType : int 
{
    None = 0,
    Error = 1 << 0, 
    Log   = 1 << 1
}

struct Logger
{
    const string name;
    LogType recordedLogTypes = cast(LogType) 0;

    bool hasErrors() { return (recordedLogTypes & LogType.Error) != 0; }
}

static g_Logger = Logger("Global");

import std.traits : isSomeString;

void error(T)(ref Logger logger, T t)
{   
    stderr.writefln("[%s] (Error) %s.", logger.name, t);
    logger.recordedLogTypes |= LogType.Error;
}

void log(T)(ref Logger logger, T t)
{
    stdout.writefln("[%s] %s.", logger.name, t);
    logger.recordedLogTypes |= LogType.Log;
}