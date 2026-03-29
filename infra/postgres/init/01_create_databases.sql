-- =============================================================
-- Worlify — PostgreSQL Init Script
-- Se ejecuta automáticamente al crear el contenedor por primera vez.
-- POSTGRES_DB (definido en docker-compose.yml) ya crea worlify_auth.
--
-- Convención de nombres:
--   worlify_<ms-name>
--
-- Microservicios registrados:
--   ms-auth       → worlify_auth       (creada via POSTGRES_DB)
--   ms-songs      → worlify_songs
--   ms-ministries → worlify_ministries
--   ms-events     → worlify_events
--
-- Para agregar un nuevo MS:
--   1. Añadir bloque CREATE DATABASE + GRANT aquí
--   2. Agregar las variables DB_HOST/PORT/NAME equivalentes en su .env.example
--   3. Agregar environment override en docker-compose.yml
-- =============================================================

-- ms-songs
CREATE DATABASE worlify_songs;
GRANT ALL PRIVILEGES ON DATABASE worlify_songs TO worlify;

-- ms-ministries
CREATE DATABASE worlify_ministries;
GRANT ALL PRIVILEGES ON DATABASE worlify_ministries TO worlify;

-- ms-events
CREATE DATABASE worlify_events;
GRANT ALL PRIVILEGES ON DATABASE worlify_events TO worlify;

-- ms-users
CREATE DATABASE worlify_users;
GRANT ALL PRIVILEGES ON DATABASE worlify_users TO worlify;

