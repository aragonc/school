<?php
/* For licensing terms, see /license.txt */

/**
 * MatriculaManager - School Plugin
 * Manages student enrollment records.
 *
 * Data is split into two tables:
 *  - plugin_school_ficha      : permanent personal data (one per student)
 *  - plugin_school_matricula  : annual enrollment (one per student per year)
 *
 * @package chamilo.plugin.school
 */
class MatriculaManager
{
    /**
     * Returns a formatted full name: APELLIDO PATERNO APELLIDO MATERNO, Nombres
     */
    public static function getFullName(array $row): string
    {
        $ap = trim($row['apellido_paterno'] ?? '');
        $am = trim($row['apellido_materno'] ?? '');
        $n  = trim($row['nombres'] ?? '');

        $apellidos = trim("$ap $am");
        if ($apellidos && $n) {
            return "$apellidos, $n";
        }
        return $apellidos ?: $n;
    }

    // =========================================================================
    // AÑO ACADÉMICO
    // =========================================================================

    public static function getActiveYear(): ?array
    {
        $table  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_YEAR);
        $result = Database::query("SELECT * FROM $table WHERE active = 1 ORDER BY year DESC LIMIT 1");
        $row    = Database::fetch_array($result, 'ASSOC');
        return $row ?: null;
    }

    public static function getAllYears(): array
    {
        $table  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_YEAR);
        $result = Database::query("SELECT * FROM $table ORDER BY year DESC");
        $rows   = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $rows[] = $row;
        }
        return $rows;
    }

    // =========================================================================
    // FICHA (datos personales permanentes)
    // =========================================================================

    public static function saveFicha(array $data): int
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_FICHA);
        $id    = isset($data['id']) ? (int) $data['id'] : 0;

        $params = [
            'user_id'              => isset($data['user_id']) && $data['user_id'] ? (int) $data['user_id'] : null,
            'apellido_paterno'     => !empty($data['apellido_paterno']) ? Database::escape_string(mb_strtoupper(trim($data['apellido_paterno']))) : null,
            'apellido_materno'     => !empty($data['apellido_materno']) ? Database::escape_string(mb_strtoupper(trim($data['apellido_materno']))) : null,
            'nombres'              => Database::escape_string(mb_strtoupper(trim($data['nombres'] ?? ''))),
            'sexo'                 => in_array($data['sexo'] ?? '', ['F', 'M']) ? $data['sexo'] : null,
            'dni'                  => !empty($data['dni']) ? Database::escape_string(trim($data['dni'])) : null,
            'tipo_documento'       => !empty($data['tipo_documento']) ? Database::escape_string(trim($data['tipo_documento'])) : null,
            'tipo_sangre'          => !empty($data['tipo_sangre']) ? Database::escape_string(trim($data['tipo_sangre'])) : null,
            'fecha_nacimiento'     => !empty($data['fecha_nacimiento']) ? Database::escape_string($data['fecha_nacimiento']) : null,
            'nacionalidad'         => in_array($data['nacionalidad'] ?? '', ['Peruana', 'Extranjera']) ? $data['nacionalidad'] : 'Peruana',
            'peso'                 => isset($data['peso']) && $data['peso'] !== '' ? (float) $data['peso'] : null,
            'estatura'             => isset($data['estatura']) && $data['estatura'] !== '' ? (float) $data['estatura'] : null,
            'domicilio'            => !empty($data['domicilio']) ? Database::escape_string(trim($data['domicilio'])) : null,
            'region'               => !empty($data['region']) ? Database::escape_string(trim($data['region'])) : null,
            'provincia'            => !empty($data['provincia']) ? Database::escape_string(trim($data['provincia'])) : null,
            'distrito'             => !empty($data['distrito']) ? Database::escape_string(trim($data['distrito'])) : null,
            'tiene_alergias'       => isset($data['tiene_alergias']) ? (int) (bool) $data['tiene_alergias'] : 0,
            'alergias_detalle'     => !empty($data['alergias_detalle']) ? Database::escape_string(trim($data['alergias_detalle'])) : null,
            'usa_lentes'           => isset($data['usa_lentes']) ? (int) (bool) $data['usa_lentes'] : 0,
            'tiene_discapacidad'   => isset($data['tiene_discapacidad']) ? (int) (bool) $data['tiene_discapacidad'] : 0,
            'discapacidad_detalle' => !empty($data['discapacidad_detalle']) ? Database::escape_string(trim($data['discapacidad_detalle'])) : null,
            'ie_procedencia'       => !empty($data['ie_procedencia']) ? Database::escape_string(trim($data['ie_procedencia'])) : null,
            'motivo_traslado'      => !empty($data['motivo_traslado']) ? Database::escape_string(trim($data['motivo_traslado'])) : null,
        ];

        if (!empty($data['foto'])) {
            $params['foto'] = Database::escape_string(trim($data['foto']));
        }

        if ($id > 0) {
            $params['updated_at'] = api_get_utc_datetime();
            Database::update($table, $params, ['id = ?' => $id]);
            return $id;
        } else {
            $params['created_by'] = api_get_user_id();
            $params['created_at'] = api_get_utc_datetime();
            return (int) Database::insert($table, $params);
        }
    }

    public static function getFichaById(int $fichaId): ?array
    {
        if ($fichaId <= 0) return null;
        $table  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_FICHA);
        $result = Database::query("SELECT * FROM $table WHERE id = $fichaId LIMIT 1");
        $row    = Database::fetch_array($result, 'ASSOC');
        return $row ?: null;
    }

    public static function getFichaByUserId(int $userId): ?array
    {
        if ($userId <= 0) return null;
        $table  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_FICHA);
        $result = Database::query("SELECT * FROM $table WHERE user_id = $userId LIMIT 1");
        $row    = Database::fetch_array($result, 'ASSOC');
        return $row ?: null;
    }

    /**
     * Returns ficha data together with padres, contactos and info.
     */
    public static function getFichaCompleta(int $fichaId): ?array
    {
        $ficha = self::getFichaById($fichaId);
        if (!$ficha) return null;

        $ficha['padres']        = self::getPadresByFicha($fichaId);
        $ficha['contactos']     = self::getContactosByFicha($fichaId);
        $ficha['info']          = self::getInfoByFicha($fichaId);
        $ficha['hermanos']      = self::getHermanosByFicha($fichaId);
        $ficha['observaciones'] = self::getObservacionesByFicha($fichaId);

        return $ficha;
    }

    // =========================================================================
    // MATRÍCULA (datos anuales)
    // =========================================================================

    public static function getMatriculas(array $filters = []): array
    {
        $matTable   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA);
        $fichaTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_FICHA);
        $grade      = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_GRADE);
        $level      = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_LEVEL);
        $section    = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_SECTION);

        $where = ['1=1'];

        if (!empty($filters['academic_year_id'])) {
            $where[] = "m.academic_year_id = " . (int) $filters['academic_year_id'];
        }
        if (!empty($filters['tipo_ingreso'])) {
            $ti = Database::escape_string($filters['tipo_ingreso']);
            $where[] = "m.tipo_ingreso = '$ti'";
        }
        if (!empty($filters['estado'])) {
            $est = Database::escape_string($filters['estado']);
            $where[] = "m.estado = '$est'";
        }
        if (!empty($filters['grade_id'])) {
            $where[] = "m.grade_id = " . (int) $filters['grade_id'];
        }
        if (!empty($filters['search'])) {
            $s = Database::escape_string($filters['search']);
            $where[] = "(f.apellido_paterno LIKE '%$s%' OR f.apellido_materno LIKE '%$s%' OR f.nombres LIKE '%$s%' OR f.dni LIKE '%$s%')";
        }

        $whereStr = implode(' AND ', $where);

        $sql = "SELECT m.id, m.ficha_id, m.academic_year_id, m.grade_id, m.section_id, m.estado, m.tipo_ingreso,
                       m.created_by, m.created_at, m.updated_at,
                       f.user_id, f.apellido_paterno, f.apellido_materno, f.nombres,
                       f.sexo, f.dni, f.tipo_documento, f.tipo_sangre, f.fecha_nacimiento,
                       f.nacionalidad, f.peso, f.estatura, f.domicilio, f.region, f.provincia, f.distrito,
                       f.tiene_alergias, f.alergias_detalle, f.usa_lentes,
                       f.tiene_discapacidad, f.discapacidad_detalle,
                       f.ie_procedencia, f.motivo_traslado, f.foto,
                       g.name AS grade_name, g.level_id,
                       lv.name AS level_name,
                       sec.name AS section_name
                FROM $matTable m
                JOIN $fichaTable f ON f.id = m.ficha_id
                LEFT JOIN $grade g ON m.grade_id = g.id
                LEFT JOIN $level lv ON g.level_id = lv.id
                LEFT JOIN $section sec ON m.section_id = sec.id
                WHERE $whereStr
                ORDER BY f.apellido_paterno, f.apellido_materno, f.nombres ASC";

        $result = Database::query($sql);
        $rows = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $row['full_name'] = self::getFullName($row);
            $rows[] = $row;
        }
        return $rows;
    }

    public static function getMatriculaByUserId(int $userId): ?array
    {
        if ($userId <= 0) return null;

        $matTable   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA);
        $fichaTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_FICHA);
        $grade      = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_GRADE);
        $level      = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_LEVEL);
        $section    = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_SECTION);

        $sql = "SELECT m.id, m.ficha_id, m.academic_year_id, m.grade_id, m.section_id, m.estado, m.tipo_ingreso,
                       m.created_by, m.created_at, m.updated_at,
                       f.user_id, f.apellido_paterno, f.apellido_materno, f.nombres,
                       f.sexo, f.dni, f.tipo_documento, f.tipo_sangre, f.fecha_nacimiento,
                       f.nacionalidad, f.peso, f.estatura, f.domicilio, f.region, f.provincia, f.distrito,
                       f.tiene_alergias, f.alergias_detalle, f.usa_lentes,
                       f.tiene_discapacidad, f.discapacidad_detalle,
                       f.ie_procedencia, f.motivo_traslado, f.foto,
                       g.name AS grade_name, g.level_id,
                       lv.name AS level_name,
                       sec.name AS section_name
                FROM $fichaTable f
                JOIN $matTable m ON m.ficha_id = f.id
                LEFT JOIN $grade g ON m.grade_id = g.id
                LEFT JOIN $level lv ON g.level_id = lv.id
                LEFT JOIN $section sec ON m.section_id = sec.id
                WHERE f.user_id = $userId
                ORDER BY m.academic_year_id DESC, m.id DESC
                LIMIT 1";

        $result = Database::query($sql);
        $row = Database::fetch_array($result, 'ASSOC');
        if ($row) {
            $row['full_name'] = self::getFullName($row);
        }
        return $row ?: null;
    }

    public static function getMatriculaById(int $id): ?array
    {
        if ($id <= 0) return null;

        $matTable   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA);
        $fichaTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_FICHA);
        $grade      = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_GRADE);
        $level      = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_LEVEL);
        $section    = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_SECTION);

        $sql = "SELECT m.id, m.ficha_id, m.academic_year_id, m.grade_id, m.section_id, m.estado, m.tipo_ingreso,
                       m.created_by, m.created_at, m.updated_at,
                       f.user_id, f.apellido_paterno, f.apellido_materno, f.nombres,
                       f.sexo, f.dni, f.tipo_documento, f.tipo_sangre, f.fecha_nacimiento,
                       f.nacionalidad, f.peso, f.estatura, f.domicilio, f.region, f.provincia, f.distrito,
                       f.tiene_alergias, f.alergias_detalle, f.usa_lentes,
                       f.tiene_discapacidad, f.discapacidad_detalle,
                       f.ie_procedencia, f.motivo_traslado, f.foto,
                       g.name AS grade_name, g.level_id,
                       lv.name AS level_name,
                       sec.name AS section_name
                FROM $matTable m
                JOIN $fichaTable f ON f.id = m.ficha_id
                LEFT JOIN $grade g ON m.grade_id = g.id
                LEFT JOIN $level lv ON g.level_id = lv.id
                LEFT JOIN $section sec ON m.section_id = sec.id
                WHERE m.id = $id";

        $result = Database::query($sql);
        $row = Database::fetch_array($result, 'ASSOC');
        if ($row) {
            $row['full_name'] = self::getFullName($row);
        }
        return $row ?: null;
    }

    public static function getMatriculaCompleta(int $id): ?array
    {
        $mat = self::getMatriculaById($id);
        if (!$mat) return null;

        $fichaId = (int) $mat['ficha_id'];
        $mat['padres']    = self::getPadresByFicha($fichaId);
        $mat['contactos'] = self::getContactosByFicha($fichaId);
        $mat['info']      = self::getInfoByFicha($fichaId);

        return $mat;
    }

    /**
     * Saves annual enrollment record. Requires ficha_id in $data.
     */
    public static function saveMatricula(array $data): int
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA);
        $id    = isset($data['id']) ? (int) $data['id'] : 0;

        $tipoIngreso = $data['tipo_ingreso'] ?? '';
        if (!in_array($tipoIngreso, ['NUEVO_INGRESO', 'REINGRESO', 'CONTINUACION'])) {
            $tipoIngreso = 'NUEVO_INGRESO';
        }

        $params = [
            'ficha_id'         => (int) ($data['ficha_id'] ?? 0),
            'academic_year_id' => isset($data['academic_year_id']) && $data['academic_year_id'] ? (int) $data['academic_year_id'] : null,
            'grade_id'         => isset($data['grade_id']) && $data['grade_id'] ? (int) $data['grade_id'] : null,
            'section_id'       => isset($data['section_id']) && $data['section_id'] ? (int) $data['section_id'] : null,
            'estado'           => in_array($data['estado'] ?? '', ['ACTIVO', 'RETIRADO']) ? $data['estado'] : 'ACTIVO',
            'tipo_ingreso'     => $tipoIngreso,
        ];

        if ($id > 0) {
            $params['updated_at'] = api_get_utc_datetime();
            Database::update($table, $params, ['id = ?' => $id]);
            return $id;
        } else {
            $params['created_by'] = api_get_user_id();
            $params['created_at'] = api_get_utc_datetime();
            return (int) Database::insert($table, $params);
        }
    }

    /**
     * Deletes only the annual enrollment record. Ficha and related data are preserved.
     */
    public static function deleteMatricula(int $id): bool
    {
        if ($id <= 0) return false;
        Database::delete(Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA), ['id = ?' => $id]);
        return true;
    }

    public static function retireMatricula(int $id): bool
    {
        if ($id <= 0) return false;
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA);
        Database::update($table, [
            'estado'     => 'RETIRADO',
            'updated_at' => api_get_utc_datetime(),
        ], ['id = ?' => $id]);
        return true;
    }

    /**
     * Promotes all ACTIVO students from one academic year to another as CONTINUACION.
     * Only creates new matricula rows (ficha data is reused as-is).
     *
     * @return int Number of students promoted.
     */
    public static function promoteToNextYear(int $fromYearId, int $toYearId): int
    {
        if ($fromYearId <= 0 || $toYearId <= 0 || $fromYearId === $toYearId) {
            return 0;
        }

        $students = self::getMatriculas(['academic_year_id' => $fromYearId, 'estado' => 'ACTIVO']);
        $count    = 0;

        $matTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA);

        foreach ($students as $m) {
            $fichaId = (int) $m['ficha_id'];

            // Skip if already enrolled in target year
            $existing = Database::query(
                "SELECT id FROM $matTable WHERE ficha_id = $fichaId AND academic_year_id = $toYearId LIMIT 1"
            );
            if (Database::num_rows($existing) > 0) {
                continue;
            }

            $newId = self::saveMatricula([
                'ficha_id'         => $fichaId,
                'academic_year_id' => $toYearId,
                'grade_id'         => $m['grade_id'],
                'tipo_ingreso'     => 'CONTINUACION',
                'estado'           => 'ACTIVO',
            ]);

            if ($newId > 0) {
                $count++;
            }
        }

        return $count;
    }

    // =========================================================================
    // HERMANOS (linked to ficha via user)
    // =========================================================================

    public static function getHermanosByFicha(int $fichaId): array
    {
        $table     = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_FICHA_HERMANO);
        $userTable = Database::get_main_table(TABLE_MAIN_USER);
        $result    = Database::query(
            "SELECT h.hermano_user_id AS user_id, u.firstname, u.lastname, u.username
             FROM $table h
             JOIN $userTable u ON u.user_id = h.hermano_user_id
             WHERE h.ficha_id = $fichaId
             ORDER BY u.lastname, u.firstname"
        );
        $rows = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $rows[] = [
                'user_id' => (int) $row['user_id'],
                'label'   => $row['lastname'] . ' ' . $row['firstname'] . ' (' . $row['username'] . ')',
            ];
        }
        return $rows;
    }

    // PADRES (linked to ficha)
    // =========================================================================

    public static function getPadresByFicha(int $fichaId): array
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA_PADRE);
        // LEFT JOIN with self to resolve linked_padre_id — avoids data duplication
        $sql = "SELECT
                    p.id, p.ficha_id, p.parentesco, p.linked_padre_id,
                    COALESCE(p.apellidos,      lp.apellidos)      AS apellidos,
                    COALESCE(p.nombres,        lp.nombres)        AS nombres,
                    COALESCE(p.celular,        lp.celular)        AS celular,
                    COALESCE(p.ocupacion,      lp.ocupacion)      AS ocupacion,
                    COALESCE(p.dni,            lp.dni)            AS dni,
                    COALESCE(p.edad,           lp.edad)           AS edad,
                    COALESCE(p.religion,       lp.religion)       AS religion,
                    COALESCE(p.tipo_parto,     lp.tipo_parto)     AS tipo_parto,
                    COALESCE(p.vive_con_menor, lp.vive_con_menor) AS vive_con_menor
                FROM $table p
                LEFT JOIN $table lp ON lp.id = p.linked_padre_id
                WHERE p.ficha_id = $fichaId
                ORDER BY p.parentesco ASC";
        $result = Database::query($sql);
        $rows   = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $rows[$row['parentesco']] = $row;
        }
        return $rows;
    }

    /** @deprecated Use getPadresByFicha() */
    public static function getPadresByMatricula(int $matriculaId): array
    {
        $mat = self::getMatriculaById($matriculaId);
        if (!$mat) return [];
        return self::getPadresByFicha((int) $mat['ficha_id']);
    }

    public static function savePadre(int $fichaId, string $parentesco, array $data): bool
    {
        $table          = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA_PADRE);
        $parentesco     = in_array($parentesco, ['MADRE', 'PADRE', 'APODERADO']) ? $parentesco : 'PADRE';
        $linkedPadreId  = isset($data['linked_padre_id']) && (int) $data['linked_padre_id'] > 0
                          ? (int) $data['linked_padre_id'] : null;

        if ($linkedPadreId) {
            // Linked mode: store only the reference — no data duplication
            $params = [
                'ficha_id'        => $fichaId,
                'parentesco'      => $parentesco,
                'linked_padre_id' => $linkedPadreId,
                // Data fields left NULL — resolved via JOIN in getPadresByFicha()
                'apellidos'       => null,
                'nombres'         => null,
                'celular'         => null,
                'ocupacion'       => null,
                'dni'             => null,
                'edad'            => null,
                'religion'        => null,
                'tipo_parto'      => null,
                'vive_con_menor'  => null,
            ];
        } else {
            $params = [
                'ficha_id'        => $fichaId,
                'parentesco'      => $parentesco,
                'linked_padre_id' => null,
                'apellidos'       => !empty($data['apellidos']) ? Database::escape_string(mb_convert_case(trim($data['apellidos']), MB_CASE_TITLE, 'UTF-8')) : null,
                'nombres'         => !empty($data['nombres']) ? Database::escape_string(mb_convert_case(trim($data['nombres']), MB_CASE_TITLE, 'UTF-8')) : null,
                'celular'         => !empty($data['celular']) ? Database::escape_string(trim($data['celular'])) : null,
                'ocupacion'       => !empty($data['ocupacion']) ? Database::escape_string(trim($data['ocupacion'])) : null,
                'dni'             => !empty($data['dni']) ? Database::escape_string(trim($data['dni'])) : null,
                'edad'            => isset($data['edad']) && $data['edad'] !== '' ? (int) $data['edad'] : null,
                'religion'        => !empty($data['religion']) ? Database::escape_string(trim($data['religion'])) : null,
                'tipo_parto'      => ($parentesco === 'MADRE' && in_array($data['tipo_parto'] ?? '', ['CESAREA', 'NORMAL'])) ? $data['tipo_parto'] : null,
                'vive_con_menor'  => isset($data['vive_con_menor']) ? (int) (bool) $data['vive_con_menor'] : null,
            ];
        }

        $sql    = "SELECT id FROM $table WHERE ficha_id = $fichaId AND parentesco = '$parentesco'";
        $result = Database::query($sql);
        $row    = Database::fetch_array($result, 'ASSOC');

        if ($row) {
            Database::update($table, $params, ['id = ?' => (int) $row['id']]);
        } else {
            Database::insert($table, $params);
        }
        return true;
    }

    // =========================================================================
    // CONTACTO DE EMERGENCIA (linked to ficha)
    // =========================================================================

    public static function getContactosByFicha(int $fichaId): array
    {
        $table  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA_CONTACTO);
        $result = Database::query("SELECT * FROM $table WHERE ficha_id = $fichaId");
        $rows   = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $rows[] = $row;
        }
        return $rows;
    }

    /** @deprecated Use getContactosByFicha() */
    public static function getContactosByMatricula(int $matriculaId): array
    {
        $mat = self::getMatriculaById($matriculaId);
        if (!$mat) return [];
        return self::getContactosByFicha((int) $mat['ficha_id']);
    }

    public static function saveContacto(int $fichaId, array $data): int
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA_CONTACTO);
        $id    = isset($data['id']) ? (int) $data['id'] : 0;

        $params = [
            'ficha_id'        => $fichaId,
            'nombre_contacto' => !empty($data['nombre_contacto']) ? Database::escape_string(trim($data['nombre_contacto'])) : null,
            'telefono'        => !empty($data['telefono']) ? Database::escape_string(trim($data['telefono'])) : null,
            'direccion'       => !empty($data['direccion']) ? Database::escape_string(trim($data['direccion'])) : null,
        ];

        if ($id > 0) {
            Database::update($table, $params, ['id = ?' => $id]);
            return $id;
        }
        return (int) Database::insert($table, $params);
    }

    public static function deleteContacto(int $id): bool
    {
        Database::delete(Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA_CONTACTO), ['id = ?' => $id]);
        return true;
    }

    // =========================================================================
    // INFORMACIÓN ADICIONAL (linked to ficha)
    // =========================================================================

    public static function getInfoByFicha(int $fichaId): array
    {
        $table  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA_INFO);
        $result = Database::query("SELECT * FROM $table WHERE ficha_id = $fichaId LIMIT 1");
        $row    = Database::fetch_array($result, 'ASSOC');
        return $row ?: [];
    }

    /** @deprecated Use getInfoByFicha() */
    public static function getInfoByMatricula(int $matriculaId): array
    {
        $mat = self::getMatriculaById($matriculaId);
        if (!$mat) return [];
        return self::getInfoByFicha((int) $mat['ficha_id']);
    }

    public static function saveInfo(int $fichaId, array $data): bool
    {
        $table  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA_INFO);
        $params = [
            'ficha_id'                => $fichaId,
            'encargados_cuidado'      => !empty($data['encargados_cuidado']) ? Database::escape_string(trim($data['encargados_cuidado'])) : null,
            'familiar_en_institucion' => !empty($data['familiar_en_institucion']) ? Database::escape_string(trim($data['familiar_en_institucion'])) : null,
            'observaciones'           => !empty($data['observaciones']) ? Database::escape_string(trim($data['observaciones'])) : null,
        ];

        if (self::getInfoByFicha($fichaId)) {
            Database::update($table, $params, ['ficha_id = ?' => $fichaId]);
        } else {
            Database::insert($table, $params);
        }
        return true;
    }

    // =========================================================================
    // OBSERVACIONES (linked to ficha)
    // =========================================================================

    public static function getObservacionesByFicha(int $fichaId): array
    {
        $table  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA_OBSERVACION);
        $result = Database::query("SELECT * FROM $table WHERE ficha_id = $fichaId ORDER BY id ASC");
        $rows   = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $rows[] = $row;
        }
        return $rows;
    }

    public static function saveObservacion(int $fichaId, array $data): int
    {
        $table  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA_OBSERVACION);
        $params = [
            'ficha_id'   => $fichaId,
            'titulo'     => !empty($data['titulo']) ? Database::escape_string(trim($data['titulo'])) : null,
            'observacion'=> !empty($data['observacion']) ? Database::escape_string(trim($data['observacion'])) : null,
            'created_at' => api_get_utc_datetime(),
        ];
        return (int) Database::insert($table, $params);
    }

    /**
     * Returns all annual enrollment rows for a ficha, newest first.
     * Each row includes academic year name, grade name and level name.
     */
    public static function getMatriculasByFichaId(int $fichaId): array
    {
        if ($fichaId <= 0) return [];

        $matTable  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA);
        $yearTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_YEAR);
        $grade     = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_GRADE);
        $level     = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_LEVEL);
        $section   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_SECTION);

        $sql = "SELECT m.id, m.ficha_id, m.academic_year_id, m.grade_id, m.section_id, m.estado, m.tipo_ingreso,
                       m.created_at, m.updated_at,
                       ay.name AS academic_year_name, ay.year AS academic_year,
                       g.name AS grade_name, g.level_id,
                       lv.name AS level_name,
                       sec.name AS section_name
                FROM $matTable m
                LEFT JOIN $yearTable ay ON ay.id = m.academic_year_id
                LEFT JOIN $grade g     ON g.id  = m.grade_id
                LEFT JOIN $level lv    ON lv.id = g.level_id
                LEFT JOIN $section sec ON sec.id = m.section_id
                WHERE m.ficha_id = $fichaId
                ORDER BY ay.year DESC, m.id DESC";

        $result = Database::query($sql);
        $rows   = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $rows[] = $row;
        }
        return $rows;
    }

    // =========================================================================
    // HELPERS
    // =========================================================================

    public static function countByTipoIngreso(?int $yearId = null): array
    {
        $table  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA);
        $counts = ['NUEVO_INGRESO' => 0, 'REINGRESO' => 0, 'CONTINUACION' => 0, 'RETIRADO' => 0];

        if ($yearId) {
            $whereBase = "academic_year_id = $yearId";
        } else {
            $year      = date('Y');
            $whereBase = "YEAR(created_at) = $year";
        }

        // Count active students by tipo_ingreso
        $sql    = "SELECT tipo_ingreso, COUNT(*) as total FROM $table
                   WHERE $whereBase AND estado = 'ACTIVO' GROUP BY tipo_ingreso";
        $result = Database::query($sql);
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $counts[$row['tipo_ingreso']] = (int) $row['total'];
        }

        // Count retired students separately
        $sqlR = "SELECT COUNT(*) as total FROM $table WHERE $whereBase AND estado = 'RETIRADO'";
        $resR = Database::query($sqlR);
        $rowR = Database::fetch_array($resR, 'ASSOC');
        $counts['RETIRADO'] = (int) ($rowR['total'] ?? 0);

        return $counts;
    }
}
