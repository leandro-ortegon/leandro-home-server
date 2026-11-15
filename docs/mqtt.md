# MQTT: Mosquitto (Etapa 4)

## Estado
- Mosquitto 2.0.21 (paquete Debian, armhf), puerto 1883 (LAN + Tailscale; no expuesto a internet).
- Persistencia: `/var/lib/mosquitto/mosquitto.db`.
- Registro: `/var/log/mosquitto/mosquitto.log` (log2ram, rotado por logrotate: 7 días o 100 KB, comprimido).
- Config: `/etc/mosquitto/mosquitto.conf` + `/etc/mosquitto/conf.d/domotica.conf` (ver `configuraciones/`).

## Archivos y permisos
| Archivo | Dueño | Permisos |
|---|---|---|
| `/etc/mosquitto/passwd` | root:mosquitto | 640 |
| `/etc/mosquitto/acl` | root:mosquitto | 640 |
| Respaldos | `passwd.bak-20261113`, `conf.d/domotica.conf.bak-20261113` | |

> `mosquitto_passwd` avisa de "group is not root": se mantiene el grupo `mosquitto` porque el broker necesita leer el archivo al hacer `reload`.

## Usuarios
| Usuario | Cliente | Permisos |
|---|---|---|
| `leandro` | Administración/pruebas | `#` lectura y escritura, `$SYS/#` lectura |
| `nodered` | Node-RED | `domotica/#` lectura y escritura |
| `esp32-habitacion` | ESP32 de la habitación | escribe `domotica/habitacion/estado` y `domotica/habitacion/conexion`, lee `domotica/habitacion/luz/set` |

Las contraseñas **no** se guardan en esta documentación.

## Tópicos en uso
| Tópico | Publica | Contenido |
|---|---|---|
| `domotica/habitacion/estado` | ESP32 cada 10 s | JSON: `temp`, `hum`, `luz`, `rssi`, `heap_libre`, `heap_min`, `heap_total`, `cpu_mhz`, `cpu0`, `cpu1`, `uptime` |
| `domotica/habitacion/luz/set` | Node-RED | Orden del relé de la luz |
| `domotica/habitacion/conexion` | ESP32 / LWT (retenido) | `online` / `offline` |
| `domotica/servidor/estado` | Node-RED cada 30 s (retain) | JSON con el estado del servidor (ver monitorizacion.md) |

Convención para nuevos dispositivos: `domotica/<zona>/<recurso>[/set]`.

## Pruebas realizadas (2026-11-13)
| Prueba | Resultado |
|---|---|
| Credenciales incorrectas | Rechazadas ("not authorised") ✅ |
| `nodered` publica en `domotica/prueba` | Recibido ✅ |
| `esp32-habitacion` publica en `domotica/prueba` | Bloqueado por la ACL ("Timed out") ✅ |
| ESP32 y Node-RED tras activar la ACL | Reconectados y enviando datos ✅ |

## Comandos útiles
```bash
# escuchar todo lo de la casa (espacio inicial = no guardar en historial)
 mosquitto_sub -h localhost -u leandro -P '****' -t 'domotica/#' -v
# añadir/cambiar usuario (NUNCA usar -c)
sudo mosquitto_passwd /etc/mosquitto/passwd <usuario> && sudo systemctl reload mosquitto
sudo tail -f /var/log/mosquitto/mosquitto.log
```

## Pendiente de migración
1. ~~Node-RED → usuario `nodered` (Etapa 5).~~ ✅ 2026-11-13
2. ~~ESP32 → usuario `esp32-habitacion` (Etapa 10).~~ ✅
3. ~~Eliminar el usuario `esp32` y su bloque en la ACL.~~ ✅ Migración completada.
