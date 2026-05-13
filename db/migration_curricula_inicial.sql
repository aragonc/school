-- Agregar nivel 'inicial' al ENUM de áreas
ALTER TABLE `plugin_school_curricula_area`
    MODIFY COLUMN `level` ENUM('inicial','primaria','secundaria','ambos') NOT NULL DEFAULT 'ambos';

-- Agregar columna 'level' a competencias transversales (para distinguir inicial de EBR)
ALTER TABLE `plugin_school_curricula_transversal`
    ADD COLUMN `level` ENUM('inicial','ebr') NOT NULL DEFAULT 'ebr' AFTER `name`;

-- Agregar columna 'level' a enfoques transversales
ALTER TABLE `plugin_school_curricula_enfoque`
    ADD COLUMN `level` ENUM('inicial','ebr','ambos') NOT NULL DEFAULT 'ebr' AFTER `name`;

-- Los enfoques existentes son de EBR (ya tienen default 'ebr'), marcar como 'ebr'
UPDATE `plugin_school_curricula_enfoque` SET `level` = 'ebr';

-- ============================================================
-- ÁREAS CURRICULARES DE INICIAL
-- ============================================================
INSERT INTO `plugin_school_curricula_area` (`name`, `level`, `order_index`) VALUES
('Personal Social',                        'inicial', 1),
('Psicomotriz',                            'inicial', 2),
('Comunicación',                           'inicial', 3),
('Castellano como Segunda Lengua (EIB)',   'inicial', 4),
('Descubrimiento del Mundo',               'inicial', 5),
('Arte y Cultura',                         'inicial', 6),
('Educación Religiosa',                    'inicial', 7);

-- Obtener los IDs insertados usando orden conocido
-- Personal Social Inicial (order_index=1, level='inicial')
SET @ps_id = (SELECT id FROM `plugin_school_curricula_area` WHERE `level`='inicial' AND `order_index`=1 LIMIT 1);
SET @psi_id = (SELECT id FROM `plugin_school_curricula_area` WHERE `level`='inicial' AND `order_index`=2 LIMIT 1);
SET @com_id = (SELECT id FROM `plugin_school_curricula_area` WHERE `level`='inicial' AND `order_index`=3 LIMIT 1);
SET @cas_id = (SELECT id FROM `plugin_school_curricula_area` WHERE `level`='inicial' AND `order_index`=4 LIMIT 1);
SET @desc_id = (SELECT id FROM `plugin_school_curricula_area` WHERE `level`='inicial' AND `order_index`=5 LIMIT 1);
SET @art_id = (SELECT id FROM `plugin_school_curricula_area` WHERE `level`='inicial' AND `order_index`=6 LIMIT 1);
SET @rel_id = (SELECT id FROM `plugin_school_curricula_area` WHERE `level`='inicial' AND `order_index`=7 LIMIT 1);

-- Competencias: Personal Social Inicial
INSERT INTO `plugin_school_curricula_competencia` (`area_id`, `name`, `order_index`) VALUES
(@ps_id, 'Construye su identidad.', 1),
(@ps_id, 'Convive y participa democráticamente en la búsqueda del bien común.', 2);

-- Capacidades: Personal Social Inicial
INSERT INTO `plugin_school_curricula_capacidad` (`area_id`, `name`, `order_index`) VALUES
(@ps_id, 'Se valora a sí mismo.', 1),
(@ps_id, 'Autorregula sus emociones.', 2),
(@ps_id, 'Interactúa con todas las personas.', 3),
(@ps_id, 'Participa en acciones que promueven el bienestar común.', 4);

-- Competencias: Psicomotriz Inicial
INSERT INTO `plugin_school_curricula_competencia` (`area_id`, `name`, `order_index`) VALUES
(@psi_id, 'Se desenvuelve de manera autónoma a través de su motricidad.', 1);

-- Capacidades: Psicomotriz Inicial
INSERT INTO `plugin_school_curricula_capacidad` (`area_id`, `name`, `order_index`) VALUES
(@psi_id, 'Comprende su cuerpo.', 1),
(@psi_id, 'Se expresa corporalmente.', 2);

-- Competencias: Comunicación Inicial
INSERT INTO `plugin_school_curricula_competencia` (`area_id`, `name`, `order_index`) VALUES
(@com_id, 'Se comunica oralmente en su lengua materna.', 1),
(@com_id, 'Lee diversos tipos de textos en su lengua materna.', 2),
(@com_id, 'Escribe diversos tipos de textos en su lengua materna.', 3);

-- Capacidades: Comunicación Inicial
INSERT INTO `plugin_school_curricula_capacidad` (`area_id`, `name`, `order_index`) VALUES
(@com_id, 'Obtiene información del texto oral o escrito.', 1),
(@com_id, 'Infiere e interpreta información.', 2),
(@com_id, 'Adecúa, organiza y desarrolla ideas.', 3),
(@com_id, 'Utiliza recursos verbales y no verbales.', 4),
(@com_id, 'Reflexiona sobre el lenguaje.', 5);

-- Competencias: Castellano como Segunda Lengua (EIB) Inicial
INSERT INTO `plugin_school_curricula_competencia` (`area_id`, `name`, `order_index`) VALUES
(@cas_id, 'Se comunica oralmente en castellano como segunda lengua.', 1),
(@cas_id, 'Lee textos en castellano como segunda lengua.', 2),
(@cas_id, 'Escribe textos en castellano como segunda lengua.', 3);

-- Competencias: Descubrimiento del Mundo Inicial
INSERT INTO `plugin_school_curricula_competencia` (`area_id`, `name`, `order_index`) VALUES
(@desc_id, 'Resuelve problemas de cantidad.', 1),
(@desc_id, 'Resuelve problemas de forma, movimiento y localización.', 2),
(@desc_id, 'Indaga mediante métodos científicos para construir conocimientos.', 3);

-- Capacidades: Descubrimiento del Mundo Inicial
INSERT INTO `plugin_school_curricula_capacidad` (`area_id`, `name`, `order_index`) VALUES
(@desc_id, 'Usa nociones matemáticas básicas.', 1),
(@desc_id, 'Explora el espacio y objetos.', 2),
(@desc_id, 'Observa y formula preguntas.', 3),
(@desc_id, 'Experimenta y comunica descubrimientos.', 4);

-- Competencias: Arte y Cultura Inicial
INSERT INTO `plugin_school_curricula_competencia` (`area_id`, `name`, `order_index`) VALUES
(@art_id, 'Aprecia de manera crítica manifestaciones artístico-culturales.', 1),
(@art_id, 'Crea proyectos desde los lenguajes artísticos.', 2);

-- Capacidades: Arte y Cultura Inicial
INSERT INTO `plugin_school_curricula_capacidad` (`area_id`, `name`, `order_index`) VALUES
(@art_id, 'Explora materiales y sonidos.', 1),
(@art_id, 'Expresa ideas y emociones.', 2),
(@art_id, 'Experimenta con dibujo, pintura, música y movimiento.', 3);

-- Competencias: Educación Religiosa Inicial
INSERT INTO `plugin_school_curricula_competencia` (`area_id`, `name`, `order_index`) VALUES
(@rel_id, 'Construye su identidad como persona humana, amada por Dios.', 1),
(@rel_id, 'Asume la experiencia del encuentro con Dios en su vida cotidiana.', 2);

-- Capacidades: Educación Religiosa Inicial
INSERT INTO `plugin_school_curricula_capacidad` (`area_id`, `name`, `order_index`) VALUES
(@rel_id, 'Reconoce manifestaciones de amor y respeto.', 1),
(@rel_id, 'Participa en prácticas religiosas y valores cristianos.', 2);

-- ============================================================
-- COMPETENCIAS TRANSVERSALES DE INICIAL
-- ============================================================
INSERT INTO `plugin_school_curricula_transversal` (`name`, `level`, `order_index`) VALUES
('Se desenvuelve en entornos virtuales generados por las TIC', 'inicial', 1),
('Gestiona su aprendizaje de manera autónoma',                 'inicial', 2);

SET @tic_ini = (SELECT id FROM `plugin_school_curricula_transversal` WHERE `level`='inicial' AND `order_index`=1 LIMIT 1);
SET @apr_ini = (SELECT id FROM `plugin_school_curricula_transversal` WHERE `level`='inicial' AND `order_index`=2 LIMIT 1);

INSERT INTO `plugin_school_curricula_transversal_cap` (`transversal_id`, `name`, `order_index`) VALUES
(@tic_ini, 'Explora herramientas digitales.', 1),
(@tic_ini, 'Interactúa con recursos tecnológicos básicos.', 2);

INSERT INTO `plugin_school_curricula_transversal_cap` (`transversal_id`, `name`, `order_index`) VALUES
(@apr_ini, 'Explora de manera autónoma.', 1),
(@apr_ini, 'Expresa intereses y necesidades.', 2),
(@apr_ini, 'Participa activamente en experiencias de aprendizaje.', 3);

-- ============================================================
-- ENFOQUES TRANSVERSALES DE INICIAL
-- ============================================================
INSERT INTO `plugin_school_curricula_enfoque` (`name`, `level`, `order_index`) VALUES
('Enfoque de derechos',          'inicial', 1),
('Inclusión y diversidad',       'inicial', 2),
('Interculturalidad',            'inicial', 3),
('Igualdad de género',           'inicial', 4),
('Ambiental',                    'inicial', 5),
('Bien común',                   'inicial', 6),
('Excelencia',                   'inicial', 7);
