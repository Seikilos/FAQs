OTEL_EXPORTER_OTLP_ENDPOINT and Endpoint differences
=========================
As of now these command are _not_ the same:

```csharp
Environment.SetEnvironmentVariable("OTEL_EXPORTER_OTLP_ENDPOINT", "https://server.name");
```

and 

```csharp
 using var tracerProvider = Sdk.CreateTracerProviderBuilder()
    ...
     .AddOtlpExporter(o =>
     {
         o.Endpoint = new Uri("https://server.name");
     })
     ...
```

because setting the Endpoint via code sets `ProgrammaticallyModifiedEndpoint` flag, where then [BaseOtlpHttpExportClient](https://github.com/open-telemetry/opentelemetry-dotnet/blob/f468dd8359f38e883782c9478e7bf7d65e2b866a/src/OpenTelemetry.Exporter.OpenTelemetryProtocol/Implementation/ExportClient/BaseOtlpHttpExportClient.cs#L35C41-L35C73)
does **not** apend `v1/traces` to the uri.

If you really want to set it via code, set the endpoint to `https://server.name/v1/traces`.

**Important:** This is not recommended because it requires internal knowledge. The Env var is preferred.

HyperDx configuration for OpenTelemetry
==============================
This basic configuration works for Logging and Activities. Currently Meters seem to not work

```csharp
Environment.SetEnvironmentVariable("HYPERDX_API_KEY", hyperDxKey);
Environment.SetEnvironmentVariable("OTEL_EXPORTER_OTLP_HEADERS", $"authorization={hyperDxKey}");
Environment.SetEnvironmentVariable("OTEL_EXPORTER_OTLP_ENDPOINT", "https://in-otel.hyperdx.io");
Environment.SetEnvironmentVariable("OTEL_EXPORTER_OTLP_PROTOCOL", "http/protobuf");
Environment.SetEnvironmentVariable("OTEL_LOGS_EXPORTER", "oltp");
Environment.SetEnvironmentVariable("OTEL_LOG_LEVEL", "info");
Environment.SetEnvironmentVariable("OTEL_SERVICE_NAME", "Dummy-test");
```

Nested activity example with these env vars above (samples taken from OpenTelemetry)
---------------------
The only thing added is `options.AddConsoleExporter();` and it worked out of the box

```csharp
using var tracerProvider = Sdk.CreateTracerProviderBuilder()
    .AddSource(serviceName)
    .SetResourceBuilder(
        ResourceBuilder.CreateDefault()
            .AddService(serviceName, serviceVersion: serviceVersion))
    .AddOtlpExporter()
    .AddConsoleExporter()
    .Build();


using var source = new ActivitySource(serviceName);
{
    using var parentActivity = source.StartActivity("ParentActivity");

    // Do some work tracked by parentActivity

    using (var childActivity = source.StartActivity("ChildActivity"))
    {
        // Do some "child" work in the same function
    }
}

```

Logging with these env vars above (samples taken from OpenTelemetry)
------------------------------
Note: These samples are broken because the log strings do not use string interpolation (`$"str"`) but the args are reported as separate parameters, which is actually better for queries.
Also hint: The only thing added is `options.AddConsoleExporter();` and it worked out of the box
```csharp
 using var loggerFactory = LoggerFactory.Create(builder =>
 {
     builder.AddOpenTelemetry(options =>
     {
         options.IncludeScopes = true;
         options.SetResourceBuilder(ResourceBuilder.CreateDefault().AddService(
             serviceName: "MyService",
             serviceVersion: "1.0.0"));
         options.AddConsoleExporter();
         options.AddOtlpExporter();
     });
 });

 var logger = loggerFactory.CreateLogger<Program>();

 logger.LogInformation("Hello from {name} {price}.", "tomato", 2.99);
 logger.LogWarning("Hello from {name} {price}.", "tomato", 2.99);
 logger.LogError("Hello from {name} {price}.", "tomato", 2.99);

 using (logger.BeginScope(new List<KeyValuePair<string, object>>
        {
            new KeyValuePair<string, object>("store", "Seattle"),
        }))
 {
     logger.LogInformation("Hello from {food} {price}.", "tomato", 2.99);
     logger.LogInformation("Hello from {food} {price}.", "tomato", 2.99);
     logger.LogInformation("Hello from {food} {price}.", "tomato", 2.99);
 }
```


