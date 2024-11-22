<?php

namespace School;
class PipedriveAPI {
    private $apiToken;
    private $apiUrl;

    public function __construct($apiToken) {
        $this->apiToken = $apiToken;
        $this->apiUrl = 'https://api.pipedrive.com/v1/';
    }

    public function getDeals() {
        // Método para obtener los negocios (deals)
        $url = $this->apiUrl . 'deals?api_token=' . $this->apiToken;

        $ch = curl_init();

        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

        $response = curl_exec($ch);

        if (curl_errno($ch)) {
            echo 'Error en cURL: ' . curl_error($ch);
            curl_close($ch);
            return null;
        }

        curl_close($ch);

        $data = json_decode($response, true);

        if ($data['success']) {
            return $data['data'];
        } else {
            echo 'Error en la API: ' . ($data['error'] ?? 'Error desconocido');
            return null;
        }
    }


    public function getProjectBoards() {
        // Método para obtener los tableros de proyectos (project boards)
        $url = $this->apiUrl . 'projects/boards?api_token=' . $this->apiToken;

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

        $response = curl_exec($ch);

        if (curl_errno($ch)) {
            echo 'Error en cURL: ' . curl_error($ch);
            curl_close($ch);
            return null;
        }

        curl_close($ch);

        $data = json_decode($response, true);

        if ($data['success']) {
            return $data['data'];
        } else {
            echo 'Error en la API: ' . ($data['error'] ?? 'Error desconocido');
            return null;
        }
    }

    public function getProjectPhases($boardId) {
        // Configura la URL completa para el endpoint de project phases con el parámetro board_id
        $url = $this->apiUrl . 'projects/phases?api_token=' . $this->apiToken . '&board_id=' . $boardId;

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

        $response = curl_exec($ch);

        if (curl_errno($ch)) {
            echo 'Error en cURL: ' . curl_error($ch);
            curl_close($ch);
            return null;
        }

        curl_close($ch);
        $data = json_decode($response, true);

        if ($data['success']) {
            return $data['data'];
        } else {
            echo 'Error en la API: ' . ($data['error'] ?? 'Error desconocido');
            return null;
        }
    }
    // Método para obtener todos los proyectos
    public function getAllProjects() {
        // Configura la URL completa para el endpoint de proyectos
        $url = $this->apiUrl . 'projects?api_token=' . $this->apiToken;

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

        $response = curl_exec($ch);

        if (curl_errno($ch)) {
            echo 'Error en cURL: ' . curl_error($ch);
            curl_close($ch);
            return null;
        }

        curl_close($ch);
        $data = json_decode($response, true);

        if ($data['success']) {
            return $data['data'];
        } else {
            echo 'Error en la API: ' . ($data['error'] ?? 'Error desconocido');
            return null;
        }
    }
    // Método para añadir un nuevo proyecto
    public function addProject($params) {
        // Configura la URL completa para el endpoint de creación de proyectos
        $url = $this->apiUrl . 'projects?api_token=' . $this->apiToken;

        // Datos obligatorios para crear un proyecto
        $projectData = [
            'title' => $params['title'],
            'board_id' => intval($params['board_id']),
            'phase_id' => intval($params['phase_id']),
            'description' => $params['description']
        ];

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/json'
        ]);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($projectData));

        $response = curl_exec($ch);

        if (curl_errno($ch)) {
            echo 'Error en cURL: ' . curl_error($ch);
            curl_close($ch);
            return null;
        }

        curl_close($ch);
        $data = json_decode($response, true);

        if ($data['success']) {
            return $data['data']; // Retorna los datos del proyecto creado
        } else {
            echo 'Error en la API: ' . ($data['error'] ?? 'Error desconocido');
            return null;
        }
    }
    // Método para obtener el detalle de un proyecto específico
    public function getProjectDetails($projectId) {
        // Configura la URL completa para el endpoint de detalle de proyecto
        $url = $this->apiUrl . 'projects/' . $projectId . '?api_token=' . $this->apiToken;

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

        $response = curl_exec($ch);

        if (curl_errno($ch)) {
            echo 'Error en cURL: ' . curl_error($ch);
            curl_close($ch);
            return null;
        }

        curl_close($ch);
        $data = json_decode($response, true);

        if ($data['success']) {
            return $data['data']; // Retorna los detalles del proyecto
        } else {
            echo 'Error en la API: ' . ($data['error'] ?? 'Error desconocido');
            return null;
        }
    }

    // Método para obtener todos los grupos activos de un proyecto específico
    public function getProjectGroups($projectId) {
        // Configura la URL completa para el endpoint de grupos de proyectos
        $url = $this->apiUrl . 'projects/' . $projectId . '/groups?api_token=' . $this->apiToken;

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

        $response = curl_exec($ch);

        if (curl_errno($ch)) {
            echo 'Error en cURL: ' . curl_error($ch);
            curl_close($ch);
            return null;
        }

        curl_close($ch);
        $data = json_decode($response, true);

        if ($data['success']) {
            return $data['data']; // Retorna los grupos activos del proyecto
        } else {
            echo 'Error en la API: ' . ($data['error'] ?? 'Error desconocido');
            return null;
        }
    }

    public function getProjectActivities($projectId) {
        // Configura la URL completa para el endpoint de actividades del proyecto
        $url = $this->apiUrl . 'projects/' . $projectId . '/activities?api_token=' . $this->apiToken;

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

        $response = curl_exec($ch);

        if (curl_errno($ch)) {
            echo 'Error en cURL: ' . curl_error($ch);
            curl_close($ch);
            return null;
        }

        curl_close($ch);
        $data = json_decode($response, true);

        if ($data['success']) {
            return $data['data']; // Retorna las actividades vinculadas al proyecto
        } else {
            echo 'Error en la API: ' . ($data['error'] ?? 'Error desconocido');
            return null;
        }
    }

    // Método para obtener el plan de un proyecto específico
    public function getProjectPlan($projectId) {
        // Configura la URL completa para el endpoint de plan de proyectos
        $url = $this->apiUrl . 'projects/' . $projectId . '/plan?api_token=' . $this->apiToken;

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

        $response = curl_exec($ch);

        if (curl_errno($ch)) {
            echo 'Error en cURL: ' . curl_error($ch);
            curl_close($ch);
            return null;
        }

        curl_close($ch);
        $data = json_decode($response, true);

        if ($data['success']) {
            return $data['data']; // Retorna los elementos del plan del proyecto (tareas y actividades)
        } else {
            echo 'Error en la API: ' . ($data['error'] ?? 'Error desconocido');
            return null;
        }
    }

    // Método para subir un archivo y asociarlo a un proyecto específico
    public function addFileToProject($filePath, $projectId) {
        // Configura la URL completa para el endpoint de subida de archivos
        $url = $this->apiUrl . 'files?api_token=' . $this->apiToken;

        // Verifica que el archivo exista
        if (!file_exists($filePath)) {
            echo 'El archivo no existe en la ruta especificada.';
            return null;
        }

        // Datos para enviar en la solicitud
        $postData = [
            'file' => new \CURLFile($filePath), // Archivo en formato binario
            'activity_id' => $projectId            // ID del proyecto al que se asocia el archivo
        ];

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: multipart/form-data'
        ]);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $postData);

        $response = curl_exec($ch);

        if (curl_errno($ch)) {
            echo 'Error en cURL: ' . curl_error($ch);
            curl_close($ch);
            return null;
        }

        curl_close($ch);
        $data = json_decode($response, true);

        if ($data['success']) {
            return $data['data']; // Retorna los detalles del archivo subido
        } else {
            echo 'Error en la API: ' . ($data['error'] ?? 'Error desconocido');
            return null;
        }
    }



}
