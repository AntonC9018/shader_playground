module main;

void main(string[] args)
{

    import shaderplayground.initialization : initialize, shutdown;
    import shaderplayground.app : run;

    initialize();
    run();
    shutdown();
}