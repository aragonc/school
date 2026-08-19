<?php
/* For licensing terms, see /license.txt */

/**
 * DocumentHelper - School Plugin
 * Helper class to manage document operations for students
 *
 * @package chamilo.plugin.school
 * @author Alex
 */

class DocumentHelper
{
    /**
     * Obtener documentos para estudiantes con filtros optimizados
     */
    public static function getStudentDocuments($courseInfo, $path, $groupId, $sessionId, $userId, $keyword = '')
    {
        $documents = DocumentManager::getAllDocumentData(
            $courseInfo,
            $path,
            $groupId,
            null,
            false, // No es editor
            !empty($keyword)
        );

        $filtered = [];
        $userIsSubscribed = CourseManager::is_user_subscribed_in_course(
            $userId,
            $courseInfo['code']
        );

        foreach ($documents as $document) {
            // Verificar visibilidad
            $isVisible = DocumentManager::is_visible_by_id(
                $document['id'],
                $courseInfo,
                $sessionId,
                $userId,
                false,
                $userIsSubscribed
            );

            // Saltar carpetas del sistema
            if (self::isSystemFolder($document['path'])) {
                continue;
            }

            // Filtrar por búsqueda si existe
            if (!empty($keyword)) {
                $title = $document['title'] ?: basename($document['path']);
                if (stripos($title, $keyword) === false) {
                    continue;
                }
            }

            // Preparar datos del documento
            $docData = [
                'id' => $document['id'],
                'title' => self::getDocumentTitle($document),
                'path' => $document['path'],
                'filetype' => $document['filetype'],
                'size' => $document['size'],
                'size_formatted' => format_file_size($document['size']),
                'comment' => $document['comment'],
                'lastedit_date' => $document['lastedit_date'],
                'lastedit_date_formatted' => api_get_local_time($document['lastedit_date']),
                'lastedit_date_ago' => date_to_str_ago($document['lastedit_date']),
                'is_visible' => $isVisible,
                'is_folder' => $document['filetype'] === 'folder',
                'extension' => strtolower(pathinfo($document['path'], PATHINFO_EXTENSION)),
                'icon' => self::getDocumentIcon($document),
                'url' => self::getDocumentUrl($document, $courseInfo),
                'download_url' => self::getDownloadUrl($document['id']),
            ];

            // Agregar información de sesión si aplica
            if (!empty($document['session_id'])) {
                $docData['session_img'] = api_get_session_image(
                    $document['session_id'],
                    api_get_user_info()['status']
                );
            }

            $filtered[] = $docData;
        }

        // Ordenar: carpetas primero, luego por nombre
        usort($filtered, function($a, $b) {
            if ($a['is_folder'] && !$b['is_folder']) return -1;
            if (!$a['is_folder'] && $b['is_folder']) return 1;
            return strcasecmp($a['title'], $b['title']);
        });

        return [
            'documents' => $filtered,
            'total' => count($filtered),
        ];
    }

    /**
     * Obtener el session_id al que pertenece un documento.
     *
     * Útil cuando el enlace de la carpeta llega sin id_session (sesión
     * perdida/expirada) y necesitamos recuperar la sesión real del documento
     * para resolverlo y verificar su visibilidad.
     *
     * @return int session_id del documento (0 si es del curso base o no existe)
     */
    public static function getDocumentSessionId($documentId, $courseInfo)
    {
        $documentTable = Database::get_course_table(TABLE_DOCUMENT);
        $documentId = (int) $documentId;
        $courseId = (int) $courseInfo['real_id'];

        if (empty($documentId) || empty($courseId)) {
            return 0;
        }

        $sql = "SELECT session_id FROM $documentTable
                WHERE c_id = $courseId AND id = $documentId";
        $result = Database::query($sql);

        if ($result && Database::num_rows($result) > 0) {
            $row = Database::fetch_array($result, 'ASSOC');

            return (int) $row['session_id'];
        }

        return 0;
    }

    /**
     * Obtener título del documento
     */
    private static function getDocumentTitle($document)
    {
        $title = $document['title'] ?: basename($document['path']);

        if (api_get_configuration_value('save_titles_as_html')) {
            $title = strip_tags($title);
        }

        return $title;
    }

    /**
     * Verificar si es carpeta del sistema
     */
    private static function isSystemFolder($path)
    {
        $systemFolders = [
            '/audio',
            '/flash',
            '/images',
            '/shared_folder',
            '/video',
            '/chat_files',
            '/certificates',
        ];

        foreach ($systemFolders as $folder) {
            if (strpos($path, $folder) === 0) {
                return true;
            }
        }

        return false;
    }

    /**
     * Obtener icono del documento
     */
    private static function getDocumentIcon($document)
    {
        if ($document['filetype'] === 'folder') {
            return 'folder.png';
        }

        if ($document['filetype'] === 'link') {
            return 'link.png';
        }

        $extension = strtolower(pathinfo($document['path'], PATHINFO_EXTENSION));

        $iconMap = [
            // Documentos
            'pdf' => 'pdf.png',
            'doc' => 'word.png',
            'docx' => 'word.png',
            'odt' => 'word.png',

            // Hojas de cálculo
            'xls' => 'excel.png',
            'xlsx' => 'excel.png',
            'ods' => 'excel.png',
            'csv' => 'excel.png',

            // Presentaciones
            'ppt' => 'powerpoint.png',
            'pptx' => 'powerpoint.png',
            'odp' => 'powerpoint.png',

            // Comprimidos
            'zip' => 'archive.png',
            'rar' => 'archive.png',
            '7z' => 'archive.png',
            'tar' => 'archive.png',
            'gz' => 'archive.png',

            // Imágenes
            'jpg' => 'image.png',
            'jpeg' => 'image.png',
            'png' => 'image.png',
            'gif' => 'image.png',
            'bmp' => 'image.png',
            'svg' => 'image.png',
            'ico' => 'image.png',

            // Videos
            'mp4' => 'video.png',
            'avi' => 'video.png',
            'mov' => 'video.png',
            'wmv' => 'video.png',
            'flv' => 'video.png',
            'mkv' => 'video.png',
            'webm' => 'video.png',

            // Audio
            'mp3' => 'audio.png',
            'wav' => 'audio.png',
            'ogg' => 'audio.png',
            'wma' => 'audio.png',
            'm4a' => 'audio.png',
            'flac' => 'audio.png',

            // Código
            'html' => 'code.png',
            'htm' => 'code.png',
            'php' => 'code.png',
            'js' => 'code.png',
            'css' => 'code.png',
            'xml' => 'code.png',
            'json' => 'code.png',
            'sql' => 'code.png',

            // Texto
            'txt' => 'text.png',
            'md' => 'text.png',
            'rtf' => 'text.png',
        ];

        return $iconMap[$extension] ?? 'file.png';
    }

    /**
     * Obtener URL del documento
     */
    private static function getDocumentUrl($document, $courseInfo)
    {
        if ($document['filetype'] === 'folder') {
            // URL amigable para carpetas
            $useRewriteUrl = api_get_configuration_value('use_friendly_document_urls');
            if ($useRewriteUrl) {
                return api_get_path(WEB_PATH) . 'documents?' . api_get_cidreq() . '&id=' . $document['id'];
            }
            return api_get_self() . '?' . api_get_cidreq() . '&id=' . $document['id'];
        }

        if ($document['filetype'] === 'link') {
            return $document['comment']; // El comment contiene la URL del enlace cloud
        }

        return api_get_path(WEB_COURSE_PATH) . $courseInfo['path'] . '/document' . $document['path'];
    }

    /**
     * Obtener URL de descarga
     */
    private static function getDownloadUrl($documentId)
    {
        $useRewriteUrl = api_get_configuration_value('use_friendly_document_urls');
        if ($useRewriteUrl) {
            return api_get_path(WEB_PATH) . 'documents?' . api_get_cidreq() . '&action=download&id=' . $documentId;
        }
        return api_get_self() . '?' . api_get_cidreq() . '&action=download&id=' . $documentId;
    }

    /**
     * Manejar descarga de archivo
     */
    public static function handleDownload($documentId, $courseInfo, $sessionId, $userId, $baseWorkDir)
    {
        // Obtener datos del documento
        $documentData = DocumentManager::get_document_data_by_id(
            $documentId,
            $courseInfo['code'],
            false,
            $sessionId
        );

        if (!$documentData && $sessionId != 0) {
            $documentData = DocumentManager::get_document_data_by_id(
                $documentId,
                $courseInfo['code'],
                false,
                0
            );
        }

        if (empty($documentData)) {
            api_not_allowed(true);
        }

        // Verificar visibilidad
        if (!DocumentManager::is_visible_by_id($documentId, $courseInfo, $sessionId, $userId)) {
            api_not_allowed(true);
        }

        // Registrar descarga
        Event::event_download($documentData['url']);

        // Enviar archivo
        $fullFileName = $baseWorkDir . $documentData['path'];
        if (Security::check_abs_path($fullFileName, $baseWorkDir . '/')) {
            $result = DocumentManager::file_send_for_download($fullFileName, true);
            if ($result === false) {
                api_not_allowed(true);
            }
        }
    }

    /**
     * Manejar descarga de carpeta
     */
    public static function handleFolderDownload($documentId, $courseInfo, $sessionId, $userId)
    {
        $documentId = (int) $documentId;

        // Carpeta raiz: no existe fila en c_document para '/'. downloadfolder.inc.php
        // ya soporta este caso (path '/' -> documents.zip), solo necesita id vacio.
        if (empty($documentId)) {
            $_GET['id'] = 0;
            $_REQUEST['id'] = 0;
            self::streamFolderZip();

            return;
        }

        // Obtener datos del documento
        $documentData = DocumentManager::get_document_data_by_id(
            $documentId,
            $courseInfo['code'],
            false,
            $sessionId
        );

        if (!$documentData && $sessionId != 0) {
            $documentData = DocumentManager::get_document_data_by_id(
                $documentId,
                $courseInfo['code'],
                false,
                0
            );
        }

        if (empty($documentData)) {
            api_not_allowed(true);
        }

        // Asegurar la sesión correcta del documento. downloadfolder.inc.php usa
        // api_get_session_id() internamente para filtrar los archivos; si el
        // enlace llegó sin id_session (sesión perdida/expirada) la consulta
        // excluye los documentos de sesión y el ZIP sale vacío. Si el documento
        // pertenece a una sesión y el contexto actual la perdió, la reinyectamos
        // en la sesión de Chamilo (api_get_session_id() lee de ahí, no de $_GET).
        if (api_get_session_id() == 0) {
            $documentSessionId = self::getDocumentSessionId($documentData['iid'] ?? $documentData['id'], $courseInfo);
            if (!empty($documentSessionId)) {
                ChamiloSession::write('id_session', (int) $documentSessionId);
                $_GET['id_session'] = (int) $documentSessionId;
                $_REQUEST['id_session'] = (int) $documentSessionId;
            }
        }

        // Verificar si es carpeta compartida del usuario o si tiene acceso
        if (DocumentManager::is_any_user_shared_folder($documentData['path'], $sessionId)) {
            if (!DocumentManager::is_my_shared_folder($userId, $documentData['path'], $sessionId)) {
                api_not_allowed(true);
            }
        }

        // downloadfolder.inc.php lee exclusivamente $_GET['id']; si llegamos aqui
        // por POST o con el id resuelto via fallback de sesion, hay que fijarlo.
        $_GET['id'] = $documentId;
        $_REQUEST['id'] = $documentId;

        // Registrar descarga
        Event::event_download($documentData['url']);

        self::streamFolderZip();
    }

    /**
     * Incluye downloadfolder.inc.php limpiando cualquier salida previa.
     *
     * El plugin ya emitio cabeceras/HTML (config.php, layout, avisos de PHP)
     * antes de llegar aqui. file_send_for_download() envia cabeceras binarias,
     * asi que cualquier byte pendiente en el buffer corrompe el ZIP.
     */
    private static function streamFolderZip()
    {
        while (ob_get_level() > 0) {
            ob_end_clean();
        }

        // Evitar que warnings/deprecations se mezclen en el stream binario.
        @ini_set('display_errors', '0');

        require_once api_get_path(SYS_CODE_PATH) . 'document/downloadfolder.inc.php';
        exit;
    }

    /**
     * Obtener breadcrumb de navegación
     */
    public static function getBreadcrumb($currentDocument, $documentId, $groupId)
    {
        $breadcrumb = [];

        // Agregar inicio
        $breadcrumb[] = [
            'url' => api_get_self() . '?' . api_get_cidreq(),
            'name' => get_lang('Documents'),
            'active' => false,
        ];

        if (empty($currentDocument['parents'])) {
            if ($currentDocument && $currentDocument['filetype'] !== 'link') {
                $breadcrumb[] = [
                    'url' => '#',
                    'name' => $currentDocument['title'],
                    'active' => true,
                ];
            }
        } else {
            $counter = 0;
            foreach ($currentDocument['parents'] as $parent) {
                // Saltar primera carpeta de grupo en breadcrumb
                if ($groupId && $counter == 0) {
                    $counter++;
                    continue;
                }

                $isLast = ($parent['id'] == $currentDocument['id']);

                $breadcrumb[] = [
                    'url' => $isLast ? '#' : $parent['document_url'],
                    'name' => $parent['title'],
                    'active' => $isLast,
                ];

                $counter++;
            }
        }

        return $breadcrumb;
    }

    /**
     * Calcular tamaño de carpeta
     */
    public static function getFolderSize($path, $courseInfo)
    {
        $baseWorkDir = api_get_path(SYS_COURSE_PATH) . $courseInfo['directory'] . '/document';
        $fullPath = $baseWorkDir . $path;

        if (!is_dir($fullPath)) {
            return 0;
        }

        $size = 0;
        $iterator = new RecursiveIteratorIterator(
            new RecursiveDirectoryIterator($fullPath, RecursiveDirectoryIterator::SKIP_DOTS)
        );

        foreach ($iterator as $file) {
            if ($file->isFile()) {
                $size += $file->getSize();
            }
        }

        return $size;
    }
}
