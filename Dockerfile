# Stage 1: Build the application
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /source

# Copy the source code into the container
COPY sharpsnmplib-samples/ ./

# Publish both snmpd and snmptrapd projects into separate publish folders
# Target .NET 9 explicitly so only net9.0 binaries are produced for the runtime image
RUN dotnet publish ./Samples/CSharpCore/snmpd/snmpd.csproj -c Release -f net9.0 -o /app/publish/snmpd \
 && dotnet publish ./Samples/CSharpCore/snmptrapd/snmptrapd.csproj -c Release -f net9.0 -o /app/publish/snmptrapd

# Stage 2: Create the runtime image
FROM mcr.microsoft.com/dotnet/runtime:9.0 AS runtime
WORKDIR /app

# Copy the build artifacts from the previous stage (both apps)
COPY --from=build /app/publish .

# Expose both SNMP ports (agent and trap receiver)
EXPOSE 161/udp
EXPOSE 162/udp

# Metadata indicating an image maintainer
LABEL maintainer="support@lextudio.com"
LABEL description="Docker image for running snmpd and snmptrapd (C# SNMP Daemons)"
LABEL version="1.1"

# Create a small start script that launches both services and handles signals
RUN printf '%s\n' '#!/bin/bash' \
  'set -e' \
  '' \
  '# Start snmptrapd first (listens on UDP 162)' \
  'dotnet /app/snmptrapd/snmptrapd.dll &' \
  'SNMPTRAPD_PID=$!' \
  '' \
  '# Start snmpd (agent) (listens on UDP 161)' \
  'dotnet /app/snmpd/snmpd.dll &' \
  'SNMPD_PID=$!' \
  '' \
  '# Signal handler: forward SIGTERM/SIGINT to both processes' \
  '_term() { echo "Stopping services..."; kill -TERM "$SNMPTRAPD_PID" 2>/dev/null; kill -TERM "$SNMPD_PID" 2>/dev/null; }' \
  'trap _term SIGTERM SIGINT' \
  '' \
  '# Wait for any process to exit and then exit' \
  'wait -n "$SNMPTRAPD_PID" "$SNMPD_PID"' \
  'wait "$SNMPTRAPD_PID" 2>/dev/null || true' \
  'wait "$SNMPD_PID" 2>/dev/null || true' \
  > /app/start.sh \
  && chmod +x /app/start.sh

# Set the container entrypoint to the start script
ENTRYPOINT ["/app/start.sh"]

# Healthcheck: ensure both dotnet processes for snmpd and snmptrapd are running
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s \
  CMD pgrep -f snmptrapd.dll >/dev/null || exit 1 && pgrep -f snmpd.dll >/dev/null || exit 1
