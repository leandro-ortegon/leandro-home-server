# USUARIO HOME SERVER
**Personal Home Infrastructure & IoT Server**

Servidor doméstico 24/7 basado en una Orange Pi PC Plus V1.1 que centraliza la domótica (ESP32 + MQTT), el almacenamiento en red, la monitorización y las copias de seguridad. Se administra de forma remota desde un ASUS Vivobook 16 con Windows 11.

> Estado del proyecto: **✅ PROYECTO COMPLETADO: Etapas 1–11 verificadas el 2026-11-13**. Última actualización: 2026-11-13.

---

## 1. Hardware

| Componente | Detalle |
|---|---|
| Placa | Orange Pi PC Plus V1.1 (Allwinner H3, 4× Cortex-A7, armv7l, 32 bits) |
| RAM | 1 GB DDR3 (991 MiB visibles) + 496 MiB de swap zram |
| Sistema | microSD de 32 GB (`mmcblk0`, ext4) |
| eMMC | 8 GB (`mmcblk2`): contiene la imagen original de fábrica (sin uso) |
| HDD | 1 TB ST1000LM024 (2,5") por USB-SATA JMicron JM20329 → ext4 en `/srv/servidor` |
| Red | WiFi (`wlan1`, activa), Ethernet 100 Mbps (`end0`, inactiva) |

Más detalles en [docs/hardware.md](docs/hardware.md).

## 2. Software

| Software | Versión | Estado |
|---|---|---|
| Armbian community (Debian 13 trixie) | 26.11.0-trunk.120 (nightly) | Funcionando |
| Kernel | 6.18.60-current-sunxi | Funcionando |
| Mosquitto | 2.0.21 | Activo, usuarios por cliente + ACL |
| Node-RED | 5.0.9 (Node.js v22.15.0) | Activo; editor con contraseña, credenciales cifradas; dashboard abierto en LAN/Tailscale |
| Node-RED Dashboard 2.0 | 1.36.1 | Activo en `/dashboard` |
| log2ram | — | Activo (`/var/log` en RAM, 50 MB) |
| Samba | 4.22.11 | Activo, SMB3, sin invitados |
| Tailscale | 1.104.7 | `usuario-home-server` · x.x.x.x |
| UFW | Debian | Activo: LAN + Tailscale |
| Taildrop | servicio `taildrop-recibir` | Archivos del celular/ASUS → `Z:\Taildrop` |
| SQLite | 3.49.1 (node:sqlite) / CLI 3.46.1 | Historial en `/srv/servidor/bases_datos/domotica.db` |

## 3. Arquitectura

```
ESP32 + DHT22 + OLED + Relés
        │  WiFi / MQTT (1883)
        ▼
┌──────────────── ORANGE PI PC PLUS ────────────────┐
│  Mosquitto ──► Node-RED ──► Base de datos (HDD)    │
│                   │                                │
│                   └──► Dashboard 2.0 (panel web)   │
│  Samba (NAS)   Tailscale (VPN)   Backups (HDD)     │
└───────────────────────────────────────────────────┘
        ▲
        │ SSH / Navegador / Explorador de archivos
   ASUS Vivobook 16 · Celular
```

Ver [docs/arquitectura.md](docs/arquitectura.md).

## 4. Direcciones de acceso (LAN)

| Servicio | Dirección | Notas |
|---|---|---|
| SSH | `ssh usuario@x.x.x.x` | Llave; contraseña solo como emergencia en la LAN |
| Node-RED (editor) | http://x.x.x.x:1880 | Requiere usuario |
| Dashboard | http://x.x.x.x:1880/dashboard | Sin contraseña (solo LAN/Tailscale) |
| Panel del servidor | http://x.x.x.x:1880/dashboard/servidor | CPU, RAM, temperatura, discos, servicios |
| MQTT | `x.x.x.x:1883` | Requiere usuario/contraseña |
| Samba | `\\x.x.x.x\archivos` · `compartido` · `backups` | Unidad Z: = archivos |

> ⚠️ La IP la asigna el router por DHCP. Conviene reservarla en el router.

### Fuera de casa (Tailscale)
| Servicio | Dirección |
|---|---|
| SSH | `ssh usuario@usuario-home-server` |
| Dashboard | http://usuario-home-server:1880/dashboard |
| Samba | `\\usuario-home-server\archivos` |
| Enviar archivos | Compartir → Tailscale → usuario-home-server (llegan a `Z:\Taildrop`) |

## 5. Plan de etapas

| # | Etapa | Estado |
|---|---|---|
| 1 | Diagnóstico del servidor | ✅ Completada |
| 2 | Configuración permanente del HDD | ✅ Completada |
| 3 | NAS con Samba | ✅ Completada |
| 4 | Seguridad MQTT | ✅ Completada |
| 5 | Node-RED + MQTT | ✅ Completada (seguridad e integración) |
| 6 | Base de datos (SQLite) | ✅ Completada |
| 7 | Dashboard de monitorización | ✅ Completada |
| 8 | Acceso remoto (Tailscale) + firewall + SSH | ✅ Completada |
| 9 | Copias de seguridad | ✅ Completada |
| 10 | Integración de ESP32 | ✅ Completada |
| 11 | Pruebas y documentación final | ✅ Completada |

## 6. Documentación

- 🆘 [docs/solucion-problemas.md](docs/solucion-problemas.md) ← **empieza aquí si algo falla**
- [docs/hardware.md](docs/hardware.md)
- [docs/arquitectura.md](docs/arquitectura.md)
- [docs/red.md](docs/red.md)
- [docs/almacenamiento.md](docs/almacenamiento.md)
- [docs/samba.md](docs/samba.md)
- [docs/mqtt.md](docs/mqtt.md)
- [docs/nodered.md](docs/nodered.md)
- [docs/base-datos.md](docs/base-datos.md)
- [docs/monitorizacion.md](docs/monitorizacion.md)
- [docs/acceso-remoto.md](docs/acceso-remoto.md)
- [docs/backups.md](docs/backups.md)
- [docs/esp32.md](docs/esp32.md)
- [docs/taildrop.md](docs/taildrop.md)
- [docs/seguridad.md](docs/seguridad.md)
- [docs/mantenimiento.md](docs/mantenimiento.md)
- [scripts/diagnostico_etapa1.sh](scripts/diagnostico_etapa1.sh)
- [scripts/estado-servidor.sh](scripts/estado-servidor.sh)
- [scripts/backup-servidor.sh](scripts/backup-servidor.sh)
- [scripts/verificacion-final.sh](scripts/verificacion-final.sh)

## 7. Verificación final (2026-11-13 19:07)
| Área | Resultado |
|---|---|
| Servicios (ssh, mosquitto, nodered, smbd, tailscaled, ufw, backup timer) | ✅ Activos |
| HDD `/srv/servidor` | ✅ Montado, 907 GB libres |
| Recursos en reposo | ✅ 798 MB de RAM disponibles · 46–50 °C · carga 0 |
| Tailscale | ✅ Servidor, ASUS (conexión directa) y celular A72 |
| Editor Node-RED | ✅ 401 sin sesión |
| MQTT | ✅ Usuarios usuario, nodered y esp32-habitacion · ESP32 `online` |
| SQLite | ✅ 190 lecturas, 11 eventos, 6 cambios de relé |
| Backups | ✅ Primera copia OK · próxima a las 03:15 |
| SSH | ✅ root no, contraseña solo en la LAN |
| Kernel/u-boot | ✅ Congelados |

Comando de auditoría completo: [`scripts/verificacion-final.sh`](scripts/verificacion-final.sh).

## 8. Pendientes recomendados
1. **Reservar la IP x.x.x.x** para la Orange Pi en el router (reserva DHCP por MAC); el ESP32 la usa fija.
2. **Rotar credenciales** compartidas en texto: token de Telegram (@BotFather `/revoke`), credenciales de Sinric Pro y `OTA_CLAVE`.
3. **Regla 3-2-1:** copiar periódicamente `\\usuario-home-server\backups` fuera del servidor.
4. **Sensor:** valorar el cambio de DHT11 a DHT22 (más preciso en humedad).
5. Opcional: contraseña en el dashboard (`httpNodeAuth`) si se comparte el WiFi con más personas.
6. Opcional: desinstalar `node-red-node-pi-gpio` (solo Raspberry Pi).
7. Guardar fuera del servidor: la `credentialSecret` de Node-RED y la llave SSH `id_ed25519` del ASUS.

## 9. Reglas del proyecto

1. No reinstalar Armbian, Mosquitto ni Node-RED.
2. No formatear el HDD ni tocar particiones sin autorización explícita.
3. Respaldar toda configuración antes de modificarla (`archivo.bak-AAAAMMDD`).
4. No avanzar de etapa sin verificar la anterior.
5. Usar solo software compatible con armv7l (32 bits) y 1 GB de RAM.
