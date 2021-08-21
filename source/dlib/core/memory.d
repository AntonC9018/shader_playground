/*
Copyright (c) 2015-2021 Timur Gafarov

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/

/**
 * Tools for manual memory management
 *
 * New/Delete for classes, structs and arrays. It utilizes dlib.memory
 * for actual memory allocation, so it is possible to switch allocator that is
 * being used. By default, dlib.memory.mallocator.Mallocator is used.
 *
 * Module includes a simple memory profiler that can be turned on with enableMemoryProfiler
 * function. If active, it will store information about every allocation (type and size),
 * and will mark those which are leaked (haven't been deleted).
 *
 * Copyright: Timur Gafarov 2015-2021.
 * License: $(LINK2 https://boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors: Timur Gafarov
 */
module dlib.core.memory;

import std.stdio;
import std.conv;
import std.traits;
import std.datetime;
import std.algorithm;
import core.stdc.stdlib;
import core.exception: onOutOfMemoryError;

import dlib.memory;

private __gshared ulong _allocatedMemory = 0;

/**
 * Returns current amount of allocated memory in bytes. This is 0 at program start
 */
ulong allocatedMemory()
{
    return _allocatedMemory;
}

private __gshared Mallocator _defaultGlobalAllocator;
private __gshared Allocator _globalAllocator;

/**
 * Returns current global Allocator that is used by New and Delete
 */
Allocator globalAllocator()
{
    if (_globalAllocator is null)
    {
        if (_defaultGlobalAllocator is null)
            _defaultGlobalAllocator = Mallocator.instance;
        _globalAllocator = _defaultGlobalAllocator;
    }
    return _globalAllocator;
}

/**
 * Sets global Allocator that is used by New and Delete
 */
void globalAllocator(Allocator a)
{
    _globalAllocator = a;
}

struct AllocationRecord
{
    string type;
    size_t size;
    string file;
    int line;
    ulong id;
    bool deleted;
}

private
{
    __gshared bool memoryProfilerEnabled = false;
    __gshared AllocationRecord[ulong] records;
    __gshared ulong counter = 0;

    void addRecord(void* p, string type, size_t size, string file = "<undefined>", int line = 0)
    {
        records[cast(ulong)p] = AllocationRecord(type, size, file, line, counter, false);
        counter++;
    }

    void markDeleted(void* p)
    {
        ulong k = cast(ulong)p - psize;
        records[k].deleted = true;
    }
}

/**
 * Enables or disables memory profiler
 */
void enableMemoryProfiler(bool mode)
{
    memoryProfilerEnabled = mode;
}

/**
 * Prints full allocation list if memory profiler is enabled, otherwise does nothing
 */
void printMemoryLog()
{
    writeln("----------------------------------------------------");
    writeln("               Memory allocation log                ");
    writeln("----------------------------------------------------");
    auto keys = records.keys;
    sort!((a, b) => records[a].id < records[b].id)(keys);
    foreach(k; keys)
    {
        AllocationRecord r = records[k];
        if (r.deleted)
            writefln("         %s - %s byte(s) in %s(%s)", r.type, r.size, r.file, r.line);
        else
            writefln("REMAINS: %s - %s byte(s) in %s(%s)", r.type, r.size, r.file, r.line);
    }
    writeln("----------------------------------------------------");
    writefln("Total amount of allocated memory: %s byte(s)", _allocatedMemory);
    writeln("----------------------------------------------------");
}

/**
 * Prints leaked allocations if memory profiler is enabled, otherwise does nothing
 */
void printMemoryLeaks()
{
    writeln("----------------------------------------------------");
    writeln("                    Memory leaks                    ");
    writeln("----------------------------------------------------");
    auto keys = records.keys;
    sort!((a, b) => records[a].id < records[b].id)(keys);
    foreach(k; keys)
    {
        AllocationRecord r = records[k];
        if (!r.deleted)
            writefln("%s - %s byte(s) in %s(%s)", r.type, r.size, r.file, r.line);
    }
    writeln("----------------------------------------------------");
    writefln("Total amount of leaked memory: %s byte(s)", _allocatedMemory);
    writeln("----------------------------------------------------");
}

interface Freeable
{
    void free();
}

enum psize = 8;

static if (__VERSION__ >= 2079)
{
    T allocate(T, A...) (A args, string file = __FILE__, int line = __LINE__) if (is(T == class))
    {
        enum size = __traits(classInstanceSize, T);
        void* p = globalAllocator.allocate(size+psize).ptr;
        if (!p)
            onOutOfMemoryError();
        auto memory = p[psize..psize+size];
        *cast(size_t*)p = size;
        _allocatedMemory += size;
        if (memoryProfilerEnabled)
        {
            addRecord(p, T.stringof, size, file, line);
        }
        auto res = emplace!(T, A)(memory, args);
        return res;
    }

    T* allocate(T, A...) (A args, string file = __FILE__, int line = __LINE__) if (is(T == struct))
    {
        enum size = T.sizeof;
        void* p = globalAllocator.allocate(size+psize).ptr;
        if (!p)
            onOutOfMemoryError();
        auto memory = p[psize..psize+size];
        *cast(size_t*)p = size;
        _allocatedMemory += size;
        if (memoryProfilerEnabled)
        {
            addRecord(p, T.stringof, size, file, line);
        }
        return emplace!(T, A)(memory, args);
    }

    T allocate(T) (size_t length, string file = __FILE__, int line = __LINE__) if (isArray!T)
    {
        alias AT = ForeachType!T;
        size_t size = length * AT.sizeof;
        auto mem = globalAllocator.allocate(size+psize).ptr;
        if (!mem)
            onOutOfMemoryError();
        T arr = cast(T)mem[psize..psize+size];
        foreach(ref v; arr)
            v = v.init;
        *cast(size_t*)mem = size;
        _allocatedMemory += size;
        if (memoryProfilerEnabled)
        {
            addRecord(mem, T.stringof, size, file, line);
        }
        return arr;
    }
}
else
{
    T allocate(T, A...) (A args) if (is(T == class))
    {
        enum size = __traits(classInstanceSize, T);
        void* p = globalAllocator.allocate(size+psize).ptr;
        if (!p)
            onOutOfMemoryError();
        auto memory = p[psize..psize+size];
        *cast(size_t*)p = size;
        _allocatedMemory += size;
        if (memoryProfilerEnabled)
        {
            addRecord(p, T.stringof, size);
        }
        auto res = emplace!(T, A)(memory, args);
        return res;
    }

    T* allocate(T, A...) (A args) if (is(T == struct))
    {
        enum size = T.sizeof;
        void* p = globalAllocator.allocate(size+psize).ptr;
        if (!p)
            onOutOfMemoryError();
        auto memory = p[psize..psize+size];
        *cast(size_t*)p = size;
        _allocatedMemory += size;
        if (memoryProfilerEnabled)
        {
            addRecord(p, T.stringof, size);
        }
        return emplace!(T, A)(memory, args);
    }

    T allocate(T) (size_t length) if (isArray!T)
    {
        alias AT = ForeachType!T;
        size_t size = length * AT.sizeof;
        auto mem = globalAllocator.allocate(size+psize).ptr;
        if (!mem)
            onOutOfMemoryError();
        T arr = cast(T)mem[psize..psize+size];
        foreach(ref v; arr)
            v = v.init;
        *cast(size_t*)mem = size;
        _allocatedMemory += size;
        if (memoryProfilerEnabled)
        {
            addRecord(mem, T.stringof, size);
        }
        return arr;
    }
}

void deallocate(T)(ref T obj) if (isArray!T)
{
    void* p = cast(void*)obj.ptr;
    size_t size = *cast(size_t*)(p - psize);
    globalAllocator.deallocate((p - psize)[0..size+psize]);
    _allocatedMemory -= size;
    if (memoryProfilerEnabled)
    {
        markDeleted(p);
    }
    obj.length = 0;
}

void deallocate(T)(T obj) if (is(T == class) || is(T == interface))
{
    Object o = cast(Object)obj;
    void* p = cast(void*)o;
    size_t size = *cast(size_t*)(p - psize);
    destroy(obj);
    globalAllocator.deallocate((p - psize)[0..size+psize]);
    _allocatedMemory -= size;
    if (memoryProfilerEnabled)
    {
        markDeleted(p);
    }
}

void deallocate(T)(T* obj)
{
    void* p = cast(void*)obj;
    size_t size = *cast(size_t*)(p - psize);
    destroy(obj);
    globalAllocator.deallocate((p - psize)[0..size+psize]);
    _allocatedMemory -= size;
    if (memoryProfilerEnabled)
    {
        markDeleted(p);
    }
}

/**
  Creates an object of type T and calls its constructor if necessary.

  Description:
  This is an equivalent for D's new opetator. It allocates arrays,
  classes and structs on a heap using currently set globalAllocator.
  Arguments to this function are passed to constructor.

  Examples:
  ----
  MyClass c = New!MyClass(10, 4, 5);
  int[] arr = New!(int[])(100);
  assert(arr.length == 100);
  MyStruct* s = New!MyStruct;
  Delete(c);
  Delete(arr);
  Delete(s);
  ----
 */
alias New = allocate;

/**
  Destroys an object of type T previously created by New and calls
  its destructor if necessary.

  Examples:
  ----
  MyClass c = New!MyClass(10, 4, 5);
  int[] arr = New!(int[])(100);
  assert(arr.length == 100);
  MyStruct* s = New!MyStruct;
  Delete(c);
  Delete(arr);
  Delete(s);
  ----
 */
alias Delete = deallocate;

unittest
{
    auto mem = allocatedMemory();
    int[] arr = New!(int[])(100);
    assert(arr.length == 100);
    assert(allocatedMemory() - mem == uint.sizeof * 100);
    Delete(arr);
    assert(arr.length == 0);

    struct Foo { int a; }
    Foo* foo = New!Foo(10);
    assert(foo.a == 10);
    Delete(foo);
}
