# Copias de seguridad (Etapa 9)

## Componentes
| Elemento | Ubicación |
|---|---|
| Script | `/usr/local/sbin/backup-servidor.sh` (root, 750) · copia en [`scripts/`](../scripts/backup-servidor.sh) |
| Servicio | `/etc/systemd/system/backup-servidor.service` |
| Temporizador | `/etc/systemd/system/backup-servidor.timer` (diario 03:15–03:20, `Persistent=true`) |
| Destino | `/srv/servidor/backups/{diario,semanal,mensual}/AAAA-MM-DD/` |
| Registro | `/srv/servidor/registros/backup.log` y `journalctl -u backup-servidor` |

## Contenido de cada copia
| Archivo | Contenido | Permisos |
|---|---|---|
| `etc.tar.gz` | `/etc` completo (Mosquitto, Samba, SSH, UFW, fstab, systemd, apt...) | 600 root (incluye `/etc/shadow`) |
| `nodered.tar.gz` | `~/.node-red` sin `node_modules` | 640 root:leandro |
| `domotica.db.gz` | SQLite (`.backup`, copia consistente) | 640 |
| `mosquitto.db` | Persistencia MQTT | 640 |
| `scripts.tar.gz` | `/usr/local/bin` y `/usr/local/sbin` | 640 |
| `paquetes.txt`, `paquetes-congelados.txt` | `dpkg --get-selections`, `apt-mark showhold` | 640 |
| `SHA256SUMS` | Sumas de verificación | 640 |

Tamaño de la primera copia (2026-11-13): **516 KB**.

## Rotación
| Tipo | Cuándo | Se conservan |
|---|---|---|
| diario | Todos los días | 7 |
| semanal | Domingos | 4 |
| mensual | Día 1 | 6 |

La rotación solo elimina carpetas `AAAA-MM-DD` dentro de esas tres carpetas. Si el HDD no está montado, el backup se cancela.

## Operación
```bash
sudo systemctl start backup-servidor.service      # backup manual (vía systemd)
systemctl list-timers backup-servidor.timer       # próxima ejecución
journalctl -u backup-servidor -n 30 --no-pager    # resultado de la última ejecución
tail -20 /srv/servidor/registros/backup.log
cd /srv/servidor/backups/diario/AAAA-MM-DD && sudo sha256sum -c SHA256SUMS
```

## Restauración (ejemplos)
```bash
B=/srv/servidor/backups/diario/AAAA-MM-DD
# Base de datos
sudo systemctl stop nodered
gunzip -c $B/domotica.db.gz > /srv/servidor/bases_datos/domotica.db
sudo systemctl start nodered
# Node-RED (requiere la credentialSecret guardada aparte)
sudo systemctl stop nodered
tar -xzf $B/nodered.tar.gz -C /home/leandro && cd ~/.node-red && npm install
sudo systemctl start nodered
# Un archivo de /etc (ejemplo: ACL de Mosquitto) sin pisar todo /etc
sudo tar -xzf $B/etc.tar.gz -C /tmp etc/mosquitto/acl && sudo cp /tmp/etc/mosquitto/acl /etc/mosquitto/acl
```

## Regla 3-2-1 (pendiente del usuario)
Las copias están en el **mismo HDD** que los datos. Si el disco falla, se pierden ambos.
Recomendación: copiar periódicamente `\\leandro-home-server\backups` (solo lectura por Samba) al ASUS o a una memoria externa.
