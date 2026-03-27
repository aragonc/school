<?php
/**
 * SupportManager - School Plugin
 * Gestión de tickets de soporte técnico entre usuarios y administradores.
 */
class SupportManager
{
    // =========================================================================
    // TICKETS
    // =========================================================================

    public static function getTickets(array $filters = []): array
    {
        $tTicket = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_SUPPORT_TICKET);
        $userId  = isset($filters['user_id']) ? (int) $filters['user_id'] : 0;
        $status  = isset($filters['status'])  ? Database::escape_string($filters['status']) : '';
        $isAdmin = isset($filters['is_admin']) ? (bool) $filters['is_admin'] : false;

        $sql = "SELECT t.*,
                       COALESCE(u.lastname,  t.guest_name)  AS lastname,
                       COALESCE(u.firstname, '')             AS firstname,
                       COALESCE(u.username,  t.guest_email) AS username
                FROM $tTicket t
                LEFT JOIN user u ON u.user_id = t.user_id AND t.user_id > 0
                WHERE 1=1";

        if (!$isAdmin && $userId > 0) {
            $sql .= " AND t.user_id = $userId";
        }
        if ($status !== '') {
            $sql .= " AND t.status = '$status'";
        }

        $sql .= " ORDER BY
                    FIELD(t.status,'open','in_progress','resolved','closed'),
                    t.created_at DESC";

        $result = Database::query($sql);
        $rows   = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $rows[] = $row;
        }
        return $rows;
    }

    public static function getTicketById(int $id): ?array
    {
        if ($id <= 0) return null;
        $tTicket = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_SUPPORT_TICKET);
        $sql    = "SELECT t.*,
                          COALESCE(u.lastname,  t.guest_name)  AS lastname,
                          COALESCE(u.firstname, '')             AS firstname,
                          COALESCE(u.username,  t.guest_email) AS username
                   FROM $tTicket t
                   LEFT JOIN user u ON u.user_id = t.user_id AND t.user_id > 0
                   WHERE t.id = $id
                   LIMIT 1";
        $result = Database::query($sql);
        $row    = Database::fetch_array($result, 'ASSOC');
        return $row ?: null;
    }

    public static function createTicket(array $data): int
    {
        $tTicket = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_SUPPORT_TICKET);
        $now     = api_get_utc_datetime();
        $userId  = (int) api_get_user_id();

        $params = [
            'user_id'     => $userId,
            'subject'     => Database::escape_string(trim($data['subject'] ?? '')),
            'category'    => Database::escape_string(trim($data['category'] ?? 'general')),
            'priority'    => Database::escape_string($data['priority'] ?? 'medium'),
            'status'      => 'open',
            'created_at'  => $now,
            'updated_at'  => $now,
        ];

        $id = (int) Database::insert($tTicket, $params);
        return $id;
    }

    public static function updateTicketStatus(int $id, string $status, ?int $assignedTo = null): bool
    {
        if ($id <= 0) return false;
        $tTicket   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_SUPPORT_TICKET);
        $now       = api_get_utc_datetime();
        $safeStatus = Database::escape_string($status);

        $params = [
            'status'     => $safeStatus,
            'updated_at' => $now,
        ];
        if ($assignedTo !== null) {
            $params['assigned_to'] = (int) $assignedTo;
        }
        if ($status === 'closed' || $status === 'resolved') {
            $params['closed_at'] = $now;
        }

        Database::update($tTicket, $params, ['id = ?' => $id]);
        return true;
    }

    // =========================================================================
    // MENSAJES
    // =========================================================================

    public static function getMessages(int $ticketId): array
    {
        if ($ticketId <= 0) return [];
        $tMsg   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_SUPPORT_MESSAGE);
        $sql    = "SELECT m.*,
                          u.lastname, u.firstname, u.username,
                          u.status as user_status
                   FROM $tMsg m
                   INNER JOIN user u ON u.user_id = m.user_id
                   WHERE m.ticket_id = $ticketId
                   ORDER BY m.created_at ASC";
        $result = Database::query($sql);
        $rows   = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $row['created_at_local'] = api_get_local_time($row['created_at']);
            $rows[] = $row;
        }
        return $rows;
    }

    public static function addMessage(int $ticketId, string $body, bool $isInternal = false): int
    {
        if ($ticketId <= 0 || trim($body) === '') return 0;
        $tMsg    = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_SUPPORT_MESSAGE);
        $tTicket = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_SUPPORT_TICKET);
        $now     = api_get_utc_datetime();
        $userId  = (int) api_get_user_id();

        $id = (int) Database::insert($tMsg, [
            'ticket_id'   => $ticketId,
            'user_id'     => $userId,
            'body'        => Database::escape_string(trim($body)),
            'is_internal' => $isInternal ? 1 : 0,
            'created_at'  => $now,
        ]);

        // Actualizar updated_at y reabrir si estaba resuelto/cerrado
        $sql = "UPDATE $tTicket
                SET updated_at = '$now',
                    status = IF(status IN ('resolved','closed'), 'in_progress', status)
                WHERE id = $ticketId";
        Database::query($sql);

        return $id;
    }

    // =========================================================================
    // HELPERS
    // =========================================================================

    public static function canAccess(array $ticket, int $userId, bool $isAdmin): bool
    {
        if ($isAdmin) return true;
        return (int) $ticket['user_id'] === $userId;
    }

    public static function getStatusLabel(string $status): string
    {
        $map = [
            'open'        => 'Abierto',
            'in_progress' => 'En proceso',
            'resolved'    => 'Resuelto',
            'closed'      => 'Cerrado',
        ];
        return $map[$status] ?? $status;
    }

    public static function getPriorityLabel(string $priority): string
    {
        $map = [
            'low'      => 'Baja',
            'medium'   => 'Media',
            'high'     => 'Alta',
            'critical' => 'Crítica',
        ];
        return $map[$priority] ?? $priority;
    }

    public static function getStatusBadgeClass(string $status): string
    {
        $map = [
            'open'        => 'badge-primary',
            'in_progress' => 'badge-warning',
            'resolved'    => 'badge-success',
            'closed'      => 'badge-secondary',
        ];
        return $map[$status] ?? 'badge-light';
    }

    public static function getPriorityBadgeClass(string $priority): string
    {
        $map = [
            'low'      => 'badge-light text-dark',
            'medium'   => 'badge-info',
            'high'     => 'badge-warning text-dark',
            'critical' => 'badge-danger',
        ];
        return $map[$priority] ?? 'badge-light';
    }

    public static function getUnreadCountForAdmin(): int
    {
        $tTicket = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_SUPPORT_TICKET);
        $result  = Database::query("SELECT COUNT(*) AS c FROM $tTicket WHERE status = 'open'");
        $row     = Database::fetch_array($result, 'ASSOC');
        return (int) ($row['c'] ?? 0);
    }

    // =========================================================================
    // ASIGNADOS
    // =========================================================================

    public static function getAssignees(int $ticketId): array
    {
        if ($ticketId <= 0) return [];
        $tA  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_SUPPORT_ASSIGNEE);
        $sql = "SELECT a.user_id, a.assigned_at,
                       u.lastname, u.firstname, u.email
                FROM $tA a
                INNER JOIN user u ON u.user_id = a.user_id
                WHERE a.ticket_id = $ticketId
                ORDER BY a.assigned_at ASC";
        $result = Database::query($sql);
        $rows   = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $rows[] = $row;
        }
        return $rows;
    }

    public static function addAssignee(int $ticketId, int $userId): bool
    {
        if ($ticketId <= 0 || $userId <= 0) return false;
        $tA  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_SUPPORT_ASSIGNEE);
        $now = api_get_utc_datetime();
        $by  = (int) api_get_user_id();
        // INSERT IGNORE para respetar UNIQUE KEY
        Database::query("INSERT IGNORE INTO $tA (ticket_id, user_id, assigned_at, assigned_by)
                         VALUES ($ticketId, $userId, '$now', $by)");
        // Pasar a in_progress si estaba abierto
        $tT = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_SUPPORT_TICKET);
        Database::query("UPDATE $tT SET status = 'in_progress', updated_at = '$now'
                         WHERE id = $ticketId AND status = 'open'");
        return true;
    }

    public static function removeAssignee(int $ticketId, int $userId): bool
    {
        if ($ticketId <= 0 || $userId <= 0) return false;
        $tA = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_SUPPORT_ASSIGNEE);
        Database::query("DELETE FROM $tA WHERE ticket_id = $ticketId AND user_id = $userId");
        return true;
    }

    public static function deleteTicket(int $id): bool
    {
        if ($id <= 0) return false;
        $tTicket   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_SUPPORT_TICKET);
        $tMessage  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_SUPPORT_MESSAGE);
        $tAssignee = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_SUPPORT_ASSIGNEE);
        Database::query("DELETE FROM $tAssignee WHERE ticket_id = $id");
        Database::query("DELETE FROM $tMessage  WHERE ticket_id = $id");
        Database::query("DELETE FROM $tTicket   WHERE id = $id");
        return true;
    }

    /** Devuelve todos los administradores de la plataforma para el selector. */
    public static function getPlatformAdmins(): array
    {
        $sql    = "SELECT u.user_id, u.lastname, u.firstname, u.email
                   FROM user u
                   INNER JOIN user_rel_user uru ON uru.friend_user_id = u.user_id
                   WHERE uru.relation_type = 1
                   ORDER BY u.lastname ASC, u.firstname ASC";
        // Fallback: buscar por status = 1 (COURSEMANAGER que sea admin)
        $admins = [];
        $result = Database::query(
            "SELECT u.user_id, u.lastname, u.firstname, u.email
             FROM user u
             WHERE u.status = 1
               AND u.active = 1
             ORDER BY u.lastname ASC, u.firstname ASC"
        );
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $admins[] = $row;
        }
        // Filtrar solo los que realmente son platform admin
        $filtered = [];
        foreach ($admins as $a) {
            if (api_is_platform_admin_by_id((int) $a['user_id'])) {
                $filtered[] = $a;
            }
        }
        return $filtered;
    }

    // =========================================================================
    // TICKETS PÚBLICOS (sin login)
    // =========================================================================

    public static function createPublicTicket(array $data): int
    {
        $tTicket = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_SUPPORT_TICKET);
        $tMsg    = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_SUPPORT_MESSAGE);
        $now     = api_get_utc_datetime();

        $ticketId = (int) Database::insert($tTicket, [
            'user_id'        => 0,
            'guest_name'     => Database::escape_string(trim($data['guest_name']      ?? '')),
            'guest_email'    => Database::escape_string(trim($data['guest_email']     ?? '')),
            'guest_whatsapp' => Database::escape_string(trim($data['guest_whatsapp']  ?? '')),
            'subject'     => Database::escape_string(trim($data['subject']     ?? '')),
            'category'    => Database::escape_string(trim($data['category']    ?? 'general')),
            'priority'    => 'medium',
            'status'      => 'open',
            'created_at'  => $now,
            'updated_at'  => $now,
        ]);

        if ($ticketId > 0 && !empty(trim($data['body'] ?? ''))) {
            $ip   = Database::escape_string($data['ip'] ?? '');
            $body = Database::escape_string(trim($data['body']));
            Database::query("INSERT INTO $tMsg (ticket_id, user_id, body, is_internal, created_at)
                              VALUES ($ticketId, 0, '$body', 0, '$now')");
        }

        return $ticketId;
    }

    /**
     * Limita a 3 tickets públicos por IP en la última hora.
     */
    public static function checkPublicRateLimit(string $ip): bool
    {
        $tTicket  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_SUPPORT_TICKET);
        $safeIp   = Database::escape_string($ip);
        // Usamos guest_email como proxy; pero realmente filtramos por user_id=0 y created_at
        $oneHourAgo = date('Y-m-d H:i:s', time() - 3600);
        $result   = Database::query(
            "SELECT COUNT(*) AS c FROM $tTicket
             WHERE user_id = 0 AND created_at >= '$oneHourAgo'"
        );
        $row = Database::fetch_array($result, 'ASSOC');
        return (int) ($row['c'] ?? 0) < 3;
    }
}
