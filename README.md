# C# SNMP snmpd Daemon

This docker image starts up the C# SNMP `snmpd` sample and also includes `snmptrapd` (an SNMP trap receiver).

The UDP ports `161` (SNMP) and `162` (SNMP traps) should be mapped to the desired host ports.

## Usage

``` shell
docker run -p 161:161/udp -p 162:162/udp ghcr.io/lextudio/docker-snmpd-sharpsnmp:main
```

## Environment variables

You can disable the built-in trap listener (`snmptrapd`) by setting the `SNMPTRAPD_ENABLED` environment variable to `0` or `false` when starting the container. By default the trap listener is enabled.

Disable trap listener example (only run `snmpd`):

``` shell
docker run -e SNMPTRAPD_ENABLED=0 -p 161:161/udp ghcr.io/lextudio/docker-snmpd-sharpsnmp:main
```

## Bug Reports

Issues about this image should be reported to [LeXtudio Inc.](support@lextudio.com).
