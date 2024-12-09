# C# SNMP snmpd Daemon

This docker image starts up C# SNMP snmpd sample.

The UDP port `161` should be mapped to the desired SNMP port.

## Usage

``` shell
docker run -p 161:161/udp ghcr.io/lextudio/docker-snmpd-sharpsnmp:main
```

## Bug Reports

Issues about this image should be reported to [LeXtudio Inc.](support@lextudio.com).
