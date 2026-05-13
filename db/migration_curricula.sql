-- Áreas Curriculares de EBR (MINEDU)
CREATE TABLE IF NOT EXISTS `plugin_school_curricula_area` (
    `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name`        VARCHAR(200) NOT NULL,
    `level`       ENUM('primaria','secundaria','ambos') NOT NULL DEFAULT 'ambos',
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
    `active`      TINYINT(1) NOT NULL DEFAULT 1,
    `order_index` INT NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- SEED DATA
-- ============================================================

-- Areas
INSERT INTO `plugin_school_curricula_area` (`name`, `level`, `order_index`) VALUES
('Comunicación',                                         'ambos',      1),
('Matemática',                                           'ambos',      2),
('Ciencia y Tecnología',                                 'ambos',      3),
('Personal Social',                                      'primaria',   4),
('Desarrollo Personal, Ciudadanía y Cívica',             'secundaria', 5),
('Ciencias Sociales',                                    'secundaria', 6),
('Educación Religiosa',                                  'ambos',      7),
('Arte y Cultura',                                       'ambos',      8),
('Educación Física',                                     'ambos',      9),
('Inglés como Lengua Extranjera',                        'ambos',      10),
('Educación para el Trabajo',                            'ambos',      11);

-- Competencias: Comunicación (area_id=1)
INSERT INTO `plugin_school_curricula_competencia` (`area_id`, `name`, `order_index`) VALUES
(1, 'Se comunica oralmente en su lengua materna.',  1),
(1, 'Lee diversos tipos de textos escritos.',       2),
(1, 'Escribe diversos tipos de textos.',            3);

-- Capacidades: Comunicación (area_id=1)
INSERT INTO `plugin_school_curricula_capacidad` (`area_id`, `name`, `order_index`) VALUES
(1, 'Obtiene información.',                            1),
(1, 'Infiere e interpreta información.',              2),
(1, 'Organiza y desarrolla ideas.',                   3),
(1, 'Utiliza recursos no verbales y paraverbales.',   4),
(1, 'Reflexiona y evalúa.',                           5);

-- Competencias: Matemática (area_id=2)
INSERT INTO `plugin_school_curricula_competencia` (`area_id`, `name`, `order_index`) VALUES
(2, 'Resuelve problemas de cantidad.',                                    1),
(2, 'Resuelve problemas de regularidad, equivalencia y cambio.',          2),
(2, 'Resuelve problemas de forma, movimiento y localización.',            3),
(2, 'Resuelve problemas de gestión de datos e incertidumbre.',            4);

-- Capacidades: Matemática (area_id=2)
INSERT INTO `plugin_school_curricula_capacidad` (`area_id`, `name`, `order_index`) VALUES
(2, 'Traduce cantidades a expresiones numéricas.',    1),
(2, 'Comunica comprensión matemática.',               2),
(2, 'Usa estrategias y procedimientos.',              3),
(2, 'Argumenta afirmaciones matemáticas.',            4);

-- Competencias: Ciencia y Tecnología (area_id=3)
INSERT INTO `plugin_school_curricula_competencia` (`area_id`, `name`, `order_index`) VALUES
(3, 'Indaga mediante métodos científicos.',                              1),
(3, 'Explica el mundo físico basándose en conocimientos científicos.',   2),
(3, 'Diseña y construye soluciones tecnológicas.',                       3);

-- Capacidades: Ciencia y Tecnología (area_id=3)
INSERT INTO `plugin_school_curricula_capacidad` (`area_id`, `name`, `order_index`) VALUES
(3, 'Problematiza situaciones.',            1),
(3, 'Diseña estrategias.',                  2),
(3, 'Genera y registra datos.',             3),
(3, 'Analiza datos e información.',         4),
(3, 'Evalúa y comunica resultados.',        5);

-- Competencias: Personal Social (area_id=4)
INSERT INTO `plugin_school_curricula_competencia` (`area_id`, `name`, `order_index`) VALUES
(4, 'Construye su identidad.',                                       1),
(4, 'Convive y participa democráticamente.',                         2),
(4, 'Construye interpretaciones históricas.',                        3),
(4, 'Gestiona responsablemente el espacio y ambiente.',              4),
(4, 'Gestiona responsablemente los recursos económicos.',            5);

-- Capacidades: Personal Social (area_id=4)
INSERT INTO `plugin_school_curricula_capacidad` (`area_id`, `name`, `order_index`) VALUES
(4, 'Se valora a sí mismo.',                             1),
(4, 'Autorregula emociones.',                            2),
(4, 'Interactúa con todas las personas.',                3),
(4, 'Delibera sobre asuntos públicos.',                  4),
(4, 'Comprende relaciones históricas.',                  5),
(4, 'Maneja fuentes de información.',                    6),
(4, 'Toma decisiones económicas responsables.',          7);

-- Competencias: Desarrollo Personal, Ciudadanía y Cívica (area_id=5)
INSERT INTO `plugin_school_curricula_competencia` (`area_id`, `name`, `order_index`) VALUES
(5, 'Construye su identidad.',              1),
(5, 'Convive y participa democráticamente.',2);

-- Capacidades: Desarrollo Personal, Ciudadanía y Cívica (area_id=5)
INSERT INTO `plugin_school_curricula_capacidad` (`area_id`, `name`, `order_index`) VALUES
(5, 'Reflexiona sobre sí mismo.',           1),
(5, 'Maneja conflictos.',                   2),
(5, 'Participa en acciones democráticas.',  3),
(5, 'Delibera asuntos públicos.',           4);

-- Competencias: Ciencias Sociales (area_id=6)
INSERT INTO `plugin_school_curricula_competencia` (`area_id`, `name`, `order_index`) VALUES
(6, 'Construye interpretaciones históricas.',                1),
(6, 'Gestiona responsablemente el espacio y ambiente.',      2),
(6, 'Gestiona responsablemente los recursos económicos.',    3);

-- Capacidades: Ciencias Sociales (area_id=6)
INSERT INTO `plugin_school_curricula_capacidad` (`area_id`, `name`, `order_index`) VALUES
(6, 'Interpreta fuentes históricas.',       1),
(6, 'Comprende el tiempo histórico.',       2),
(6, 'Maneja información geográfica.',       3),
(6, 'Comprende relaciones económicas.',     4);

-- Competencias: Educación Religiosa (area_id=7)
INSERT INTO `plugin_school_curricula_competencia` (`area_id`, `name`, `order_index`) VALUES
(7, 'Construye su identidad como persona humana, amada por Dios.',         1),
(7, 'Asume la experiencia del encuentro personal y comunitario con Dios.', 2);

-- Capacidades: Educación Religiosa (area_id=7)
INSERT INTO `plugin_school_curricula_capacidad` (`area_id`, `name`, `order_index`) VALUES
(7, 'Conoce a Dios y asume su identidad religiosa.',    1),
(7, 'Cultiva y valora manifestaciones religiosas.',     2),
(7, 'Transforma su entorno desde valores cristianos.',  3);

-- Competencias: Arte y Cultura (area_id=8)
INSERT INTO `plugin_school_curricula_competencia` (`area_id`, `name`, `order_index`) VALUES
(8, 'Aprecia de manera crítica manifestaciones artístico-culturales.',  1),
(8, 'Crea proyectos desde los lenguajes artísticos.',                   2);

-- Capacidades: Arte y Cultura (area_id=8)
INSERT INTO `plugin_school_curricula_capacidad` (`area_id`, `name`, `order_index`) VALUES
(8, 'Percibe manifestaciones artísticas.',          1),
(8, 'Contextualiza manifestaciones culturales.',    2),
(8, 'Experimenta procesos creativos.',              3),
(8, 'Presenta proyectos artísticos.',               4);

-- Competencias: Educación Física (area_id=9)
INSERT INTO `plugin_school_curricula_competencia` (`area_id`, `name`, `order_index`) VALUES
(9, 'Se desenvuelve de manera autónoma a través de su motricidad.',  1),
(9, 'Asume una vida saludable.',                                      2),
(9, 'Interactúa a través de sus habilidades sociomotrices.',         3);

-- Capacidades: Educación Física (area_id=9)
INSERT INTO `plugin_school_curricula_capacidad` (`area_id`, `name`, `order_index`) VALUES
(9, 'Comprende su cuerpo.',                              1),
(9, 'Se expresa corporalmente.',                         2),
(9, 'Incorpora prácticas saludables.',                   3),
(9, 'Coopera y participa en actividades físicas.',       4);

-- Competencias: Inglés como Lengua Extranjera (area_id=10)
INSERT INTO `plugin_school_curricula_competencia` (`area_id`, `name`, `order_index`) VALUES
(10, 'Se comunica oralmente en inglés.',                1),
(10, 'Lee diversos tipos de textos en inglés.',         2),
(10, 'Escribe diversos tipos de textos en inglés.',     3);

-- Capacidades: Inglés como Lengua Extranjera (area_id=10)
INSERT INTO `plugin_school_curricula_capacidad` (`area_id`, `name`, `order_index`) VALUES
(10, 'Obtiene información.',             1),
(10, 'Infiere e interpreta.',            2),
(10, 'Organiza ideas.',                  3),
(10, 'Reflexiona sobre el lenguaje.',    4);

-- Competencias: Educación para el Trabajo (area_id=11)
INSERT INTO `plugin_school_curricula_competencia` (`area_id`, `name`, `order_index`) VALUES
(11, 'Gestiona proyectos de emprendimiento económico o social.', 1);

-- Capacidades: Educación para el Trabajo (area_id=11)
INSERT INTO `plugin_school_curricula_capacidad` (`area_id`, `name`, `order_index`) VALUES
(11, 'Crea propuestas de valor.',            1),
(11, 'Trabaja cooperativamente.',            2),
(11, 'Aplica habilidades técnicas.',         3),
(11, 'Evalúa resultados del proyecto.',      4);

-- Competencias Transversales
INSERT INTO `plugin_school_curricula_transversal` (`name`, `order_index`) VALUES
('Se desenvuelve en entornos virtuales generados por las TIC', 1),
('Gestiona su aprendizaje de manera autónoma',                 2);

-- Capacidades de Competencias Transversales (transversal_id=1)
INSERT INTO `plugin_school_curricula_transversal_cap` (`transversal_id`, `name`, `order_index`) VALUES
(1, 'Personaliza entornos virtuales.',      1),
(1, 'Gestiona información.',                2),
(1, 'Interactúa en entornos virtuales.',    3),
(1, 'Crea objetos virtuales.',              4);

-- Capacidades de Competencias Transversales (transversal_id=2)
INSERT INTO `plugin_school_curricula_transversal_cap` (`transversal_id`, `name`, `order_index`) VALUES
(2, 'Define metas de aprendizaje.',                 1),
(2, 'Organiza acciones estratégicas.',              2),
(2, 'Monitorea y ajusta su desempeño.',             3);

-- Enfoques Transversales del CNEB
INSERT INTO `plugin_school_curricula_enfoque` (`name`, `order_index`) VALUES
('Enfoque de derechos',                          1),
('Inclusivo o de atención a la diversidad',      2),
('Intercultural',                                3),
('Igualdad de género',                           4),
('Ambiental',                                    5),
('Orientación al bien común',                    6),
('Búsqueda de la excelencia',                    7);
