<?php
require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../src/MatriculaManager.php';
require_once __DIR__ . '/../src/AcademicManager.php';

$plugin = SchoolPlugin::create();
$plugin->requireLogin();

header('Content-Type: application/json');

$isAdmin     = api_is_platform_admin();
$userInfo    = api_get_user_info();
$isSecretary = $userInfo && $userInfo['status'] == SCHOOL_SECRETARY;

if (!$isAdmin && !$isSecretary) {
    echo json_encode(['success' => false, 'message' => 'Access denied']);
    exit;
}

$action = $_POST['action'] ?? $_GET['action'] ?? '';

switch ($action) {

    case 'delete_matricula':
        $id = (int) ($_POST['id'] ?? 0);
        if (!$id) {
            echo json_encode(['success' => false, 'message' => 'ID requerido']);
            break;
        }
        $result = MatriculaManager::deleteMatricula($id);
        echo json_encode(['success' => $result]);
        break;

    case 'delete_contacto':
        $id = (int) ($_POST['id'] ?? 0);
        if (!$id) {
            echo json_encode(['success' => false, 'message' => 'ID requerido']);
            break;
        }
        $result = MatriculaManager::deleteContacto($id);
        echo json_encode(['success' => $result]);
        break;

    case 'get_retirement_info':
        $id   = (int) ($_GET['id'] ?? $_POST['id'] ?? 0);
        $info = AcademicManager::getRetirementInfo($id);
        echo json_encode(['success' => !empty($info), 'data' => $info]);
        break;

    case 'retire_matricula':
        $id = (int) ($_POST['id'] ?? 0);
        if (!$id) {
            echo json_encode(['success' => false, 'message' => 'ID requerido']);
            break;
        }
        $result = MatriculaManager::retireMatricula($id);
        if ($result) {
            // Save refund record if admission was paid (amount > 0)
            $admissionPaid = (float) ($_POST['admission_paid'] ?? 0);
            $refundData    = [
                'matricula_id'     => $id,
                'ficha_id'         => (int) ($_POST['ficha_id']         ?? 0),
                'user_id'          => (int) ($_POST['user_id']          ?? 0) ?: null,
                'years_contracted' => (int) ($_POST['years_contracted']  ?? 1),
                'years_attended'   => (int) ($_POST['years_attended']    ?? 0),
                'admission_paid'   => $admissionPaid,
                'notes'            => $_POST['retire_notes'] ?? '',
            ];
            // Always save refund record (even if amount is 0, for audit trail)
            if ((int) $refundData['ficha_id'] > 0) {
                $plugin->saveRefund($refundData);
            }
        }
        echo json_encode(['success' => $result]);
        break;

    case 'promote_year':
        $fromYearId = (int) ($_POST['from_year_id'] ?? 0);
        $toYearId   = (int) ($_POST['to_year_id'] ?? 0);
        if (!$fromYearId || !$toYearId) {
            echo json_encode(['success' => false, 'message' => 'Se requieren los IDs de ambos años académicos']);
            break;
        }
        $count = MatriculaManager::promoteToNextYear($fromYearId, $toYearId);
        echo json_encode(['success' => true, 'count' => $count]);
        break;

    case 'save_matricula_anual':
        $fichaId     = (int) ($_POST['ficha_id'] ?? 0);
        $matId       = (int) ($_POST['mat_id'] ?? 0);
        $yearId      = (int) ($_POST['academic_year_id'] ?? 0);
        $gradeId     = (int) ($_POST['grade_id'] ?? 0);
        $sectionId   = (int) ($_POST['section_id'] ?? 0);
        $tipoIngreso = $_POST['tipo_ingreso'] ?? 'NUEVO_INGRESO';
        $estado      = $_POST['estado'] ?? 'ACTIVO';

        if (!$fichaId) {
            echo json_encode(['success' => false, 'message' => 'ficha_id requerido']);
            break;
        }

        // Check for duplicate enrollment to avoid unique key violation on (ficha_id, academic_year_id).
        // For new enrollments (mat_id=0): if a row already exists, update that row instead of inserting.
        // For edits (mat_id>0): if the selected year conflicts with a DIFFERENT existing row, report error.
        if ($yearId > 0) {
            $matTable   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA);
            $existCheck = Database::query(
                "SELECT id FROM $matTable WHERE ficha_id = $fichaId AND academic_year_id = $yearId LIMIT 1"
            );
            $existRow = Database::fetch_array($existCheck, 'ASSOC');
            if ($existRow) {
                $conflictId = (int) $existRow['id'];
                if ($matId === 0) {
                    // New enrollment: reuse existing row
                    $matId = $conflictId;
                } elseif ($conflictId !== $matId) {
                    // Edit: another row already holds this ficha+year combination
                    echo json_encode([
                        'success' => false,
                        'message' => 'Ya existe una matrícula para este alumno en el año académico seleccionado. Elimine la matrícula duplicada antes de continuar.',
                    ]);
                    break;
                }
            }
        }

        try {
            $savedId = MatriculaManager::saveMatricula([
                'id'               => $matId,
                'ficha_id'         => $fichaId,
                'academic_year_id' => $yearId ?: null,
                'grade_id'         => $gradeId ?: null,
                'section_id'       => $sectionId ?: null,
                'tipo_ingreso'     => $tipoIngreso,
                'estado'           => $estado,
            ]);
        } catch (\Throwable $e) {
            echo json_encode(['success' => false, 'message' => 'Error al guardar la matrícula: ' . $e->getMessage()]);
            break;
        }

        if (!$savedId) {
            echo json_encode(['success' => false, 'message' => 'Error al guardar la matrícula']);
            break;
        }

        echo json_encode([
            'success' => true,
            'id'      => $savedId,
        ]);
        break;

    case 'crear_usuario_chamilo':
        // Accept ficha_id directly (new) or fall back to matricula_id (legacy)
        $fichaId     = (int) ($_POST['ficha_id'] ?? 0);
        $matriculaId = (int) ($_POST['matricula_id'] ?? 0);

        if ($fichaId > 0) {
            $mat = MatriculaManager::getFichaById($fichaId);
        } elseif ($matriculaId > 0) {
            $matRow  = MatriculaManager::getMatriculaById($matriculaId);
            $fichaId = $matRow ? (int) $matRow['ficha_id'] : 0;
            $mat     = $fichaId > 0 ? MatriculaManager::getFichaById($fichaId) : null;
        } else {
            $mat = null;
        }

        if (!$mat) {
            echo json_encode(['success' => false, 'message' => 'Ficha no encontrada']);
            break;
        }
        if (!empty($mat['user_id'])) {
            echo json_encode(['success' => false, 'message' => 'Esta ficha ya tiene un usuario vinculado']);
            break;
        }

        // Build user fields from ficha data
        $firstName = ucwords(mb_strtolower(trim($mat['nombres'] ?? '')));
        $lastName  = trim(($mat['apellido_paterno'] ?? '') . ' ' . ($mat['apellido_materno'] ?? ''));
        $lastName  = ucwords(mb_strtolower($lastName));

        // Username: use DNI if available, otherwise generate from name
        if (!empty($mat['dni'])) {
            $username = $mat['dni'];
        } else {
            $username = UserManager::create_username($firstName, $lastName);
        }

        // Ensure username is unique
        $base = $username;
        $i = 1;
        $userTable = Database::get_main_table(TABLE_MAIN_USER);
        while (Database::num_rows(Database::query("SELECT id FROM $userTable WHERE username = '" . Database::escape_string($username) . "'")) > 0) {
            $username = $base . $i++;
        }

        // Generate initial password (same as DNI or random)
        $password = !empty($mat['dni']) ? $mat['dni'] : api_generate_password(8);

        // Email: generate a placeholder if DNI available
        $email = !empty($mat['dni']) ? $mat['dni'] . '@alumno.local' : '';

        $newUserId = UserManager::create_user(
            $firstName,
            $lastName,
            STUDENT,
            $email,
            $username,
            $password,
            (string) $fichaId,   // official_code = ficha id
            '',
            '',
            '',
            PLATFORM_AUTH_SOURCE,
            null,
            0   // inactive
        );

        if (!$newUserId || $newUserId < 0) {
            echo json_encode(['success' => false, 'message' => 'Error al crear el usuario. Verifique que el username o email no esté duplicado.']);
            break;
        }

        // Link the new user to the ficha
        Database::update(
            Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_FICHA),
            ['user_id' => $newUserId],
            ['id = ?' => $fichaId]
        );

        echo json_encode([
            'success'  => true,
            'user_id'  => $newUserId,
            'username' => $username,
            'password' => $password,
        ]);
        break;

    case 'buscar_padre':
        $term = trim($_POST['term'] ?? '');
        if (strlen($term) < 2) {
            echo json_encode(['success' => false, 'padres' => []]);
            break;
        }
        $escaped = Database::escape_string($term);
        $padreTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA_PADRE);
        $res = Database::query(
            "SELECT id, parentesco, apellidos, nombres, dni, celular, ocupacion,
                    edad, religion, tipo_parto, vive_con_menor
             FROM $padreTable
             WHERE (apellidos LIKE '%$escaped%' OR dni LIKE '%$escaped%')
             GROUP BY apellidos, nombres, dni
             ORDER BY apellidos, nombres
             LIMIT 10"
        );
        $padres = [];
        while ($p = Database::fetch_array($res, 'ASSOC')) {
            $label = trim(($p['apellidos'] ?? '') . ', ' . ($p['nombres'] ?? ''));
            if (!empty($p['dni'])) {
                $label .= ' — DNI: ' . $p['dni'];
            }
            $padres[] = [
                'id'            => (int) $p['id'],
                'label'         => $label,
                'parentesco'    => $p['parentesco'],
                'apellidos'     => $p['apellidos'] ?? '',
                'nombres'       => $p['nombres'] ?? '',
                'dni'           => $p['dni'] ?? '',
                'celular'       => $p['celular'] ?? '',
                'ocupacion'     => $p['ocupacion'] ?? '',
                'edad'          => $p['edad'] ?? '',
                'religion'      => $p['religion'] ?? '',
                'tipo_parto'    => $p['tipo_parto'] ?? '',
                'vive_con_menor'=> (int) ($p['vive_con_menor'] ?? 0),
            ];
        }
        echo json_encode(['success' => true, 'padres' => $padres]);
        break;

    case 'buscar_usuario':
        $term = trim($_POST['term'] ?? '');
        if (strlen($term) < 2) {
            echo json_encode(['success' => false, 'users' => []]);
            break;
        }
        $escaped = Database::escape_string($term);
        $userTable = Database::get_main_table(TABLE_MAIN_USER);
        $res = Database::query(
            "SELECT id, username, firstname, lastname
             FROM $userTable
             WHERE status != 6
               AND (username LIKE '%$escaped%' OR firstname LIKE '%$escaped%' OR lastname LIKE '%$escaped%')
             ORDER BY lastname, firstname
             LIMIT 10"
        );
        $users = [];
        while ($u = Database::fetch_array($res, 'ASSOC')) {
            $users[] = [
                'id'    => (int) $u['id'],
                'label' => $u['lastname'] . ' ' . $u['firstname'] . ' (' . $u['username'] . ')',
            ];
        }
        echo json_encode(['success' => true, 'users' => $users]);
        break;

    case 'consultar_reniec':
        $dni = trim($_POST['dni'] ?? '');
        if (!preg_match('/^\d{8}$/', $dni)) {
            echo json_encode(['success' => false, 'message' => 'DNI inválido: debe tener exactamente 8 dígitos']);
            break;
        }
        $url = 'https://api.apis.net.pe/v2/reniec/dni?numero=' . $dni;
        $ch  = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT        => 10,
            CURLOPT_HTTPHEADER     => ['Accept: application/json'],
        ]);
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        if ($httpCode === 200 && $response) {
            $data = json_decode($response, true);
            echo json_encode([
                'success'          => true,
                'apellido_paterno' => $data['apellidoPaterno'] ?? '',
                'apellido_materno' => $data['apellidoMaterno'] ?? '',
                'nombres'          => $data['nombre'] ?? '',
            ]);
        } else {
            echo json_encode(['success' => false, 'message' => 'No se encontró el DNI en RENIEC']);
        }
        break;

    case 'get_tarjeta_data':
        $matriculaId   = (int) ($_GET['matricula_id'] ?? 0);
        $tarjetaUserId = (int) ($_GET['user_id'] ?? 0);
        $currentUserId = api_get_user_id();
        $isSelf        = ($tarjetaUserId > 0 && $tarjetaUserId === $currentUserId);
        // Also allow if the matricula belongs to the current user
        if (!$isSelf && $matriculaId > 0) {
            $tempMat = MatriculaManager::getMatriculaById($matriculaId);
            $isSelf  = ($tempMat && (int) ($tempMat['user_id'] ?? 0) === $currentUserId);
        }
        if (!$isAdmin && !$isSecretary && !$isSelf) {
            echo json_encode(['success' => false, 'error' => 'Sin permisos']);
            break;
        }
        $gradeName = ''; $levelName = ''; $sectionName = '';

        if ($matriculaId > 0) {
            // Alumno con ficha de matrícula
            $mat = MatriculaManager::getMatriculaById($matriculaId);
            if (!$mat) {
                echo json_encode(['success' => false, 'error' => 'Matrícula no encontrada']);
                break;
            }
            $gradeName   = $mat['grade_name'] ?? '';
            $sectionName = $mat['section_name'] ?? '';
            $levelName   = $mat['level_name'] ?? '';
            $fotoUrl = '';
            if (!empty($mat['foto'])) {
                $fotoUrl = api_get_path(WEB_PLUGIN_PATH) . 'school/uploads/matricula/' . $mat['foto'];
            } elseif (!empty($mat['user_id'])) {
                $uInfoCard = api_get_user_info((int) $mat['user_id']);
                $fotoUrl   = $uInfoCard['avatar'] ?? '';
            }
            $email = '';
            if (!empty($mat['user_id'])) {
                $uInfoCard = api_get_user_info((int) $mat['user_id']);
                $email     = $uInfoCard['email'] ?? '';
            }
            echo json_encode([
                'success'   => true,
                'nombres'   => trim($mat['nombres'] ?? ''),
                'apellidos' => trim(($mat['apellido_paterno'] ?? '') . ' ' . ($mat['apellido_materno'] ?? '')),
                'dni'       => $mat['dni'] ?? '',
                'grade'     => $gradeName,
                'section'   => $sectionName,
                'level'     => $levelName,
                'foto_url'  => $fotoUrl,
                'email'     => $email,
            ]);
        } elseif ($tarjetaUserId > 0) {
            // Alumno solo con cuenta Chamilo (sin ficha de matrícula)
            $uInfoCard = api_get_user_info($tarjetaUserId);
            if (!$uInfoCard) {
                echo json_encode(['success' => false, 'error' => 'Usuario no encontrado']);
                break;
            }
            $apellidos = trim($uInfoCard['lastname'] ?? '');
            $nombres   = trim($uInfoCard['firstname'] ?? '');
            echo json_encode([
                'success'   => true,
                'nombres'   => $nombres,
                'apellidos' => $apellidos,
                'dni'       => '',
                'grade'     => '',
                'section'   => '',
                'level'     => '',
                'foto_url'  => $uInfoCard['avatar'] ?? '',
                'email'     => $uInfoCard['email'] ?? '',
            ]);
        } else {
            echo json_encode(['success' => false, 'error' => 'ID inválido']);
        }
        break;

    case 'toggle_user_active':
        if (!api_is_platform_admin() && !($userInfo && $userInfo['status'] == SCHOOL_SECRETARY)) {
            echo json_encode(['success' => false, 'error' => 'Sin permisos']);
            break;
        }
        $toggleUserId = (int) ($_POST['user_id'] ?? 0);
        $newActive    = (int) ($_POST['active'] ?? 0);
        $newActive    = $newActive ? 1 : 0;
        if ($toggleUserId <= 0) {
            echo json_encode(['success' => false, 'error' => 'ID inválido']);
            break;
        }
        $userTable = Database::get_main_table(TABLE_MAIN_USER);
        Database::update($userTable, ['active' => $newActive], ['user_id = ?' => $toggleUserId]);
        echo json_encode([
            'success' => true,
            'message' => $newActive ? 'Usuario activado.' : 'Usuario desactivado.',
        ]);
        break;

    case 'crear_alumno_nuevo':
        $apellidos = Database::escape_string(mb_convert_case(trim($_POST['apellidos'] ?? ''), MB_CASE_TITLE, 'UTF-8'));
        $nombres   = Database::escape_string(mb_convert_case(trim($_POST['nombres']   ?? ''), MB_CASE_TITLE, 'UTF-8'));
        $dni       = Database::escape_string(preg_replace('/[^0-9]/', '', trim($_POST['dni'] ?? '')));
        $active    = isset($_POST['active']) && (int) $_POST['active'] === 1 ? 1 : 0;

        if (!$apellidos || !$nombres || !$dni) {
            echo json_encode(['success' => false, 'error' => 'Apellidos, nombres y DNI son obligatorios.']);
            break;
        }

        $domain   = 'playschool.edu.pe';
        $username = $dni . '@' . $domain;
        $email    = $username;
        $password = $dni;

        $userTable = Database::get_main_table(TABLE_MAIN_USER);

        // Check username not taken
        $chkUser = Database::query("SELECT user_id FROM $userTable WHERE username = '" . Database::escape_string($username) . "' LIMIT 1");
        if (Database::num_rows($chkUser) > 0) {
            echo json_encode(['success' => false, 'error' => 'Ya existe un usuario con el DNI ' . $dni . '.']);
            break;
        }

        $newUserId = UserManager::create_user(
            $nombres,           // firstname
            $apellidos,         // lastname
            STUDENT,            // status
            $email,
            $username,
            $password,
            $dni,               // official_code
            '',                 // language
            '',                 // phone
            '',                 // picture_uri
            'platform',         // auth_source
            '',                 // expiration_date
            $active,            // active
            0,                  // creator_id (0 = current admin)
            0,                  // hr_dept_id
            null,               // extra
            '',                 // encrypt_method
            false,              // send_mail
            false               // dry_run
        );

        if ($newUserId > 0) {
            echo json_encode([
                'success'     => true,
                'user_id'     => $newUserId,
                'form_url'    => api_get_path(WEB_PATH) . 'matricula/nueva?user_id=' . $newUserId,
                'message'     => 'Alumno creado correctamente.',
            ]);
        } else {
            echo json_encode(['success' => false, 'error' => 'No se pudo crear el usuario. Verifique los datos.']);
        }
        break;

    case 'get_grades_by_level':
        $levelId = (int) ($_GET['level_id'] ?? $_POST['level_id'] ?? 0);
        if (!$levelId) {
            echo json_encode(['success' => false, 'grades' => []]);
            break;
        }
        $grades = AcademicManager::getGrades($levelId, true);
        echo json_encode(['success' => true, 'grades' => $grades]);
        break;

    case 'get_sections_by_grade':
        $sgYearId  = (int) ($_GET['academic_year_id'] ?? $_POST['academic_year_id'] ?? 0);
        $sgGradeId = (int) ($_GET['grade_id'] ?? $_POST['grade_id'] ?? 0);
        if (!$sgYearId || !$sgGradeId) {
            echo json_encode(['success' => false, 'sections' => []]);
            break;
        }
        $cTable  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM);
        $sTable  = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_SECTION);
        $csTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_CLASSROOM_STUDENT);
        $uTable  = Database::get_main_table(TABLE_MAIN_USER);
        $sgRes   = Database::query(
            "SELECT c.id AS classroom_id, c.section_id, c.capacity, c.tutor_id,
                    s.name AS section_name,
                    (SELECT COUNT(*) FROM $csTable cs WHERE cs.classroom_id = c.id) AS student_count
             FROM $cTable c
             INNER JOIN $sTable s ON c.section_id = s.id
             WHERE c.academic_year_id = $sgYearId AND c.grade_id = $sgGradeId AND c.active = 1
             ORDER BY s.name ASC"
        );
        $sections = [];
        while ($sgRow = Database::fetch_array($sgRes, 'ASSOC')) {
            $tutorName = '';
            if (!empty($sgRow['tutor_id'])) {
                $tInfo     = api_get_user_info((int) $sgRow['tutor_id']);
                $tutorName = $tInfo ? $tInfo['complete_name'] : '';
            }
            $sections[] = [
                'classroom_id'  => (int) $sgRow['classroom_id'],
                'section_id'    => (int) $sgRow['section_id'],
                'section_name'  => $sgRow['section_name'],
                'capacity'      => (int) $sgRow['capacity'],
                'student_count' => (int) $sgRow['student_count'],
                'tutor_name'    => $tutorName,
            ];
        }
        echo json_encode(['success' => true, 'sections' => $sections]);
        break;

    // =========================================================================
    // BULK CSV ENROLL
    // =========================================================================
    case 'bulk_enroll_csv':
        // Modal defaults — used as fallback when CSV columns are empty
        $defaultYearId      = (int) ($_POST['academic_year_id'] ?? 0);
        $defaultGradeId     = (int) ($_POST['grade_id']         ?? 0);
        $defaultSectionId   = (int) ($_POST['section_id']       ?? 0);
        $defaultTipoIngreso = $_POST['tipo_ingreso'] ?? 'NUEVO_INGRESO';

        if (empty($_FILES['csv_file']['tmp_name'])) {
            echo json_encode(['success' => false, 'message' => 'Archivo CSV requerido']);
            break;
        }

        $handle = fopen($_FILES['csv_file']['tmp_name'], 'r');
        if (!$handle) {
            echo json_encode(['success' => false, 'message' => 'No se pudo leer el archivo']);
            break;
        }

        $userTable    = Database::get_main_table(TABLE_MAIN_USER);
        $matTable     = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA);
        $yearTable    = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_YEAR);
        $levelTable   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_LEVEL);
        $gradeTable   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_GRADE);
        $sectionTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_ACADEMIC_SECTION);

        // Lookup caches to avoid repeated DB queries for same values
        $yearCache    = [];
        $gradeCache   = [];
        $sectionCache = [];

        $results = [];
        $lineNum = 0;

        // Column indices (defaults for single-column legacy format)
        $colUsuario = 0;
        $colYear    = false;
        $colTipo    = false;
        $colNivel   = false;
        $colGrado   = false;
        $colSeccion = false;

        while (($row = fgetcsv($handle, 1000, ',')) !== false) {
            $lineNum++;

            // First row: detect if it's a header
            if ($lineNum === 1) {
                $knownHeaders = ['usuario', 'username', 'user', 'año_academico', 'ano_academico',
                                 'tipo_ingreso', 'nivel', 'grado', 'seccion', 'sección'];
                $firstCell = strtolower(trim($row[0] ?? ''));
                if (in_array($firstCell, $knownHeaders)) {
                    // Parse column positions from header row
                    foreach ($row as $i => $cell) {
                        $h = strtolower(trim($cell));
                        if (in_array($h, ['usuario', 'username', 'user']))                          $colUsuario = $i;
                        elseif (in_array($h, ['año_academico', 'ano_academico', 'año', 'year']))    $colYear    = $i;
                        elseif (in_array($h, ['tipo_ingreso', 'tipo', 'type']))                     $colTipo    = $i;
                        elseif (in_array($h, ['nivel', 'level', 'nivel_educativo']))                $colNivel   = $i;
                        elseif (in_array($h, ['grado', 'grade']))                                   $colGrado   = $i;
                        elseif (in_array($h, ['seccion', 'sección', 'section']))                    $colSeccion = $i;
                    }
                    continue; // Skip header row, process next rows
                }
                // No header — treat first row as data (legacy single-column format)
            }

            $username = trim($row[$colUsuario] ?? '');
            if ($username === '') continue;

            // ---- Resolve academic year ----
            $csvYearRaw = ($colYear !== false) ? trim($row[$colYear] ?? '') : '';
            if ($csvYearRaw !== '') {
                if (!isset($yearCache[$csvYearRaw])) {
                    $esc = Database::escape_string($csvYearRaw);
                    $yr  = Database::fetch_array(
                        Database::query("SELECT id FROM $yearTable WHERE name = '$esc' OR year = '$esc' LIMIT 1"),
                        'ASSOC'
                    );
                    $yearCache[$csvYearRaw] = $yr ? (int) $yr['id'] : 0;
                }
                $yearId = $yearCache[$csvYearRaw];
                if (!$yearId) {
                    $results[] = ['username' => $username, 'status' => 'error',
                                  'message'  => "Año académico no encontrado: $csvYearRaw"];
                    continue;
                }
            } else {
                $yearId = $defaultYearId;
            }

            if (!$yearId) {
                $results[] = ['username' => $username, 'status' => 'error',
                              'message'  => 'Año académico requerido (columna o valor por defecto)'];
                continue;
            }

            // ---- Resolve tipo_ingreso ----
            $csvTipo     = ($colTipo !== false) ? strtoupper(trim($row[$colTipo] ?? '')) : '';
            $tipoIngreso = in_array($csvTipo, ['NUEVO_INGRESO', 'REINGRESO', 'CONTINUACION'])
                ? $csvTipo
                : $defaultTipoIngreso;

            // ---- Resolve grade ----
            $csvNivel = ($colNivel !== false) ? trim($row[$colNivel] ?? '') : '';
            $csvGrado = ($colGrado !== false) ? trim($row[$colGrado] ?? '') : '';
            if ($csvGrado !== '') {
                $cacheKey = strtolower($csvNivel . '||' . $csvGrado);
                if (!isset($gradeCache[$cacheKey])) {
                    $escNivel = Database::escape_string($csvNivel);
                    $escGrado = Database::escape_string($csvGrado);
                    $gradeRow = null;
                    if ($csvNivel !== '') {
                        $gradeRow = Database::fetch_array(
                            Database::query(
                                "SELECT g.id FROM $gradeTable g
                                 INNER JOIN $levelTable l ON l.id = g.level_id
                                 WHERE l.name = '$escNivel' AND g.name = '$escGrado' LIMIT 1"
                            ),
                            'ASSOC'
                        );
                    }
                    if (!$gradeRow) {
                        // Try without level constraint
                        $gradeRow = Database::fetch_array(
                            Database::query("SELECT id FROM $gradeTable WHERE name = '$escGrado' LIMIT 1"),
                            'ASSOC'
                        );
                    }
                    $gradeCache[$cacheKey] = $gradeRow ? (int) $gradeRow['id'] : 0;
                }
                $gradeId = $gradeCache[$cacheKey];
                if (!$gradeId) {
                    $results[] = ['username' => $username, 'status' => 'error',
                                  'message'  => "Grado no encontrado: $csvGrado"];
                    continue;
                }
            } else {
                $gradeId = $defaultGradeId;
            }

            // ---- Resolve section ----
            $csvSeccion = ($colSeccion !== false) ? trim($row[$colSeccion] ?? '') : '';
            if ($csvSeccion !== '') {
                $ck = strtolower($csvSeccion);
                if (!isset($sectionCache[$ck])) {
                    $escSec  = Database::escape_string($csvSeccion);
                    $secRow  = Database::fetch_array(
                        Database::query("SELECT id FROM $sectionTable WHERE name = '$escSec' LIMIT 1"),
                        'ASSOC'
                    );
                    $sectionCache[$ck] = $secRow ? (int) $secRow['id'] : 0;
                }
                $sectionId = $sectionCache[$ck];
                if (!$sectionId) {
                    $results[] = ['username' => $username, 'status' => 'error',
                                  'message'  => "Sección no encontrada: $csvSeccion"];
                    continue;
                }
            } else {
                $sectionId = $defaultSectionId;
            }

            // ---- Find Chamilo user ----
            $esc     = Database::escape_string($username);
            $userRow = Database::fetch_array(
                Database::query("SELECT id, firstname, lastname FROM $userTable WHERE username = '$esc' AND status = 5 LIMIT 1"),
                'ASSOC'
            );
            if (!$userRow) {
                $results[] = ['username' => $username, 'status' => 'error', 'message' => 'Usuario no encontrado'];
                continue;
            }
            $userId = (int) $userRow['id'];

            // ---- Get or create minimal ficha ----
            $ficha = MatriculaManager::getFichaByUserId($userId);
            if ($ficha) {
                $fichaId = (int) $ficha['id'];
            } else {
                $fichaId = MatriculaManager::saveFicha([
                    'user_id'          => $userId,
                    'nombres'          => $userRow['firstname'],
                    'apellido_paterno' => $userRow['lastname'],
                ]);
                if (!$fichaId) {
                    $results[] = ['username' => $username, 'status' => 'error', 'message' => 'Error al crear la ficha'];
                    continue;
                }
            }

            // ---- Check duplicate enrollment ----
            $existRow = Database::fetch_array(
                Database::query("SELECT id FROM $matTable WHERE ficha_id = $fichaId AND academic_year_id = $yearId LIMIT 1"),
                'ASSOC'
            );
            if ($existRow) {
                $results[] = ['username' => $username, 'status' => 'skipped',
                              'message'  => $userRow['lastname'] . ', ' . $userRow['firstname'] . ' — ya matriculado'];
                continue;
            }

            try {
                MatriculaManager::saveMatricula([
                    'id'               => 0,
                    'ficha_id'         => $fichaId,
                    'academic_year_id' => $yearId,
                    'grade_id'         => $gradeId ?: null,
                    'section_id'       => $sectionId ?: null,
                    'tipo_ingreso'     => $tipoIngreso,
                    'estado'           => 'ACTIVO',
                ]);
                $results[] = ['username' => $username, 'status' => 'enrolled',
                              'message'  => $userRow['lastname'] . ', ' . $userRow['firstname']];
            } catch (\Throwable $e) {
                $results[] = ['username' => $username, 'status' => 'error', 'message' => $e->getMessage()];
            }
        }
        fclose($handle);

        $enrolled = count(array_filter($results, fn($r) => $r['status'] === 'enrolled'));
        $skipped  = count(array_filter($results, fn($r) => $r['status'] === 'skipped'));
        $errors   = count(array_filter($results, fn($r) => $r['status'] === 'error'));
        echo json_encode(['success' => true, 'results' => $results,
                          'enrolled' => $enrolled, 'skipped' => $skipped, 'errors' => $errors]);
        break;

    // =========================================================================
    // QUICK ENROLL
    // =========================================================================

    case 'search_users_no_matricula':
        // Search Chamilo students not yet enrolled in the given academic year
        $q          = trim($_GET['q'] ?? '');
        $yearId     = (int) ($_GET['academic_year_id'] ?? 0);
        $userTable  = Database::get_main_table(TABLE_MAIN_USER);
        $fichaTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_FICHA);
        $matTable   = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA);

        $esc = Database::escape_string($q);
        $yearCond = $yearId
            ? "AND u.id NOT IN (
                    SELECT f2.user_id FROM $matTable m2
                    INNER JOIN $fichaTable f2 ON f2.id = m2.ficha_id
                    WHERE m2.academic_year_id = $yearId AND f2.user_id IS NOT NULL
               )"
            : '';

        $sql = "SELECT u.id AS user_id, u.firstname, u.lastname, u.username, u.email
                FROM $userTable u
                WHERE u.status = 5
                  AND u.active = 1
                  AND (u.firstname LIKE '%$esc%' OR u.lastname LIKE '%$esc%'
                       OR u.username LIKE '%$esc%' OR u.email LIKE '%$esc%')
                  $yearCond
                ORDER BY u.lastname ASC, u.firstname ASC
                LIMIT 30";
        $res   = Database::query($sql);
        $users = [];
        while ($row = Database::fetch_array($res, 'ASSOC')) {
            $users[] = $row;
        }
        echo json_encode(['success' => true, 'data' => $users]);
        break;

    case 'quick_enroll':
        $userId      = (int) ($_POST['user_id']          ?? 0);
        $yearId      = (int) ($_POST['academic_year_id'] ?? 0);
        $gradeId     = (int) ($_POST['grade_id']         ?? 0);
        $sectionId   = (int) ($_POST['section_id']       ?? 0);
        $tipoIngreso = $_POST['tipo_ingreso'] ?? 'NUEVO_INGRESO';

        if (!$userId || !$yearId) {
            echo json_encode(['success' => false, 'message' => 'Usuario y año académico son requeridos']);
            break;
        }

        // Get or create minimal ficha for this user
        $ficha = MatriculaManager::getFichaByUserId($userId);
        if ($ficha) {
            $fichaId = (int) $ficha['id'];
        } else {
            $userInfo = api_get_user_info($userId);
            if (!$userInfo) {
                echo json_encode(['success' => false, 'message' => 'Usuario no encontrado']);
                break;
            }
            $fichaId = MatriculaManager::saveFicha([
                'user_id'          => $userId,
                'nombres'          => $userInfo['firstname'],
                'apellido_paterno' => $userInfo['lastname'],
            ]);
            if (!$fichaId) {
                echo json_encode(['success' => false, 'message' => 'Error al crear la ficha']);
                break;
            }
        }

        // Check for existing enrollment (same ficha + year)
        $matTable = Database::get_main_table(SchoolPlugin::TABLE_SCHOOL_MATRICULA);
        $existRow = Database::fetch_array(
            Database::query("SELECT id FROM $matTable WHERE ficha_id = $fichaId AND academic_year_id = $yearId LIMIT 1"),
            'ASSOC'
        );
        if ($existRow) {
            echo json_encode(['success' => false, 'message' => 'Este alumno ya tiene una matrícula para el año seleccionado']);
            break;
        }

        try {
            $matId = MatriculaManager::saveMatricula([
                'id'               => 0,
                'ficha_id'         => $fichaId,
                'academic_year_id' => $yearId,
                'grade_id'         => $gradeId ?: null,
                'section_id'       => $sectionId ?: null,
                'tipo_ingreso'     => $tipoIngreso,
                'estado'           => 'ACTIVO',
            ]);
        } catch (\Throwable $e) {
            echo json_encode(['success' => false, 'message' => 'Error al guardar la matrícula: ' . $e->getMessage()]);
            break;
        }

        echo json_encode([
            'success'      => true,
            'ficha_id'     => $fichaId,
            'matricula_id' => $matId,
            'ficha_url'    => api_get_path(WEB_PATH) . 'matricula/editar?ficha_id=' . $fichaId,
        ]);
        break;

    default:
        echo json_encode(['success' => false, 'message' => 'Acción no reconocida']);
        break;
}
