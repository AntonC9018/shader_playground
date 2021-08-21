/*
Copyright (c) 2017-2021 Timur Gafarov

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
 * Allocator based on D's built-in garbage collector
 *
 * Copyright: Timur Gafarov 2017-2021.
 * License: $(LINK2 boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors: Timur Gafarov
 */
module dlib.memory.gcallocator;

import core.exception;
import core.memory;
import std.algorithm.comparison;
import dlib.memory.allocator;

/**
 * Allocator based on D's built-in garbage collector
 */
class GCallocator: Allocator
{
    void[] allocate(size_t size)
    {
        return GC.malloc(size)[0..size];
    }

    bool deallocate(void[] p)
    {
        GC.free(p.ptr);
        return true;
    }

    bool reallocate(ref void[] p, size_t size)
    {
        GC.realloc(p.ptr, size);
        return true;
    }

    @property immutable(uint) alignment() const
    {
        return cast(uint) max(double.alignof, real.alignof);
    }

    static @property GCallocator instance() nothrow
    {
        if (instance_ is null)
        {
            immutable size = __traits(classInstanceSize, GCallocator);
            void* p = GC.malloc(size);

            if (p is null)
            {
                onOutOfMemoryError();
            }
            p[0..size] = typeid(GCallocator).initializer[];
            instance_ = cast(GCallocator)p[0..size].ptr;

        }
        return instance_;
    }

    private static __gshared GCallocator instance_;
}
