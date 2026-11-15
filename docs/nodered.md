# Node-RED (Etapa 5)

## Estado
| Elemento | Valor |
|---|---|
| Versión | Node-RED 5.0.9 · Node.js v22.15.0 · npm 10.9.2 |
| Servicio | `nodered.service` (usuario `leandro`), unos 130 MB de RAM |
| Directorio | `/home/leandro/.node-red` |
| Editor | http://192.168.1.9:1880 (`adminAuth`, usuario `leandro`) → 401 sin sesión ✅ |
| Dashboard 2.0 | http://192.168.1.9:1880/dashboard · **sin contraseña por decisión del usuario** (accesible solo desde la LAN y Tailscale gracias a UFW) |
| Credenciales | Cifradas (`credentialSecret`) ✅ |
| MQTT | Nodo de configuración "Mosquitto local" → `localhost:1883`, usuario `nodered` ✅ |

## Nodos instalados
`@flowfuse/node-red-dashboard` 1.36.1, `node-red-contrib-buffer-parser`, `node-red-contrib-play-audio`,
`node-red-node-ping`, `node-red-node-random`, `node-red-node-serialport`, `node-red-node-smooth`,
`node-red-node-pi-gpio` (solo Raspberry Pi; no sirve en Orange Pi, candidato a desinstalar).

## Flujo "Domótica habitación"
- `mqtt in` **Estado ESP32** (`domotica/habitacion/estado`, JSON) → función **Separar datos** → widgets del dashboard.
- Botón **Conmutar luz** → `mqtt out` **Orden a la luz** (`domotica/habitacion/luz/set`).

## Cambios realizados (2026-11-13)
```bash
# respaldo previo
sudo tar --exclude=node_modules -czf /srv/servidor/backups/nodered-20261113.tar.gz -C /home/leandro .node-red
# 1. cifrado de credenciales (clave guardada FUERA del repositorio)
#    settings.js: credentialSecret: "<clave de 48 hex>"   (respaldo settings.js.bak-20261113)
# 2. autenticación del dashboard: NO aplicada (decisión del usuario, 2026-11-13)
# 3. broker MQTT en la interfaz: usuario esp32 → nodered, y Deploy
```

> ⚠️ Sin la `credentialSecret`, un `flows_cred.json` restaurado no se puede descifrar. Guárdala en un gestor de contraseñas.

## Verificación
```bash
curl -s -o /dev/null -w '%{http_code}\n' http://localhost:1880/flows       # 401
curl -s -o /dev/null -w '%{http_code}\n' http://localhost:1880/dashboard/  # 200 (sin contraseña, por decisión)
head -c 120 ~/.node-red/flows_cred.json                                   # {"$": "..."}  cifrado
journalctl -u nodered -n 30 --no-pager
```
