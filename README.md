## Despliegue del proyecto

### Requisitos previos

Antes de clonar el repositorio, asegúrate de tener instaladas las siguientes herramientas:

| Herramienta | Versión mínima | Uso |
|---|---|---|
| Java JDK | 17 | Compilar y ejecutar el backend |
| Maven | 3.9 (incluido via wrapper) | Gestión de dependencias del backend |
| Docker y Docker Compose | Cualquier versión estable | Levantar la base de datos MariaDB |
| Git | Cualquier versión estable | Clonar el repositorio |

---

### 1. Clonar el repositorio

El repositorio contiene las siguientes carpetas principales:

```
citaria/
├── citaria_backend/    # API REST — Spring Boot
└── citaria_frontend/   # App móvil — Flutter (en desarrollo)
```

---

### 2. Configurar las variables de entorno

El backend utiliza variables de entorno que **no se incluyen en el repositorio** por razones de seguridad. Se proporciona un archivo `.env_ejemplo` en `citaria_backend/` como referencia.

Las variables requeridas son:

```env
DB_USERNAME=        # Usuario de la base de datos MariaDB
DB_PASSWORD=        # Contraseña de la base de datos MariaDB
MARIADB_ROOT_PASSWORD=  # Contraseña root de MariaDB (usada por Docker)
MARIADB_DATABASE=citaria
MARIADB_USER=       # Mismo valor que DB_USERNAME
MARIADB_PASSWORD=   # Mismo valor que DB_PASSWORD
JWT_SECRET=         # Clave secreta para firmar los tokens JWT (mínimo 32 caracteres)
GEMINI_API_KEY=     # Clave de la API de Google Gemini (necesaria para el chatbot)
```

---

### 3. Levantar la base de datos

Desde la carpeta `citaria_backend/`, ejecuta:

```bash
docker-compose up -d
```

Esto levantará un contenedor con **MariaDB 10.11** en el puerto `3306` y ejecutará automáticamente el script `docker/scripts/init.sql`, que crea el esquema completo de la base de datos.

---

### 4. Arrancar el backend

Abre el proyecto `citaria_backend/` desde tu IDE, asegúrate de que las variables de entorno del `.env` están cargadas en la configuración de ejecución, y lanza la clase principal `CitariaBackendApplication`.

El backend quedará disponible en `http://localhost:8080`.

> **Nota — deshabilitar la autenticación para pruebas:** si se quiere probar la API sin gestionar tokens JWT, en `SecurityConfig.java` basta con sustituir el bloque `authorizeHttpRequests` por `.anyRequest().permitAll()` y comentar la línea `.addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class)`. Con esto todos los endpoints quedan accesibles sin autenticación.

---

### Prueba de la API

Una vez el backend esté en marcha, la documentación interactiva de todos los endpoints está disponible en:

```
http://localhost:8080/swagger-ui.html
```

Desde ahí se pueden probar todas las operaciones REST sin necesidad de ninguna herramienta adicional.

Funcionamiento actual:
1. Entrar en http://localhost:8080/swagger-ui/index.html?continue=#/

<img width="955" height="719" alt="imagen" src="https://github.com/user-attachments/assets/41e75760-ef61-4233-82b8-ec65cb3b30a0" />


2. Abajo de todo en autenticación meter los credenciales de prueba
   
<img width="950" height="112" alt="imagen" src="https://github.com/user-attachments/assets/03463fef-b16c-40a1-a2a6-736ab1820417" />
<img width="935" height="469" alt="imagen" src="https://github.com/user-attachments/assets/16186430-0a61-4bd3-8dcc-3a1c3f24d6b1" />


4. Tomamos el token que nos devuelve y lo metemos en el Authorize de arriba de todo
   
<img width="906" height="392" alt="imagen" src="https://github.com/user-attachments/assets/aceb0c94-aac1-4e8c-a0a6-e02b4cd0261f" />
<img width="794" height="294" alt="imagen" src="https://github.com/user-attachments/assets/46e1d73b-be94-4e04-90eb-771220c96b5f" />


6. Ya podemos hacer consultas logeados, por ejemplo, servicios de una organización
   
<img width="926" height="581" alt="imagen" src="https://github.com/user-attachments/assets/9f11d86f-f611-43de-893b-0a5720e8898a" />
<img width="911" height="497" alt="imagen" src="https://github.com/user-attachments/assets/bed9eb66-2389-4cb2-9ca5-fba4dbcb9a9e" />


O por ejemplo una consulta a la ia preguntando por los servicios que ofrece una empresa

<img width="924" height="444" alt="imagen" src="https://github.com/user-attachments/assets/96f5f8b5-ead2-4a05-bb2b-d18fae38471c" />
<img width="928" height="199" alt="imagen" src="https://github.com/user-attachments/assets/396a9cfc-2ec6-4cb6-b3b7-d3d33d0383d8" />


En la plataforma de ia podemos consular el uso que estamos haciendo del modelo

<img width="1051" height="897" alt="imagen" src="https://github.com/user-attachments/assets/ab38da5c-643a-4d96-8d79-ead6c92840e1" />


