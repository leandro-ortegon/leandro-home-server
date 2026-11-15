# Integración ESP32 (Etapa 10)

## Dispositivo: `esp32-habitacion`
| Elemento | Valor |
|---|---|
| Placa | ESP32 DevKit V1 (ESP32-WROOM-32), 240 MHz, 2 núcleos |
| Sensor | **DHT11** en G4 (precisión ±2 °C / ±5 % HR; el DHT22 sería más preciso) |
| Pantalla | OLED SSD1306 128x64, I2C 0x3C (SDA G21, SCL G22) |
| Relé | G26, activo en HIGH, circuito conmutado (3 vías) |
| Integraciones | MQTT (Orange Pi), Google Home (Sinric Pro), Telegram, OTA (`domotica-habitacion`) |
| Firmware | `esp32_domotica_habitacion.ino` v3 |

## MQTT
| Tópico | Dirección | Contenido |
|---|---|---|
| `domotica/habitacion/estado` | ESP32 → servidor, cada 10 s | JSON: temp, hum, cpu_mhz, cpu0, cpu1, heap_libre, heap_min, heap_total, rssi, luz, uptime |
| `domotica/habitacion/conexion` | ESP32 / broker (LWT), retenido | `online` al conectar · `offline` si desaparece (unos 22 s, keepalive 15 s × 1,5) |
| `domotica/habitacion/luz/set` | servidor → ESP32 | `ON` / `OFF` / `TOGGLE` |

Conexión: usuario `esp32-habitacion`, client-id `esp32-habitacion`, keepalive 15 s, LWT QoS 1 retenido.

```cpp
mqtt.connect("esp32-habitacion", MQTT_USUARIO, MQTT_CLAVE,
             MQTT_TEMA_CONEXION, 1, true, "offline");
mqtt.publish(MQTT_TEMA_CONEXION, "online", true);
```

## Node-RED
- Flujo [`flujo-conexion-esp32.json`](../configuraciones/nodered/flujo-conexion-esp32.json): `mqtt in conexion` → "Indicador + evento" → texto **ESP32 🟢/🔴** en el grupo *Sistema ESP32*; cada cambio se registra en `eventos` (SQLite).

## Pruebas (2026-11-13)
| Prueba | Resultado |
|---|---|
| Conexión con el usuario nuevo | ✅ `online` + datos de estado |
| Desconectar la alimentación | ✅ `offline` publicado por Mosquitto (LWT) |
| Usuario compartido `esp32` | ✅ Eliminado de `passwd` y de la ACL |
| Indicador en el dashboard | ✅ |

## Plantilla para un ESP32 nuevo (ej. `esp32-sala`)
1. Servidor:
   ```bash
   sudo mosquitto_passwd /etc/mosquitto/passwd esp32-sala
   sudo tee -a /etc/mosquitto/acl > /dev/null <<'FIN'

   user esp32-sala
   topic write domotica/sala/estado
   topic write domotica/sala/conexion
   topic read domotica/sala/+/set
   FIN
   sudo systemctl reload mosquitto
   sqlite3 /srv/servidor/bases_datos/domotica.db "INSERT INTO dispositivos (id, zona, descripcion) VALUES ('esp32-sala','sala','...');"
   ```
2. Firmware: cambiar `MQTT_USUARIO`, client-id, tópicos (`domotica/sala/...`) y `OTA_NOMBRE`.
3. Node-RED: duplicar los flujos de la habitación cambiando los tópicos y el nombre del dispositivo en "Guardar historial".

## Pendientes recomendados
- Rotar el token de Telegram (@BotFather `/revoke`) y las credenciales de Sinric Pro (se compartieron en texto).
- Cambiar `OTA_CLAVE` por una clave propia.
- Reservar la IP 192.168.1.9 para la Orange Pi en el router (el firmware la usa fija).
- Valorar el cambio de DHT11 a DHT22 (cambiar `DHT_TYPE` a `DHT22`).
