-- LEANDRO HOME SERVER - Esquema SQLite
-- Archivo: /srv/servidor/bases_datos/domotica.db  (dueño leandro)
PRAGMA journal_mode=WAL;

CREATE TABLE IF NOT EXISTS dispositivos (
  id              TEXT PRIMARY KEY,
  zona            TEXT NOT NULL,
  descripcion     TEXT,
  creado          TEXT DEFAULT (datetime('now','localtime')),
  ultimo_contacto TEXT
);

CREATE TABLE IF NOT EXISTS lecturas (
  id          INTEGER PRIMARY KEY,
  ts          TEXT NOT NULL DEFAULT (datetime('now','localtime')),
  dispositivo TEXT NOT NULL REFERENCES dispositivos(id),
  temperatura REAL,
  humedad     REAL,
  rssi        INTEGER,
  heap_libre  INTEGER,
  uptime      INTEGER
);
CREATE INDEX IF NOT EXISTS idx_lecturas_disp_ts ON lecturas(dispositivo, ts);

CREATE TABLE IF NOT EXISTS estados_rele (
  id          INTEGER PRIMARY KEY,
  ts          TEXT NOT NULL DEFAULT (datetime('now','localtime')),
  dispositivo TEXT NOT NULL REFERENCES dispositivos(id),
  rele        TEXT NOT NULL,
  estado      INTEGER NOT NULL,
  origen      TEXT
);

CREATE TABLE IF NOT EXISTS eventos (
  id      INTEGER PRIMARY KEY,
  ts      TEXT NOT NULL DEFAULT (datetime('now','localtime')),
  nivel   TEXT NOT NULL DEFAULT 'info',
  origen  TEXT,
  mensaje TEXT NOT NULL
);

INSERT OR IGNORE INTO dispositivos (id, zona, descripcion)
VALUES ('esp32-habitacion', 'habitacion', 'ESP32 DevKit V1 + DHT22 + OLED + relé de luz');
