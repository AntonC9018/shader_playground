module mmain;

void main(string[] args)
{

    import initialization;
    import app;

    initialization.initialize();
    app.run();
    initialization.shutdown();
}