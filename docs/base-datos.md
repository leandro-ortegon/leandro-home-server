# Base de datos: SQLite (Etapa 6)

## Decisión
| Opción | Resultado |
|---|---|
| **SQLite** | ✅ Elegida: no consume RAM en reposo, es un solo archivo y se respalda copiándolo |
| MariaDB | ❌ 80–150 MB de RAM permanentes, excesivo para este volumen |
| InfluxDB 2.x | ❌ No existe para ARM de 32 bits |
| InfluxDB 1.8 | ❌ Sin soporte |

## Componentes
- Motor: módulo `node:sqlite` de Node.js v22.15 (SQLite 3.49.1). Sin nodos extra ni compilación.
  - Aviso `ExperimentalWarning` en el log: normal (la API de Node podría cambiar en versiones futuras).
- CLI: paquete `sqlite3` 3.46.1 (Debian).
- Archivo: `/srv/servidor/bases_datos/domotica.db` (leandro:leandro, modo WAL).
- Esquema: [`configuraciones/esquema-domotica.sql`](../configuraciones/esquema-domotica.sql).

## Tablas
| Tabla | Contenido | Frecuencia |
|---|---|---|
| `dispositivos` | Catálogo de ESP32 y `ultimo_contacto` | Alta manual / actualización cada minuto |
| `lecturas` | Temperatura, humedad, RSSI, heap, uptime | Promedio cada 60 s (unos 35 MB/año) |
| `estados_rele` | Cambios de relé (`origen`: inicio/esp32) | Solo cuando cambia |
| `eventos` | Inicio/parada del registro, ESP32 sin datos o reconectado | Cuando ocurre |

## Integración con Node-RED
- `settings.js` → `functionGlobalContext: { sqlite: require("node:sqlite"), ... }` (respaldo `settings.js.bak-sqlite`).
- Flujo importado: [`configuraciones/nodered/flujo-historial-sqlite.json`](../configuraciones/nodered/flujo-historial-sqlite.json)
  - `Estado ESP32` → **Guardar historial** (abre la BD en *On Start*, guarda cada 60 s, la cierra en *On Stop*).
  - **Consultar BD** → **Últimos registros** → Debug.

## Consultas útiles
```bash
DB=/srv/servidor/bases_datos/domotica.db
sqlite3 -header -column $DB "SELECT * FROM lecturas ORDER BY id DESC LIMIT 10;"
sqlite3 -header -column $DB "SELECT date(ts) dia, round(min(temperatura),1) tmin, round(max(temperatura),1) tmax, round(avg(humedad)) hum FROM lecturas GROUP BY dia ORDER BY dia DESC LIMIT 7;"
sqlite3 -header -column $DB "SELECT * FROM eventos ORDER BY id DESC LIMIT 20;"
ls -lh /srv/servidor/bases_datos/
```

## Respaldo seguro (con la BD en uso)
```bash
sqlite3 /srv/servidor/bases_datos/domotica.db ".backup '/ruta/destino/domotica-$(date +%F).db'"
```
