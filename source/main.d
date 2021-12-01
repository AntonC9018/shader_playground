module main;

void main(string[] args)
{
    import shaderplayground.initialization : initialize, shutdown;


    // TODO: Load from dll. Should be pretty easy too.

    initialize();
    import std.stdio;
    string appname;
    if (args.length < 2)
        appname = "abstract";
    else
        appname = args[1];

    switch (appname)
    {
        case "diagram": 
        {
            import diagram : App;
            run([new App()]);
            break;
        }
        case "cloth": 
        {
            import cloth : App;
            run([new App()]);
            break;
        }
        case "cloth2": 
        {
            import cloth2 : App;
            run([new App()]);
            break;
        }
        case "abstract": 
        {
            import abstract_thing : App;
            run([new App()]);
            break;
        }
        default: 
        {
            import app : App;
            run([new App()]);
            break;
        }
    }
    shutdown();
}

import shaderplayground.userutils : IApp;
import shaderplayground.globals;

void run(IApp[] apps)
{
    import shaderplayground;
    import std.exception : enforce;
    
    foreach (a; apps)
		a.setup();
    g_TextDrawer.setup();

    double time = glfwGetTime();

    import fswatch;
    import std.path;
    import std.array;
    import std.stdio;

    bool recursive = true;
    string sourceFolder = "../source";
    FileWatch sourceFolderWatcher = FileWatch(sourceFolder, recursive);
    string absoluteNormalizedWatchedPath = sourceFolder.absolutePath.asNormalizedPath.array;

    bool processFileEvents(ref FileWatch watcher)
    {
        foreach (event; watcher.getEvents())
        {
            if (event.type == FileChangeEventType.modify)
            {
                string path = buildNormalizedPath(absoluteNormalizedWatchedPath, event.path);
                // if (isAbsolute(name))
                //     path = name;
                // else
                //     path = buildPath(absoluteNormalizedWatchedPath, name);
                // assert(asNormalizedPath(path).array == path);
                
                g_SourceFilesHotreloadProvider.fileModified(path);
            }
        }
        return true;
    }

    while (!glfwWindowShouldClose(g_Window))
    {
        processFileEvents(sourceFolderWatcher);

        glfwPollEvents();
        glViewport(0, 0, g_CurrentWindowDimensions.width, g_CurrentWindowDimensions.height);

        double dt = glfwGetTime() - time;
        time = glfwGetTime();

        g_Camera.update(dt);

        ImguiImpl.NewFrame();
        if (ImGui.Begin("Main Window"))
        {
            ImGui.Text("User-defined uniforms");
            foreach (a; apps)  a.doImgui();
            ImGui.Separator();

            g_Camera.onGUI();
        }
        g_Camera.active = !ImGui.IsWindowFocused(ImGuiFocusedFlags_AnyWindow);
        ImGui.End();
        ImGui.Render();

        glfwMakeContextCurrent(g_Window);
        glClear(GL_COLOR_BUFFER_BIT);
        glClear(GL_DEPTH_BUFFER_BIT);
        glEnable(GL_DEPTH_TEST);

        foreach (a; apps)  a.loop(dt);

        ImguiImpl.RenderDrawData(ImGui.GetDrawData());

        glfwMakeContextCurrent(g_Window);
        glfwSwapBuffers(g_Window);
    }

    foreach (a; apps)
    {
        if (auto t = cast(ITerminate) a)
            t.terminate();
    }
}