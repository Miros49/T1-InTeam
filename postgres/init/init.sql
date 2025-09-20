-- init.sql для Postgres (./postgres/init/init.sql)

CREATE TABLE IF NOT EXISTS sites (
    id SERIAL PRIMARY KEY,
    url TEXT NOT NULL UNIQUE,             -- 👈 теперь уникальный
    name TEXT NOT NULL,
    com JSONB DEFAULT '{}'::jsonb,        -- любые дополнительные настройки
    last_traffic_light TEXT,              -- последний статус (green/orange/red)
    history JSONB DEFAULT '[]'::jsonb,    -- история последних проверок
    ping_interval INTEGER DEFAULT 30,     -- частота проверки (в секундах)
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Индексы для ускорения выборок
CREATE INDEX IF NOT EXISTS idx_sites_url ON sites(url);
CREATE INDEX IF NOT EXISTS idx_sites_name ON sites(name);

-- Триггер для автообновления updated_at
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_sites_updated_at ON sites;
CREATE TRIGGER trg_sites_updated_at
BEFORE UPDATE ON sites
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();
