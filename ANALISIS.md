# Handoff — Capa de testing (pendiente)

> Registro para continuar mañana. Tienes acceso al proyecto y puedes buscar/leer.
> Objetivo acordado: testear **solo las partes importantes** (lógica de negocio back + lógica pura front), sin cubrir getters/widgets/CRUD trivial.

---

## Estado actual (hecho)

- ✅ **`citaria_backend/src/test/java/com/citaria/service/DisponibilidadServiceImplTest.java`** — 9 tests, Mockito, verde. Cubre salidas tempranas + generación de franjas + solapes + periodo con cierre.
- ✅ **`citaria_frontend/test/viewmodels/viewmodel_wizard_test.dart`** — 2 tests, fake a mano. Cubre la race de `cargarFranjas` + carga normal.

## Convenciones de testing (YA decididas, respétalas)

**Backend** — JUnit 5 + **Mockito** (ya en `spring-boot-starter-test`, sin deps nuevas):
- `@ExtendWith(MockitoExtension.class)`, `@Mock` en cada DAO, `@InjectMocks` el servicio.
- Strict stubs por defecto → **stubea solo lo que el test usa** (si no, `UnnecessaryStubbingException`).
- Entidades **sin Lombok**, tienen setters planos (`new X(); x.setY(...)`). Usa helpers privados para construirlas (mira el patrón en `DisponibilidadServiceImplTest`).
- Usa **fechas futuras (no hoy)** para evitar lógica dependiente de `LocalDate.now()`/`LocalTime.now()`.
- Tests en `src/test/java/com/citaria/...`.

**Frontend** — **fakes a mano** (NO mockito/mocktail):
- Subclase del repo real en el propio test, override de los métodos necesarios (con `Completer` si hay que controlar orden async). Ver `_RepoDisponibilidadFake` en `viewmodel_wizard_test.dart`.
- `test/` replica la estructura de `lib/`.
- Si el VM construye un `DateFormat('es_ES')`, llama `await initializeDateFormatting('es_ES', null)` en `setUpAll` (import `package:intl/date_symbol_data_local.dart`).
- Constructores: `RepoX(this._api)`, `CitariaApi(this._httpClient)` → para deps no usadas pasa `RepoX(CitariaApi(http.Client()))`.

## Comandos
- Back: `cd citaria_backend && ./mvnw test -Dtest=NombreClaseTest` (o `./mvnw test` para todo).
- Front: `cd citaria_frontend && flutter test test/ruta/al_test.dart` (o `flutter test`).
- ⚠️ El cwd de bash puede quedarse en subcarpetas; usa rutas absolutas o `cd` explícito.

---

## TESTS PENDIENTES (por prioridad)

### 1. 🔴 Backend — `ReservaServiceImpl` (lo más valioso que queda)
**Fichero a crear:** `citaria_backend/src/test/java/com/citaria/service/ReservaServiceImplTest.java`
**Clase:** `service/ReservaServiceImpl.java` (632 líneas). Lee el constructor para la lista exacta de DAOs a `@Mock` (incluye `reservaDAO`, `reservaServicioDAO`, `clienteDAO`, `servicioDAO`, `empleadoDAO`, `servicioHabilidadDAO`, `empleadoHabilidadDAO`, `contextoSeguridad`…).

**Qué cubrir:**
- **`crear(clienteId, dto)`** — validaciones de entrada (recién cambiadas): servicios vacíos / `horaInicio` null / fecha pasada → ahora lanzan **`IllegalArgumentException`** (no `IllegalStateException`). Límite de 5 reservas activas → `IllegalStateException`. Solape (mock `reservaServicioDAO.contarSolapamientos(...) > 0`) → `IllegalStateException("No hay disponibilidad...")`.
- **Asignación automática de empleado** (`buscarEmpleadoDisponible`, empleadoId null): elige el de menos carga (`contarReservasPorEmpleadoYFecha`) entre los que tienen las habilidades (`servicioHabilidadDAO.obtenerHabilidadIdsRequeridas` + `empleadoHabilidadDAO.contarHabilidadesQueCoinciden`).
- **`actualizarEstado(id, estado)`** y `validarTransicion` (privado, testéalo a través del público): pendiente→{confirmada,cancelada} OK; confirmada→{pendiente,cancelada} OK; cancelada/completada→cualquiera lanza `IllegalStateException`. Al cancelar, verifica que llama `reservaServicioDAO.cancelarDetallesPorReserva(...)` (usa `verify(...)`).
**Gotchas:** `crear` usa `contextoSeguridad.obtenerOrganizacionActual()`; `verificarPertenencia*` comparan ids de organización (mockea entidades con la misma org). `findByIdConLock` devuelve `Optional<Empleado>`. Construye entidades con setters como en el test existente.

### 2. 🟢 Frontend — `Validadores` (lo más barato, cero mocks)
**Fichero a crear:** `citaria_frontend/test/ui/utils/validadores_test.dart`
**Clase:** `lib/ui/utils/validadores.dart` — métodos estáticos puros que devuelven `String?` (null = válido). Lee el fichero para firmas/reglas exactas (longitudes min/max, flag `obligatorio`, regex).
**Qué cubrir:** `nombrePersonaValidador`, `telefonoValidador`, `dniValidador`, `emailValidador`, `nombreCatalogoValidador`, precio: caso válido, vacío+obligatorio, por debajo del mínimo, por encima del máximo, formato inválido. Sin mocks: llamar y asertar el `String?`.

### 3. 🟢 Frontend — modelos `fromJson` con lógica
**Ficheros a crear:** `test/data/models/reserva_test.dart`, `franja_horaria_test.dart` (+ opcional `pagina_reservas_test.dart`).
**Clases:** `lib/data/models/reserva.dart` (parseo defensivo: `as String?`, `?? []`, manejo de null), `franja_horaria.dart` (casts duros + `_parsearHora`), `disponibilidad.dart`, `pagina_reservas.dart`.
**Qué cubrir:** construir un `Map<String,dynamic>` representativo y asertar los campos parseados; casos con campos null/ausentes (los defensivos no deben petar; los de cast duro documentan el comportamiento actual). Sin mocks.

### 4. 🟡 Backend — `EstadisticaServiceImpl` (ligero, 3-4 tests)
**Fichero:** `citaria_backend/src/test/java/com/citaria/service/EstadisticaServiceImplTest.java`
**Qué cubrir:** cálculo de porcentaje y **división por cero** (total=0 → 0.0) y redondeo (`Math.round(x*100)/100`), en `reservasPorEmpleado`/`cancelacionesPor*` (líneas ~115,145,195,268).
**Gotcha:** el DAO devuelve **proyecciones (interfaces)**; tendrás que mockear el DAO para que devuelva objetos proyección (mock de la interfaz de proyección con `when(proj.getX()).thenReturn(...)`). Mira `repository/EstadisticaDAO.java` y los tipos que devuelve antes de empezar.

### 5. 🟢 Frontend — `ViewModelWizard` cálculos (ampliar el test existente)
**Fichero:** ampliar `test/viewmodels/viewmodel_wizard_test.dart`.
**Qué cubrir:** `duracionTotalMinutos`, `precioTotal`, `diasCalendario` (generación de celdas), `franjas` getter. Necesitas un **fake de `RepoCatalogo`** que devuelva servicios en `listarServicios` para poder `inicializar()` y `toggleServicio()`.
**Gotcha:** `_franjaYaPaso` solo filtra franjas pasadas **si la fecha es hoy**; para testearlo usa fecha = hoy (rompe el determinismo de fechas futuras, tenlo en cuenta).

---

## Otros pendientes NO-test (no perder de vista)

**Bug conocido sin corregir:** `DisponibilidadServiceImpl:134` — `horaCierre.minusMinutes(duracionTotalMinutos)` da la vuelta a medianoche si la duración supera la ventana horaria → genera franjas inválidas. Al corregirlo, añadir su test de regresión (por eso no se incluyó en el test actual).

**Pendientes que afectan al funcionamiento (sin tocar):**
- 🟡 `viewmodel_admin_reservas.dart:170-188` `cargarMas` comparte `_cargando` y un fallo machaca la lista visible.
- 🟡 `viewmodel_chatbot.dart:82-96` envíos concurrentes podrían quitar el mensaje equivocado.
- 🔵 `Consumer<VM>` envolviendo el `Scaffold` entero en `estadisticas:47`, `ajustes:126`, `inicio:115`, `calendario:86` → rebuilds.
- 🔵 `PopScope` siempre `true` en `detalle_cliente:71`/`detalle_empleado:70` → recarga innecesaria al volver.

**Calidad / arquitectura (no funcional):** fuga de `data/enums` + `_estadoVisual` ×4 y reglas de negocio en la vista (`_estadosPermitidos` en `detalle_reserva:557`); VM admin devuelven modelos crudos; `@Autowired` redundante; typo `verificarPerenenciaServicio`; duplicaciones varias (conversores reserva, porcentajes, helpers de fecha/VM). Detalle: estaba en este MD antes de reescribirlo; se puede re-derivar leyendo el código.

**Ya corregido este sprint (con/ sin test):** race wizard (con test) · estadísticas todo-o-nada · dispose en `ViewModelAdminBase` · `cancelarReserva` cliente · N+1 `viewmodel_admin_inicio` · `TareaExpiracionReservas` cancela líneas · cierre duplicado en `OrganizacionServiceImpl` · validación de entrada 409→400 en `ReservaServiceImpl.crear`.

**Recuerda el flujo de trabajo:** proponer → discutir → aprobar → codificar. No escribir código sin OK expreso. Los commits los hace el usuario.
