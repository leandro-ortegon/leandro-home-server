# Acceso remoto y firewall (Etapa 8)

## Tailscale
| Dato | Valor |
|---|---|
| Paquete | `tailscale` 1.104.7 (repositorio oficial `pkgs.tailscale.com/stable/debian trixie`, armhf) |
| Nombre | `leandro-home-server` (MagicDNS) |
| IP Tailscale | 100.76.238.119 |
| Cuenta | leandro-ortegon@github (plan Free) |
| Expiración de clave | Desactivada en el servidor (*Disable key expiry*) |

```bash
curl -fsSL https://pkgs.tailscale.com/stable/debian/trixie.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg > /dev/null
curl -fsSL https://pkgs.tailscale.com/stable/debian/trixie.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
sudo apt update && sudo apt install tailscale
sudo tailscale up --hostname=leandro-home-server --auth-key=<clave de un solo uso, revocada después>
```

### Incidencia resuelta
El inicio de sesión por enlace dio *Error 500* y dejó el nodo pendiente de aprobación en otra cuenta
(`register request: node ... already exists`). Solución:
```bash
sudo systemctl stop tailscaled
sudo mv /var/lib/tailscale/tailscaled.state /var/lib/tailscale/tailscaled.state.bak-20261113
sudo systemctl start tailscaled
sudo tailscale up --hostname=leandro-home-server --auth-key=<clave>
```

### Accesos remotos
| Servicio | Dirección |
|---|---|
| SSH | `ssh leandro@leandro-home-server` |
| Node-RED | http://leandro-home-server:1880 |
| Dashboard | http://leandro-home-server:1880/dashboard |
| Samba | `\\leandro-home-server\archivos` |

No hay puertos abiertos en el router.

## Firewall UFW
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow in on tailscale0 comment 'Tailscale: mis dispositivos'
sudo ufw allow 41641/udp comment 'Tailscale conexion directa'
sudo ufw allow from 192.168.1.0/24 to any port 22 proto tcp comment 'SSH LAN'
sudo ufw allow from 192.168.1.0/24 to any port 1880 proto tcp comment 'Node-RED LAN'
sudo ufw allow from 192.168.1.0/24 to any port 1883 proto tcp comment 'MQTT ESP32 LAN'
sudo ufw allow from 192.168.1.0/24 to any port 445 proto tcp comment 'Samba LAN'
# red de seguridad antes de activar:
sudo systemd-run --on-active=5m --unit=ufw-rescate /usr/sbin/ufw disable
sudo ufw enable
# tras verificar SSH por LAN y Tailscale:
sudo systemctl stop ufw-rescate.timer
```

| Origen | Permitido |
|---|---|
| tailscale0 | Todo |
| 192.168.1.0/24 | 22, 1880, 1883, 445 (TCP) |
| Cualquiera | 41641/udp (Tailscale directo) |
| Resto | Denegado |

Verificar: `sudo ufw status verbose`. Desactivar en emergencia: `sudo ufw disable`.

## Endurecimiento SSH (2026-11-13)
- Llave `ed25519` del ASUS (`C:\Users\Asus\.ssh\id_ed25519`) en `~/.ssh/authorized_keys`.
- Configuración: `/etc/ssh/sshd_config.d/00-leandro-hardening.conf` (ver [`configuraciones/`](../configuraciones/00-leandro-hardening.conf)). Respaldo: `/etc/ssh/sshd_config.bak-20261113`.

| Prueba | Resultado |
|---|---|
| Llave por Tailscale | ✅ Entra sin contraseña |
| Contraseña por Tailscale | ❌ `Permission denied (publickey)` |
| Contraseña desde la LAN (emergencia) | ✅ |
| root con contraseña | ❌ Rechazado |

Rescate:
```bash
sudo mv /etc/ssh/sshd_config.d/00-leandro-hardening.conf /etc/ssh/00-leandro-hardening.conf.desactivado && sudo systemctl reload ssh
```
