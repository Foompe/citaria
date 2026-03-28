-- ─────────────────────────────────────────
-- CITARIA — Script de inicialización BD
-- ─────────────────────────────────────────

-- ─────────────────────────────────────────
-- EMPRESA
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS empresa (
    id               BIGINT       NOT NULL AUTO_INCREMENT,
    nombre           VARCHAR(100) NOT NULL,
    logo_url         VARCHAR(255),
    color_primario   VARCHAR(7)   NOT NULL DEFAULT '#1F3864',
    color_secundario VARCHAR(7)   NOT NULL DEFAULT '#2E75B6',
    tipografia       VARCHAR(50)  NOT NULL DEFAULT 'Roboto',
    telefono         VARCHAR(20),
    email            VARCHAR(150),
    direccion        VARCHAR(255),
    ciudad           VARCHAR(100),
    codigo_postal    VARCHAR(10),
    horario_apertura TIME,
    horario_cierre   TIME,
    descripcion      TEXT,
    PRIMARY KEY (id)
    );

-- ─────────────────────────────────────────
-- EMPRESA_HORARIO
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS empresa_horario (
    id          BIGINT NOT NULL AUTO_INCREMENT,
    empresa_id  BIGINT NOT NULL,
    dia_semana  ENUM('LUNES','MARTES','MIERCOLES','JUEVES',
    'VIERNES','SABADO','DOMINGO') NOT NULL,
    hora_apertura TIME  NOT NULL,
    hora_cierre   TIME  NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_empresa_horario_empresa FOREIGN KEY (empresa_id)
    REFERENCES empresa (id) ON DELETE CASCADE
    );

-- ─────────────────────────────────────────
-- USUARIO
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS usuario (
    id         BIGINT       NOT NULL AUTO_INCREMENT,
    email      VARCHAR(150) NOT NULL UNIQUE,
    password   VARCHAR(255) NOT NULL,
    rol        ENUM('EMPRESA', 'CLIENTE') NOT NULL,
    empresa_id BIGINT       NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_usuario_empresa FOREIGN KEY (empresa_id)
    REFERENCES empresa (id) ON DELETE CASCADE
    );

-- ─────────────────────────────────────────
-- SKILL
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS skill (
    id          BIGINT       NOT NULL AUTO_INCREMENT,
    nombre      VARCHAR(100) NOT NULL,
    descripcion TEXT,
    empresa_id  BIGINT       NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_skill_empresa FOREIGN KEY (empresa_id)
    REFERENCES empresa (id) ON DELETE CASCADE
    );

-- ─────────────────────────────────────────
-- SERVICIO
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS servicio (
    id           BIGINT         NOT NULL AUTO_INCREMENT,
    nombre       VARCHAR(100)   NOT NULL,
    descripcion  TEXT,
    duracion_min INT            NOT NULL,
    precio       DECIMAL(10, 2) NOT NULL,
    imagen_url   VARCHAR(255),
    activo       BOOLEAN        NOT NULL DEFAULT TRUE,
    empresa_id   BIGINT         NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_servicio_empresa FOREIGN KEY (empresa_id)
    REFERENCES empresa (id) ON DELETE CASCADE
    );

-- ─────────────────────────────────────────
-- SERVICIO_SKILL
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS servicio_skill (
    servicio_id BIGINT NOT NULL,
    skill_id    BIGINT NOT NULL,
    PRIMARY KEY (servicio_id, skill_id),
    CONSTRAINT fk_ss_servicio FOREIGN KEY (servicio_id)
    REFERENCES servicio (id) ON DELETE CASCADE,
    CONSTRAINT fk_ss_skill FOREIGN KEY (skill_id)
    REFERENCES skill (id) ON DELETE CASCADE
    );

-- ─────────────────────────────────────────
-- EMPLEADO
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS empleado (
    id          BIGINT         NOT NULL AUTO_INCREMENT,
    nombre      VARCHAR(100),
    apellidos   VARCHAR(150),
    dni         VARCHAR(20),
    email       VARCHAR(150),
    telefono    VARCHAR(20),
    foto_url    VARCHAR(255),
    salario     DECIMAL(10, 2),
    activo      BOOLEAN        NOT NULL DEFAULT TRUE,
    anonimizado BOOLEAN        NOT NULL DEFAULT FALSE,
    empresa_id  BIGINT         NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_empleado_empresa FOREIGN KEY (empresa_id)
    REFERENCES empresa (id) ON DELETE CASCADE,
    CONSTRAINT uq_empleado_email_empresa UNIQUE (email, empresa_id)
    );

-- ─────────────────────────────────────────
-- EMPLEADO_SKILL
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS empleado_skill (
    empleado_id BIGINT NOT NULL,
    skill_id    BIGINT NOT NULL,
    PRIMARY KEY (empleado_id, skill_id),
    CONSTRAINT fk_es_empleado FOREIGN KEY (empleado_id)
    REFERENCES empleado (id) ON DELETE CASCADE,
    CONSTRAINT fk_es_skill FOREIGN KEY (skill_id)
    REFERENCES skill (id) ON DELETE CASCADE
    );

-- ─────────────────────────────────────────
-- HORARIO_EMPLEADO
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS horario_empleado (
    id          BIGINT NOT NULL AUTO_INCREMENT,
    empleado_id BIGINT NOT NULL,
    dia_semana  ENUM('LUNES','MARTES','MIERCOLES','JUEVES',
    'VIERNES','SABADO','DOMINGO') NOT NULL,
    hora_inicio TIME   NOT NULL,
    hora_fin    TIME   NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_horario_empleado FOREIGN KEY (empleado_id)
    REFERENCES empleado (id) ON DELETE CASCADE
    );

-- ─────────────────────────────────────────
-- CLIENTE
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS cliente (
    id               BIGINT       NOT NULL AUTO_INCREMENT,
    nombre           VARCHAR(100),
    apellidos        VARCHAR(150),
    dni              VARCHAR(20),
    email            VARCHAR(150),
    telefono         VARCHAR(20),
    fecha_nacimiento DATE,
    bloqueado        BOOLEAN      NOT NULL DEFAULT FALSE,
    anonimizado      BOOLEAN      NOT NULL DEFAULT FALSE,
    usuario_id       BIGINT       UNIQUE,
    empresa_id       BIGINT       NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_cliente_usuario FOREIGN KEY (usuario_id)
    REFERENCES usuario (id) ON DELETE SET NULL,
    CONSTRAINT fk_cliente_empresa FOREIGN KEY (empresa_id)
    REFERENCES empresa (id) ON DELETE CASCADE,
    CONSTRAINT uq_cliente_email_empresa UNIQUE (email, empresa_id)
    );

-- ─────────────────────────────────────────
-- RESERVA
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS reserva (
    id                 BIGINT         NOT NULL AUTO_INCREMENT,
    fecha              DATE           NOT NULL,
    hora_inicio        TIME           NOT NULL,
    hora_fin           TIME           NOT NULL,
    estado             ENUM('PENDIENTE','CONFIRMADA','CANCELADA')
    NOT NULL DEFAULT 'PENDIENTE',
    precio_final       DECIMAL(10,2)  NOT NULL,
    notas              TEXT,
    motivo_cancelacion TEXT,
    fecha_creacion     DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    cliente_id         BIGINT         NOT NULL,
    servicio_id        BIGINT         NOT NULL,
    empleado_id        BIGINT         NOT NULL,
    empresa_id         BIGINT         NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_reserva_cliente  FOREIGN KEY (cliente_id)
    REFERENCES cliente  (id) ON DELETE RESTRICT,
    CONSTRAINT fk_reserva_servicio FOREIGN KEY (servicio_id)
    REFERENCES servicio (id) ON DELETE RESTRICT,
    CONSTRAINT fk_reserva_empleado FOREIGN KEY (empleado_id)
    REFERENCES empleado (id) ON DELETE RESTRICT,
    CONSTRAINT fk_reserva_empresa  FOREIGN KEY (empresa_id)
    REFERENCES empresa  (id) ON DELETE CASCADE
    );