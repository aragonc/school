<?php
/* For licensing terms, see /license.txt */

/**
 * GoogleAdminService — School Plugin
 * Integración con Google Workspace Admin Directory API v1
 * usando Service Account (JWT / RS256) y Guzzle HTTP.
 *
 * Requiere:
 *  - Credenciales de Service Account (JSON) subidas en la configuración del plugin
 *  - Domain-wide delegation habilitada en Google Admin Console
 *  - Scope: https://www.googleapis.com/auth/admin.directory.user
 *  - Impersonation de un super-admin del dominio
 */

require_once __DIR__ . '/../vendor/autoload.php';

use GuzzleHttp\Client as GuzzleClient;
use GuzzleHttp\Exception\RequestException;

class GoogleAdminService
{
    const SCOPE_DIRECTORY = 'https://www.googleapis.com/auth/admin.directory.user';
    const TOKEN_URI       = 'https://oauth2.googleapis.com/token';
    const DIRECTORY_URI   = 'https://admin.googleapis.com/admin/directory/v1';

    private array  $credentials;
    private string $impersonateEmail;
    private string $domain;
    private ?string $accessToken    = null;
    private int     $tokenExpiresAt = 0;
    private GuzzleClient $http;

    public function __construct(array $credentials, string $impersonateEmail, string $domain)
    {
        $this->credentials      = $credentials;
        $this->impersonateEmail = $impersonateEmail;
        $this->domain           = $domain;
        $this->http             = new GuzzleClient(['timeout' => 15, 'http_errors' => false]);
    }

    // ----------------------------------------------------------------
    // Construir y retornar instancia desde la configuración del plugin
    // ----------------------------------------------------------------
    public static function fromPluginSettings(SchoolPlugin $plugin): ?self
    {
        $jsonPath  = api_get_path(SYS_UPLOAD_PATH) . 'plugins/school/' .
                     ($plugin->getSchoolSetting('google_sa_json') ?: '');
        $adminEmail = trim($plugin->getSchoolSetting('google_admin_email') ?: '');
        $domain     = trim($plugin->getSchoolSetting('google_domain') ?: '');

        if (!$jsonPath || !file_exists($jsonPath) || !$adminEmail || !$domain) {
            return null;
        }

        $creds = json_decode(file_get_contents($jsonPath), true);
        if (!$creds || empty($creds['private_key'])) {
            return null;
        }

        return new self($creds, $adminEmail, $domain);
    }

    // ----------------------------------------------------------------
    // JWT → Access Token (OAuth2 service account)
    // ----------------------------------------------------------------
    private function getAccessToken(): string
    {
        if ($this->accessToken && time() < $this->tokenExpiresAt - 30) {
            return $this->accessToken;
        }

        $now = time();
        $payload = [
            'iss'   => $this->credentials['client_email'],
            'sub'   => $this->impersonateEmail,
            'scope' => self::SCOPE_DIRECTORY,
            'aud'   => self::TOKEN_URI,
            'iat'   => $now,
            'exp'   => $now + 3600,
        ];

        // Firebase JWT (disponible en el vendor de Chamilo)
        $jwtLibPath = api_get_path(SYS_PATH) . 'vendor/firebase/php-jwt/src/JWT.php';
        if (!class_exists('Firebase\\JWT\\JWT') && file_exists($jwtLibPath)) {
            require_once $jwtLibPath;
            $keyPath = dirname($jwtLibPath) . '/Key.php';
            if (file_exists($keyPath)) require_once $keyPath;
        }

        $privateKey = $this->credentials['private_key'];
        $jwt = \Firebase\JWT\JWT::encode($payload, $privateKey, 'RS256',
            $this->credentials['private_key_id'] ?? null);

        $resp = $this->http->post(self::TOKEN_URI, [
            'form_params' => [
                'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion'  => $jwt,
            ],
        ]);

        $body = json_decode((string) $resp->getBody(), true);
        if (empty($body['access_token'])) {
            throw new \RuntimeException('Error obteniendo token de Google: ' .
                ($body['error_description'] ?? $body['error'] ?? 'unknown'));
        }

        $this->accessToken    = $body['access_token'];
        $this->tokenExpiresAt = $now + (int) ($body['expires_in'] ?? 3600);
        return $this->accessToken;
    }

    // ----------------------------------------------------------------
    // Verificar si un usuario existe en Google Workspace
    // Retorna array con datos del usuario o null si no existe
    // ----------------------------------------------------------------
    public function getUser(string $email): ?array
    {
        $token = $this->getAccessToken();
        $url   = self::DIRECTORY_URI . '/users/' . urlencode($email);
        $resp  = $this->http->get($url, [
            'headers' => ['Authorization' => 'Bearer ' . $token],
        ]);

        if ($resp->getStatusCode() === 404) {
            return null;
        }
        if ($resp->getStatusCode() !== 200) {
            $body = json_decode((string) $resp->getBody(), true);
            throw new \RuntimeException('Error Google API: ' .
                ($body['error']['message'] ?? $resp->getStatusCode()));
        }
        return json_decode((string) $resp->getBody(), true);
    }

    // ----------------------------------------------------------------
    // Crear un usuario en Google Workspace
    // ----------------------------------------------------------------
    public function createUser(string $email, string $firstName, string $lastName, string $password, bool $changeAtNextLogin = true): array
    {
        $token    = $this->getAccessToken();
        $url      = self::DIRECTORY_URI . '/users';
        $body     = [
            'primaryEmail' => $email,
            'name' => [
                'givenName'  => $firstName,
                'familyName' => $lastName,
            ],
            'password'                  => $password,
            'changePasswordAtNextLogin' => $changeAtNextLogin,
            'orgUnitPath'               => '/',
        ];

        $resp = $this->http->post($url, [
            'headers' => [
                'Authorization' => 'Bearer ' . $token,
                'Content-Type'  => 'application/json',
            ],
            'body' => json_encode($body),
        ]);

        $result = json_decode((string) $resp->getBody(), true);
        if ($resp->getStatusCode() !== 200 && $resp->getStatusCode() !== 201) {
            throw new \RuntimeException('Error al crear usuario: ' .
                ($result['error']['message'] ?? $resp->getStatusCode()));
        }
        return $result;
    }

    // ----------------------------------------------------------------
    // Verificar una lista de emails — retorna ['email' => true/false]
    // ----------------------------------------------------------------
    // ----------------------------------------------------------------
    // Cambiar contraseña de un usuario en Google Workspace
    // ----------------------------------------------------------------
    public function updateUserPassword(string $email, string $newPassword, bool $changeAtNextLogin = true): void
    {
        $token = $this->getAccessToken();
        $url   = self::DIRECTORY_URI . '/users/' . urlencode($email);
        $body  = [
            'password'                  => $newPassword,
            'changePasswordAtNextLogin' => $changeAtNextLogin,
        ];

        $resp = $this->http->patch($url, [
            'headers' => [
                'Authorization' => 'Bearer ' . $token,
                'Content-Type'  => 'application/json',
            ],
            'body' => json_encode($body),
        ]);

        if ($resp->getStatusCode() !== 200) {
            $result = json_decode((string) $resp->getBody(), true);
            throw new \RuntimeException('Error al actualizar contraseña: ' .
                ($result['error']['message'] ?? $resp->getStatusCode()));
        }
    }

    // ----------------------------------------------------------------
    // Verificar una lista de emails — retorna ['email' => true/false]
    // ----------------------------------------------------------------
    public function checkMultipleUsers(array $emails): array
    {
        $results = [];
        foreach ($emails as $email) {
            try {
                $results[$email] = $this->getUser($email) !== null;
            } catch (\Exception $e) {
                $results[$email] = null; // error al verificar
            }
        }
        return $results;
    }

    public function getDomain(): string { return $this->domain; }
}
