# Citaria

Aplicación de gestión de citas para negocios de servicios. Consta de una API REST
(Spring Boot) y una app móvil (Flutter).

```
citaria/
├── citaria_backend/    # API REST — Spring Boot 3 · Java 17 · MariaDB
└── citaria_frontend/   # App móvil — Flutter
```

> La app actualmente corre desplegada en un servidor (Railway). Esta guía cubre
> cómo levantarla y probarla **en local** de principio a fin.

---

## Requisitos previos

| Herramienta | Versión | Uso |
|---|---|---|
| Java JDK | 17 | Compilar y ejecutar el backend |
| Docker y Docker Compose | Estable | Levantar la base de datos MariaDB |
| Flutter SDK | ≥ 3.10 | Compilar y ejecutar la app |
| Git | Estable | Clonar el repositorio |

> Maven no hace falta instalarlo: el backend incluye el wrapper (`./mvnw`).

---

## Probar en local — paso a paso

### 1. Clonar el repositorio

### 2. Configurar las variables de entorno

El backend usa variables de entorno que **no se incluyen en el repositorio**. Se
proporciona `citaria_backend/.env_ejemplo` como referencia. Crea tu propio `.env`:

Rellena los valores en `.env`:

```env
# JWT
JWT_SECRET=               # mínimo 32 caracteres
JWT_EXPIRATION_MS=86400000

# Spring — conexión a la base de datos
DB_USERNAME=citaria
DB_PASSWORD=citaria

# Docker Compose — MariaDB (DB_USERNAME/DB_PASSWORD deben coincidir con estos)
MARIADB_ROOT_PASSWORD=root
MARIADB_DATABASE=citaria
MARIADB_USER=citaria
MARIADB_PASSWORD=citaria

# Gemini (chatbot)
GEMINI_API_KEY=
GEMINI_API_URL=

# Cloudinary (subida de imágenes)
CLOUDINARY_CLOUD_NAME=
CLOUDINARY_API_KEY=
CLOUDINARY_API_SECRET=
```

> **Importante:**
> - `DB_USERNAME`/`DB_PASSWORD` deben coincidir con `MARIADB_USER`/`MARIADB_PASSWORD`.
> - Docker Compose lee el `.env` automáticamente. El backend, al arrancarlo desde
>   el IDE o la terminal, necesita que esas variables estén cargadas en su entorno
>   de ejecución.
> - `GEMINI_*` y `CLOUDINARY_*` solo son necesarias para el chatbot y la subida de
>   imágenes respectivamente; el resto de la app funciona sin ellas.

### 3. Levantar la base de datos

Arranca **MariaDB 10.11** en el puerto `3306` y ejecuta automáticamente:

- `docker/scripts/init.sql` — crea el esquema completo.
- `docker/scripts/data.sql` — carga datos de prueba (incluidos los usuarios de prueba).

También levanta **phpMyAdmin** en `http://localhost:8081` para inspeccionar la BD.

### 4. Arrancar el backend

Desde `citaria_backend/`, con el perfil `dev` (deja Swagger activo):

```bash
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

El backend queda disponible en `http://localhost:8080`. La documentación interactiva
de la API está en `http://localhost:8080/swagger-ui.html`.

### 5. Apuntar el frontend al backend local

Por defecto la app apunta al servidor de producción. Para probar contra tu backend
local, edita `citaria_frontend/lib/data/api/configuracion_api.dart`:

```dart
static const String urlBase = 'http://localhost:8080';
```

### 6. Ejecutar la app Flutter

### 7. Comprobar que todo funciona

Inicia sesión con uno de los usuarios de prueba (organización **1**):

| Rol | Email | Contraseña |
|---|---|---|
| Admin | `admin@admin.com` | `12345678` |
| Cliente | `cliente@cliente.com` | `12345678` |

> También puedes crear un cliente nuevo desde la opción de **registro** de la app.

---
