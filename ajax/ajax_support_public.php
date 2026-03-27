<?php
/**
 * Endpoint público de soporte — accesible sin sesión iniciada.
 * Acciones: get_captcha, submit_public_ticket
 */

require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../src/SupportManager.php';

// Iniciar sesión si no está activa (necesario para captcha)
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

header('Content-Type: application/json');

$action = isset($_REQUEST['action']) ? $_REQUEST['action'] : '';

switch ($action) {

    // ------------------------------------------------------------------
    // Genera y devuelve una pregunta matemática simple
    // ------------------------------------------------------------------
    case 'get_captcha':
        $a = rand(2, 9);
        $b = rand(1, 9);
        $_SESSION['school_support_captcha']      = $a + $b;
        $_SESSION['school_support_captcha_time'] = time();
        echo json_encode([
            'success'  => true,
            'question' => "¿Cuánto es $a + $b?",
        ]);
        break;

    // ------------------------------------------------------------------
    // Crea un ticket público (sin login)
    // ------------------------------------------------------------------
    case 'submit_public_ticket':
        // --- Validar captcha ---
        $captchaAnswer  = isset($_POST['captcha']) ? (int) trim($_POST['captcha']) : -1;
        $captchaExpected = isset($_SESSION['school_support_captcha']) ? (int) $_SESSION['school_support_captcha'] : null;
        $captchaTime     = isset($_SESSION['school_support_captcha_time']) ? (int) $_SESSION['school_support_captcha_time'] : 0;

        // Limpiar captcha de sesión tras intento
        unset($_SESSION['school_support_captcha'], $_SESSION['school_support_captcha_time']);

        if ($captchaExpected === null || $captchaAnswer !== $captchaExpected) {
            echo json_encode(['success' => false, 'field' => 'captcha', 'message' => 'Respuesta incorrecta. Intenta de nuevo.']);
            exit;
        }
        if (time() - $captchaTime > 600) {
            echo json_encode(['success' => false, 'field' => 'captcha', 'message' => 'El captcha expiró. Recarga el formulario.']);
            exit;
        }

        // --- Validar campos ---
        $guestName     = trim($_POST['guest_name']      ?? '');
        $guestEmail    = trim($_POST['guest_email']     ?? '');
        $guestWhatsapp = preg_replace('/[^0-9+]/', '', $_POST['guest_whatsapp'] ?? '');
        $subject       = trim($_POST['subject']         ?? '');
        $category      = trim($_POST['category']        ?? 'general');
        $body          = Security::remove_XSS(trim($_POST['body'] ?? ''));

        if ($guestName === '') {
            echo json_encode(['success' => false, 'field' => 'guest_name', 'message' => 'Ingresa tu nombre.']);
            exit;
        }
        if ($guestEmail === '' || !filter_var($guestEmail, FILTER_VALIDATE_EMAIL)) {
            echo json_encode(['success' => false, 'field' => 'guest_email', 'message' => 'Ingresa un correo electrónico válido.']);
            exit;
        }
        if ($subject === '') {
            echo json_encode(['success' => false, 'field' => 'subject', 'message' => 'El asunto es obligatorio.']);
            exit;
        }
        if ($body === '') {
            echo json_encode(['success' => false, 'field' => 'body', 'message' => 'El mensaje es obligatorio.']);
            exit;
        }

        // --- Anti-spam básico: max 3 tickets públicos desde misma IP en 1 hora ---
        $ip = $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';
        if (!SupportManager::checkPublicRateLimit($ip)) {
            echo json_encode(['success' => false, 'message' => 'Has enviado demasiados mensajes. Intenta más tarde.']);
            exit;
        }

        // --- Crear ticket ---
        $ticketId = SupportManager::createPublicTicket([
            'guest_name'     => $guestName,
            'guest_email'    => $guestEmail,
            'guest_whatsapp' => $guestWhatsapp,
            'subject'        => $subject,
            'category'       => $category,
            'body'           => $body,
            'ip'             => $ip,
        ]);

        if ($ticketId > 0) {
            echo json_encode(['success' => true]);
        } else {
            echo json_encode(['success' => false, 'message' => 'Error al enviar el ticket. Intenta de nuevo.']);
        }
        break;

    default:
        echo json_encode(['success' => false, 'message' => 'Acción desconocida.']);
}
