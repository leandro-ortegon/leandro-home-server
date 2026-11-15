#!/bin/bash
# ============================================================
# LEANDRO HOME SERVER - Copia de seguridad diaria
# Ubicación: /usr/local/sbin/backup-servidor.sh (se ejecuta como root)
# Lo lanza: backup-servidor.timer (todos los días 03:15)
# ============================================================
set -uo pipefail
export LC_ALL=C

DESTINO=/srv/servidor/backups
LOG=/srv/servidor/registros/backup.log
NODERED=/home/leandro/.node-red
BD=/srv/servidor/bases_datos/domotica.db
GUARDAR_DIARIAS=7
GUARDAR_SEMANALES=4
GUARDAR_MENSUALES=6

HOY=$(date +%F)
DIR="$DESTINO/diario/$HOY"
FALLOS=0

log()  { echo "$(date '+%F %T') $*" | tee -a "$LOG"; }
paso() {
  local desc=$1; shift
  if "$@"; then log "  OK    $desc"; else log "  ERROR $desc"; FALLOS=$((FALLOS+1)); fi
}

# 0. Si el HDD no está montado, NO escribir en la microSD
if ! mountpoint -q /srv/servidor; then
  echo "HDD no montado en /srv/servidor: backup cancelado" >&2
  exit 1
fi

mkdir -p "$DIR" "$DESTINO/semanal" "$DESTINO/mensual"
log "=== Inicio backup $HOY ==="

# 1. Configuración del sistema (/etc completo)
paso "etc.tar.gz"      tar --warning=no-file-changed -czf "$DIR/etc.tar.gz" -C / etc
chmod 600 "$DIR/etc.tar.gz" 2>/dev/null

# 2. Node-RED (sin node_modules)
paso "nodered.tar.gz"  tar --exclude=node_modules -czf "$DIR/nodered.tar.gz" -C "$(dirname "$NODERED")" "$(basename "$NODERED")"

# 3. Base de datos (copia consistente)
paso "domotica.db"     sqlite3 "$BD" ".backup '$DIR/domotica.db'"
paso "domotica.db.gz"  gzip -f "$DIR/domotica.db"

# 4. Persistencia de Mosquitto
paso "mosquitto.db"    cp -p /var/lib/mosquitto/mosquitto.db "$DIR/mosquitto.db"

# 5. Scripts propios
paso "scripts.tar.gz"  tar -czf "$DIR/scripts.tar.gz" -C / usr/local/bin usr/local/sbin

# 6. Inventario de paquetes
paso "paquetes.txt"    sh -c "dpkg --get-selections > '$DIR/paquetes.txt'"
paso "congelados.txt"  sh -c "apt-mark showhold > '$DIR/paquetes-congelados.txt'"

# 7. Sumas de verificación
paso "SHA256SUMS"      sh -c "cd '$DIR' && sha256sum *.gz *.db *.txt > SHA256SUMS"

# 8. Semanal (domingo) y mensual (día 1)
if [ "$(date +%u)" = "7" ];  then paso "copia semanal" cp -a "$DIR" "$DESTINO/semanal/$HOY"; fi
if [ "$(date +%d)" = "01" ]; then paso "copia mensual" cp -a "$DIR" "$DESTINO/mensual/$HOY"; fi

# 9. Rotación: conservar solo las N copias más recientes
rotar() {
  local carpeta=$1 n=$2 d
  find "$carpeta" -mindepth 1 -maxdepth 1 -type d -name '20??-??-??' | sort | head -n -"$n" |
  while read -r d; do rm -rf -- "$d" && log "  Rotación: eliminada $d"; done
}
rotar "$DESTINO/diario"  "$GUARDAR_DIARIAS"
rotar "$DESTINO/semanal" "$GUARDAR_SEMANALES"
rotar "$DESTINO/mensual" "$GUARDAR_MENSUALES"

# 10. Permisos: leandro puede leer, solo root escribe
chown -R root:leandro "$DESTINO/diario" "$DESTINO/semanal" "$DESTINO/mensual"
find "$DESTINO/diario" "$DESTINO/semanal" "$DESTINO/mensual" -type d -exec chmod 750 {} +
find "$DESTINO/diario" "$DESTINO/semanal" "$DESTINO/mensual" -type f ! -name 'etc.tar.gz' -exec chmod 640 {} +

TAM=$(du -sh "$DIR" | cut -f1)
LIBRE=$(df -h --output=avail /srv/servidor | tail -1 | tr -d ' ')
if [ "$FALLOS" -eq 0 ]; then
  log "=== Backup OK: $DIR ($TAM) · libre en HDD: $LIBRE ==="
  exit 0
else
  log "=== Backup con $FALLOS ERROR(ES): revisar $LOG ==="
  exit 1
fi
