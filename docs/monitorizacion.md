# Monitorización (Etapa 7)

## Decisión
| Opción | RAM extra | Resultado |
|---|---|---|
| Netdata | 100–200 MB | ❌ Demasiado para 1 GB |
| Cockpit | 20–40 MB mientras se usa | Posible, pero añade otra web y otro inicio de sesión |
| **Node-RED Dashboard 2.0** | ~0 MB (ya instalado) | ✅ Un solo panel para la habitación y el servidor |

## Componentes
- Script de solo lectura: `/usr/local/bin/estado-servidor.sh` (copia en [`scripts/estado-servidor.sh`](../scripts/estado-servidor.sh)).
  - `export LC_ALL=C` es obligatorio: con el locale es_CO, `awk` escribía `52,1` y rompía el JSON.
- Flujo: [`configuraciones/nodered/flujo-monitor-servidor.json`](../configuraciones/nodered/flujo-monitor-servidor.json), pestaña **Servidor**:
  `Cada 30 s` → `exec estado-servidor.sh` → `json` → `Repartir datos` → 10 widgets + `mqtt out`.
- Página del dashboard: http://192.168.1.9:1880/dashboard/servidor (grupos Recursos, Almacenamiento y Servicios).
- MQTT: `domotica/servidor/estado` (retain) con el JSON completo.

## Campos del JSON
`cpu` (%), `temp` (°C del SoC), `ram` (%), `ram_total_mb`, `ram_disp_mb`, `load` (1 min), `uptime` (s),
`sd_uso` (%), `hdd_montado` (bool), `hdd_uso` (%), `hdd_libre_gb`, `mosquitto`, `nodered`, `samba` (bool).

## Umbrales
| Métrica | Verde | Amarillo | Rojo |
|---|---|---|---|
| CPU / RAM | < 60 % | 60–85 % | > 85 % |
| Temp. CPU | < 65 °C | 65–80 °C | > 80 °C |
| Discos | < 75 % | 75–90 % | > 90 % |

## Línea base (2026-11-13, en reposo)
CPU 0–5 % · RAM 16–17 % (unos 826 MB disponibles) · 47–52 °C · microSD 8 % · HDD 1 % (907 GB libres).

## Verificación
```bash
/usr/local/bin/estado-servidor.sh
 mosquitto_sub -h localhost -u leandro -P '****' -t 'domotica/servidor/estado' -v -C 1
```
