# Almacenamiento

## Resumen
| Dispositivo | Uso | Sistema de archivos | Montaje |
|---|---|---|---|
| microSD `mmcblk0p1` (29 GB) | Sistema operativo | ext4 | `/` |
| HDD `sda1` (916 GB) | Datos del servidor | ext4 (etiqueta `servidor`) | `/srv/servidor` |
| `zram1` (50 MB) | Logs en RAM (log2ram) | ext4 | `/var/log` |

## HDD: historial
- **Estado inicial (2026-11-13):** el disco tenía 5 particiones de un antiguo Windows (EFI, MSR, NTFS de 372 GB vacía, recuperación y NTFS "memoria" con 20 GB de datos antiguos).
- **Decisión:** el usuario autorizó borrar toda la información y usar el disco completo para el servidor.

## Procedimiento realizado (Etapa 2)
```bash
# 1. Borrar firmas y crear GPT con una sola partición Linux
sudo wipefs -a /dev/sda1 /dev/sda2 /dev/sda3 /dev/sda4 /dev/sda5
sudo wipefs -a /dev/sda
printf 'label: gpt\n,,L\n' | sudo sfdisk /dev/sda

# 2. Formatear (1 % reservado en lugar del 5 % por defecto)
sudo mkfs.ext4 -L servidor -m 1 /dev/sda1

# 3. Montaje permanente
sudo cp /etc/fstab /etc/fstab.bak-20261113
sudo mkdir -p /srv/servidor
echo 'UUID=39ca6a1f-0cc4-437a-ac86-573b770455a5  /srv/servidor  ext4  defaults,noatime,nofail,x-systemd.device-timeout=30s  0  2' | sudo tee -a /etc/fstab
sudo systemctl daemon-reload && sudo mount -a
```

## Línea en `/etc/fstab`
```
UUID=39ca6a1f-0cc4-437a-ac86-573b770455a5  /srv/servidor  ext4  defaults,noatime,nofail,x-systemd.device-timeout=30s  0  2
```
| Opción | Motivo |
|---|---|
| `noatime` | No registrar los accesos de lectura: menos escrituras. |
| `nofail` | El sistema arranca aunque el HDD falle o esté desconectado. |
| `x-systemd.device-timeout=30s` | Espera máxima por el disco en el arranque. |
| `0 2` | Sin dump; fsck después de la raíz. |

Respaldo del fstab original: `/etc/fstab.bak-20261113`.

## Estructura y permisos
| Carpeta | Dueño:grupo | Permisos | Uso |
|---|---|---|---|
| `archivos/` | leandro:leandro | 755 | Archivos personales (Samba) |
| `compartido/` | leandro:leandro | 755 | Carpeta compartida (Samba) |
| `nodered/` | leandro:leandro | 755 | Datos de Node-RED |
| `registros/` | leandro:leandro | 755 | Logs persistentes |
| `bases_datos/` | leandro:leandro | 750 | SQLite |
| `mqtt/` | mosquitto:mosquitto | 750 | Persistencia/logs de Mosquitto |
| `backups/` | root:leandro | 750 | Copias de seguridad |

```bash
sudo mkdir -p /srv/servidor/{archivos,backups,mqtt,nodered,registros,compartido,bases_datos}
sudo chown leandro:leandro /srv/servidor/{archivos,compartido,nodered,bases_datos,registros}
sudo chown mosquitto:mosquitto /srv/servidor/mqtt
sudo chown root:leandro /srv/servidor/backups
sudo chmod 750 /srv/servidor/{backups,bases_datos,mqtt}
```

## Verificación
- `mount -a` sin errores.
- Reinicio el 2026-11-13: el disco se montó automáticamente en `/srv/servidor` y conservó las carpetas y los permisos. ✅

## Notas
- Adaptador JMicron JM20329, USB 2.0: velocidad práctica de unos 30–35 MB/s.
- Tras el formateo, `ext4lazyinit` inicializa tablas en segundo plano durante horas (actividad normal del disco).
- Pendiente opcional: revisar la salud del disco con `smartmontools` (SMART).
