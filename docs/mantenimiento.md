# Mantenimiento

## Comandos de verificación rápida
```bash
uptime && free -h                                   # carga y memoria
cat /sys/class/thermal/thermal_zone0/temp           # temperatura (m°C)
df -hT -x tmpfs -x devtmpfs                         # espacio en disco
systemctl status mosquitto nodered --no-pager       # servicios
sudo ss -tulpn                                      # puertos abiertos
journalctl -p err -b --no-pager | tail -30          # errores desde el arranque
```

## Diagnóstico completo
```bash
sudo bash ~/diagnostico_etapa1.sh 2>&1 | tee ~/diagnostico_$(date +%F).txt
# auditoría rápida de todos los servicios:
bash verificacion-final.sh   # ver scripts/
```

## Copias de seguridad
Automáticas a diario a las 03:15. Ver [backups.md](backups.md).

## Notas
- `/var/log` está en RAM (log2ram, 50 MB). Los registros grandes, como los de Mosquitto o el histórico, deben ir al HDD (`/srv/servidor/registros`).
- La imagen es nightly: antes de un `apt full-upgrade`, revisar qué paquetes de kernel y bootloader se van a actualizar.

## Bitácora
| Fecha | Etapa | Acción |
|---|---|---|
| 2026-11-13 | 1 | Diagnóstico completo del servidor |
| 2026-11-13 | 2 | HDD reformateado a ext4 (1 partición), montaje por UUID en `/srv/servidor`, estructura de carpetas, prueba de reinicio OK |
| 2026-11-13 | 3 | Congelados kernel/u-boot/firmware/bsp (apt-mark hold). Samba 4.22.11 instalado: recursos archivos, compartido, backups (ro). SMB3_11 verificado |
| 2026-11-13 | 4 | Mosquitto: usuarios leandro/nodered/esp32-habitacion, ACL, passwd root:mosquitto 640, timestamps legibles. Pruebas de ACL OK |
| 2026-11-13 | 5 | Node-RED: credentialSecret, httpNodeAuth en el dashboard, broker MQTT con usuario nodered. Respaldo en backups/nodered-20261113.tar.gz |
| 2026-11-13 | 6 | SQLite: domotica.db (4 tablas), node:sqlite en functionGlobalContext, flujo 'Guardar historial' (promedio cada 60 s) |
| 2026-11-13 | 7 | estado-servidor.sh + página Servidor en el Dashboard + MQTT domotica/servidor/estado |
| 2026-11-13 | 8 | Tailscale 1.104.7 (leandro-home-server, 100.76.238.119), UFW activo con red de seguridad systemd-run |
| 2026-11-13 | 8 | SSH: llave ed25519, root deshabilitado, contraseña solo en la LAN. Etapa 8 cerrada |
| 2026-11-13 | 9 | backup-servidor.sh + timer systemd 03:15; rotación 7/4/6; primera copia 516 KB OK |
| 2026-11-13 | 10 | ESP32 con usuario esp32-habitacion + LWT; usuario esp32 eliminado; indicador 🟢/🔴 en el dashboard |
| 2026-11-13 | 11 | Auditoría final OK. ufw habilitado al arranque. Dashboard sin contraseña por decisión del usuario. Proyecto cerrado |
| 2026-11-13 | Extra | Taildrop: servicio taildrop-recibir → archivos/Taildrop; operator=leandro; libheif-examples y webp instalados; cámara del celular en JPG |
