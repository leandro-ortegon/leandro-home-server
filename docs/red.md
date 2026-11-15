# Red

## Estado actual
| Interfaz | Estado | IP |
|---|---|---|
| `wlan1` (WiFi) | UP | 192.168.1.9/24 (DHCP) |
| `wlan0` | DOWN | — |
| `end0` (Ethernet) | DOWN | — (error `Failed to reset the dma`) |

- Puerta de enlace: 192.168.1.1
- DNS: systemd-resolved (127.0.0.53)
- Internet: correcto (1.1.1.1 ≈ 18 ms, google.com ≈ 15 ms)
- Gestión de red: netplan + systemd-networkd (`netplan-wpa-wlan1.service`)

## Puertos escuchando
| Puerto | Servicio | Alcance |
|---|---|---|
| 22/tcp | SSH | Todas las interfaces |
| 1880/tcp | Node-RED + Dashboard | Todas las interfaces |
| 1883/tcp | Mosquitto | Todas las interfaces (IPv4/IPv6) |
| 5355/tcp+udp | LLMNR (systemd-resolved) | Todas las interfaces (innecesario) |
| 53 | DNS local | Solo localhost |

## Pendientes
- Reservar la IP 192.168.1.9 en el router (reserva DHCP).
- Evaluar el cambio a Ethernet para mayor estabilidad 24/7.
- Tailscale para acceso remoto (Etapa 8).
- Desactivar LLMNR.
