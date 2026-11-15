# Hardware

Datos obtenidos con el diagnóstico de la Etapa 1 (2026-11-13).

## Placa
| Parámetro | Valor |
|---|---|
| Modelo | Orange Pi PC Plus V1.1 (`BOARD=orangepipcplus`, familia sun8i) |
| SoC | Allwinner H3 |
| CPU | 4× ARM Cortex-A7 (ARMv7 rev 5), 480–1296 MHz, NEON, VFPv4 |
| Arquitectura | `armv7l` (32 bits) → paquetes Debian `armhf` |
| RAM | 991 MiB; ~830 MiB disponibles en reposo |
| Swap | zram de 496 MiB (comprimida en RAM) |
| Temperatura CPU en reposo | 47,7 °C |

## Almacenamiento
| Dispositivo | Tamaño | Uso actual |
|---|---|---|
| `mmcblk0` (microSD) | 28,8 GB | **Sistema operativo** (`/`, ext4, 8 % usado) |
| `mmcblk2` (eMMC) | 7,3 GB | Imagen de fábrica (Android/vendor) sin uso |
| `sda` (HDD USB) | 931,5 GB | `sda1` ext4 "servidor" → `/srv/servidor` |
| `zram1` | 50 MB | `/var/log` (log2ram) |

> Observación: el sistema arranca desde la **microSD**, no desde la eMMC.

## HDD
- Modelo: ST1000LM024 HN-M101MBB (disco de portátil 2,5", 5400 rpm, 1 TB).
- Adaptador: JMicron JM20329 (`152d:2329`), USB 2.0, driver `usb-storage` (no UAS).
- Sin errores de E/S en el arranque.

## Red
- WiFi integrado (SDIO) → interfaz `wlan1` activa.
- Ethernet 100 Mbps `end0`: inactiva; el kernel registra `Failed to reset the dma` (típico cuando no hay cable conectado).

## IoT
- ESP32 DevKit V1 (ESP32-WROOM-32), DHT22, OLED, módulos de relé, protoboard y cables Dupont.
