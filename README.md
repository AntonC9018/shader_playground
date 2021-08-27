# Shaders Playground

A sandbox project for me to experiment with shaders.

![Screenshot](screenshot.png)

It's tedious to do shaders in C or C++, because you will end up writing a lot more boilerplate or commenting lines in and out as you change the shader code. In a typical application, the uniforms will be bound by their names, for any new custom uniform a new imgui function call must be added and stuff like that. This distracted me when I did my [opengl_experiments](https://github.com/AntonC9018/opengl_experiments).

Now, in D, metaprogramming is a thing, and it's actually trivial to use. Via metaprogramming, the tediuos tasks can be simplified or entirely eliminated, which helps focus on the actual work — the shader code. Plus, D is a hell of a lot more enjoyable and simple than C++, and it compiles faster.