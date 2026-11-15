# Arquitectura

```
                 ┌──────────────────────────────┐
  ESP32 (n) ───► │  Mosquitto 2.0.21  :1883     │
  casa/<zona>/<dispositivo>/<medida>            │
                 │        │                     │
                 │        ▼                     │
                 │  Node-RED  :1880             │──► Dashboard 2.0 (/dashboard)
                 │        │                     │
                 │        ▼                     │
                 │  SQLite en HDD               │
                 │  /srv/servidor/bases_datos   │
                 └──────────────────────────────┘
                    Samba · Tailscale · Backups
```

## Decisiones técnicas (borrador, se confirman en cada etapa)
| Necesidad | Elección | Motivo |
|---|---|---|
| Base de datos | SQLite | Sin servidor ni RAM residente. InfluxDB 2.x no soporta 32 bits y MariaDB es excesiva para este volumen. |
| Panel IoT | Node-RED Dashboard 2.0 | Ya instalado; no consume RAM adicional. |
| Panel del sistema | Dashboard 2.0 + Cockpit opcional | Cockpit se activa por socket y solo consume RAM mientras se usa. Netdata es demasiado pesado para 1 GB. |
| Acceso remoto | Tailscale | Tiene paquete armhf y no requiere abrir puertos. |
| NAS | Samba | Integración nativa con Windows. |

## Convención de tópicos MQTT (adoptada)
Se conserva el prefijo `domotica/` que ya usaban el ESP32 y Node-RED:
```
domotica/<zona>/estado        JSON de telemetría del dispositivo
domotica/<zona>/<recurso>/set orden (p. ej. domotica/habitacion/luz/set)
```
Ver [mqtt.md](mqtt.md).
