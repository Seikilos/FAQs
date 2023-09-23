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
