#!/bin/bash
# LEANDRO HOME SERVER - Etapa 1: Diagnóstico (SOLO LECTURA)
sec(){ echo; echo "==================== $1 ===================="; }
sec "FECHA Y HOST";            date; hostnamectl
sec "ARMBIAN / SISTEMA";       cat /etc/armbian-release 2>/dev/null; cat /etc/os-release; uname -a
sec "CPU";                     lscpu; grep -m1 -i hardware /proc/cpuinfo
sec "TEMPERATURA CPU (m°C)";   cat /sys/class/thermal/thermal_zone*/temp
sec "MEMORIA Y SWAP/ZRAM";     free -h; swapon --show
sec "CARGA Y PROCESOS";        uptime; top -bn1 -o %MEM | head -20
sec "DISCOS";                  lsblk -o NAME,SIZE,TYPE,FSTYPE,LABEL,UUID,MOUNTPOINT,MODEL
sec "BLKID";                   blkid
sec "USO DE ESPACIO";          df -hT -x tmpfs -x devtmpfs
sec "FSTAB";                   cat /etc/fstab
sec "DISPOSITIVOS USB";        lsusb
sec "KERNEL - DISCO USB";      dmesg | grep -iE "sd[a-z]|uas|usb-storage|I/O error|reset" | tail -40
sec "RED - INTERFACES";        ip -br addr; ip route; nmcli dev status 2>/dev/null
sec "RED - DNS E INTERNET";    cat /etc/resolv.conf; ping -c 3 1.1.1.1; ping -c 2 google.com
sec "PUERTOS ESCUCHANDO";      ss -tulpn
sec "SERVICIOS ACTIVOS";       systemctl list-units --type=service --state=running --no-pager
sec "SERVICIOS FALLIDOS";      systemctl --failed --no-pager
sec "MOSQUITTO - ESTADO";      systemctl status mosquitto --no-pager -l | head -20; mosquitto -h 2>&1 | head -1
sec "MOSQUITTO - CONFIG";      for f in /etc/mosquitto/mosquitto.conf /etc/mosquitto/conf.d/*.conf; do echo "--- $f"; grep -vE '^\s*(#|$)' "$f" 2>/dev/null; done
sec "NODE-RED - ESTADO";       systemctl list-unit-files --no-pager | grep -iE "node|red"; systemctl status nodered --no-pager -l | head -20; node -v; npm -v
sec "NODE-RED - SEGURIDAD";    grep -n "adminAuth" /home/*/.node-red/settings.js /root/.node-red/settings.js 2>/dev/null
sec "USUARIOS CON SHELL";      grep -E '/(bash|sh|zsh)$' /etc/passwd | cut -d: -f1,3,6
sec "SSH - CONFIG EFECTIVA";   sshd -T | grep -iE "^(port|permitrootlogin|passwordauthentication|pubkeyauthentication)"
sec "FIREWALL";                command -v ufw >/dev/null && ufw status verbose || echo "UFW no instalado"
sec "ACTUALIZACIONES PEND.";   apt list --upgradable 2>/dev/null | head -30
sec "ERRORES DEL KERNEL";      dmesg -l err,crit,alert,emerg | tail -30
echo; echo "=== FIN DEL DIAGNÓSTICO ==="
