<?php

use Doctrine\ORM\Query\QueryException;
use Twig\Error\LoaderError;
use Twig\Error\RuntimeError;
use Twig\Error\SyntaxError;

class SchoolPlugin extends Plugin
{
    public $twig = null;
    public $params = [];
    public $user_is_logged_in = false;
    public $title = null;

    protected function __construct()
    {
        parent::__construct(
            '1.5.0',
            'Alex Aragon <alex.aragon@tunqui.pe>',
            [
                'tool_enable' => 'boolean'
            ]
        );

        $this->isAdminPlugin = true;

        $urlId = api_get_current_access_url_id();

        $template_paths = [
            api_get_path(SYS_PLUGIN_PATH).'school/view', // plugin folder
        ];

        $cache_folder = api_get_path(SYS_ARCHIVE_PATH).'twig/'.$urlId.'/';

        if (!is_dir($cache_folder)) {
            mkdir($cache_folder, api_get_permissions_for_new_directories(), true);
        }

        $loader = new Twig_Loader_Filesystem($template_paths);

        $isTestMode = api_get_setting('server_type') === 'test';

        if ($isTestMode) {
            $options = [
                //'cache' => api_get_path(SYS_ARCHIVE_PATH), //path to the cache folder
                'autoescape' => false,
                'debug' => true,
                'auto_reload' => true,
                'optimizations' => 0,
                // turn on optimizations with -1
                'strict_variables' => false,
                //If set to false, Twig will silently ignore invalid variables
            ];
        } else {
            $options = [
                'cache' => $cache_folder,
                //path to the cache folder
                'autoescape' => false,
                'debug' => false,
                'auto_reload' => false,
                'optimizations' => -1,
                // turn on optimizations with -1
                'strict_variables' => false,
                //If set to false, Twig will silently ignore invalid variables
            ];
        }



        $this->twig = new Twig_Environment($loader, $options);

        if ($isTestMode) {
            $this->twig->addExtension(new Twig_Extension_Debug());
        }

        // Añadir la función personalizada get_svg_icon
        $this->twig->addFunction('get_svg_icon', new Twig_SimpleFunction('get_svg_icon', [$this, 'get_svg_icon']));

        $filters = [
            'var_dump',
            'get_plugin_lang',
            'get_lang',
            'api_get_path',
            'api_get_local_time',
            'api_convert_and_format_date',
            'api_is_allowed_to_edit',
            'api_get_user_info',
            'api_get_configuration_value',
            'api_get_setting',
            'api_get_plugin_setting',
            [
                'name' => 'return_message',
                'callable' => 'Display::return_message_and_translate',
            ],
            [
                'name' => 'display_page_header',
                'callable' => 'Display::page_header_and_translate',
            ],
            [
                'name' => 'display_page_subheader',
                'callable' => 'Display::page_subheader_and_translate',
            ],
            [
                'name' => 'icon',
                'callable' => 'Display::get_icon_path',
            ],
            [
                'name' => 'img',
                'callable' => 'Display::get_image',
            ],
            [
                'name' => 'format_date',
                'callable' => 'api_format_date',
            ],
            [
                'name' => 'get_template',
                'callable' => 'api_find_template',
            ],
            [
                'name' => 'date_to_time_ago',
                'callable' => 'Display::dateToStringAgoAndLongDate',
            ],
            [
                'name' => 'remove_xss',
                'callable' => 'Security::remove_XSS',
            ],
            /*[
                'name' => 'get_icon',
                'callable' => 'self::get_svg_icon',
            ]*/
        ];

        foreach ($filters as $filter) {
            if (is_array($filter)) {
                $this->twig->addFilter(new Twig_SimpleFilter($filter['name'], $filter['callable']));
            } else {
                $this->twig->addFilter(new Twig_SimpleFilter($filter, $filter));
            }
        }


        $js_file_to_string = '';
        $css[] = api_get_cdn_path(api_get_path(WEB_PLUGIN_PATH) . 'school/css/style.css');

        $css_file_to_string = null;
        foreach ($css as $file) {
            $css_file_to_string .= api_get_css($file);
        }

        $bowerJsFiles = [
            'modernizr/modernizr.js',
            'jqueryui-touch-punch/jquery.ui.touch-punch.min.js',
            'moment/min/moment-with-locales.js',
            'jquery-timeago/jquery.timeago.js',
            'mediaelement/build/mediaelement-and-player.min.js',
            'jqueryui-timepicker-addon/dist/jquery-ui-timepicker-addon.min.js',
            'image-map-resizer/js/imageMapResizer.min.js',
            'jquery.scrollbar/jquery.scrollbar.min.js',
            'readmore-js/readmore.min.js',
            'bootstrap-select/dist/js/bootstrap-select.min.js',
            'select2/dist/js/select2.min.js',
            'js-cookie/src/js.cookie.js',
        ];

        $js_file_to_string .= '<script src="'.api_get_cdn_path(api_get_path(WEB_PLUGIN_PATH).'school/vendor/jquery/jquery.min.js').'"></script>'."\n";
        $js_file_to_string .= '<script src="'.api_get_cdn_path(api_get_path(WEB_PLUGIN_PATH).'school/vendor/bootstrap/js/bootstrap.bundle.min.js').'"></script>'."\n";

        $js_file_to_string .= '<script src="'.api_get_cdn_path(api_get_path(WEB_PLUGIN_PATH).'school/vendor/jquery-easing/jquery.easing.min.js').'"></script>'."\n";


        /*foreach ($bowerJsFiles as $file) {
            $js_file_to_string .= '<script src="'.api_get_cdn_path(api_get_path(WEB_PUBLIC_PATH).'assets/'.$file).'"></script>'."\n";
        }*/

        $js_file_to_string .= '<script src="'.api_get_cdn_path(api_get_path(WEB_PLUGIN_PATH).'school/js/main.js').'"></script>'."\n";

        // Setting system variables
        $this->set_system_parameters();
        $this->set_user_parameters();
        $this->assign('title_string', $this->title);
        $this->setSidebar();
        //$this->setNavBar();


        $vendor = api_get_path(WEB_PLUGIN_PATH).'school/vendor/';
        $this->assign('assets', $vendor);
        $this->assign('js_files', $js_file_to_string);
        $this->assign('css_files', $css_file_to_string);

    }

    /**
     * @param null $title
     */
    public function setTitle($title): void
    {
        $this->title = $title;
        $this->assign('title_string', $title);
    }

    /**
     * @return null
     */
    public function getTitle()
    {
        return $this->title;
    }

    public function get_svg_icon($iconName, $altText = '', $size = 64): string
    {
        $icon_path = __DIR__ . '/img/icons/' . $iconName . '.svg';
        if (file_exists($icon_path)) {
            $iconPathWeb = api_get_path(WEB_PLUGIN_PATH).'school/img/icons/' . $iconName . '.svg';
            $img = Display::img($iconPathWeb,$altText,['width' => $size, 'height' => $size]);
        } else {
            $img = '<!-- Icono no encontrado -->';
        }
        return $img;
    }
    public function display_logo(): string
    {
        $theme = api_get_visual_theme();
        $themeDir = Template::getThemeDir($theme);
        $customLogoPathSvg = $themeDir."images/header-logo-vector.svg";
        $logoPath = api_get_path(WEB_CSS_PATH).$customLogoPathSvg;
        //var_dump($logoPath);
        $institution = api_get_setting('Institution');
        $siteName = api_get_setting('siteName');
        //$logoPath = ChamiloApi::getPlatformLogoPath();
        $imageAttributes = [
            'title' => $siteName,
            'class' => 'logo-site',
            'id' => 'header-logo',
        ];
        return Display::img($logoPath, $institution, $imageAttributes);
    }

    public function display_logo_icon(): string
    {
        $theme = api_get_visual_theme();
        $themeDir = Template::getThemeDir($theme);
        $customLogoPathSvg = $themeDir."images/header-logo-icon.svg";
        $logoPath = api_get_path(WEB_CSS_PATH).$customLogoPathSvg;
        $institution = api_get_setting('Institution');
        $siteName = api_get_setting('siteName');
        $imageAttributes = [
            'title' => $siteName,
            'class' => 'logo-site',
            'id' => 'header-icon',
        ];
        return Display::img($logoPath, $institution, $imageAttributes);
    }

    public function set_system_parameters()
    {
        // Get the interface language from global.inc.php
        global $language_interface;

        $_s = [
            'software_name' => api_get_configuration_value('software_name'),
            'system_version' => api_get_configuration_value('system_version'),
            'site_name' => api_get_setting('siteName'),
            'institution' => api_get_setting('Institution'),
            'institution_url' => api_get_setting('InstitutionUrl'),
            'date' => api_format_date('now', DATE_FORMAT_LONG),
            'timezone' => api_get_timezone(),
            'gamification_mode' => api_get_setting('gamification_mode'),
            'language_interface' => $language_interface,
        ];
        $this->assign('_s', $_s);
    }

    private function set_user_parameters()
    {
        $user_info = [];
        $user_info['logged'] = 0;
        $this->user_is_logged_in = false;
        if (api_user_is_login()) {
            $user_info = api_get_user_info(api_get_user_id(), true, false,true, true);
            $user_info['logged'] = 1;

            $user_info['is_admin'] = 0;
            if (api_is_platform_admin()) {
                $user_info['is_admin'] = 1;
            }

            $user_info['messages_count'] = MessageManager::getCountNewMessages();
            $this->user_is_logged_in = true;
        }
        // Setting the $_u array that could be use in any template
        $this->assign('_u', $user_info);
    }

    /**
     * @return string
     */
    public function getToolTitle(): string
    {
        $title = $this->get_lang('tool_title');

        if (!empty($title)) {
            return $title;
        }

        return $this->get_title();
    }

    /**
     * @return SchoolPlugin
     */
    public static function create(): SchoolPlugin
    {
        static $result = null;

        return $result ? $result : $result = new self();
    }

    public function install()
    {

    }

    public function uninstall()
    {

    }
    /**
     * @param string $variable
     * @param mixed  $value
     */
    public function assign(string $variable, $value = '')
    {
        $this->params[$variable] = $value;
    }

    public function fetch(string $template): string
    {
        $template = $this->twig->loadTemplate($template);
        return $template->render($this->params);
    }

    /**
     * @throws SyntaxError
     * @throws RuntimeError
     * @throws LoaderError
     */
    public function display($template)
    {
        echo $this->twig->render($template, $this->params);
    }
    public function find_template($name): string
    {
        return self::findTemplateFilePath($name);
    }

    public static function findTemplateFilePath($name): string
    {
        $sysTemplatePath = api_get_path(SYS_PLUGIN_PATH);
        return $sysTemplatePath."school/view/layout/$name";
    }
    /**
     * @throws RuntimeError
     * @throws SyntaxError
     * @throws LoaderError
     */
    public function display_blank_template()
    {

        $tpl = $this->twig->loadTemplate('layout/blank.tpl');
        $this->display($tpl);
    }

    public function setSidebar()
    {
        $this->assign('logo_svg', self::display_logo());
        $this->assign('logo_icon', self::display_logo_icon());
        $this->assign('menus', self::getMenus());
        $content = $this->fetch('/layout/sidebar.tpl');
        $this->assign('sidebar', $content);
    }

    public function setNavBar()
    {
        $content = $this->fetch('/layout/navbar.tpl');
        $this->assign('navbar', $content);
    }

    public function getSessionsByCategory($userID): array
    {
        $categories = null;
        $accessUrlId = api_get_current_access_url_id();
        $table_session = Database::get_main_table(TABLE_MAIN_SESSION);
        $table_session_category = Database::get_main_table(TABLE_MAIN_SESSION_CATEGORY);
        $table_session_user = Database::get_main_table(TABLE_MAIN_SESSION_USER);
        $table_access_url_session = Database::get_main_table(TABLE_MAIN_ACCESS_URL_REL_SESSION);
        $sql = "
            SELECT
                s.id,
                s.id_coach,
                s.session_category_id AS 'id_category',
                sc.name AS 'category',
                s.name,
                s.description,
                s.nbr_courses,
                s.nbr_users,
                s.display_start_date,
                s.display_end_date,
                DATE(srs.registered_at) AS 'registered_at',
                CASE
                    WHEN s.id_coach = srs.user_id THEN 'true'
                    ELSE 'false'
                END AS coach
            FROM $table_session s
            INNER JOIN $table_session_user srs ON srs.session_id = s.id
            INNER JOIN $table_session_category sc ON sc.id = s.session_category_id
            INNER JOIN $table_access_url_session aus ON aus.session_id = s.id
            WHERE srs.user_id = $userID AND aus.access_url_id = $accessUrlId;
        ";

        $result = Database::query($sql);

        if (empty($result)) {
            return [];
        }
        if (Database::num_rows($result) > 0) {
            foreach ($result as $row) {
                $courseList = self::getCoursesListBySession($userID, $row['id']);
                $row['courses'] = $courseList;
                $row['session_image'] = self::get_svg_icon('course', $row['name'],32);
                if (!isset($categories[$row['id_category']])) {
                    $nameImage = 'category_'.$row['id_category'];
                    $categories[$row['id_category']] = [
                        'category_id' => $row['id_category'],
                        'category_name' => $row['category'],
                        'category_image' => self::get_svg_icon($nameImage, $row['category'], 50),
                        'sessions' => []
                    ];
                }

                $categories[$row['id_category']]['sessions'][] = $row;
            }

        }
        return $categories;

    }

    public function getCoursesListBySession($user_id, $session_id): array
    {
        // Database Table Definitions
        $tbl_session = Database::get_main_table(TABLE_MAIN_SESSION);
        $tableCourse = Database::get_main_table(TABLE_MAIN_COURSE);
        $tbl_session_course_user = Database::get_main_table(TABLE_MAIN_SESSION_COURSE_USER);
        $tbl_session_course = Database::get_main_table(TABLE_MAIN_SESSION_COURSE);

        $user_id = (int) $user_id;
        $session_id = (int) $session_id;
        // We filter the courses from the URL
        $join_access_url = $where_access_url = '';
        if (api_get_multiple_access_url()) {
            $urlId = api_get_current_access_url_id();
            if ($urlId != -1) {
                $tbl_url_session = Database::get_main_table(TABLE_MAIN_ACCESS_URL_REL_SESSION);
                $join_access_url = " ,  $tbl_url_session url_rel_session ";
                $where_access_url = " AND access_url_id = $urlId AND url_rel_session.session_id = $session_id ";
            }
        }

        $sql = "SELECT DISTINCT
                    c.title,
                    c.visibility,
                    c.id as real_id,
                    c.code as course_code,
                    sc.id as insertion_order,
                    sc.position,
                    c.unsubscribe
                FROM $tbl_session_course_user as scu
                INNER JOIN $tbl_session_course sc
                ON (scu.session_id = sc.session_id AND scu.c_id = sc.c_id)
                INNER JOIN $tableCourse as c
                ON (scu.c_id = c.id)
                $join_access_url
                WHERE
                    scu.user_id = $user_id AND
                    scu.session_id = $session_id
                    $where_access_url ORDER BY sc.position ASC ";
        $myCourseList = [];
        $courses = [];
        $result = Database::query($sql);

        $count = 0;
        if (Database::num_rows($result) > 0) {
            while ($result_row = Database::fetch_array($result, 'ASSOC')) {
                $count++;
                $result_row['status'] = 5;
                $result_row['icon'] = self::get_svg_icon('course', $result_row['title'],32);
                $result_row['url'] = '#';
                if (!in_array($result_row['real_id'], $courses)) {
                    $position = $result_row['position'];
                    $insertionOrder = $result_row['insertion_order'];
                    if(!$position == '0'){
                        $myCourseList[$position] = $result_row;
                    } else {
                        if($count <= 1){
                            $myCourseList[0] = $result_row;
                            $myCourseList[0]['number'] = 0;
                            if($myCourseList[0]['course_code'] == 'INDUCCION'){
                                $myCourseList[0]['icon'] = self::get_svg_icon('induccion', $result_row['title'],32);
                            }

                        } else {
                            $myCourseList[$insertionOrder] = $result_row;
                            $myCourseList[$insertionOrder]['number'] = $count-1;
                        }
                    }
                }
            }
        }

        if (api_is_allowed_to_create_course()) {
            $sql = "SELECT DISTINCT
                        c.title,
                        c.visibility,
                        c.id as real_id,
                        c.code as course_code,
                        sc.id as insertion_order,
                        sc.position,
                        c.unsubscribe
                    FROM $tbl_session_course_user as scu
                    INNER JOIN $tbl_session as s
                    ON (scu.session_id = s.id)
                    INNER JOIN $tbl_session_course sc
                    ON (scu.session_id = sc.session_id AND scu.c_id = sc.c_id)
                    INNER JOIN $tableCourse as c
                    ON (scu.c_id = c.id)
                    $join_access_url
                    WHERE
                      s.id = $session_id AND
                      (
                        (scu.user_id = $user_id AND scu.status = 2) OR
                        s.id_coach = $user_id
                      )
                    $where_access_url ORDER BY sc.position ASC ";

            $result = Database::query($sql);

            if (Database::num_rows($result) > 0) {
                while ($result_row = Database::fetch_array($result, 'ASSOC')) {
                    $result_row['status'] = 2;
                    if (!in_array($result_row['real_id'], $courses)) {
                        $position = $result_row['position'];
                        if (!isset($myCourseList[$position])) {
                            $myCourseList[$position] = $result_row;
                        } else {
                            $myCourseList[] = $result_row;
                        }
                        $courses[] = $result_row['real_id'];
                    }
                }
            }
        }

        if (api_is_drh()) {
            $sessionList = SessionManager::get_sessions_followed_by_drh($user_id);
            $sessionList = array_keys($sessionList);
            if (in_array($session_id, $sessionList)) {
                $courseList = SessionManager::get_course_list_by_session_id($session_id);
                if (!empty($courseList)) {
                    foreach ($courseList as $course) {
                        if (!in_array($course['id'], $courses)) {
                            $position = $course['position'];
                            if (!isset($myCourseList[$position])) {
                                $myCourseList[$position] = $course;
                            } else {
                                $myCourseList[] = $course;
                            }
                        }
                    }
                }
            }
        } else {
            //check if user is general coach for this session
            $sessionInfo = api_get_session_info($session_id);
            if ($sessionInfo['id_coach'] == $user_id) {
                $courseList = SessionManager::get_course_list_by_session_id($session_id);
                if (!empty($courseList)) {
                    foreach ($courseList as $course) {
                        if (!in_array($course['id'], $courses)) {
                            $position = $course['position'];
                            if (!isset($myCourseList[$position])) {
                                $myCourseList[$position] = $course;
                            } else {
                                $myCourseList[] = $course;
                            }
                        }
                    }
                }
            }
        }

        if (!empty($myCourseList)) {
            ksort($myCourseList);
        }


        return $myCourseList;
    }

    private static function merge_session_data($sessionDataStudent, $sessionDataCoach): array
    {
        $sessionData = [];
        foreach (array_merge($sessionDataStudent, $sessionDataCoach) as $row) {
            $sessionData[$row['id']] = $row;
        }
        return $sessionData;
    }

    public function getMenus(): array
    {
        return [
            [
                'id' => 1,
                'label' => 'Mis Capacitaciones',
                'current' => true,
                'icon' => 'book',
                'class' => 'show',
                'items' => [
                    [
                        'id' => 101,
                        'label' => 'Actuales (3)',
                        'current' => true,
                        'class' => 'active',
                        'url' => '/capacitaciones/actuales'
                    ],
                    [
                        'id' => 102,
                        'label' => 'Anteriores (4)',
                        'current' => false,
                        'class' => '',
                        'url' => '/capacitaciones/anteriores'
                    ]
                ]
            ],
            [
                'id' => 2,
                'label' => 'Mis Notificaciones',
                'current' => false,
                'icon' => 'bell',
                'class' => '',
                'items' => [
                    [
                        'id' => 201,
                        'label' => 'No Leídas (1)',
                        'current' => false,
                        'class' => '',
                        'url' => '/notificaciones/no-leidas'
                    ],
                    [
                        'id' => 202,
                        'label' => 'Ver todas',
                        'current' => false,
                        'class' => '',
                        'url' => '/notificaciones'
                    ]
                ]
            ],
            [
                'id' => 3,
                'label' => 'Mis Certificados',
                'current' => false,
                'icon' => 'file',
                'url' => '#',
                'class' => '',
                'items' => []
            ],
            [
                'id' => 4,
                'label' => 'Solicitudes',
                'current' => false,
                'icon' => 'envelope',
                'url' => '#',
                'class' => '',
                'items' => []
            ],
            [
                'id' => 5,
                'label' => 'Ayuda',
                'current' => false,
                'icon' => 'question-circle',
                'url' => '#',
                'class' => '',
                'items' => []
            ],
            [
                'id' => 6,
                'label' => 'Comprar',
                'current' => false,
                'icon' => 'shopping-cart',
                'class' => '',
                'items' => [
                    [
                        'id' => 601,
                        'label' => 'Cursos',
                        'current' => false,
                        'class' => '',
                        'url' => '/comprar/cursos'
                    ],
                    [
                        'id' => 602,
                        'label' => 'Diplomados',
                        'current' => false,
                        'class' => '',
                        'url' => '/comprar/diplomados'
                    ]
                ]
            ]
        ];

    }
}
