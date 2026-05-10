-- ============================================================
-- DetailCarWash — Datos de prueba
-- Contraseñas: admin → admin2026 | clientes → cliente2026
-- ============================================================

-- ORGANIZACIÓN
INSERT INTO organizacion (nombre, email, telefono, cif, calle, codigo_postal, ciudad, pais, token_registro)
VALUES ('DetailCarWash', 'info@detailcarwash.com', '981234567', 'B12345678',
        'Calle Real 45', '15001', 'A Coruña', 'ES', 'DCW2026');

-- CONFIGURACIÓN VISUAL
INSERT INTO configuracion_visual (organizacion_id, logo_url, color_primario, color_secundario, tipografia, version)
VALUES (1, 'https://res.cloudinary.com/dvvsp9a09/image/upload/v1778440147/logoDCW_x1uq6r.png', '#2E6BFF', '#F5F6FA', 'Syne', 1);

-- CATEGORÍAS
INSERT INTO categoria (organizacion_id, nombre, activo) VALUES
                                                            (1, 'Lavado Exterior', TRUE),
                                                            (1, 'Limpieza Interior', TRUE),
                                                            (1, 'Tratamientos Especiales', TRUE);

-- SERVICIOS
INSERT INTO servicio (organizacion_id, categoria_id, nombre, descripcion, precio, duracion_minutos, activo) VALUES
                                                                                                                (1, 1, 'Lavado Básico Exterior',    'Lavado a mano exterior con agua a presión y secado',         15.00,  30,  TRUE),
                                                                                                                (1, 1, 'Lavado Completo Exterior',  'Lavado exterior completo con champú, abrillantador y secado', 25.00,  45,  TRUE),
                                                                                                                (1, 2, 'Limpieza Interior',         'Aspirado completo, limpieza de salpicadero y cristales',      35.00,  60,  TRUE),
                                                                                                                (1, 1, 'Lavado Completo + Interior','Combinación de lavado exterior completo y limpieza interior', 55.00,  90,  TRUE),
                                                                                                                (1, 3, 'Detailing Completo',        'Tratamiento profesional integral exterior e interior',        120.00, 180, TRUE),
                                                                                                                (1, 3, 'Desodorización y Ozono',    'Eliminación de olores mediante tratamiento de ozono',         40.00,  45,  TRUE);

-- SKILLS
INSERT INTO skill (organizacion_id, nombre, descripcion, activo) VALUES
                                                                     (1, 'Lavado exterior',    'Lavado manual y a presión de carrocería',           TRUE),
                                                                     (1, 'Limpieza interior',  'Aspirado y limpieza de habitáculo',                 TRUE),
                                                                     (1, 'Detailing',          'Tratamiento profesional de pintura y acabados',     TRUE),
                                                                     (1, 'Ozono',              'Manejo de equipos de desodorización por ozono',     TRUE),
                                                                     (1, 'Atención al cliente','Gestión de citas y atención directa al cliente',    TRUE);

-- SERVICIO_SKILL
INSERT INTO servicio_skill (servicio_id, skill_id) VALUES
                                                       (1, 1), -- Lavado Básico → Lavado exterior
                                                       (2, 1), -- Lavado Completo Exterior → Lavado exterior
                                                       (3, 2), -- Limpieza Interior → Limpieza interior
                                                       (4, 1), (4, 2), -- Lavado Completo + Interior → ambas
                                                       (5, 1), (5, 2), (5, 3), -- Detailing → todas menos ozono
                                                       (6, 4); -- Ozono → Ozono

-- EMPLEADOS
INSERT INTO empleado (organizacion_id, nombre, apellidos, email, telefono, activo) VALUES
                                                                                       (1, 'Carlos',    'Fernández López',   'carlos@detailcarwash.com',   '600111001', TRUE),
                                                                                       (1, 'María',     'González Pérez',    'maria@detailcarwash.com',    '600111002', TRUE),
                                                                                       (1, 'Alejandro', 'Martínez Ruiz',     'alejandro@detailcarwash.com','600111003', TRUE),
                                                                                       (1, 'Lucía',     'Rodríguez Sánchez', 'lucia@detailcarwash.com',    '600111004', TRUE),
                                                                                       (1, 'David',     'López García',      'david@detailcarwash.com',    '600111005', TRUE);

-- EMPLEADO_SKILL
-- Carlos: todo
INSERT INTO empleado_skill (empleado_id, skill_id) VALUES (1,1),(1,2),(1,3),(1,4),(1,5);
-- María: lavado exterior + atención
INSERT INTO empleado_skill (empleado_id, skill_id) VALUES (2,1),(2,5);
-- Alejandro: lavado exterior + interior
INSERT INTO empleado_skill (empleado_id, skill_id) VALUES (3,1),(3,2);
-- Lucía: interior + ozono + atención
INSERT INTO empleado_skill (empleado_id, skill_id) VALUES (4,2),(4,4),(4,5);
-- David: detailing + lavado exterior
INSERT INTO empleado_skill (empleado_id, skill_id) VALUES (5,1),(5,3);

-- HORARIOS EMPLEADOS (todos igual: L-V 9-14 y 16-20, S 9-14)
INSERT INTO horario_empleado (empleado_id, dia_semana, hora_inicio, hora_fin, activo) VALUES
                                                                                          (1,1,'09:00','20:00',TRUE),(1,2,'09:00','20:00',TRUE),(1,3,'09:00','20:00',TRUE),
                                                                                          (1,4,'09:00','20:00',TRUE),(1,5,'09:00','20:00',TRUE),(1,6,'09:00','14:00',TRUE),
                                                                                          (2,1,'09:00','20:00',TRUE),(2,2,'09:00','20:00',TRUE),(2,3,'09:00','20:00',TRUE),
                                                                                          (2,4,'09:00','20:00',TRUE),(2,5,'09:00','20:00',TRUE),(2,6,'09:00','14:00',TRUE),
                                                                                          (3,1,'09:00','20:00',TRUE),(3,2,'09:00','20:00',TRUE),(3,3,'09:00','20:00',TRUE),
                                                                                          (3,4,'09:00','20:00',TRUE),(3,5,'09:00','20:00',TRUE),(3,6,'09:00','14:00',TRUE),
                                                                                          (4,1,'09:00','20:00',TRUE),(4,2,'09:00','20:00',TRUE),(4,3,'09:00','20:00',TRUE),
                                                                                          (4,4,'09:00','20:00',TRUE),(4,5,'09:00','20:00',TRUE),(4,6,'09:00','14:00',TRUE),
                                                                                          (5,1,'09:00','20:00',TRUE),(5,2,'09:00','20:00',TRUE),(5,3,'09:00','20:00',TRUE),
                                                                                          (5,4,'09:00','20:00',TRUE),(5,5,'09:00','20:00',TRUE),(5,6,'09:00','14:00',TRUE);

-- HORARIOS ORGANIZACIÓN
INSERT INTO organizacion_horario (organizacion_id, dia_semana, hora_apertura, hora_cierre, activo) VALUES
                                                                                                       (1, 1, '09:00', '20:00', TRUE),
                                                                                                       (1, 2, '09:00', '20:00', TRUE),
                                                                                                       (1, 3, '09:00', '20:00', TRUE),
                                                                                                       (1, 4, '09:00', '20:00', TRUE),
                                                                                                       (1, 5, '09:00', '20:00', TRUE),
                                                                                                       (1, 6, '09:00', '14:00', TRUE);

-- CLIENTES (35 total: 15 con cuenta + 20 sin cuenta)
INSERT INTO cliente (organizacion_id, nombre, apellidos, email, telefono, notas) VALUES
-- Con cuenta (ids 1-15)
(1, 'Juan',      'García Martínez',   'juan.garcia@email.com',      '600200001', NULL),
(1, 'Ana',       'López Fernández',   'ana.lopez@email.com',        '600200002', NULL),
(1, 'Pedro',     'Martínez González', 'pedro.martinez@email.com',   '600200003', NULL),
(1, 'Laura',     'Sánchez Pérez',     'laura.sanchez@email.com',    '600200004', NULL),
(1, 'Miguel',    'González Ruiz',     'miguel.gonzalez@email.com',  '600200005', NULL),
(1, 'Carmen',    'Pérez López',       'carmen.perez@email.com',     '600200006', NULL),
(1, 'Antonio',   'Ruiz García',       'antonio.ruiz@email.com',     '600200007', NULL),
(1, 'Isabel',    'Fernández Díaz',    'isabel.fernandez@email.com', '600200008', NULL),
(1, 'Francisco', 'Díaz Moreno',       'francisco.diaz@email.com',   '600200009', NULL),
(1, 'María José','Moreno Jiménez',    'mariajose.moreno@email.com', '600200010', NULL),
(1, 'José',      'Jiménez Álvarez',   'jose.jimenez@email.com',     '600200011', NULL),
(1, 'Cristina',  'Álvarez Romero',    'cristina.alvarez@email.com', '600200012', NULL),
(1, 'Manuel',    'Romero Torres',     'manuel.romero@email.com',    '600200013', NULL),
(1, 'Patricia',  'Torres Navarro',    'patricia.torres@email.com',  '600200014', NULL),
(1, 'Javier',    'Navarro Domínguez', 'javier.navarro@email.com',   '600200015', NULL),
-- Sin cuenta (ids 16-35)
(1, 'Sergio',    'Domínguez Vega',    'sergio.dominguez@email.com', '600200016', 'Cliente habitual'),
(1, 'Elena',     'Vega Castro',       'elena.vega@email.com',       '600200017', NULL),
(1, 'Roberto',   'Castro Ortega',     'roberto.castro@email.com',   '600200018', NULL),
(1, 'Marta',     'Ortega Rubio',      'marta.ortega@email.com',     '600200019', NULL),
(1, 'Diego',     'Rubio Molina',      'diego.rubio@email.com',      '600200020', NULL),
(1, 'Raquel',    'Molina Delgado',    'raquel.molina@email.com',    '600200021', 'Prefiere cita por la mañana'),
(1, 'Andrés',    'Delgado Ramírez',   'andres.delgado@email.com',   '600200022', NULL),
(1, 'Silvia',    'Ramírez Flores',    'silvia.ramirez@email.com',   '600200023', NULL),
(1, 'Óscar',     'Flores Herrera',    'oscar.flores@email.com',     '600200024', NULL),
(1, 'Natalia',   'Herrera Vargas',    'natalia.herrera@email.com',  '600200025', NULL),
(1, 'Rubén',     'Vargas Iglesias',   'ruben.vargas@email.com',     '600200026', NULL),
(1, 'Verónica',  'Iglesias Santos',   'veronica.iglesias@email.com','600200027', NULL),
(1, 'Héctor',    'Santos Reyes',      'hector.santos@email.com',    '600200028', NULL),
(1, 'Mónica',    'Reyes Blanco',      'monica.reyes@email.com',     '600200029', NULL),
(1, 'Iván',      'Blanco Medina',     'ivan.blanco@email.com',      '600200030', NULL),
(1, 'Beatriz',   'Medina Cortés',     'beatriz.medina@email.com',   '600200031', NULL),
(1, 'Álvaro',    'Cortés Guerrero',   'alvaro.cortes@email.com',    '600200032', NULL),
(1, 'Nuria',     'Guerrero Campos',   'nuria.guerrero@email.com',   '600200033', NULL),
(1, 'Adrián',    'Campos Prieto',     'adrian.campos@email.com',    '600200034', NULL),
(1, 'Lorena',    'Prieto Cano',       'lorena.prieto@email.com',    '600200035', NULL);

-- USUARIO ADMIN
INSERT INTO usuario (organizacion_id, email, password_hash, rol, activo, email_verificado)
VALUES (1, 'admin@detailcarwash.com',
        '$2b$10$yEFAqB941uA8cWGT3MMKO.NdH5h8wM2edDEAbXBLqMLvLwoPLtmLC',
        'ADMIN', TRUE, TRUE);

-- USUARIOS CLIENTES (15 vinculados a fichas 1-15)
INSERT INTO usuario (organizacion_id, email, password_hash, rol, activo, email_verificado, cliente_id)
VALUES
    (1,'juan.garcia@email.com',      '$2b$10$cQlM.8dTarXPURYnYWbJfeBH9pcV9mv6pCQNIxxmgmHAcaKPDwj.u','CLIENTE',TRUE,TRUE,1),
    (1,'ana.lopez@email.com',        '$2b$10$cQlM.8dTarXPURYnYWbJfeBH9pcV9mv6pCQNIxxmgmHAcaKPDwj.u','CLIENTE',TRUE,TRUE,2),
    (1,'pedro.martinez@email.com',   '$2b$10$cQlM.8dTarXPURYnYWbJfeBH9pcV9mv6pCQNIxxmgmHAcaKPDwj.u','CLIENTE',TRUE,TRUE,3),
    (1,'laura.sanchez@email.com',    '$2b$10$cQlM.8dTarXPURYnYWbJfeBH9pcV9mv6pCQNIxxmgmHAcaKPDwj.u','CLIENTE',TRUE,TRUE,4),
    (1,'miguel.gonzalez@email.com',  '$2b$10$cQlM.8dTarXPURYnYWbJfeBH9pcV9mv6pCQNIxxmgmHAcaKPDwj.u','CLIENTE',TRUE,TRUE,5),
    (1,'carmen.perez@email.com',     '$2b$10$cQlM.8dTarXPURYnYWbJfeBH9pcV9mv6pCQNIxxmgmHAcaKPDwj.u','CLIENTE',TRUE,TRUE,6),
    (1,'antonio.ruiz@email.com',     '$2b$10$cQlM.8dTarXPURYnYWbJfeBH9pcV9mv6pCQNIxxmgmHAcaKPDwj.u','CLIENTE',TRUE,TRUE,7),
    (1,'isabel.fernandez@email.com', '$2b$10$cQlM.8dTarXPURYnYWbJfeBH9pcV9mv6pCQNIxxmgmHAcaKPDwj.u','CLIENTE',TRUE,TRUE,8),
    (1,'francisco.diaz@email.com',   '$2b$10$cQlM.8dTarXPURYnYWbJfeBH9pcV9mv6pCQNIxxmgmHAcaKPDwj.u','CLIENTE',TRUE,TRUE,9),
    (1,'mariajose.moreno@email.com', '$2b$10$cQlM.8dTarXPURYnYWbJfeBH9pcV9mv6pCQNIxxmgmHAcaKPDwj.u','CLIENTE',TRUE,TRUE,10),
    (1,'jose.jimenez@email.com',     '$2b$10$cQlM.8dTarXPURYnYWbJfeBH9pcV9mv6pCQNIxxmgmHAcaKPDwj.u','CLIENTE',TRUE,TRUE,11),
    (1,'cristina.alvarez@email.com', '$2b$10$cQlM.8dTarXPURYnYWbJfeBH9pcV9mv6pCQNIxxmgmHAcaKPDwj.u','CLIENTE',TRUE,TRUE,12),
    (1,'manuel.romero@email.com',    '$2b$10$cQlM.8dTarXPURYnYWbJfeBH9pcV9mv6pCQNIxxmgmHAcaKPDwj.u','CLIENTE',TRUE,TRUE,13),
    (1,'patricia.torres@email.com',  '$2b$10$cQlM.8dTarXPURYnYWbJfeBH9pcV9mv6pCQNIxxmgmHAcaKPDwj.u','CLIENTE',TRUE,TRUE,14),
    (1,'javier.navarro@email.com',   '$2b$10$cQlM.8dTarXPURYnYWbJfeBH9pcV9mv6pCQNIxxmgmHAcaKPDwj.u','CLIENTE',TRUE,TRUE,15);

-- ============================================================
-- RESERVAS — Año pasado (2025): Enero a Diciembre
-- ============================================================

-- ENERO 2025
INSERT INTO reserva (organizacion_id, cliente_id, estado, fecha, notas) VALUES
                                                                            (1,1,'completada','2025-01-06',NULL),(1,3,'completada','2025-01-07',NULL),
                                                                            (1,5,'completada','2025-01-08',NULL),(1,7,'completada','2025-01-09',NULL),
                                                                            (1,2,'completada','2025-01-10',NULL),(1,9,'completada','2025-01-11',NULL),
                                                                            (1,4,'completada','2025-01-13',NULL),(1,6,'completada','2025-01-14',NULL),
                                                                            (1,8,'completada','2025-01-15',NULL),(1,10,'completada','2025-01-16',NULL),
                                                                            (1,11,'completada','2025-01-17',NULL),(1,12,'completada','2025-01-18',NULL),
                                                                            (1,13,'cancelada','2025-01-20',NULL),(1,14,'completada','2025-01-21',NULL),
                                                                            (1,15,'completada','2025-01-22',NULL),(1,16,'completada','2025-01-23',NULL),
                                                                            (1,17,'completada','2025-01-24',NULL),(1,18,'cancelada','2025-01-25',NULL),
                                                                            (1,19,'completada','2025-01-27',NULL),(1,20,'completada','2025-01-28',NULL),
                                                                            (1,21,'completada','2025-01-29',NULL),(1,22,'completada','2025-01-30',NULL),
                                                                            (1,23,'completada','2025-01-31',NULL);

-- FEBRERO 2025
INSERT INTO reserva (organizacion_id, cliente_id, estado, fecha, notas) VALUES
                                                                            (1,1,'completada','2025-02-03',NULL),(1,2,'completada','2025-02-04',NULL),
                                                                            (1,3,'completada','2025-02-05',NULL),(1,4,'cancelada','2025-02-06',NULL),
                                                                            (1,5,'completada','2025-02-07',NULL),(1,6,'completada','2025-02-08',NULL),
                                                                            (1,7,'completada','2025-02-10',NULL),(1,8,'completada','2025-02-11',NULL),
                                                                            (1,9,'completada','2025-02-12',NULL),(1,10,'completada','2025-02-13',NULL),
                                                                            (1,11,'completada','2025-02-14',NULL),(1,12,'cancelada','2025-02-15',NULL),
                                                                            (1,13,'completada','2025-02-17',NULL),(1,14,'completada','2025-02-18',NULL),
                                                                            (1,15,'completada','2025-02-19',NULL),(1,16,'completada','2025-02-20',NULL),
                                                                            (1,17,'completada','2025-02-21',NULL),(1,18,'completada','2025-02-22',NULL),
                                                                            (1,19,'completada','2025-02-24',NULL),(1,20,'completada','2025-02-25',NULL),
                                                                            (1,21,'completada','2025-02-26',NULL),(1,22,'completada','2025-02-27',NULL);

-- MARZO 2025
INSERT INTO reserva (organizacion_id, cliente_id, estado, fecha, notas) VALUES
                                                                            (1,1,'completada','2025-03-03',NULL),(1,3,'completada','2025-03-04',NULL),
                                                                            (1,5,'completada','2025-03-05',NULL),(1,7,'completada','2025-03-06',NULL),
                                                                            (1,9,'completada','2025-03-07',NULL),(1,11,'completada','2025-03-08',NULL),
                                                                            (1,2,'completada','2025-03-10',NULL),(1,4,'cancelada','2025-03-11',NULL),
                                                                            (1,6,'completada','2025-03-12',NULL),(1,8,'completada','2025-03-13',NULL),
                                                                            (1,10,'completada','2025-03-14',NULL),(1,12,'completada','2025-03-15',NULL),
                                                                            (1,13,'completada','2025-03-17',NULL),(1,14,'completada','2025-03-18',NULL),
                                                                            (1,15,'completada','2025-03-19',NULL),(1,16,'completada','2025-03-20',NULL),
                                                                            (1,17,'completada','2025-03-21',NULL),(1,18,'cancelada','2025-03-22',NULL),
                                                                            (1,19,'completada','2025-03-24',NULL),(1,20,'completada','2025-03-25',NULL),
                                                                            (1,21,'completada','2025-03-26',NULL),(1,22,'completada','2025-03-27',NULL),
                                                                            (1,23,'completada','2025-03-28',NULL),(1,24,'completada','2025-03-29',NULL);

-- ABRIL 2025
INSERT INTO reserva (organizacion_id, cliente_id, estado, fecha, notas) VALUES
                                                                            (1,1,'completada','2025-04-01',NULL),(1,2,'completada','2025-04-02',NULL),
                                                                            (1,3,'completada','2025-04-03',NULL),(1,4,'completada','2025-04-04',NULL),
                                                                            (1,5,'completada','2025-04-05',NULL),(1,6,'cancelada','2025-04-07',NULL),
                                                                            (1,7,'completada','2025-04-08',NULL),(1,8,'completada','2025-04-09',NULL),
                                                                            (1,9,'completada','2025-04-10',NULL),(1,10,'completada','2025-04-11',NULL),
                                                                            (1,11,'completada','2025-04-12',NULL),(1,12,'completada','2025-04-14',NULL),
                                                                            (1,13,'completada','2025-04-15',NULL),(1,14,'completada','2025-04-16',NULL),
                                                                            (1,15,'completada','2025-04-17',NULL),(1,16,'completada','2025-04-22',NULL),
                                                                            (1,17,'completada','2025-04-23',NULL),(1,18,'completada','2025-04-24',NULL),
                                                                            (1,19,'cancelada','2025-04-25',NULL),(1,20,'completada','2025-04-26',NULL),
                                                                            (1,21,'completada','2025-04-28',NULL),(1,22,'completada','2025-04-29',NULL),
                                                                            (1,23,'completada','2025-04-30',NULL);

-- MAYO 2025
INSERT INTO reserva (organizacion_id, cliente_id, estado, fecha, notas) VALUES
                                                                            (1,1,'completada','2025-05-02',NULL),(1,3,'completada','2025-05-03',NULL),
                                                                            (1,5,'completada','2025-05-05',NULL),(1,7,'completada','2025-05-06',NULL),
                                                                            (1,9,'completada','2025-05-07',NULL),(1,2,'completada','2025-05-08',NULL),
                                                                            (1,4,'completada','2025-05-09',NULL),(1,6,'cancelada','2025-05-10',NULL),
                                                                            (1,8,'completada','2025-05-12',NULL),(1,10,'completada','2025-05-13',NULL),
                                                                            (1,11,'completada','2025-05-14',NULL),(1,12,'completada','2025-05-15',NULL),
                                                                            (1,13,'completada','2025-05-16',NULL),(1,14,'completada','2025-05-17',NULL),
                                                                            (1,15,'completada','2025-05-19',NULL),(1,16,'completada','2025-05-20',NULL),
                                                                            (1,17,'completada','2025-05-21',NULL),(1,18,'cancelada','2025-05-22',NULL),
                                                                            (1,19,'completada','2025-05-23',NULL),(1,20,'completada','2025-05-24',NULL),
                                                                            (1,21,'completada','2025-05-26',NULL),(1,22,'completada','2025-05-27',NULL),
                                                                            (1,23,'completada','2025-05-28',NULL),(1,24,'completada','2025-05-29',NULL),
                                                                            (1,25,'completada','2025-05-30',NULL);

-- JUNIO 2025
INSERT INTO reserva (organizacion_id, cliente_id, estado, fecha, notas) VALUES
                                                                            (1,1,'completada','2025-06-02',NULL),(1,2,'completada','2025-06-03',NULL),
                                                                            (1,3,'completada','2025-06-04',NULL),(1,4,'completada','2025-06-05',NULL),
                                                                            (1,5,'completada','2025-06-06',NULL),(1,6,'completada','2025-06-07',NULL),
                                                                            (1,7,'completada','2025-06-09',NULL),(1,8,'cancelada','2025-06-10',NULL),
                                                                            (1,9,'completada','2025-06-11',NULL),(1,10,'completada','2025-06-12',NULL),
                                                                            (1,11,'completada','2025-06-13',NULL),(1,12,'completada','2025-06-14',NULL),
                                                                            (1,13,'completada','2025-06-16',NULL),(1,14,'completada','2025-06-17',NULL),
                                                                            (1,15,'completada','2025-06-18',NULL),(1,16,'completada','2025-06-19',NULL),
                                                                            (1,17,'completada','2025-06-20',NULL),(1,18,'completada','2025-06-21',NULL),
                                                                            (1,19,'cancelada','2025-06-23',NULL),(1,20,'completada','2025-06-24',NULL),
                                                                            (1,21,'completada','2025-06-25',NULL),(1,22,'completada','2025-06-26',NULL),
                                                                            (1,23,'completada','2025-06-27',NULL),(1,24,'completada','2025-06-28',NULL);

-- JULIO 2025
INSERT INTO reserva (organizacion_id, cliente_id, estado, fecha, notas) VALUES
                                                                            (1,1,'completada','2025-07-01',NULL),(1,3,'completada','2025-07-02',NULL),
                                                                            (1,5,'completada','2025-07-03',NULL),(1,7,'completada','2025-07-04',NULL),
                                                                            (1,2,'completada','2025-07-05',NULL),(1,4,'cancelada','2025-07-07',NULL),
                                                                            (1,6,'completada','2025-07-08',NULL),(1,8,'completada','2025-07-09',NULL),
                                                                            (1,9,'completada','2025-07-10',NULL),(1,10,'completada','2025-07-11',NULL),
                                                                            (1,11,'completada','2025-07-12',NULL),(1,12,'completada','2025-07-14',NULL),
                                                                            (1,13,'completada','2025-07-15',NULL),(1,14,'completada','2025-07-16',NULL),
                                                                            (1,15,'completada','2025-07-17',NULL),(1,16,'completada','2025-07-18',NULL),
                                                                            (1,17,'cancelada','2025-07-19',NULL),(1,18,'completada','2025-07-21',NULL),
                                                                            (1,19,'completada','2025-07-22',NULL),(1,20,'completada','2025-07-23',NULL),
                                                                            (1,21,'completada','2025-07-24',NULL),(1,22,'completada','2025-07-25',NULL),
                                                                            (1,23,'completada','2025-07-26',NULL),(1,24,'completada','2025-07-28',NULL),
                                                                            (1,25,'completada','2025-07-29',NULL),(1,26,'completada','2025-07-30',NULL);

-- AGOSTO 2025
INSERT INTO reserva (organizacion_id, cliente_id, estado, fecha, notas) VALUES
                                                                            (1,1,'completada','2025-08-01',NULL),(1,2,'completada','2025-08-02',NULL),
                                                                            (1,3,'completada','2025-08-04',NULL),(1,4,'completada','2025-08-05',NULL),
                                                                            (1,5,'completada','2025-08-06',NULL),(1,6,'cancelada','2025-08-07',NULL),
                                                                            (1,7,'completada','2025-08-08',NULL),(1,8,'completada','2025-08-09',NULL),
                                                                            (1,9,'completada','2025-08-11',NULL),(1,10,'completada','2025-08-12',NULL),
                                                                            (1,11,'completada','2025-08-13',NULL),(1,12,'completada','2025-08-14',NULL),
                                                                            (1,13,'completada','2025-08-15',NULL),(1,14,'completada','2025-08-16',NULL),
                                                                            (1,15,'completada','2025-08-18',NULL),(1,16,'completada','2025-08-19',NULL),
                                                                            (1,17,'completada','2025-08-20',NULL),(1,18,'cancelada','2025-08-21',NULL),
                                                                            (1,19,'completada','2025-08-22',NULL),(1,20,'completada','2025-08-23',NULL),
                                                                            (1,21,'completada','2025-08-25',NULL),(1,22,'completada','2025-08-26',NULL),
                                                                            (1,23,'completada','2025-08-27',NULL),(1,24,'completada','2025-08-28',NULL),
                                                                            (1,25,'completada','2025-08-29',NULL),(1,26,'completada','2025-08-30',NULL);

-- SEPTIEMBRE 2025
INSERT INTO reserva (organizacion_id, cliente_id, estado, fecha, notas) VALUES
                                                                            (1,1,'completada','2025-09-01',NULL),(1,3,'completada','2025-09-02',NULL),
                                                                            (1,5,'completada','2025-09-03',NULL),(1,2,'completada','2025-09-04',NULL),
                                                                            (1,4,'completada','2025-09-05',NULL),(1,6,'completada','2025-09-06',NULL),
                                                                            (1,7,'cancelada','2025-09-08',NULL),(1,8,'completada','2025-09-09',NULL),
                                                                            (1,9,'completada','2025-09-10',NULL),(1,10,'completada','2025-09-11',NULL),
                                                                            (1,11,'completada','2025-09-12',NULL),(1,12,'completada','2025-09-13',NULL),
                                                                            (1,13,'completada','2025-09-15',NULL),(1,14,'completada','2025-09-16',NULL),
                                                                            (1,15,'completada','2025-09-17',NULL),(1,16,'completada','2025-09-18',NULL),
                                                                            (1,17,'completada','2025-09-19',NULL),(1,18,'completada','2025-09-20',NULL),
                                                                            (1,19,'cancelada','2025-09-22',NULL),(1,20,'completada','2025-09-23',NULL),
                                                                            (1,21,'completada','2025-09-24',NULL),(1,22,'completada','2025-09-25',NULL),
                                                                            (1,23,'completada','2025-09-26',NULL),(1,24,'completada','2025-09-27',NULL);

-- OCTUBRE 2025
INSERT INTO reserva (organizacion_id, cliente_id, estado, fecha, notas) VALUES
                                                                            (1,1,'completada','2025-10-01',NULL),(1,2,'completada','2025-10-02',NULL),
                                                                            (1,3,'completada','2025-10-03',NULL),(1,4,'cancelada','2025-10-04',NULL),
                                                                            (1,5,'completada','2025-10-06',NULL),(1,6,'completada','2025-10-07',NULL),
                                                                            (1,7,'completada','2025-10-08',NULL),(1,8,'completada','2025-10-09',NULL),
                                                                            (1,9,'completada','2025-10-10',NULL),(1,10,'completada','2025-10-11',NULL),
                                                                            (1,11,'completada','2025-10-13',NULL),(1,12,'completada','2025-10-14',NULL),
                                                                            (1,13,'completada','2025-10-15',NULL),(1,14,'completada','2025-10-16',NULL),
                                                                            (1,15,'completada','2025-10-17',NULL),(1,16,'completada','2025-10-18',NULL),
                                                                            (1,17,'cancelada','2025-10-20',NULL),(1,18,'completada','2025-10-21',NULL),
                                                                            (1,19,'completada','2025-10-22',NULL),(1,20,'completada','2025-10-23',NULL),
                                                                            (1,21,'completada','2025-10-24',NULL),(1,22,'completada','2025-10-25',NULL),
                                                                            (1,23,'completada','2025-10-27',NULL),(1,24,'completada','2025-10-28',NULL),
                                                                            (1,25,'completada','2025-10-29',NULL),(1,26,'completada','2025-10-30',NULL),
                                                                            (1,27,'completada','2025-10-31',NULL);

-- NOVIEMBRE 2025
INSERT INTO reserva (organizacion_id, cliente_id, estado, fecha, notas) VALUES
                                                                            (1,1,'completada','2025-11-03',NULL),(1,3,'completada','2025-11-04',NULL),
                                                                            (1,5,'completada','2025-11-05',NULL),(1,2,'completada','2025-11-06',NULL),
                                                                            (1,4,'completada','2025-11-07',NULL),(1,6,'cancelada','2025-11-08',NULL),
                                                                            (1,7,'completada','2025-11-10',NULL),(1,8,'completada','2025-11-11',NULL),
                                                                            (1,9,'completada','2025-11-12',NULL),(1,10,'completada','2025-11-13',NULL),
                                                                            (1,11,'completada','2025-11-14',NULL),(1,12,'completada','2025-11-15',NULL),
                                                                            (1,13,'cancelada','2025-11-17',NULL),(1,14,'completada','2025-11-18',NULL),
                                                                            (1,15,'completada','2025-11-19',NULL),(1,16,'completada','2025-11-20',NULL),
                                                                            (1,17,'completada','2025-11-21',NULL),(1,18,'completada','2025-11-22',NULL),
                                                                            (1,19,'completada','2025-11-24',NULL),(1,20,'completada','2025-11-25',NULL),
                                                                            (1,21,'completada','2025-11-26',NULL),(1,22,'completada','2025-11-27',NULL),
                                                                            (1,23,'completada','2025-11-28',NULL),(1,24,'completada','2025-11-29',NULL);

-- DICIEMBRE 2025
INSERT INTO reserva (organizacion_id, cliente_id, estado, fecha, notas) VALUES
                                                                            (1,1,'completada','2025-12-01',NULL),(1,2,'completada','2025-12-02',NULL),
                                                                            (1,3,'completada','2025-12-03',NULL),(1,4,'completada','2025-12-04',NULL),
                                                                            (1,5,'cancelada','2025-12-05',NULL),(1,6,'completada','2025-12-06',NULL),
                                                                            (1,7,'completada','2025-12-08',NULL),(1,8,'completada','2025-12-09',NULL),
                                                                            (1,9,'completada','2025-12-10',NULL),(1,10,'completada','2025-12-11',NULL),
                                                                            (1,11,'completada','2025-12-12',NULL),(1,12,'completada','2025-12-13',NULL),
                                                                            (1,13,'completada','2025-12-15',NULL),(1,14,'completada','2025-12-16',NULL),
                                                                            (1,15,'completada','2025-12-17',NULL),(1,16,'completada','2025-12-18',NULL),
                                                                            (1,17,'completada','2025-12-19',NULL),(1,18,'cancelada','2025-12-20',NULL),
                                                                            (1,19,'completada','2025-12-22',NULL),(1,20,'completada','2025-12-23',NULL),
                                                                            (1,21,'completada','2025-12-26',NULL),(1,22,'completada','2025-12-27',NULL),
                                                                            (1,23,'completada','2025-12-29',NULL),(1,24,'completada','2025-12-30',NULL);

-- ============================================================
-- RESERVAS — 2026: Enero a Junio
-- ============================================================

-- ENERO 2026
INSERT INTO reserva (organizacion_id, cliente_id, estado, fecha, notas) VALUES
                                                                            (1,1,'completada','2026-01-05',NULL),(1,2,'completada','2026-01-06',NULL),
                                                                            (1,3,'completada','2026-01-07',NULL),(1,4,'completada','2026-01-08',NULL),
                                                                            (1,5,'completada','2026-01-09',NULL),(1,6,'cancelada','2026-01-10',NULL),
                                                                            (1,7,'completada','2026-01-12',NULL),(1,8,'completada','2026-01-13',NULL),
                                                                            (1,9,'completada','2026-01-14',NULL),(1,10,'completada','2026-01-15',NULL),
                                                                            (1,11,'completada','2026-01-16',NULL),(1,12,'completada','2026-01-17',NULL),
                                                                            (1,13,'completada','2026-01-19',NULL),(1,14,'cancelada','2026-01-20',NULL),
                                                                            (1,15,'completada','2026-01-21',NULL),(1,16,'completada','2026-01-22',NULL),
                                                                            (1,17,'completada','2026-01-23',NULL),(1,18,'completada','2026-01-24',NULL),
                                                                            (1,19,'completada','2026-01-26',NULL),(1,20,'completada','2026-01-27',NULL),
                                                                            (1,21,'completada','2026-01-28',NULL),(1,22,'completada','2026-01-29',NULL),
                                                                            (1,23,'completada','2026-01-30',NULL),(1,24,'completada','2026-01-31',NULL);

-- FEBRERO 2026
INSERT INTO reserva (organizacion_id, cliente_id, estado, fecha, notas) VALUES
                                                                            (1,1,'completada','2026-02-02',NULL),(1,3,'completada','2026-02-03',NULL),
                                                                            (1,5,'completada','2026-02-04',NULL),(1,2,'completada','2026-02-05',NULL),
                                                                            (1,4,'completada','2026-02-06',NULL),(1,6,'completada','2026-02-07',NULL),
                                                                            (1,7,'cancelada','2026-02-09',NULL),(1,8,'completada','2026-02-10',NULL),
                                                                            (1,9,'completada','2026-02-11',NULL),(1,10,'completada','2026-02-12',NULL),
                                                                            (1,11,'completada','2026-02-13',NULL),(1,12,'completada','2026-02-14',NULL),
                                                                            (1,13,'completada','2026-02-16',NULL),(1,14,'completada','2026-02-17',NULL),
                                                                            (1,15,'completada','2026-02-18',NULL),(1,16,'cancelada','2026-02-19',NULL),
                                                                            (1,17,'completada','2026-02-20',NULL),(1,18,'completada','2026-02-21',NULL),
                                                                            (1,19,'completada','2026-02-23',NULL),(1,20,'completada','2026-02-24',NULL),
                                                                            (1,21,'completada','2026-02-25',NULL),(1,22,'completada','2026-02-26',NULL),
                                                                            (1,23,'completada','2026-02-27',NULL),(1,24,'completada','2026-02-28',NULL);

-- MARZO 2026
INSERT INTO reserva (organizacion_id, cliente_id, estado, fecha, notas) VALUES
                                                                            (1,1,'completada','2026-03-02',NULL),(1,2,'completada','2026-03-03',NULL),
                                                                            (1,3,'completada','2026-03-04',NULL),(1,4,'cancelada','2026-03-05',NULL),
                                                                            (1,5,'completada','2026-03-06',NULL),(1,6,'completada','2026-03-07',NULL),
                                                                            (1,7,'completada','2026-03-09',NULL),(1,8,'completada','2026-03-10',NULL),
                                                                            (1,9,'completada','2026-03-11',NULL),(1,10,'completada','2026-03-12',NULL),
                                                                            (1,11,'completada','2026-03-13',NULL),(1,12,'cancelada','2026-03-14',NULL),
                                                                            (1,13,'completada','2026-03-16',NULL),(1,14,'completada','2026-03-17',NULL),
                                                                            (1,15,'completada','2026-03-18',NULL),(1,16,'completada','2026-03-19',NULL),
                                                                            (1,17,'completada','2026-03-20',NULL),(1,18,'completada','2026-03-21',NULL),
                                                                            (1,19,'completada','2026-03-23',NULL),(1,20,'completada','2026-03-24',NULL),
                                                                            (1,21,'completada','2026-03-25',NULL),(1,22,'completada','2026-03-26',NULL),
                                                                            (1,23,'completada','2026-03-27',NULL),(1,24,'completada','2026-03-28',NULL),
                                                                            (1,25,'completada','2026-03-30',NULL),(1,26,'completada','2026-03-31',NULL);

-- ABRIL 2026
INSERT INTO reserva (organizacion_id, cliente_id, estado, fecha, notas) VALUES
                                                                            (1,1,'completada','2026-04-01',NULL),(1,3,'completada','2026-04-02',NULL),
                                                                            (1,5,'completada','2026-04-03',NULL),(1,2,'completada','2026-04-06',NULL),
                                                                            (1,4,'completada','2026-04-07',NULL),(1,6,'cancelada','2026-04-08',NULL),
                                                                            (1,7,'completada','2026-04-09',NULL),(1,8,'completada','2026-04-13',NULL),
                                                                            (1,9,'completada','2026-04-14',NULL),(1,10,'completada','2026-04-15',NULL),
                                                                            (1,11,'completada','2026-04-16',NULL),(1,12,'completada','2026-04-17',NULL),
                                                                            (1,13,'completada','2026-04-20',NULL),(1,14,'completada','2026-04-21',NULL),
                                                                            (1,15,'completada','2026-04-22',NULL),(1,16,'completada','2026-04-23',NULL),
                                                                            (1,17,'cancelada','2026-04-24',NULL),(1,18,'completada','2026-04-27',NULL),
                                                                            (1,19,'completada','2026-04-28',NULL),(1,20,'completada','2026-04-29',NULL),
                                                                            (1,21,'completada','2026-04-30',NULL);

-- MAYO 2026 (pasado reciente — completadas)
INSERT INTO reserva (organizacion_id, cliente_id, estado, fecha, notas) VALUES
                                                                            (1,1,'completada','2026-05-04',NULL),(1,2,'completada','2026-05-05',NULL),
                                                                            (1,3,'completada','2026-05-06',NULL),(1,4,'completada','2026-05-07',NULL),
                                                                            (1,5,'completada','2026-05-08',NULL),(1,6,'cancelada','2026-05-09',NULL),
                                                                            (1,7,'completada','2026-05-11',NULL),(1,8,'completada','2026-05-12',NULL),
                                                                            (1,9,'completada','2026-05-13',NULL),(1,10,'completada','2026-05-14',NULL),
                                                                            (1,11,'completada','2026-05-15',NULL),(1,12,'completada','2026-05-16',NULL),
                                                                            (1,13,'completada','2026-05-18',NULL),(1,14,'completada','2026-05-19',NULL),
                                                                            (1,15,'completada','2026-05-20',NULL),(1,16,'completada','2026-05-21',NULL),
                                                                            (1,17,'completada','2026-05-22',NULL),(1,18,'cancelada','2026-05-23',NULL);

-- JUNIO 2026 (futuro — pendientes y confirmadas)
INSERT INTO reserva (organizacion_id, cliente_id, estado, fecha, notas) VALUES
                                                                            (1,1,'confirmada','2026-06-01',NULL),(1,2,'pendiente','2026-06-02',NULL),
                                                                            (1,3,'confirmada','2026-06-03',NULL),(1,4,'pendiente','2026-06-04',NULL),
                                                                            (1,5,'confirmada','2026-06-05',NULL),(1,6,'pendiente','2026-06-06',NULL),
                                                                            (1,7,'confirmada','2026-06-08',NULL),(1,8,'pendiente','2026-06-09',NULL),
                                                                            (1,9,'confirmada','2026-06-10',NULL),(1,10,'pendiente','2026-06-11',NULL),
                                                                            (1,11,'confirmada','2026-06-12',NULL),(1,12,'pendiente','2026-06-13',NULL),
                                                                            (1,13,'confirmada','2026-06-15',NULL),(1,14,'pendiente','2026-06-16',NULL),
                                                                            (1,15,'confirmada','2026-06-17',NULL),(1,16,'pendiente','2026-06-18',NULL),
                                                                            (1,17,'confirmada','2026-06-19',NULL),(1,18,'pendiente','2026-06-20',NULL),
                                                                            (1,19,'confirmada','2026-06-22',NULL),(1,20,'pendiente','2026-06-23',NULL),
                                                                            (1,21,'confirmada','2026-06-24',NULL),(1,22,'pendiente','2026-06-25',NULL),
                                                                            (1,23,'confirmada','2026-06-26',NULL),(1,24,'pendiente','2026-06-27',NULL),
                                                                            (1,25,'confirmada','2026-06-29',NULL),(1,26,'pendiente','2026-06-30',NULL);

-- ============================================================
-- RESERVA_SERVICIO — líneas de detalle para todas las reservas
-- Asignamos servicios y empleados de forma coherente con las skills
-- ============================================================

-- Procedimiento: cada reserva tiene 1 línea de detalle
-- Rotamos servicios y empleados con horas coherentes

-- Reservas 1-23 (Enero 2025) → servicio 1 (Lavado Básico 30min) → empleado 2 (María, skill lavado)
INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 1, 2, '10:00', '10:30', 15.00, 1, 'activo'
FROM reserva WHERE fecha BETWEEN '2025-01-01' AND '2025-01-31' AND estado = 'completada';

INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 1, 2, '11:00', '11:30', 15.00, 1, 'cancelado'
FROM reserva WHERE fecha BETWEEN '2025-01-01' AND '2025-01-31' AND estado = 'cancelada';

-- Reservas Febrero 2025 → servicio 2 (Lavado Completo 45min) → empleado 3 (Alejandro)
INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 2, 3, '10:00', '10:45', 25.00, 1, 'activo'
FROM reserva WHERE fecha BETWEEN '2025-02-01' AND '2025-02-28' AND estado = 'completada';

INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 2, 3, '11:00', '11:45', 25.00, 1, 'cancelado'
FROM reserva WHERE fecha BETWEEN '2025-02-01' AND '2025-02-28' AND estado = 'cancelada';

-- Marzo 2025 → servicio 3 (Limpieza Interior 60min) → empleado 4 (Lucía)
INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 3, 4, '10:00', '11:00', 35.00, 1, 'activo'
FROM reserva WHERE fecha BETWEEN '2025-03-01' AND '2025-03-31' AND estado = 'completada';

INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 3, 4, '11:00', '12:00', 35.00, 1, 'cancelado'
FROM reserva WHERE fecha BETWEEN '2025-03-01' AND '2025-03-31' AND estado = 'cancelada';

-- Abril 2025 → servicio 4 (Lavado Completo + Interior 90min) → empleado 1 (Carlos)
INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 4, 1, '10:00', '11:30', 55.00, 1, 'activo'
FROM reserva WHERE fecha BETWEEN '2025-04-01' AND '2025-04-30' AND estado = 'completada';

INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 4, 1, '11:00', '12:30', 55.00, 1, 'cancelado'
FROM reserva WHERE fecha BETWEEN '2025-04-01' AND '2025-04-30' AND estado = 'cancelada';

-- Mayo 2025 → servicio 5 (Detailing 180min) → empleado 5 (David)
INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 5, 5, '09:00', '12:00', 120.00, 1, 'activo'
FROM reserva WHERE fecha BETWEEN '2025-05-01' AND '2025-05-31' AND estado = 'completada';

INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 5, 5, '09:00', '12:00', 120.00, 1, 'cancelado'
FROM reserva WHERE fecha BETWEEN '2025-05-01' AND '2025-05-31' AND estado = 'cancelada';

-- Junio 2025 → servicio 6 (Ozono 45min) → empleado 4 (Lucía, skill ozono)
INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 6, 4, '10:00', '10:45', 40.00, 1, 'activo'
FROM reserva WHERE fecha BETWEEN '2025-06-01' AND '2025-06-30' AND estado = 'completada';

INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 6, 4, '11:00', '11:45', 40.00, 1, 'cancelado'
FROM reserva WHERE fecha BETWEEN '2025-06-01' AND '2025-06-30' AND estado = 'cancelada';

-- Julio 2025 → servicio 1 → empleado 2
INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 1, 2, '10:00', '10:30', 15.00, 1, 'activo'
FROM reserva WHERE fecha BETWEEN '2025-07-01' AND '2025-07-31' AND estado = 'completada';

INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 1, 2, '11:00', '11:30', 15.00, 1, 'cancelado'
FROM reserva WHERE fecha BETWEEN '2025-07-01' AND '2025-07-31' AND estado = 'cancelada';

-- Agosto 2025 → servicio 2 → empleado 3
INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 2, 3, '10:00', '10:45', 25.00, 1, 'activo'
FROM reserva WHERE fecha BETWEEN '2025-08-01' AND '2025-08-31' AND estado = 'completada';

INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 2, 3, '11:00', '11:45', 25.00, 1, 'cancelado'
FROM reserva WHERE fecha BETWEEN '2025-08-01' AND '2025-08-31' AND estado = 'cancelada';

-- Septiembre 2025 → servicio 3 → empleado 4
INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 3, 4, '10:00', '11:00', 35.00, 1, 'activo'
FROM reserva WHERE fecha BETWEEN '2025-09-01' AND '2025-09-30' AND estado = 'completada';

INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 3, 4, '11:00', '12:00', 35.00, 1, 'cancelado'
FROM reserva WHERE fecha BETWEEN '2025-09-01' AND '2025-09-30' AND estado = 'cancelada';

-- Octubre 2025 → servicio 4 → empleado 1
INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 4, 1, '10:00', '11:30', 55.00, 1, 'activo'
FROM reserva WHERE fecha BETWEEN '2025-10-01' AND '2025-10-31' AND estado = 'completada';

INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 4, 1, '11:00', '12:30', 55.00, 1, 'cancelado'
FROM reserva WHERE fecha BETWEEN '2025-10-01' AND '2025-10-31' AND estado = 'cancelada';

-- Noviembre 2025 → servicio 5 → empleado 5
INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 5, 5, '09:00', '12:00', 120.00, 1, 'activo'
FROM reserva WHERE fecha BETWEEN '2025-11-01' AND '2025-11-30' AND estado = 'completada';

INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 5, 5, '09:00', '12:00', 120.00, 1, 'cancelado'
FROM reserva WHERE fecha BETWEEN '2025-11-01' AND '2025-11-30' AND estado = 'cancelada';

-- Diciembre 2025 → servicio 6 → empleado 4
INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 6, 4, '10:00', '10:45', 40.00, 1, 'activo'
FROM reserva WHERE fecha BETWEEN '2025-12-01' AND '2025-12-31' AND estado = 'completada';

INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 6, 4, '11:00', '11:45', 40.00, 1, 'cancelado'
FROM reserva WHERE fecha BETWEEN '2025-12-01' AND '2025-12-31' AND estado = 'cancelada';

-- Enero 2026 → servicio 1 → empleado 2
INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 1, 2, '10:00', '10:30', 15.00, 1, 'activo'
FROM reserva WHERE fecha BETWEEN '2026-01-01' AND '2026-01-31' AND estado = 'completada';

INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 1, 2, '11:00', '11:30', 15.00, 1, 'cancelado'
FROM reserva WHERE fecha BETWEEN '2026-01-01' AND '2026-01-31' AND estado = 'cancelada';

-- Febrero 2026 → servicio 2 → empleado 3
INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 2, 3, '10:00', '10:45', 25.00, 1, 'activo'
FROM reserva WHERE fecha BETWEEN '2026-02-01' AND '2026-02-28' AND estado = 'completada';

INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 2, 3, '11:00', '11:45', 25.00, 1, 'cancelado'
FROM reserva WHERE fecha BETWEEN '2026-02-01' AND '2026-02-28' AND estado = 'cancelada';

-- Marzo 2026 → servicio 3 → empleado 4
INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 3, 4, '10:00', '11:00', 35.00, 1, 'activo'
FROM reserva WHERE fecha BETWEEN '2026-03-01' AND '2026-03-31' AND estado = 'completada';

INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 3, 4, '11:00', '12:00', 35.00, 1, 'cancelado'
FROM reserva WHERE fecha BETWEEN '2026-03-01' AND '2026-03-31' AND estado = 'cancelada';

-- Abril 2026 → servicio 4 → empleado 1
INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 4, 1, '10:00', '11:30', 55.00, 1, 'activo'
FROM reserva WHERE fecha BETWEEN '2026-04-01' AND '2026-04-30' AND estado = 'completada';

INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 4, 1, '11:00', '12:30', 55.00, 1, 'cancelado'
FROM reserva WHERE fecha BETWEEN '2026-04-01' AND '2026-04-30' AND estado = 'cancelada';

-- Mayo 2026 → servicio 5 → empleado 5
INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 5, 5, '09:00', '12:00', 120.00, 1, 'activo'
FROM reserva WHERE fecha BETWEEN '2026-05-01' AND '2026-05-31' AND estado = 'completada';

INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 5, 5, '09:00', '12:00', 120.00, 1, 'cancelado'
FROM reserva WHERE fecha BETWEEN '2026-05-01' AND '2026-05-31' AND estado = 'cancelada';

-- Junio 2026 (futuras) → servicio 1 → empleado 2
INSERT INTO reserva_servicio (reserva_id, servicio_id, empleado_id, hora_inicio, hora_fin, precio_unitario, cantidad, estado)
SELECT id, 1, 2, '10:00', '10:30', 15.00, 1, 'activo'
FROM reserva WHERE fecha BETWEEN '2026-06-01' AND '2026-06-30';