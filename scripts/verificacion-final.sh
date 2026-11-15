#!/bin/bash
# LEANDRO HOME SERVER - Auditoría rápida (solo lectura). Uso: bash verificacion-final.sh
echo "===== LEANDRO HOME SERVER · VERIFICACIÓN ====="; date
echo; echo "--- Servicios ---"; for s in ssh mosquitto nodered smbd tailscaled ufw taildrop-recibir backup-servidor.timer; do printf "%-24s %s\n" "$s" "$(systemctl is-active $s)"; done
echo; echo "--- HDD ---"; findmnt -no SOURCE,TARGET,OPTIONS /srv/servidor; df -h /srv/servidor | tail -1
echo; echo "--- Recursos ---"; free -h | head -2; echo "Temp CPU: $(awk '{printf "%.1f °C", $1/1000}' /sys/class/thermal/thermal_zone0/temp)"; uptime
echo; echo "--- Firewall ---"; sudo ufw status | head -12
echo; echo "--- Tailscale ---"; tailscale ip -4; tailscale status | head -5
echo; echo "--- Node-RED ---"; for u in /flows /dashboard/; do printf "%-12s %s\n" "$u" "$(curl -s -o /dev/null -w '%{http_code}' http://localhost:1880$u)"; done
echo; echo "--- MQTT (usuarios) ---"; sudo cut -d: -f1 /etc/mosquitto/passwd | tr '\n' ' '; echo
echo; echo "--- Base de datos ---"; sqlite3 /srv/servidor/bases_datos/domotica.db "SELECT 'lecturas', count(*) FROM lecturas UNION ALL SELECT 'eventos', count(*) FROM eventos UNION ALL SELECT 'reles', count(*) FROM estados_rele;"
echo; echo "--- Backups ---"; systemctl list-timers backup-servidor.timer --no-pager | sed -n 2p; tail -1 /srv/servidor/registros/backup.log
echo; echo "--- Paquetes congelados ---"; apt-mark showhold | tr '\n' ' '; echo
echo; echo "--- SSH ---"; sudo sshd -T | grep -E "^(permitrootlogin|passwordauthentication) "
echo "===== FIN ====="
