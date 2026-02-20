# Build stage - SDK image has all the compilation tools
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj first - Docker caches this layer
# Dependencies only re-download if csproj changes
COPY WeatherApi/*.csproj ./WeatherApi/
RUN dotnet restore WeatherApi/WeatherApi.csproj

# Copy everything else and build
COPY WeatherApi/ ./WeatherApi/
RUN dotnet publish WeatherApi/WeatherApi.csproj \
    -c Release -o /app/publish --no-restore

# Runtime stage - minimal image, no SDK bloat
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS runtime
WORKDIR /app

# Non-root user - required by Pod Security Standards
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD wget -qO- http://localhost:8080/health || exit 1

ENTRYPOINT ["dotnet", "WeatherApi.dll"]