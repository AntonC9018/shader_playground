module main;

void main(string[] args)
{
    import shaderplayground.initialization : initialize, shutdown;

    // TODO: Load from dll. Should be pretty easy too.
    import diagram : App;

    initialize();
    run([new App()]);
    shutdown();
}

import shaderplayground.app : IApp;

void run(IApp[] apps)
{
    import shaderplayground;
    import std.exception : enforce;
    
    foreach (a; apps)  a.setup();
    g_TextDrawer.setup();

    double time = glfwGetTime();


    while (!glfwWindowShouldClose(g_Window))
    {
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
}