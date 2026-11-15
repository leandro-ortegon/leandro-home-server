# Seguridad

## Línea base (Etapa 1)
| Control | Estado | Riesgo |
|---|---|---|
| SSH `PermitRootLogin` | `no` | 🟢 |
| SSH `PasswordAuthentication` | `no` (sí solo desde 192.168.1.0/24) | 🟢 |
| SSH con llaves | ed25519 del ASUS | 🟢 |
| Firewall | UFW activo y habilitado al arranque (`systemctl enable ufw`) | 🟢 |
| Acceso remoto | Tailscale, sin puertos abiertos en el router | 🟢 |
| MQTT anónimo | `allow_anonymous false` + `password_file` | 🟢 Correcto |
| MQTT usuarios/ACL | Un usuario por cliente + ACL por tópico (leandro, nodered, esp32-habitacion) | 🟢 |
| MQTT cifrado (TLS) | No | 🟡 Bajo en LAN/VPN |
| Node-RED `adminAuth` | Activo (401 sin sesión) | 🟢 |
| Node-RED Dashboard | Sin contraseña (decisión del usuario). Expuesto solo a la LAN y a Tailscale | 🟡 Aceptado |
| Node-RED `credentialSecret` | Definido; `flows_cred.json` cifrado | 🟢 |
| Usuarios con shell | `root`, `leandro` (UID 1000) | — |
| Imagen del sistema | Armbian **nightly/trunk** | 🟢 Kernel/arranque congelados |
| Samba | SMB3, sin invitados, `hosts allow` LAN+Tailscale | 🟢 Correcto |

## Plan de endurecimiento
1. Llaves SSH desde Windows → desactivar el login de root → desactivar las contraseñas (siempre con una sesión abierta de respaldo).
2. Instalar UFW: permitir 22, 1880, 1883 y Samba solo desde la LAN y Tailscale.
3. Verificar `adminAuth` y definir `credentialSecret` en Node-RED.
4. Acceso remoto solo por Tailscale, sin abrir puertos en el router.
5. Congelar las actualizaciones de kernel/bootloader de la imagen nightly mientras el servidor esté sin supervisión.

## Paquetes congelados (`apt-mark hold`, 2026-11-13)
Provienen del repositorio beta de Armbian. Se congelan para que `apt upgrade` no cambie el arranque:
```
linux-image-current-sunxi
linux-dtb-current-sunxi
linux-u-boot-orangepipcplus-current
armbian-firmware
armbian-bsp-cli-orangepipcplus-current
```
Consultar: `apt-mark showhold` · Liberar: `sudo apt-mark unhold <paquete>`
