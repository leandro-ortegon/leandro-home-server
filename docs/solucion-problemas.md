# Solución de problemas (guía rápida)

> Lee primero la sección del síntoma que tienes. Todos los comandos se ejecutan **en la Orange Pi** por SSH, salvo los marcados como *PowerShell*.

## Datos clave a mano
| Dato | Valor |
|---|---|
| IP en casa | 192.168.1.9 |
| Nombre en Tailscale | `leandro-home-server` (100.76.238.119) |
| Usuario Linux | `leandro` |
| HDD | `/srv/servidor` (UUID `39ca6a1f-0cc4-437a-ac86-573b770455a5`) |
| Editor Node-RED | http://192.168.1.9:1880 |
| Dashboard | http://192.168.1.9:1880/dashboard |
| Archivos | `\\192.168.1.9\archivos` (unidad Z:) |

## 0. Revisión general (lo primero que hay que hacer)
```bash
bash verificacion-final.sh        # ver scripts/verificacion-final.sh
# o rápido:
systemctl --failed --no-pager
systemctl is-active ssh mosquitto nodered smbd tailscaled ufw taildrop-recibir
```

---

## 1. No puedo entrar por SSH
| Desde | Qué probar |
|---|---|
| Casa | *PowerShell*: `ssh leandro@192.168.1.9`. Desde la LAN se acepta la contraseña de emergencia: `ssh -o PubkeyAuthentication=no leandro@192.168.1.9` |
| Fuera de casa | ¿Tailscale está **Connected** en el ASUS? Luego `ssh leandro@leandro-home-server` (solo con llave) |

- **"Connection timed out"**: la Orange Pi está apagada, no tiene WiFi o cambió de IP. Mira en el router qué IP tiene `orangepipcplus`.
- **"Permission denied (publickey)" desde fuera**: el ASUS perdió la llave `C:\Users\Asus\.ssh\id_ed25519`. Entra desde casa con contraseña y vuelve a copiar la llave:
  *PowerShell*: `type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh leandro@192.168.1.9 "cat >> ~/.ssh/authorized_keys"`
- **Si cambiaste la configuración SSH y quedaste fuera**: conecta monitor y teclado a la Orange Pi y ejecuta:
  `sudo mv /etc/ssh/sshd_config.d/00-leandro-hardening.conf /etc/ssh/00-leandro-hardening.conf.desactivado && sudo systemctl reload ssh`

## 2. El firewall me bloqueó algo
```bash
sudo ufw status verbose        # ver reglas
sudo ufw disable               # emergencia: apaga el firewall
sudo ufw enable                # volver a activarlo
```
Reglas: Tailscale todo; LAN 192.168.1.0/24 → 22, 1880, 1883, 445.

## 3. El HDD no aparece / backups o base de datos fallan
```bash
findmnt /srv/servidor                    # ¿montado?
lsblk -f                                 # ¿aparece sda1 con UUID 39ca6a1f...?
sudo dmesg | grep -iE "sd[a-z]|usb|I/O error" | tail -20
sudo mount -a                            # intentar montar según fstab
```
- Si `lsblk` no muestra `sda`: revisa el cable USB y la alimentación del disco.
- Gracias a la opción `nofail`, el sistema arranca aunque el disco falle; los servicios que lo usan (backups, SQLite) darán error hasta que vuelva.
- Respaldo del fstab original: `/etc/fstab.bak-20261113`.

## 4. El Dashboard no muestra datos de la habitación
1. ¿El ESP32 está en línea? En el dashboard (grupo *Sistema ESP32*) o:
   ```bash
    mosquitto_sub -h localhost -u leandro -P '****' -t 'domotica/habitacion/#' -v
   ```
   - `conexion offline` → el ESP32 está apagado o sin WiFi. Revisa su pantalla OLED (icono WiFi).
   - Sin mensajes de `estado` pero `online` → revisa el monitor serie del ESP32.
2. ¿Mosquitto rechaza al ESP32?
   ```bash
   sudo tail -30 /var/log/mosquitto/mosquitto.log | grep -iE "esp32|denied|not authorised"
   ```
3. ¿Cambió la IP de la Orange Pi? El ESP32 tiene `MQTT_SERVIDOR "192.168.1.9"` fijo → reserva la IP en el router.

## 5. Node-RED no abre
```bash
systemctl status nodered --no-pager
journalctl -u nodered -n 50 --no-pager
sudo systemctl restart nodered          # tarda unos 40 s en arrancar
node -e 'require(process.env.HOME+"/.node-red/settings.js")' && echo "settings.js correcto"
```
- Si `settings.js` tiene un error de sintaxis, restaura un respaldo: `settings.js.bak-20261113`, `.bak-dashboard` o `.bak-sqlite` en `~/.node-red/`.
- Si se pierden los flujos: restaura desde backups (sección 9). Hace falta la `credentialSecret` guardada aparte.

## 6. MQTT no funciona
```bash
systemctl status mosquitto --no-pager
sudo tail -30 /var/log/mosquitto/mosquitto.log
sudo ls -l /etc/mosquitto/passwd /etc/mosquitto/acl   # deben ser root mosquitto -rw-r-----
```
- Si Mosquitto no arranca tras editar la configuración, restaura `/etc/mosquitto/conf.d/domotica.conf.bak-20261113` o `/etc/mosquitto/acl.bak-etapa10`.
- Cambiar una contraseña (NUNCA usar `-c`): `sudo mosquitto_passwd /etc/mosquitto/passwd <usuario> && sudo systemctl reload mosquitto`

## 7. No veo mis archivos (Samba / unidad Z:)
```bash
systemctl status smbd --no-pager
testparm -s
sudo smbstatus
```
- Desde fuera de casa usa `\\leandro-home-server\archivos` con Tailscale activo.
- Si olvidaste la contraseña de Samba: `sudo smbpasswd leandro`.

## 8. Tailscale no conecta
```bash
tailscale status
sudo systemctl restart tailscaled
```
- Panel: https://login.tailscale.com/admin/machines (cuenta leandro-ortegon@github).
- Si aparece "expired": en el panel, **⋯ → Disable key expiry**.
- Si queda pendiente de aprobación o con la identidad rota: ver *Incidencia resuelta* en [acceso-remoto.md](acceso-remoto.md).

## 8b. No llegan los archivos enviados con Taildrop
Ver [taildrop.md](taildrop.md), sección *Si deja de recibir archivos*. Revisión rápida: `systemctl status taildrop-recibir --no-pager`.

## 9. Restaurar desde una copia de seguridad
Las copias están en `/srv/servidor/backups/{diario,semanal,mensual}/AAAA-MM-DD/`. Ver ejemplos completos en [backups.md](backups.md).
```bash
ls /srv/servidor/backups/diario/
cd /srv/servidor/backups/diario/AAAA-MM-DD && sudo sha256sum -c SHA256SUMS   # comprobar integridad
```

## 10. La Orange Pi se calienta o va lenta
```bash
cat /sys/class/thermal/thermal_zone0/temp    # en m°C (47000 = 47 °C)
free -h; uptime
top -o %MEM
```
Normal en reposo: 45–55 °C, menos del 25 % de RAM usada. Por encima de 75 °C conviene un disipador o un ventilador.

## 11. Antes de actualizar el sistema
El kernel y el arranque están **congelados** (imagen nightly). `sudo apt update && sudo apt upgrade` es seguro.
Para ver qué está congelado: `apt-mark showhold`. **No** ejecutes `apt-mark unhold` sin un backup y acceso físico a la placa.
