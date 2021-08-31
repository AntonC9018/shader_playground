module main;

void main(string[] args)
{

    import shaderplayground.initialization : initialize, shutdown;
    import shaderplayground.app : App;

    initialize();
    run(new App());
    shutdown();
}

void run(TApp)(TApp app)
{
    import shaderplayground;
    import std.exception : enforce;
    
    app.setup();

    double time = glfwGetTime();


    while (!glfwWindowShouldClose(g_Window))
    {
        glfwPollEvents();
        
        double dt = glfwGetTime() - time;
        time = glfwGetTime();

        g_Camera.update(dt);

        ImguiImpl.NewFrame();
        if (ImGui.Begin("Main Window"))
        {
            ImGui.Text("User-defined uniforms");
            doImgui(&app.uniforms);
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

        app.loop(dt);

		ImguiImpl.RenderDrawData(ImGui.GetDrawData());

		glfwMakeContextCurrent(g_Window);
		glfwSwapBuffers(g_Window);
    }
}