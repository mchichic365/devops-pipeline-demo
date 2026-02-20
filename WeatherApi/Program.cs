var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers();

var app = builder.Build();

app.Use(async (context, next) =>
{
    WeatherApi.Controllers.MetricsController.IncrementRequests();
    await next();
});

app.MapControllers();

app.Run();