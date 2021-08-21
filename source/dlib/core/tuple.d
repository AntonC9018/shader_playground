/*
Copyright (c) 2011-2021 Timur Gafarov

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
 * Templates that construct tuples of numeric values
 *
 * Copyright: Timur Gafarov 2011-2021.
 * License: $(LINK2 https://boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors: Timur Gafarov
 */
module dlib.core.tuple;

/// Create a tuple
template Tuple(E...)
{
    alias Tuple = E;
}

/// Yields a tuple of integer literals from 0 to stop
template RangeTuple(int stop)
{
    static if (stop <= 0)
        alias RangeTuple = Tuple!();
    else
        alias RangeTuple = Tuple!(RangeTuple!(stop-1), stop-1);
}

/// Yields a tuple of integer literals from start to stop
template RangeTuple(int start, int stop)
{
    static if (stop <= start)
        alias RangeTuple = Tuple!();
    else
        alias RangeTuple = Tuple!(RangeTuple!(start, stop-1), stop-1);
}

/// Yields a tuple of integer literals from start to stop with defined step
template RangeTuple(int start, int stop, int step)
{
    static assert(step != 0, "RangeTuple: step must be != 0");

    static if (step > 0)
    {
        static if (stop <= start)
            alias RangeTuple = Tuple!();
        else
            alias RangeTuple = Tuple!(RangeTuple!(start, stop-step, step), stop-step);
    }
    else
    {
        static if (stop >= start)
            alias RangeTuple = Tuple!();
        else
            alias RangeTuple = Tuple!(RangeTuple!(start, stop-step, step), stop-step);
    }
}
