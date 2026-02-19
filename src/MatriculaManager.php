<?php
/* For licensing terms, see /license.txt */

/**
 * MatriculaManager - School Plugin
 * Manages student enrollment records (fichas de matrícula).
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

    /**
     * Returns the currently active academic year, or null if none is set.
     */
    public static function getActiveYear(): ?array
    {
        $table  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_YEAR);
        $result = Database::query("SELECT * FROM $table WHERE active = 1 ORDER BY year DESC LIMIT 1");
        $row    = Database::fetch_array($result, 'ASSOC');
        return $row ?: null;
    }

    /**
     * Returns all academic years ordered by year DESC.
     */
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
    // MATRÍCULA PRINCIPAL
    // =========================================================================

    public static function getMatriculas(array $filters = []): array
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA);
        $grade = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_GRADE);
        $level = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_LEVEL);

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
            $where[] = "(m.apellido_paterno LIKE '%$s%' OR m.apellido_materno LIKE '%$s%' OR m.nombres LIKE '%$s%' OR m.dni LIKE '%$s%')";
        }

        $whereStr = implode(' AND ', $where);

        $sql = "SELECT m.*,
                       g.name AS grade_name,
                       lv.name AS level_name
                FROM $table m
                LEFT JOIN $grade g ON m.grade_id = g.id
                LEFT JOIN $level lv ON g.level_id = lv.id
                WHERE $whereStr
                ORDER BY m.apellido_paterno, m.apellido_materno, m.nombres ASC";

        $result = Database::query($sql);
        $rows = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $row['full_name'] = self::getFullName($row);
            $rows[] = $row;
        }
        return $rows;
    }

    public static function getMatriculaById(int $id): ?array
    {
        if ($id <= 0) return null;

        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA);
        $grade = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_GRADE);
        $level = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_LEVEL);

        $sql = "SELECT m.*,
                       g.name AS grade_name,
                       lv.name AS level_name,
                       g.level_id
                FROM $table m
                LEFT JOIN $grade g ON m.grade_id = g.id
                LEFT JOIN $level lv ON g.level_id = lv.id
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

        $mat['padres']    = self::getPadresByMatricula($id);
        $mat['contactos'] = self::getContactosByMatricula($id);
        $mat['info']      = self::getInfoByMatricula($id);

        return $mat;
    }

    public static function saveMatricula(array $data): int
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA);
        $id    = isset($data['id']) ? (int) $data['id'] : 0;

        $tipoIngreso = $data['tipo_ingreso'] ?? '';
        if (!in_array($tipoIngreso, ['NUEVO_INGRESO', 'REINGRESO', 'CONTINUACION'])) {
            $tipoIngreso = 'NUEVO_INGRESO';
        }

        $params = [
            'user_id'              => isset($data['user_id']) && $data['user_id'] ? (int) $data['user_id'] : null,
            'academic_year_id'     => isset($data['academic_year_id']) && $data['academic_year_id'] ? (int) $data['academic_year_id'] : null,
            'estado'               => in_array($data['estado'] ?? '', ['ACTIVO', 'RETIRADO']) ? $data['estado'] : 'ACTIVO',
            'tipo_ingreso'         => $tipoIngreso,
            'apellido_paterno'     => !empty($data['apellido_paterno']) ? Database::escape_string(mb_strtoupper(trim($data['apellido_paterno']))) : null,
            'apellido_materno'     => !empty($data['apellido_materno']) ? Database::escape_string(mb_strtoupper(trim($data['apellido_materno']))) : null,
            'nombres'              => Database::escape_string(mb_strtoupper(trim($data['nombres'] ?? ''))),
            'grade_id'             => isset($data['grade_id']) && $data['grade_id'] ? (int) $data['grade_id'] : null,
            'sexo'                 => in_array($data['sexo'] ?? '', ['F', 'M']) ? $data['sexo'] : null,
            'dni'                  => !empty($data['dni']) ? Database::escape_string(trim($data['dni'])) : null,
            'tipo_sangre'          => !empty($data['tipo_sangre']) ? Database::escape_string(trim($data['tipo_sangre'])) : null,
            'fecha_nacimiento'     => !empty($data['fecha_nacimiento']) ? Database::escape_string($data['fecha_nacimiento']) : null,
            'nacionalidad'         => Database::escape_string(trim($data['nacionalidad'] ?? 'Peruana')),
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

    public static function deleteMatricula(int $id): bool
    {
        if ($id <= 0) return false;

        foreach ([
            SchoolPlugin::TABLE_SCHOOL_MATRICULA_INFO,
            SchoolPlugin::TABLE_SCHOOL_MATRICULA_CONTACTO,
            SchoolPlugin::TABLE_SCHOOL_MATRICULA_PADRE,
        ] as $t) {
            Database::delete(Database::get_main_table($t), ['matricula_id = ?' => $id]);
        }
        Database::delete(Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA), ['id = ?' => $id]);
        return true;
    }

    /**
     * Marks a student as RETIRADO.
     */
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
     * Copies base student data and related records (padres, contactos, info).
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

        foreach ($students as $m) {
            $oldId = (int) $m['id'];

            $newData = $m;
            // Remove fields that should not be copied directly
            foreach (['id', 'full_name', 'grade_name', 'level_name', 'level_id', 'created_at', 'created_by', 'updated_at'] as $k) {
                unset($newData[$k]);
            }
            $newData['academic_year_id'] = $toYearId;
            $newData['tipo_ingreso']     = 'CONTINUACION';
            $newData['estado']           = 'ACTIVO';

            $newId = self::saveMatricula($newData);

            if ($newId > 0) {
                // Copy padres
                foreach (self::getPadresByMatricula($oldId) as $parentesco => $padre) {
                    unset($padre['id']);
                    self::savePadre($newId, $parentesco, $padre);
                }
                // Copy contactos
                foreach (self::getContactosByMatricula($oldId) as $c) {
                    unset($c['id']);
                    self::saveContacto($newId, $c);
                }
                // Copy info adicional
                $info = self::getInfoByMatricula($oldId);
                if ($info) {
                    unset($info['id']);
                    self::saveInfo($newId, $info);
                }
                $count++;
            }
        }

        return $count;
    }

    // =========================================================================
    // PADRES
    // =========================================================================

    public static function getPadresByMatricula(int $matriculaId): array
    {
        $table  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA_PADRE);
        $result = Database::query("SELECT * FROM $table WHERE matricula_id = $matriculaId ORDER BY parentesco ASC");
        $rows   = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $rows[$row['parentesco']] = $row;
        }
        return $rows;
    }

    public static function savePadre(int $matriculaId, string $parentesco, array $data): bool
    {
        $table      = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA_PADRE);
        $parentesco = in_array($parentesco, ['MADRE', 'PADRE']) ? $parentesco : 'PADRE';

        $params = [
            'matricula_id'   => $matriculaId,
            'parentesco'     => $parentesco,
            'apellidos'      => !empty($data['apellidos']) ? Database::escape_string(mb_strtoupper(trim($data['apellidos']))) : null,
            'nombres'        => !empty($data['nombres']) ? Database::escape_string(mb_strtoupper(trim($data['nombres']))) : null,
            'celular'        => !empty($data['celular']) ? Database::escape_string(trim($data['celular'])) : null,
            'ocupacion'      => !empty($data['ocupacion']) ? Database::escape_string(trim($data['ocupacion'])) : null,
            'dni'            => !empty($data['dni']) ? Database::escape_string(trim($data['dni'])) : null,
            'edad'           => isset($data['edad']) && $data['edad'] !== '' ? (int) $data['edad'] : null,
            'religion'       => !empty($data['religion']) ? Database::escape_string(trim($data['religion'])) : null,
            'tipo_parto'     => ($parentesco === 'MADRE' && in_array($data['tipo_parto'] ?? '', ['CESAREA', 'NORMAL'])) ? $data['tipo_parto'] : null,
            'vive_con_menor' => ($parentesco === 'PADRE' && isset($data['vive_con_menor'])) ? (int) (bool) $data['vive_con_menor'] : null,
        ];

        $sql    = "SELECT id FROM $table WHERE matricula_id = $matriculaId AND parentesco = '$parentesco'";
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
    // CONTACTO DE EMERGENCIA
    // =========================================================================

    public static function getContactosByMatricula(int $matriculaId): array
    {
        $table  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA_CONTACTO);
        $result = Database::query("SELECT * FROM $table WHERE matricula_id = $matriculaId");
        $rows   = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $rows[] = $row;
        }
        return $rows;
    }

    public static function saveContacto(int $matriculaId, array $data): int
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA_CONTACTO);
        $id    = isset($data['id']) ? (int) $data['id'] : 0;

        $params = [
            'matricula_id'    => $matriculaId,
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
    // INFORMACIÓN ADICIONAL
    // =========================================================================

    public static function getInfoByMatricula(int $matriculaId): array
    {
        $table  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA_INFO);
        $result = Database::query("SELECT * FROM $table WHERE matricula_id = $matriculaId LIMIT 1");
        $row    = Database::fetch_array($result, 'ASSOC');
        return $row ?: [];
    }

    public static function saveInfo(int $matriculaId, array $data): bool
    {
        $table  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA_INFO);
        $params = [
            'matricula_id'            => $matriculaId,
            'encargados_cuidado'      => !empty($data['encargados_cuidado']) ? Database::escape_string(trim($data['encargados_cuidado'])) : null,
            'familiar_en_institucion' => !empty($data['familiar_en_institucion']) ? Database::escape_string(trim($data['familiar_en_institucion'])) : null,
            'observaciones'           => !empty($data['observaciones']) ? Database::escape_string(trim($data['observaciones'])) : null,
        ];

        if (self::getInfoByMatricula($matriculaId)) {
            Database::update($table, $params, ['matricula_id = ?' => $matriculaId]);
        } else {
            Database::insert($table, $params);
        }
        return true;
    }

    // =========================================================================
    // HELPERS
    // =========================================================================

    /**
     * Counts enrollments by tipo_ingreso.
     * If $yearId is provided, filters by academic_year_id; otherwise falls back to current calendar year.
     */
    public static function countByTipoIngreso(?int $yearId = null): array
    {
        $table  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA);
        $counts = ['NUEVO_INGRESO' => 0, 'REINGRESO' => 0, 'CONTINUACION' => 0];

        if ($yearId) {
            $sql = "SELECT tipo_ingreso, COUNT(*) as total FROM $table WHERE academic_year_id = $yearId GROUP BY tipo_ingreso";
        } else {
            $year = date('Y');
            $sql  = "SELECT tipo_ingreso, COUNT(*) as total FROM $table WHERE YEAR(created_at) = $year GROUP BY tipo_ingreso";
        }

        $result = Database::query($sql);
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $counts[$row['tipo_ingreso']] = (int) $row['total'];
        }
        return $counts;
    }
}
