# NAS con Samba (Etapa 3)

## Instalación
- Paquete: `samba` 2:4.22.11+dfsg-0+deb13u1 (Debian trixie estable, armhf). Se descartó la versión de backports.
- Consumo: unos 10 MB de RAM (`smbd`).
- `nmbd` (NetBIOS) desactivado: el acceso se hace por IP.

```bash
sudo apt install samba
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak-original
# configuración: ver configuraciones/smb.conf
testparm -s
sudo smbpasswd -a leandro        # contraseña Samba (independiente de la de Linux)
sudo systemctl restart smbd
sudo systemctl disable --now nmbd
```

## Recursos compartidos
| Recurso | Ruta | Acceso |
|---|---|---|
| `\\192.168.1.9\archivos` | /srv/servidor/archivos | leandro, lectura/escritura (unidad Z:) |
| `\\192.168.1.9\compartido` | /srv/servidor/compartido | leandro, lectura/escritura |
| `\\192.168.1.9\backups` | /srv/servidor/backups | leandro, **solo lectura** |

## Seguridad aplicada
- `server min protocol = SMB3` (SMB1/SMB2 rechazados). Sesión verificada: **SMB3_11**, firma **AES-128-GMAC**.
- Sin invitados ni acceso anónimo (`map to guest = never`, `restrict anonymous = 2`).
- `hosts allow`: solo la LAN 192.168.1.0/24, localhost y Tailscale 100.64.0.0/10.
- Sin cifrado SMB en la LAN: el H3 no tiene aceleración AES de ARMv8, así que cifrar reduciría mucho la velocidad. El acceso remoto irá cifrado por Tailscale (WireGuard).

## Conexión desde Windows
```powershell
net use Z: \\192.168.1.9\archivos /persistent:yes
```

## Verificación
```bash
sudo smbstatus          # sesiones activas, protocolo, firma
testparm -s             # validar la configuración
```
