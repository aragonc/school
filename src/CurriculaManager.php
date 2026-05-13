<?php
/* For licensing terms, see /license.txt */

/**
 * CurriculaManager - School Plugin
 * Manages EBR curricular areas, competencies, capacities,
 * transversal competencies and CNEB transversal approaches.
 *
 * @package chamilo.plugin.school
 */
class CurriculaManager
{
    // =========================================================================
    // ÁREAS CURRICULARES
    // =========================================================================

    public static function getAreas(bool $activeOnly = false): array
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_AREA);
        $sql = "SELECT * FROM $table";
        if ($activeOnly) {
            $sql .= " WHERE active = 1";
        }
        $sql .= " ORDER BY order_index ASC, name ASC";
        $result = Database::query($sql);
        $rows = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $rows[] = $row;
        }
        return $rows;
    }

    public static function getArea(int $id): ?array
    {
        if ($id <= 0) return null;
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_AREA);
        $result = Database::query("SELECT * FROM $table WHERE id = $id LIMIT 1");
        $row = Database::fetch_array($result, 'ASSOC');
        return $row ?: null;
    }

    public static function saveArea(array $data): int
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_AREA);
        $id = (int) ($data['id'] ?? 0);
        $params = [
            'name'        => Database::escape_string(trim($data['name'] ?? '')),
            'level'       => in_array($data['level'] ?? '', ['inicial', 'primaria', 'secundaria', 'ambos']) ? $data['level'] : 'ambos',
            'active'      => isset($data['active']) ? (int) $data['active'] : 1,
            'order_index' => (int) ($data['order_index'] ?? 0),
        ];
        if ($id > 0) {
            Database::update($table, $params, ['id = ?' => $id]);
            return $id;
        }
        return (int) Database::insert($table, $params);
    }

    public static function deleteArea(int $id): bool
    {
        if ($id <= 0) return false;
        $tComp = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_COMPETENCIA);
        $tCap  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_CAPACIDAD);
        Database::delete($tComp, ['area_id = ?' => $id]);
        Database::delete($tCap,  ['area_id = ?' => $id]);
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_AREA);
        Database::delete($table, ['id = ?' => $id]);
        return true;
    }

    // =========================================================================
    // COMPETENCIAS DE ÁREA
    // =========================================================================

    public static function getCompetenciasByArea(int $areaId): array
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_COMPETENCIA);
        $result = Database::query("SELECT * FROM $table WHERE area_id = $areaId ORDER BY order_index ASC, name ASC");
        $rows = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $rows[] = $row;
        }
        return $rows;
    }

    public static function saveCompetencia(array $data): int
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_COMPETENCIA);
        $id = (int) ($data['id'] ?? 0);
        $params = [
            'area_id'     => (int) ($data['area_id'] ?? 0),
            'name'        => Database::escape_string(trim($data['name'] ?? '')),
            'active'      => isset($data['active']) ? (int) $data['active'] : 1,
            'order_index' => (int) ($data['order_index'] ?? 0),
        ];
        if ($id > 0) {
            Database::update($table, $params, ['id = ?' => $id]);
            return $id;
        }
        return (int) Database::insert($table, $params);
    }

    public static function deleteCompetencia(int $id): bool
    {
        if ($id <= 0) return false;
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_COMPETENCIA);
        Database::delete($table, ['id = ?' => $id]);
        return true;
    }

    // =========================================================================
    // CAPACIDADES DE ÁREA
    // =========================================================================

    public static function getCapacidadesByArea(int $areaId): array
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_CAPACIDAD);
        $result = Database::query("SELECT * FROM $table WHERE area_id = $areaId ORDER BY order_index ASC, name ASC");
        $rows = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $rows[] = $row;
        }
        return $rows;
    }

    public static function saveCapacidad(array $data): int
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_CAPACIDAD);
        $id = (int) ($data['id'] ?? 0);
        $params = [
            'area_id'     => (int) ($data['area_id'] ?? 0),
            'name'        => Database::escape_string(trim($data['name'] ?? '')),
            'active'      => isset($data['active']) ? (int) $data['active'] : 1,
            'order_index' => (int) ($data['order_index'] ?? 0),
        ];
        if ($id > 0) {
            Database::update($table, $params, ['id = ?' => $id]);
            return $id;
        }
        return (int) Database::insert($table, $params);
    }

    public static function deleteCapacidad(int $id): bool
    {
        if ($id <= 0) return false;
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_CAPACIDAD);
        Database::delete($table, ['id = ?' => $id]);
        return true;
    }

    // =========================================================================
    // COMPETENCIAS TRANSVERSALES
    // =========================================================================

    public static function getTransversales(string $level = ''): array
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_TRANSVERSAL);
        $where = $level ? " WHERE level = '" . Database::escape_string($level) . "'" : '';
        $result = Database::query("SELECT * FROM $table$where ORDER BY order_index ASC, name ASC");
        $rows = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $rows[] = $row;
        }
        return $rows;
    }

    public static function saveTransversal(array $data): int
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_TRANSVERSAL);
        $id = (int) ($data['id'] ?? 0);
        $params = [
            'name'        => Database::escape_string(trim($data['name'] ?? '')),
            'level'       => in_array($data['level'] ?? '', ['inicial', 'ebr']) ? $data['level'] : 'ebr',
            'active'      => isset($data['active']) ? (int) $data['active'] : 1,
            'order_index' => (int) ($data['order_index'] ?? 0),
        ];
        if ($id > 0) {
            Database::update($table, $params, ['id = ?' => $id]);
            return $id;
        }
        return (int) Database::insert($table, $params);
    }

    public static function deleteTransversal(int $id): bool
    {
        if ($id <= 0) return false;
        $tCap = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_TRANSVERSAL_CAP);
        Database::delete($tCap, ['transversal_id = ?' => $id]);
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_TRANSVERSAL);
        Database::delete($table, ['id = ?' => $id]);
        return true;
    }

    // =========================================================================
    // CAPACIDADES DE COMPETENCIAS TRANSVERSALES
    // =========================================================================

    public static function getCapacidadesByTransversal(int $transversalId): array
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_TRANSVERSAL_CAP);
        $result = Database::query("SELECT * FROM $table WHERE transversal_id = $transversalId ORDER BY order_index ASC, name ASC");
        $rows = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $rows[] = $row;
        }
        return $rows;
    }

    public static function saveTransversalCap(array $data): int
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_TRANSVERSAL_CAP);
        $id = (int) ($data['id'] ?? 0);
        $params = [
            'transversal_id' => (int) ($data['transversal_id'] ?? 0),
            'name'           => Database::escape_string(trim($data['name'] ?? '')),
            'active'         => isset($data['active']) ? (int) $data['active'] : 1,
            'order_index'    => (int) ($data['order_index'] ?? 0),
        ];
        if ($id > 0) {
            Database::update($table, $params, ['id = ?' => $id]);
            return $id;
        }
        return (int) Database::insert($table, $params);
    }

    public static function deleteTransversalCap(int $id): bool
    {
        if ($id <= 0) return false;
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_TRANSVERSAL_CAP);
        Database::delete($table, ['id = ?' => $id]);
        return true;
    }

    // =========================================================================
    // ENFOQUES TRANSVERSALES
    // =========================================================================

    public static function getEnfoques(string $level = ''): array
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_ENFOQUE);
        $where = $level ? " WHERE level = '" . Database::escape_string($level) . "'" : '';
        $result = Database::query("SELECT * FROM $table$where ORDER BY order_index ASC, name ASC");
        $rows = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $rows[] = $row;
        }
        return $rows;
    }

    public static function saveEnfoque(array $data): int
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_ENFOQUE);
        $id = (int) ($data['id'] ?? 0);
        $params = [
            'name'        => Database::escape_string(trim($data['name'] ?? '')),
            'level'       => in_array($data['level'] ?? '', ['inicial', 'ebr', 'ambos']) ? $data['level'] : 'ebr',
            'active'      => isset($data['active']) ? (int) $data['active'] : 1,
            'order_index' => (int) ($data['order_index'] ?? 0),
        ];
        if ($id > 0) {
            Database::update($table, $params, ['id = ?' => $id]);
            return $id;
        }
        return (int) Database::insert($table, $params);
    }

    public static function deleteEnfoque(int $id): bool
    {
        if ($id <= 0) return false;
        $table      = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_ENFOQUE);
        $valorTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_ENFOQUE_VALOR);
        Database::delete($valorTable, ['enfoque_id = ?' => $id]);
        Database::delete($table, ['id = ?' => $id]);
        return true;
    }

    // =========================================================================
    // VALORES DE ENFOQUES TRANSVERSALES
    // =========================================================================

    public static function getValoresByEnfoque(int $enfoqueId): array
    {
        if ($enfoqueId <= 0) return [];
        $table  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_ENFOQUE_VALOR);
        $result = Database::query(
            "SELECT * FROM $table WHERE enfoque_id = $enfoqueId AND active = 1 ORDER BY order_index ASC, name ASC"
        );
        $rows = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $rows[] = $row;
        }
        return $rows;
    }

    public static function saveEnfoqueValor(array $data): int
    {
        $table      = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_ENFOQUE_VALOR);
        $id         = (int) ($data['id'] ?? 0);
        $enfoqueId  = (int) ($data['enfoque_id'] ?? 0);
        $name       = Database::escape_string(trim($data['name'] ?? ''));
        $orderIndex = (int) ($data['order_index'] ?? 0);

        if (empty($name) || $enfoqueId <= 0) return 0;

        if ($id > 0) {
            Database::query(
                "UPDATE $table SET name='$name', order_index=$orderIndex WHERE id=$id AND enfoque_id=$enfoqueId"
            );
            return $id;
        }
        Database::query(
            "INSERT INTO $table (enfoque_id, name, active, order_index) VALUES ($enfoqueId, '$name', 1, $orderIndex)"
        );
        return Database::insert_id();
    }

    public static function deleteEnfoqueValor(int $id): void
    {
        if ($id <= 0) return;
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_ENFOQUE_VALOR);
        Database::delete($table, ['id = ?' => $id]);
    }

    public static function getEnfoquesWithValores(string $level = ''): array
    {
        $enfoques = self::getEnfoques($level);
        foreach ($enfoques as &$ef) {
            $ef['valores'] = self::getValoresByEnfoque((int) $ef['id']);
        }
        return $enfoques;
    }

    // =========================================================================
    // HELPERS - Full data load for view
    // =========================================================================

    public static function getAreasWithDetails(string $level = ''): array
    {
        $areas = $level ? self::getAreasByLevel($level) : self::getAreas();
        foreach ($areas as &$area) {
            $area['competencias'] = self::getCompetenciasByArea((int) $area['id']);
            $area['capacidades']  = self::getCapacidadesByArea((int) $area['id']);
        }
        return $areas;
    }

    public static function getAreasByLevel(string $level): array
    {
        $table = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_CURRICULA_AREA);
        $l = Database::escape_string($level);
        $result = Database::query("SELECT * FROM $table WHERE level = '$l' ORDER BY order_index ASC, name ASC");
        $rows = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $rows[] = $row;
        }
        return $rows;
    }

    public static function getTransversalesWithCaps(string $level = ''): array
    {
        $transversales = self::getTransversales($level);
        foreach ($transversales as &$t) {
            $t['capacidades'] = self::getCapacidadesByTransversal((int) $t['id']);
        }
        return $transversales;
    }

    public static function getAllDataByLevel(): array
    {
        $levels = ['inicial', 'primaria', 'secundaria', 'ambos'];
        $result = [];
        foreach ($levels as $level) {
            $areas = self::getAreasWithDetails($level);
            if (!empty($areas)) {
                $result[$level] = $areas;
            }
        }
        return $result;
    }
}
