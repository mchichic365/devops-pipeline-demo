using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;

namespace WeatherApi.Controllers;

[ApiController]
[Route("[controller]")]
public class MetricsController : ControllerBase
{
    private static long _requestCount = 0;
    private static readonly DateTime _startTime = DateTime.UtcNow;

    public static void IncrementRequests() =>
        Interlocked.Increment(ref _requestCount);

    [HttpGet]
    public IActionResult Get()
    {
        var uptime = DateTime.UtcNow - _startTime;
        // Prometheus text format - industry standard
        var metrics = $"""
            # HELP app_requests_total Total requests served
            # TYPE app_requests_total counter
            app_requests_total {_requestCount}
            # HELP app_uptime_seconds Application uptime
            # TYPE app_uptime_seconds gauge
            app_uptime_seconds {uptime.TotalSeconds:F0}
            # HELP app_memory_bytes Current memory usage
            # TYPE app_memory_bytes gauge
            app_memory_bytes {Process.GetCurrentProcess().WorkingSet64}
            """;
        return Content(metrics.Trim(), "text/plain");
    }
}