# Stage 1: Build the application
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /source

# Copy the source code into the container
COPY sharpsnmplib-samples/ ./

# Change to the directory that contains the project file
WORKDIR /source/Samples/CSharpCore/snmpd

# Restore dependencies
RUN dotnet restore

# Build the application
RUN dotnet publish -c Release -o /app/publish

# Stage 2: Create the runtime image
FROM mcr.microsoft.com/dotnet/runtime:8.0 AS runtime
WORKDIR /app

# Copy the build artifacts from the previous stage
COPY --from=build /app/publish .

# Expose the port that the application will run on (optional, change as necessary)
EXPOSE 161/udp

# Metadata indicating an image maintainer
LABEL maintainer="support@lextudio.com"
LABEL description="Docker image for running snmpd (C# SNMP Daemon)"
LABEL version="1.0"

# Set the entrypoint for the application
ENTRYPOINT ["dotnet", "snmpd.dll"]

# Optional: Add a health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s \
  CMD pgrep dotnet || exit 1
