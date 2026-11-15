#!/bin/bash
# LEANDRO HOME SERVER - Estado del servidor en JSON (solo lectura)
export LC_ALL=C   # punto decimal (no coma) aunque el sistema esté en español
# Ubicación: /usr/local/bin/estado-servidor.sh   · Lo usa Node-RED (nodo exec)

# CPU: dos muestras de /proc/stat separadas 1 s
read -r _ u1 n1 s1 i1 w1 x1 y1 z1 _ < /proc/stat
sleep 1
read -r _ u2 n2 s2 i2 w2 x2 y2 z2 _ < /proc/stat
total=$(( (u2+n2+s2+i2+w2+x2+y2+z2) - (u1+n1+s1+i1+w1+x1+y1+z1) ))
idle=$(( (i2+w2) - (i1+w1) ))
cpu=$(( total > 0 ? 100 * (total - idle) / total : 0 ))

temp=$(awk '{printf "%.1f", $1/1000}' /sys/class/thermal/thermal_zone0/temp)
read -r mem_total mem_disp < <(awk '/^MemTotal/{t=$2} /^MemAvailable/{a=$2} END{print int(t/1024), int(a/1024)}' /proc/meminfo)
ram=$(( 100 * (mem_total - mem_disp) / mem_total ))
load=$(cut -d' ' -f1 /proc/loadavg)
uptime_s=$(cut -d. -f1 /proc/uptime)
sd_uso=$(df --output=pcent / | tail -1 | tr -dc '0-9')

if mountpoint -q /srv/servidor; then
  hdd_montado=true
  hdd_uso=$(df --output=pcent /srv/servidor | tail -1 | tr -dc '0-9')
  hdd_libre=$(df -BG --output=avail /srv/servidor | tail -1 | tr -dc '0-9')
else
  hdd_montado=false; hdd_uso=null; hdd_libre=null
fi

svc() { systemctl is-active --quiet "$1" 2>/dev/null && echo true || echo false; }

printf '{"cpu":%s,"temp":%s,"ram":%s,"ram_total_mb":%s,"ram_disp_mb":%s,"load":%s,"uptime":%s,"sd_uso":%s,"hdd_montado":%s,"hdd_uso":%s,"hdd_libre_gb":%s,"mosquitto":%s,"nodered":%s,"samba":%s}\n' \
  "$cpu" "$temp" "$ram" "$mem_total" "$mem_disp" "$load" "$uptime_s" "$sd_uso" \
  "$hdd_montado" "$hdd_uso" "$hdd_libre" "$(svc mosquitto)" "$(svc nodered)" "$(svc smbd)"
