# Worlify — Infraestructura Compartida

Configuración de bases de datos compartidas entre microservicios.

---

## Estrategia de Bases de Datos

Una **instancia por motor** con **bases de datos aisladas por microservicio**. Los MS nunca comparten la misma base de datos ni hacen JOIN entre ellas — las referencias cruzadas son UUIDs lógicos.

| Motor      | Propósito                        | Puerto |
| ---------- | -------------------------------- | ------ |
| PostgreSQL | Datos transaccionales de cada MS | 5432   |
| MongoDB    | Logs y auditoría de cada MS      | 27017  |
| Redis      | Caché compartido                 | 6379   |

---

## Bases de Datos por Microservicio

| Microservicio | PostgreSQL DB        | MongoDB DB               |
| ------------- | -------------------- | ------------------------ |
| ms-auth       | `worlify_auth`       | `worlify_auth_logs`      |
| ms-songs      | `worlify_songs`      | `worlify_songs_logs`     |

---

## Convención de Nombres

```
PostgreSQL:  worlify_<ms-name>
MongoDB:     worlify_<ms-name>_logs
```

---

## Agregar un Nuevo Microservicio

### 1. PostgreSQL — `infra/postgres/init/01_create_databases.sql`

Añadir al final del archivo:

```sql
-- ms-<name>
CREATE DATABASE worlify_<name>;
GRANT ALL PRIVILEGES ON DATABASE worlify_<name> TO worlify;
```

### 2. MongoDB — `infra/mongo/init/01_create_databases.js`

Añadir al final del archivo (solo si el MS usa MongoDB):

```js
// ms-<name>
db = db.getSiblingDB('worlify_<name>_logs');
db.createCollection('_init');
```

### 3. Variables de entorno — `worlify_backend/ms-<name>/.env.example`

```env
# PostgreSQL
<NAME>_DB_HOST=localhost
<NAME>_DB_PORT=5432
<NAME>_DB_NAME=worlify_<name>
<NAME>_DB_USER=worlify
<NAME>_DB_PASSWORD=worlify123

# MongoDB (si aplica)
MONGO_URI=mongodb://localhost:27017/worlify_<name>_logs
```

### 4. `application.yml` del MS

```yaml
spring:
  datasource:
    url: jdbc:postgresql://${<NAME>_DB_HOST:localhost}:${<NAME>_DB_PORT:5432}/${<NAME>_DB_NAME:worlify_<name>}
    username: ${<NAME>_DB_USER:worlify}
    password: ${<NAME>_DB_PASSWORD:worlify123}

  # Solo si usa MongoDB:
  data:
    mongodb:
      uri: ${MONGO_URI:mongodb://localhost:27017/worlify_<name>_logs}
```

### 5. `docker-compose.yml` raíz — bloque del nuevo MS

```yaml
ms-<name>:
  build:
    context: ./worlify_backend/ms-<name>
    dockerfile: Dockerfile
  container_name: worlify-ms-<name>
  env_file:
    - ./worlify_backend/ms-<name>/.env
  environment:
    <NAME>_DB_HOST: postgres
    <NAME>_DB_PORT: 5432
    <NAME>_DB_NAME: worlify_<name>
    REDIS_HOST: redis
    KAFKA_SERVERS: kafka:9092
    # Solo si usa MongoDB:
    MONGO_URI: mongodb://mongodb:27017/worlify_<name>_logs
  ports:
    - "<port>:<port>"
  depends_on:
    postgres:
      condition: service_healthy
    redis:
      condition: service_healthy
    kafka:
      condition: service_healthy
    # Solo si usa MongoDB:
    mongodb:
      condition: service_healthy
  networks:
    - worlify-network
```

> **Importante:** Los init scripts de Postgres y Mongo solo se ejecutan la **primera vez** que se crean los volúmenes (entorno desde cero).
>
> **Si el contenedor ya está corriendo**, crear la DB directamente:
> ```bash
> # PostgreSQL
> docker exec worlify-postgres psql -U worlify -c "CREATE DATABASE worlify_<name>;"
>
> # MongoDB — no hace falta, se crea automáticamente al primer uso
> ```
>
> **Si quieres recrear todo desde cero** (pierde todos los datos):
> ```bash
> docker-compose down -v
> docker-compose up -d
> ```
