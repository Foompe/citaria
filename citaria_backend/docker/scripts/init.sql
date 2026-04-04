CREATE TABLE organizacion
(
    id            INT  AUTO_INCREMENT PRIMARY KEY,
    nombre        VARCHAR(100) NOT NULL,
    email         VARCHAR(255) NOT NULL UNIQUE,
    telefono      VARCHAR(20)  NULL,
    cif           VARCHAR(20)  NULL UNIQUE,
    calle         VARCHAR(255) NULL,
    codigo_postal VARCHAR(10)  NULL,
    ciudad        VARCHAR(100) NULL,
    pais          VARCHAR(2)   NOT NULL
);

CREATE TABLE organizacion_horario
(
    id              INT  AUTO_INCREMENT PRIMARY KEY,
    organizacion_id INT      NOT NULL,
    dia_semana      TINYINT  NOT NULL CHECK (dia_semana BETWEEN 1 AND 7),
    hora_apertura   TIME             NOT NULL,
    hora_cierre     TIME             NOT NULL,
    activo          BOOLEAN          NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_orh_organizacion FOREIGN KEY (organizacion_id)
        REFERENCES organizacion (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uq_orh_dia UNIQUE (organizacion_id, dia_semana)
);

CREATE TABLE organizacion_horario_cierre
(
    id              INT  AUTO_INCREMENT PRIMARY KEY,
    organizacion_id INT  NOT NULL,
    fecha           DATE         NOT NULL,
    motivo          VARCHAR(100) NULL,
    CONSTRAINT fk_ohc_organizacion FOREIGN KEY (organizacion_id)
        REFERENCES organizacion (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uq_ohc_fecha UNIQUE (organizacion_id, fecha)
);

CREATE TABLE configuracion_visual
(
    id               INT  AUTO_INCREMENT PRIMARY KEY,
    organizacion_id  INT  NOT NULL UNIQUE,
    logo_url         VARCHAR(500) NULL,
    favicon_url      VARCHAR(500) NULL,
    icono_app_url    VARCHAR(500) NULL,
    color_primario   VARCHAR(7)   NULL,
    color_secundario VARCHAR(7)   NULL,
    tipografia       VARCHAR(100) NULL,
    CONSTRAINT fk_cv_organizacion FOREIGN KEY (organizacion_id)
        REFERENCES organizacion (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE cliente
(
    id              INT  AUTO_INCREMENT PRIMARY KEY,
    organizacion_id INT  NOT NULL,
    nombre          VARCHAR(100) NOT NULL,
    apellidos       VARCHAR(150) NULL,
    dni             VARCHAR(9)   NULL,
    email           VARCHAR(255) NULL,
    telefono        VARCHAR(20)  NULL,
    notas           TEXT         NULL,
    anonimizado_at  DATETIME     NULL,
    CONSTRAINT fk_cli_organizacion FOREIGN KEY (organizacion_id)
        REFERENCES organizacion (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uq_cli_dni UNIQUE (organizacion_id, dni)
);

CREATE TABLE empleado
(
    id              INT  AUTO_INCREMENT PRIMARY KEY,
    organizacion_id INT  NOT NULL,
    nombre          VARCHAR(100) NOT NULL,
    apellidos       VARCHAR(150) NOT NULL,
    email           VARCHAR(255) NULL,
    telefono        VARCHAR(20)  NULL,
    foto_url        VARCHAR(500) NULL,
    activo          BOOLEAN      NOT NULL DEFAULT TRUE,
    anonimizado_at  DATETIME     NULL,
    CONSTRAINT fk_emp_organizacion FOREIGN KEY (organizacion_id)
        REFERENCES organizacion (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uq_emp_email UNIQUE (organizacion_id, email)
);

CREATE TABLE usuario
(
    id               INT  AUTO_INCREMENT PRIMARY KEY,
    organizacion_id  INT          NOT NULL,
    email            VARCHAR(255) NOT NULL UNIQUE,
    password_hash    VARCHAR(255) NOT NULL,
    rol              ENUM('ADMIN','EMPLEADO','CLIENTE') NOT NULL,
    activo           BOOLEAN      NOT NULL DEFAULT TRUE,
    email_verificado BOOLEAN      NOT NULL DEFAULT FALSE,
    ultimo_acceso    DATETIME     NULL,
    cliente_id       INT          NULL UNIQUE,
    empleado_id      INT          NULL UNIQUE,
    CONSTRAINT fk_usu_organizacion FOREIGN KEY (organizacion_id)
        REFERENCES organizacion (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_usu_cliente FOREIGN KEY (cliente_id)
        REFERENCES cliente (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_usu_empleado FOREIGN KEY (empleado_id)
        REFERENCES empleado (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE horario_empleado
(
    id          INT  AUTO_INCREMENT PRIMARY KEY,
    empleado_id INT      NOT NULL,
    dia_semana  TINYINT  NOT NULL CHECK (dia_semana BETWEEN 1 AND 7),
    hora_inicio TIME             NOT NULL,
    hora_fin    TIME             NOT NULL,
    activo      BOOLEAN          NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_he_empleado FOREIGN KEY (empleado_id)
        REFERENCES empleado (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uq_he_dia UNIQUE (empleado_id, dia_semana)
);

CREATE TABLE skill
(
    id              INT  AUTO_INCREMENT PRIMARY KEY,
    organizacion_id INT  NOT NULL,
    nombre          VARCHAR(100) NOT NULL,
    descripcion     TEXT         NULL,
    CONSTRAINT fk_sk_organizacion FOREIGN KEY (organizacion_id)
        REFERENCES organizacion (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uq_sk_nombre UNIQUE (organizacion_id, nombre)
);

CREATE TABLE categoria
(
    id              INT  AUTO_INCREMENT PRIMARY KEY,
    organizacion_id INT  NOT NULL,
    nombre          VARCHAR(100) NOT NULL,
    CONSTRAINT fk_cat_organizacion FOREIGN KEY (organizacion_id)
        REFERENCES organizacion (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uq_cat_nombre UNIQUE (organizacion_id, nombre)
);

CREATE TABLE servicio
(
    id               INT  AUTO_INCREMENT PRIMARY KEY,
    organizacion_id  INT       NOT NULL,
    categoria_id     INT       NULL,
    nombre           VARCHAR(100)      NOT NULL,
    descripcion      TEXT              NULL,
    imagen_url       VARCHAR(500)      NULL,
    precio           DECIMAL(10, 2)    NOT NULL,
    duracion_minutos SMALLINT  NOT NULL,
    activo           BOOLEAN           NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_srv_organizacion FOREIGN KEY (organizacion_id)
        REFERENCES organizacion (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_srv_categoria FOREIGN KEY (categoria_id)
        REFERENCES categoria (id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE servicio_skill
(
    servicio_id INT  NOT NULL,
    skill_id    INT  NOT NULL,
    PRIMARY KEY (servicio_id, skill_id),
    CONSTRAINT fk_ss_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicio (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_ss_skill FOREIGN KEY (skill_id)
        REFERENCES skill (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE empleado_skill
(
    empleado_id INT  NOT NULL,
    skill_id    INT  NOT NULL,
    PRIMARY KEY (empleado_id, skill_id),
    CONSTRAINT fk_es_empleado FOREIGN KEY (empleado_id)
        REFERENCES empleado (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_es_skill FOREIGN KEY (skill_id)
        REFERENCES skill (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE reserva
(
    id              INT  AUTO_INCREMENT PRIMARY KEY,
    organizacion_id INT  NOT NULL,
    cliente_id      INT  NOT NULL,
    estado          ENUM ('pendiente','confirmada','cancelada','completada')
                         NOT NULL DEFAULT 'pendiente',
    fecha           DATE         NOT NULL,
    notas           TEXT         NULL,
    CONSTRAINT fk_res_organizacion FOREIGN KEY (organizacion_id)
        REFERENCES organizacion (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_res_cliente FOREIGN KEY (cliente_id)
        REFERENCES cliente (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE reserva_servicio
(
    id              INT  AUTO_INCREMENT PRIMARY KEY,
    reserva_id      INT    NOT NULL,
    servicio_id     INT    NOT NULL,
    empleado_id     INT    NOT NULL,
    hora_inicio     TIME           NOT NULL,
    hora_fin        TIME           NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    cantidad        INT   NOT NULL DEFAULT 1,
    CONSTRAINT fk_rs_reserva FOREIGN KEY (reserva_id)
        REFERENCES reserva (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_rs_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicio (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_rs_empleado FOREIGN KEY (empleado_id)
        REFERENCES empleado (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);