-- ============================================================
-- MIGRACIÓN ÁREAS CURRICULARES - PRODUCCIÓN
-- Seguro: usa IF NOT EXISTS y no duplica datos
-- ============================================================

-- 1. Crear tablas
CREATE TABLE IF NOT EXISTS `plugin_school_curricula_area` (
    `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name`        VARCHAR(200) NOT NULL,
    `level`       ENUM('inicial','primaria','secundaria','ambos') NOT NULL DEFAULT 'ambos',
    `active`      TINYINT(1) NOT NULL DEFAULT 1,
    `order_index` INT NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `plugin_school_curricula_competencia` (
    `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `area_id`     INT UNSIGNED NOT NULL,
    `name`        VARCHAR(300) NOT NULL,
    `active`      TINYINT(1) NOT NULL DEFAULT 1,
    `order_index` INT NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `idx_area` (`area_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `plugin_school_curricula_capacidad` (
    `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `area_id`     INT UNSIGNED NOT NULL,
    `name`        VARCHAR(300) NOT NULL,
    `active`      TINYINT(1) NOT NULL DEFAULT 1,
    `order_index` INT NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `idx_area` (`area_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `plugin_school_curricula_transversal` (
    `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name`        VARCHAR(300) NOT NULL,
    `level`       ENUM('inicial','ebr') NOT NULL DEFAULT 'ebr',
    `active`      TINYINT(1) NOT NULL DEFAULT 1,
    `order_index` INT NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `plugin_school_curricula_transversal_cap` (
    `id`             INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `transversal_id` INT UNSIGNED NOT NULL,
    `name`           VARCHAR(300) NOT NULL,
    `active`         TINYINT(1) NOT NULL DEFAULT 1,
    `order_index`    INT NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `idx_transversal` (`transversal_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `plugin_school_curricula_enfoque` (
    `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name`        VARCHAR(300) NOT NULL,
    `level`       ENUM('inicial','ebr','ambos') NOT NULL DEFAULT 'ebr',
    `active`      TINYINT(1) NOT NULL DEFAULT 1,
    `order_index` INT NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Agregar columnas si no existen (ALTER seguro)
ALTER TABLE `plugin_school_curricula_area`
    MODIFY COLUMN `level` ENUM('inicial','primaria','secundaria','ambos') NOT NULL DEFAULT 'ambos';

ALTER TABLE `plugin_school_curricula_transversal`
    ADD COLUMN IF NOT EXISTS `level` ENUM('inicial','ebr') NOT NULL DEFAULT 'ebr' AFTER `name`;

ALTER TABLE `plugin_school_curricula_enfoque`
    ADD COLUMN IF NOT EXISTS `level` ENUM('inicial','ebr','ambos') NOT NULL DEFAULT 'ebr' AFTER `name`;

-- 3. Cargar datos solo si las tablas están vacías
-- (Si ya corriste la migración antes, esto no inserta nada)

INSERT INTO `plugin_school_curricula_area` (`name`, `level`, `order_index`)
SELECT * FROM (VALUES
    ROW('Comunicación',                                         'ambos',      1),
    ROW('Matemática',                                           'ambos',      2),
    ROW('Ciencia y Tecnología',                                 'ambos',      3),
    ROW('Personal Social',                                      'primaria',   4),
    ROW('Desarrollo Personal, Ciudadanía y Cívica',             'secundaria', 5),
    ROW('Ciencias Sociales',                                    'secundaria', 6),
    ROW('Educación Religiosa',                                  'ambos',      7),
    ROW('Arte y Cultura',                                       'ambos',      8),
    ROW('Educación Física',                                     'ambos',      9),
    ROW('Inglés como Lengua Extranjera',                        'ambos',      10),
    ROW('Educación para el Trabajo',                            'ambos',      11),
    ROW('Personal Social',                                      'inicial',    1),
    ROW('Psicomotriz',                                          'inicial',    2),
    ROW('Comunicación',                                         'inicial',    3),
    ROW('Castellano como Segunda Lengua (EIB)',                 'inicial',    4),
    ROW('Descubrimiento del Mundo',                             'inicial',    5),
    ROW('Arte y Cultura',                                       'inicial',    6),
    ROW('Educación Religiosa',                                  'inicial',    7)
) AS tmp(name, level, order_index)
WHERE (SELECT COUNT(*) FROM `plugin_school_curricula_area`) = 0;

-- Competencias y capacidades: solo si área existe y no tiene competencias aún
-- Se usan variables para los IDs dinámicos

SET @com_ebr  = (SELECT id FROM `plugin_school_curricula_area` WHERE level='ambos'      AND order_index=1  LIMIT 1);
SET @mat_ebr  = (SELECT id FROM `plugin_school_curricula_area` WHERE level='ambos'      AND order_index=2  LIMIT 1);
SET @cyt_ebr  = (SELECT id FROM `plugin_school_curricula_area` WHERE level='ambos'      AND order_index=3  LIMIT 1);
SET @ps_ebr   = (SELECT id FROM `plugin_school_curricula_area` WHERE level='primaria'   AND order_index=4  LIMIT 1);
SET @dpcc_ebr = (SELECT id FROM `plugin_school_curricula_area` WHERE level='secundaria' AND order_index=5  LIMIT 1);
SET @cs_ebr   = (SELECT id FROM `plugin_school_curricula_area` WHERE level='secundaria' AND order_index=6  LIMIT 1);
SET @rel_ebr  = (SELECT id FROM `plugin_school_curricula_area` WHERE level='ambos'      AND order_index=7  LIMIT 1);
SET @art_ebr  = (SELECT id FROM `plugin_school_curricula_area` WHERE level='ambos'      AND order_index=8  LIMIT 1);
SET @ef_ebr   = (SELECT id FROM `plugin_school_curricula_area` WHERE level='ambos'      AND order_index=9  LIMIT 1);
SET @ing_ebr  = (SELECT id FROM `plugin_school_curricula_area` WHERE level='ambos'      AND order_index=10 LIMIT 1);
SET @edt_ebr  = (SELECT id FROM `plugin_school_curricula_area` WHERE level='ambos'      AND order_index=11 LIMIT 1);
SET @ps_ini   = (SELECT id FROM `plugin_school_curricula_area` WHERE level='inicial'    AND order_index=1  LIMIT 1);
SET @psi_ini  = (SELECT id FROM `plugin_school_curricula_area` WHERE level='inicial'    AND order_index=2  LIMIT 1);
SET @com_ini  = (SELECT id FROM `plugin_school_curricula_area` WHERE level='inicial'    AND order_index=3  LIMIT 1);
SET @cas_ini  = (SELECT id FROM `plugin_school_curricula_area` WHERE level='inicial'    AND order_index=4  LIMIT 1);
SET @desc_ini = (SELECT id FROM `plugin_school_curricula_area` WHERE level='inicial'    AND order_index=5  LIMIT 1);
SET @art_ini  = (SELECT id FROM `plugin_school_curricula_area` WHERE level='inicial'    AND order_index=6  LIMIT 1);
SET @rel_ini  = (SELECT id FROM `plugin_school_curricula_area` WHERE level='inicial'    AND order_index=7  LIMIT 1);

INSERT INTO `plugin_school_curricula_competencia` (`area_id`, `name`, `order_index`)
SELECT area_id, name, ord FROM (VALUES
    -- Comunicación EBR
    ROW(@com_ebr,  'Se comunica oralmente en su lengua materna.',                               1),
    ROW(@com_ebr,  'Lee diversos tipos de textos escritos.',                                     2),
    ROW(@com_ebr,  'Escribe diversos tipos de textos.',                                          3),
    -- Matemática EBR
    ROW(@mat_ebr,  'Resuelve problemas de cantidad.',                                            1),
    ROW(@mat_ebr,  'Resuelve problemas de regularidad, equivalencia y cambio.',                  2),
    ROW(@mat_ebr,  'Resuelve problemas de forma, movimiento y localización.',                    3),
    ROW(@mat_ebr,  'Resuelve problemas de gestión de datos e incertidumbre.',                    4),
    -- Ciencia y Tecnología EBR
    ROW(@cyt_ebr,  'Indaga mediante métodos científicos.',                                       1),
    ROW(@cyt_ebr,  'Explica el mundo físico basándose en conocimientos científicos.',            2),
    ROW(@cyt_ebr,  'Diseña y construye soluciones tecnológicas.',                                3),
    -- Personal Social Primaria
    ROW(@ps_ebr,   'Construye su identidad.',                                                    1),
    ROW(@ps_ebr,   'Convive y participa democráticamente.',                                      2),
    ROW(@ps_ebr,   'Construye interpretaciones históricas.',                                     3),
    ROW(@ps_ebr,   'Gestiona responsablemente el espacio y ambiente.',                           4),
    ROW(@ps_ebr,   'Gestiona responsablemente los recursos económicos.',                         5),
    -- DPCC Secundaria
    ROW(@dpcc_ebr, 'Construye su identidad.',                                                    1),
    ROW(@dpcc_ebr, 'Convive y participa democráticamente.',                                      2),
    -- Ciencias Sociales Secundaria
    ROW(@cs_ebr,   'Construye interpretaciones históricas.',                                     1),
    ROW(@cs_ebr,   'Gestiona responsablemente el espacio y ambiente.',                           2),
    ROW(@cs_ebr,   'Gestiona responsablemente los recursos económicos.',                         3),
    -- Educación Religiosa EBR
    ROW(@rel_ebr,  'Construye su identidad como persona humana, amada por Dios.',               1),
    ROW(@rel_ebr,  'Asume la experiencia del encuentro personal y comunitario con Dios.',        2),
    -- Arte y Cultura EBR
    ROW(@art_ebr,  'Aprecia de manera crítica manifestaciones artístico-culturales.',            1),
    ROW(@art_ebr,  'Crea proyectos desde los lenguajes artísticos.',                             2),
    -- Educación Física EBR
    ROW(@ef_ebr,   'Se desenvuelve de manera autónoma a través de su motricidad.',              1),
    ROW(@ef_ebr,   'Asume una vida saludable.',                                                  2),
    ROW(@ef_ebr,   'Interactúa a través de sus habilidades sociomotrices.',                     3),
    -- Inglés EBR
    ROW(@ing_ebr,  'Se comunica oralmente en inglés.',                                           1),
    ROW(@ing_ebr,  'Lee diversos tipos de textos en inglés.',                                    2),
    ROW(@ing_ebr,  'Escribe diversos tipos de textos en inglés.',                                3),
    -- Educación para el Trabajo EBR
    ROW(@edt_ebr,  'Gestiona proyectos de emprendimiento económico o social.',                  1),
    -- Personal Social Inicial
    ROW(@ps_ini,   'Construye su identidad.',                                                    1),
    ROW(@ps_ini,   'Convive y participa democráticamente en la búsqueda del bien común.',       2),
    -- Psicomotriz Inicial
    ROW(@psi_ini,  'Se desenvuelve de manera autónoma a través de su motricidad.',              1),
    -- Comunicación Inicial
    ROW(@com_ini,  'Se comunica oralmente en su lengua materna.',                               1),
    ROW(@com_ini,  'Lee diversos tipos de textos en su lengua materna.',                        2),
    ROW(@com_ini,  'Escribe diversos tipos de textos en su lengua materna.',                    3),
    -- Castellano EIB Inicial
    ROW(@cas_ini,  'Se comunica oralmente en castellano como segunda lengua.',                  1),
    ROW(@cas_ini,  'Lee textos en castellano como segunda lengua.',                              2),
    ROW(@cas_ini,  'Escribe textos en castellano como segunda lengua.',                         3),
    -- Descubrimiento del Mundo Inicial
    ROW(@desc_ini, 'Resuelve problemas de cantidad.',                                            1),
    ROW(@desc_ini, 'Resuelve problemas de forma, movimiento y localización.',                   2),
    ROW(@desc_ini, 'Indaga mediante métodos científicos para construir conocimientos.',          3),
    -- Arte y Cultura Inicial
    ROW(@art_ini,  'Aprecia de manera crítica manifestaciones artístico-culturales.',            1),
    ROW(@art_ini,  'Crea proyectos desde los lenguajes artísticos.',                             2),
    -- Educación Religiosa Inicial
    ROW(@rel_ini,  'Construye su identidad como persona humana, amada por Dios.',               1),
    ROW(@rel_ini,  'Asume la experiencia del encuentro con Dios en su vida cotidiana.',         2)
) AS tmp(area_id, name, ord)
WHERE (SELECT COUNT(*) FROM `plugin_school_curricula_competencia`) = 0
  AND area_id IS NOT NULL;

INSERT INTO `plugin_school_curricula_capacidad` (`area_id`, `name`, `order_index`)
SELECT area_id, name, ord FROM (VALUES
    -- Comunicación EBR
    ROW(@com_ebr,  'Obtiene información.',                              1),
    ROW(@com_ebr,  'Infiere e interpreta información.',                 2),
    ROW(@com_ebr,  'Organiza y desarrolla ideas.',                      3),
    ROW(@com_ebr,  'Utiliza recursos no verbales y paraverbales.',      4),
    ROW(@com_ebr,  'Reflexiona y evalúa.',                              5),
    -- Matemática EBR
    ROW(@mat_ebr,  'Traduce cantidades a expresiones numéricas.',       1),
    ROW(@mat_ebr,  'Comunica comprensión matemática.',                  2),
    ROW(@mat_ebr,  'Usa estrategias y procedimientos.',                 3),
    ROW(@mat_ebr,  'Argumenta afirmaciones matemáticas.',               4),
    -- Ciencia y Tecnología EBR
    ROW(@cyt_ebr,  'Problematiza situaciones.',                         1),
    ROW(@cyt_ebr,  'Diseña estrategias.',                               2),
    ROW(@cyt_ebr,  'Genera y registra datos.',                          3),
    ROW(@cyt_ebr,  'Analiza datos e información.',                      4),
    ROW(@cyt_ebr,  'Evalúa y comunica resultados.',                     5),
    -- Personal Social Primaria
    ROW(@ps_ebr,   'Se valora a sí mismo.',                             1),
    ROW(@ps_ebr,   'Autorregula emociones.',                            2),
    ROW(@ps_ebr,   'Interactúa con todas las personas.',                3),
    ROW(@ps_ebr,   'Delibera sobre asuntos públicos.',                  4),
    ROW(@ps_ebr,   'Comprende relaciones históricas.',                  5),
    ROW(@ps_ebr,   'Maneja fuentes de información.',                    6),
    ROW(@ps_ebr,   'Toma decisiones económicas responsables.',          7),
    -- DPCC Secundaria
    ROW(@dpcc_ebr, 'Reflexiona sobre sí mismo.',                        1),
    ROW(@dpcc_ebr, 'Maneja conflictos.',                                2),
    ROW(@dpcc_ebr, 'Participa en acciones democráticas.',               3),
    ROW(@dpcc_ebr, 'Delibera asuntos públicos.',                        4),
    -- Ciencias Sociales Secundaria
    ROW(@cs_ebr,   'Interpreta fuentes históricas.',                    1),
    ROW(@cs_ebr,   'Comprende el tiempo histórico.',                    2),
    ROW(@cs_ebr,   'Maneja información geográfica.',                    3),
    ROW(@cs_ebr,   'Comprende relaciones económicas.',                  4),
    -- Educación Religiosa EBR
    ROW(@rel_ebr,  'Conoce a Dios y asume su identidad religiosa.',     1),
    ROW(@rel_ebr,  'Cultiva y valora manifestaciones religiosas.',      2),
    ROW(@rel_ebr,  'Transforma su entorno desde valores cristianos.',   3),
    -- Arte y Cultura EBR
    ROW(@art_ebr,  'Percibe manifestaciones artísticas.',               1),
    ROW(@art_ebr,  'Contextualiza manifestaciones culturales.',         2),
    ROW(@art_ebr,  'Experimenta procesos creativos.',                   3),
    ROW(@art_ebr,  'Presenta proyectos artísticos.',                    4),
    -- Educación Física EBR
    ROW(@ef_ebr,   'Comprende su cuerpo.',                              1),
    ROW(@ef_ebr,   'Se expresa corporalmente.',                         2),
    ROW(@ef_ebr,   'Incorpora prácticas saludables.',                   3),
    ROW(@ef_ebr,   'Coopera y participa en actividades físicas.',       4),
    -- Inglés EBR
    ROW(@ing_ebr,  'Obtiene información.',                              1),
    ROW(@ing_ebr,  'Infiere e interpreta.',                             2),
    ROW(@ing_ebr,  'Organiza ideas.',                                   3),
    ROW(@ing_ebr,  'Reflexiona sobre el lenguaje.',                     4),
    -- Educación para el Trabajo EBR
    ROW(@edt_ebr,  'Crea propuestas de valor.',                         1),
    ROW(@edt_ebr,  'Trabaja cooperativamente.',                         2),
    ROW(@edt_ebr,  'Aplica habilidades técnicas.',                      3),
    ROW(@edt_ebr,  'Evalúa resultados del proyecto.',                   4),
    -- Personal Social Inicial
    ROW(@ps_ini,   'Se valora a sí mismo.',                             1),
    ROW(@ps_ini,   'Autorregula sus emociones.',                        2),
    ROW(@ps_ini,   'Interactúa con todas las personas.',                3),
    ROW(@ps_ini,   'Participa en acciones que promueven el bienestar común.', 4),
    -- Psicomotriz Inicial
    ROW(@psi_ini,  'Comprende su cuerpo.',                              1),
    ROW(@psi_ini,  'Se expresa corporalmente.',                         2),
    -- Comunicación Inicial
    ROW(@com_ini,  'Obtiene información del texto oral o escrito.',     1),
    ROW(@com_ini,  'Infiere e interpreta información.',                 2),
    ROW(@com_ini,  'Adecúa, organiza y desarrolla ideas.',             3),
    ROW(@com_ini,  'Utiliza recursos verbales y no verbales.',          4),
    ROW(@com_ini,  'Reflexiona sobre el lenguaje.',                     5),
    -- Descubrimiento del Mundo Inicial
    ROW(@desc_ini, 'Usa nociones matemáticas básicas.',                 1),
    ROW(@desc_ini, 'Explora el espacio y objetos.',                     2),
    ROW(@desc_ini, 'Observa y formula preguntas.',                      3),
    ROW(@desc_ini, 'Experimenta y comunica descubrimientos.',           4),
    -- Arte y Cultura Inicial
    ROW(@art_ini,  'Explora materiales y sonidos.',                     1),
    ROW(@art_ini,  'Expresa ideas y emociones.',                        2),
    ROW(@art_ini,  'Experimenta con dibujo, pintura, música y movimiento.', 3),
    -- Educación Religiosa Inicial
    ROW(@rel_ini,  'Reconoce manifestaciones de amor y respeto.',       1),
    ROW(@rel_ini,  'Participa en prácticas religiosas y valores cristianos.', 2)
) AS tmp(area_id, name, ord)
WHERE (SELECT COUNT(*) FROM `plugin_school_curricula_capacidad`) = 0
  AND area_id IS NOT NULL;

INSERT INTO `plugin_school_curricula_transversal` (`name`, `level`, `order_index`)
SELECT * FROM (VALUES
    ROW('Se desenvuelve en entornos virtuales generados por las TIC', 'ebr',     1),
    ROW('Gestiona su aprendizaje de manera autónoma',                 'ebr',     2),
    ROW('Se desenvuelve en entornos virtuales generados por las TIC', 'inicial', 1),
    ROW('Gestiona su aprendizaje de manera autónoma',                 'inicial', 2)
) AS tmp(name, level, ord)
WHERE (SELECT COUNT(*) FROM `plugin_school_curricula_transversal`) = 0;

SET @tic_ebr  = (SELECT id FROM `plugin_school_curricula_transversal` WHERE level='ebr'     AND order_index=1 LIMIT 1);
SET @apr_ebr  = (SELECT id FROM `plugin_school_curricula_transversal` WHERE level='ebr'     AND order_index=2 LIMIT 1);
SET @tic_ini2 = (SELECT id FROM `plugin_school_curricula_transversal` WHERE level='inicial' AND order_index=1 LIMIT 1);
SET @apr_ini2 = (SELECT id FROM `plugin_school_curricula_transversal` WHERE level='inicial' AND order_index=2 LIMIT 1);

INSERT INTO `plugin_school_curricula_transversal_cap` (`transversal_id`, `name`, `order_index`)
SELECT tid, name, ord FROM (VALUES
    ROW(@tic_ebr,  'Personaliza entornos virtuales.',                        1),
    ROW(@tic_ebr,  'Gestiona información.',                                  2),
    ROW(@tic_ebr,  'Interactúa en entornos virtuales.',                      3),
    ROW(@tic_ebr,  'Crea objetos virtuales.',                                4),
    ROW(@apr_ebr,  'Define metas de aprendizaje.',                           1),
    ROW(@apr_ebr,  'Organiza acciones estratégicas.',                        2),
    ROW(@apr_ebr,  'Monitorea y ajusta su desempeño.',                       3),
    ROW(@tic_ini2, 'Explora herramientas digitales.',                        1),
    ROW(@tic_ini2, 'Interactúa con recursos tecnológicos básicos.',          2),
    ROW(@apr_ini2, 'Explora de manera autónoma.',                            1),
    ROW(@apr_ini2, 'Expresa intereses y necesidades.',                       2),
    ROW(@apr_ini2, 'Participa activamente en experiencias de aprendizaje.',  3)
) AS tmp(tid, name, ord)
WHERE (SELECT COUNT(*) FROM `plugin_school_curricula_transversal_cap`) = 0
  AND tid IS NOT NULL;

INSERT INTO `plugin_school_curricula_enfoque` (`name`, `level`, `order_index`)
SELECT * FROM (VALUES
    ROW('Enfoque de derechos',                     'ebr',     1),
    ROW('Inclusivo o de atención a la diversidad', 'ebr',     2),
    ROW('Intercultural',                           'ebr',     3),
    ROW('Igualdad de género',                      'ebr',     4),
    ROW('Ambiental',                               'ebr',     5),
    ROW('Orientación al bien común',               'ebr',     6),
    ROW('Búsqueda de la excelencia',               'ebr',     7),
    ROW('Enfoque de derechos',                     'inicial', 1),
    ROW('Inclusión y diversidad',                  'inicial', 2),
    ROW('Interculturalidad',                       'inicial', 3),
    ROW('Igualdad de género',                      'inicial', 4),
    ROW('Ambiental',                               'inicial', 5),
    ROW('Bien común',                              'inicial', 6),
    ROW('Excelencia',                              'inicial', 7)
) AS tmp(name, level, ord)
WHERE (SELECT COUNT(*) FROM `plugin_school_curricula_enfoque`) = 0;
