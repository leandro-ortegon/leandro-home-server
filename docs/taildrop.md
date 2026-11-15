# Taildrop: enviar archivos al servidor ("AirDrop" propio)

## Qué es
Taildrop es la función de Tailscale para enviar archivos entre tus dispositivos. En el servidor, un servicio recoge
automáticamente todo lo que llega y lo guarda en el HDD. Funciona en casa y fuera de casa, sin abrir puertos.

```
Celular / ASUS ──(Tailscale, cifrado)──► leandro-home-server ──► /srv/servidor/archivos/Taildrop
                                                                    = Z:\Taildrop en el ASUS
```

## Cómo usarlo
| Desde | Pasos |
|---|---|
| **Celular (Android)** | En cualquier app (Galería, Archivos, WhatsApp...): **Compartir → Tailscale → leandro-home-server** |
| **ASUS (Windows)** | Clic derecho sobre un archivo → **Enviar con Tailscale** → leandro-home-server |

Dónde aparece:
| Desde | Ruta |
|---|---|
| ASUS | `Z:\Taildrop` (pulsa F5 si no se ve aún) |
| Celular (CX File Explorer) | `archivos → Taildrop` |
| Servidor | `/srv/servidor/archivos/Taildrop` |

Si envías dos veces un archivo con el mismo nombre, **no se sobrescribe**: el nuevo se renombra (`foto (1).jpg`).

## Cómo está configurado (2026-11-13)
```bash
sudo tailscale set --operator=leandro          # leandro puede usar 'tailscale file get' sin sudo
# servicio: /etc/systemd/system/taildrop-recibir.service (ver configuraciones/taildrop-recibir.service)
sudo systemctl daemon-reload && sudo systemctl enable --now taildrop-recibir
```
| Opción | Función |
|---|---|
| `User=leandro` | Los archivos quedan como tuyos: se abren y borran desde Windows sin problemas |
| `--loop` | Recoge cada archivo apenas llega |
| `--conflict=rename` | Nunca sobrescribe |
| `RequiresMountsFor=/srv/servidor` | Si el HDD no está montado, no recibe (protege la microSD) |
| `Restart=always` | Se reinicia solo si falla |

## Fotos HEIC
- Samsung guarda las fotos en **HEIC** si la opción "Fotos HEIF" de la cámara está activa. Windows no las abre sin extensión.
- **Solución aplicada:** en el celular, *Cámara → ⚙️ → Opciones avanzadas de imagen → Formatos de imagen →* **"Fotos HEIF" desactivado**. Las fotos nuevas salen en JPG.
- Las fotos **antiguas** de la galería siguen siendo HEIC. Opciones:
  - Windows: instalar **"Extensiones de imagen HEIF"** (gratis, Microsoft Store).
  - Servidor (conversores instalados: `libheif-examples`, `webp`). Conversión manual sin borrar los originales:
    ```bash
    cd /srv/servidor/archivos/Taildrop && for f in *.heic; do heif-dec -q 92 "$f" "${f%.heic}.jpg" >/dev/null && touch -r "$f" "${f%.heic}.jpg" && echo "OK $f"; done; cd ~
    ```
- Si Windows dice **"COM Surrogate tiene abierto el archivo"** al borrar un HEIC: cambia la vista a *Detalles*, cierra el panel de vista previa (`Alt+P`) o finaliza *COM Surrogate* en el Administrador de tareas, y reintenta.

## Si deja de recibir archivos
```bash
systemctl status taildrop-recibir --no-pager | head -6      # debe estar active (running)
journalctl -u taildrop-recibir -n 20 --no-pager
sudo tailscale file get --verbose /srv/servidor/archivos/Taildrop/   # recoger a mano lo pendiente
sudo chown -R leandro:leandro /srv/servidor/archivos/Taildrop
sudo systemctl restart taildrop-recibir
```
- `moved 0/0 files` = no había nada pendiente (el servicio ya lo había recogido).
- Comprueba que el celular tenga Tailscale **Connected** y que el servidor aparezca en la lista al compartir.
