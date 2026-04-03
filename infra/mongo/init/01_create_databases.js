// =============================================================
// Worlify — MongoDB Init Script
// Se ejecuta automáticamente al crear el contenedor por primera vez.
// MONGO_INITDB_DATABASE (definido en docker-compose.yml) ya crea worlify_auth_logs.
//
// Convención de nombres:
//   worlify_<ms-name>_logs
//
// Microservicios registrados:
//   ms-auth   → worlify_auth_logs   (creada via MONGO_INITDB_DATABASE)
//   ms-songs  → worlify_songs_logs
//
// Para agregar un nuevo MS:
//   1. Añadir bloque getSiblingDB + createCollection aquí
//   2. Agregar variable MONGO_URI en su .env.example
//   3. Agregar environment override en docker-compose.yml (si aplica)
// =============================================================

// ms-songs
db = db.getSiblingDB('worlify_songs_logs');
db.createCollection('_init');
