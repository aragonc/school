<?php

require_once 'src/PipedriveAPI.php';

use Chamilo\CoreBundle\Entity\Session;
use Twig\Error\LoaderError;
use Twig\Error\RuntimeError;
use Twig\Error\SyntaxError;
use Endroid\QrCode\ErrorCorrectionLevel;
use Endroid\QrCode\QrCode;
use Picqer\Barcode\BarcodeGeneratorPNG;

class SchoolPlugin extends Plugin
{
    public $twig = null;
    public $params = [];
    public $user_is_logged_in = false;
    public $title = null;
    public $currentSection = null;
    public $show_sidebar = true;
    public $show_header = true;

    const TABLE_SCHOOL_REQUEST = 'plugin_school_request';
    const TABLE_SCHOOL_SETTINGS = 'plugin_school_settings';
    const TABLE_SHORTIFY_TAGS = 'plugin_shortify_tags';
    const TABLE_SHORTIFY_URL_TAGS = 'plugin_shortify_url_tags';
    const TABLE_SHORTIFY_URL = 'plugin_shortify_urls';
    const TABLE_BUYCOURSE_ITEM = 'plugin_buycourses_item';

    const TEMPLATE_ZERO = 0;
    const INTERFACE_ONE = 1;
    protected function __construct()
    {
        parent::__construct(
            '1.5.0',
            'Alex Aragon <alex.aragon@tunqui.pe>',
            $this->extendAttributes([
                'tool_enable' => 'boolean',
                'api_token_pipedrive' => 'text',
                'activate_search' => 'boolean',
                'activate_shopping' => 'boolean',
                'email_help' => 'text',
                'enable_complete_profile' => 'boolean',
                'show_base_courses' => 'boolean',
                'show_certificates' => 'boolean',
                'show_previous_tab' => 'boolean',
                'template_certificate' => [
                    'type' => 'select',
                    'options' => [
                        self::TEMPLATE_ZERO => 'Plantilla por defecto',
                        self::INTERFACE_ONE => 'Plantilla Sence',
                    ],
                ]
            ])
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
            ]
        ];

        foreach ($filters as $filter) {
            if (is_array($filter)) {
                $this->twig->addFilter(new Twig_SimpleFilter($filter['name'], $filter['callable']));
            } else {
                $this->twig->addFilter(new Twig_SimpleFilter($filter, $filter));
            }
        }

        $js_file_to_string = '';

        $js_file_to_string .= '<script src="'.api_get_cdn_path(api_get_path(WEB_PLUGIN_PATH).'school/assets/jquery/jquery.min.js').'"></script>'."\n";
        $js_file_to_string .= '<script src="'.api_get_cdn_path(api_get_path(WEB_PLUGIN_PATH).'school/assets/jquery/jquery-ui.min.js').'"></script>'."\n";
        $js_file_to_string .= '<script src="'.api_get_cdn_path(api_get_path(WEB_PLUGIN_PATH).'school/assets/popper/popper.min.js').'"></script>'."\n";
        $js_file_to_string .= '<script src="'.api_get_cdn_path(api_get_path(WEB_PLUGIN_PATH).'school/assets/bootstrap/js/bootstrap.bundle.min.js').'"></script>'."\n";
        $js_file_to_string .= '<script src="'.api_get_cdn_path(api_get_path(WEB_PLUGIN_PATH).'school/assets/jquery-easing/jquery.easing.min.js').'"></script>'."\n";

        $css[] = api_get_cdn_path(api_get_path(WEB_PLUGIN_PATH) . 'school/css/style.css');

        $css_file_to_string = null;
        foreach ($css as $file) {
            $css_file_to_string .= api_get_css($file);
        }

        $this->set_js_files();

        // Setting system variables
        $this->set_system_parameters();
        $this->set_user_parameters();
        //$this->setSidebar();
        $this->assign('flash_messages', Display::getFlashToString());
        Display::cleanFlashMessages();
        $breadCrumb = $this->getBreadCrumb();

        $vendor = api_get_path(WEB_PLUGIN_PATH).'school/assets/';
        $imageFolder = api_get_path(WEB_PLUGIN_PATH).'school/img/icons/';

        $this->assign('administrator_mail', api_get_setting('emailAdministrator'));
        $this->assign('breadcrumb', $breadCrumb);
        $this->assign('image_url', $imageFolder);
        $this->assign('assets', $vendor);
        $this->assign('js_files', $js_file_to_string);
        $this->assign('css_files', $css_file_to_string);
        $this->assign('logout_link', api_get_path(WEB_PATH).'index.php?logout=logout&uid='.api_get_user_id());

    }

    /**
     * @param array $attributes Los atributos iniciales.
     * @return array Los atributos modificados.
     */
    private function extendAttributes(array $attributes): array
    {
        // Verificar si el atributo 'api_token_pipedrive' tiene un valor
        if (!empty($this->get('api_token_pipedrive'))) {
            $boardsList = $phasesList = [];
            $apiToken = $this->get('api_token_pipedrive');
            $pipedriveAPI = new School\PipedriveAPI($apiToken);
            $projectBoards = $pipedriveAPI->getProjectBoards();

            if ($projectBoards !== null) {
                $boardsList = array_combine(
                    array_column($projectBoards, 'id'),
                    array_column($projectBoards, 'name')
                );
            }
            $idBoard = $this->get('board_pipedrive');

            $projectPhases = $pipedriveAPI->getProjectPhases($idBoard);

            if ($projectPhases !== null) {
                $phasesList = array_combine(
                    array_column($projectPhases, 'id'),
                    array_column($projectPhases, 'name')
                );
            }

            // Agregar atributos adicionales
            $attributes['board_pipedrive'] = [
                'type' => 'select',
                'options' => $boardsList,
            ];
            $attributes['phase_pipedrive'] = [
                'type' => 'select',
                'options' => $phasesList,
            ];
        }

        return $attributes;
    }

    public function isShowSidebar(): bool
    {
        return $this->show_sidebar;
    }

    public function setShowSidebar($show_sidebar = true): void
    {
        $this->show_sidebar = $show_sidebar;
        $this->assign('show_sidebar', $this->show_sidebar);
    }

    public function isShowHeader(): bool
    {
        return $this->show_header;
    }

    public function setShowHeader($show_header = true): void
    {
        $this->show_header = $show_header;
        $this->assign('show_header', $this->show_header);
    }

    /**
     * @return mixed
     */
    public function getCurrentSection()
    {
        return $this->currentSection;
    }

    /**
     * @param mixed $currentSection
     */
    public function setCurrentSection($currentSection): void
    {
        $this->currentSection = $currentSection;
    }


    /**
     * @param null $title
     */
    public function setTitle($title): void
    {
        $this->title = $title;
        $this->assign('title_string', $this->title);

    }

    /**
     * @param null $form
     */
    public function setFilter($form): void
    {
        $this->assign('form_filter', $form);

    }

    public function set_js_extras($htmlExtras): string
    {
        $extraHeaders = '';
        if (isset($htmlExtras) && $htmlExtras) {
            foreach ($htmlExtras as &$this_html_head) {
                $extraHeaders .= $this_html_head."\n";
            }
        }
        return $extraHeaders;
    }
    public function set_js_files(): void
    {
        global $disable_js_and_css_files, $htmlHeadXtra;
        $isoCode = api_get_language_isocode();
        $selectLink = 'bootstrap-select/dist/js/i18n/defaults-'.$isoCode.'_'.strtoupper($isoCode).'.min.js';

        if ($isoCode == 'en') {
            $selectLink = 'bootstrap-select/dist/js/i18n/defaults-'.$isoCode.'_US.min.js';
        }
        // JS files
        $js_files = [
            'chosen/chosen.jquery.min.js',
            'mediaelement/plugins/vrview/vrview.js',
            'mediaelement/plugins/markersrolls/markersrolls.min.js',
        ];

        if (api_get_setting('accessibility_font_resize') === 'true') {
            $js_files[] = 'fontresize.js';
        }

        $js_file_to_string = '';
        $bowerJsFiles = [
            'modernizr/modernizr.js',
            'jqueryui-touch-punch/jquery.ui.touch-punch.min.js',
            'moment/min/moment-with-locales.js',
            'bootstrap-daterangepicker/daterangepicker.js',
            'jquery-timeago/jquery.timeago.js',
            'mediaelement/build/mediaelement-and-player.min.js',
            'jqueryui-timepicker-addon/dist/jquery-ui-timepicker-addon.min.js',
            'image-map-resizer/js/imageMapResizer.min.js',
            'jquery.scrollbar/jquery.scrollbar.min.js',
            'readmore-js/readmore.min.js',
            'bootstrap-select/dist/js/bootstrap-select.min.js',
            $selectLink,
            'select2/dist/js/select2.min.js',
            "select2/dist/js/i18n/$isoCode.js",
            'js-cookie/src/js.cookie.js',
        ];

        $features = api_get_configuration_value('video_features');
        if (!empty($features) && isset($features['features'])) {
            foreach ($features['features'] as $feature) {
                if ($feature === 'vrview') {
                    continue;
                }
                $js_files[] = "mediaelement/plugins/$feature/$feature.min.js";
            }
        }

        if (CHAMILO_LOAD_WYSIWYG === true) {
            $bowerJsFiles[] = 'ckeditor/ckeditor.js';
        }

        if (api_get_setting('include_asciimathml_script') === 'true') {
            $bowerJsFiles[] = 'MathJax/MathJax.js?config=TeX-MML-AM_HTMLorMML';
        }

        // If not English and the language is supported by timepicker, localize
        $assetsPath = api_get_path(SYS_PUBLIC_PATH).'assets/';
        if ($isoCode != 'en') {
            if (is_file($assetsPath.'jqueryui-timepicker-addon/dist/i18n/jquery-ui-timepicker-'.$isoCode.'.js') && is_file($assetsPath.'jquery-ui/ui/minified/i18n/datepicker-'.$isoCode.'.min.js')) {
                $bowerJsFiles[] = 'jqueryui-timepicker-addon/dist/i18n/jquery-ui-timepicker-'.$isoCode.'.js';
                $bowerJsFiles[] = 'jquery-ui/ui/minified/i18n/datepicker-'.$isoCode.'.min.js';
            }
        }

        foreach ($bowerJsFiles as $file) {
            $js_file_to_string .= '<script src="'.api_get_cdn_path(api_get_path(WEB_PUBLIC_PATH).'assets/'.$file).'"></script>'."\n";
        }

        foreach ($js_files as $file) {
            $js_file_to_string .= api_get_js($file);
        }

        if (!$disable_js_and_css_files) {
            $this->assign('js_file_to_string', $js_file_to_string);

            $extraHeaders = '<script>var _p = '.json_encode($this->getWebPaths(), JSON_PRETTY_PRINT).'</script>';
            // Adding jquery ui by default
            $extraHeaders .= api_get_jquery_ui_js();
            if (isset($htmlHeadXtra) && $htmlHeadXtra) {
                foreach ($htmlHeadXtra as &$this_html_head) {
                    $extraHeaders .= $this_html_head."\n";
                }
            }
            $ajax = api_get_path(WEB_AJAX_PATH);
            $courseId = api_get_course_id();
            if (empty($courseId)) {
                $courseLogoutCode = '
                <script>
                function courseLogout() {
                }
                </script>';
            } else {
                $courseLogoutCode = "
                <script>
                var logOutUrl = '".$ajax."course.ajax.php?a=course_logout&".api_get_cidreq()."';
                function courseLogout() {
                    $.ajax({
                        async : false,
                        url: logOutUrl,
                        success: function (data) {
                            return 1;
                        }
                    });
                }
                </script>";
            }

            $extraHeaders .= $courseLogoutCode;
            $this->assign('extra_headers', $extraHeaders);
            $this->assign('favicon', self::get_favicon('favicon'));
        }
    }

    public function get_favicon($iconName): string
    {
        $iconPathWeb = '';
        $icon_path = __DIR__ . '/img/icons/' . $iconName . '.svg';
        if (file_exists($icon_path)) {
            $iconPathWeb = api_get_path(WEB_PLUGIN_PATH).'school/img/icons/' . $iconName . '.svg';
        }
        return $iconPathWeb;
    }
    public function get_svg_icon($iconName, $altText = '', $size = 64, $responsive = false, $type = 'svg'): string
    {
        $icon_path = __DIR__ . '/img/icons/' . $iconName . '.' . $type;
        if (file_exists($icon_path)) {
            $iconPathWeb = api_get_path(WEB_PLUGIN_PATH).'school/img/icons/' . $iconName . '.' . $type;
            $attrib = null;
            if(!$responsive){
                $attrib = ['width' => $size, 'height' => $size, 'class' => 'img-fluid'];
            } else {
                $attrib = ['width' => $size, 'height' => $size];
            }
            $img = Display::img($iconPathWeb,$altText, $attrib);
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

    private function getWebPaths(): array
    {
        $queryString = empty($_SERVER['QUERY_STRING']) ? '' : $_SERVER['QUERY_STRING'];
        $requestURI = empty($_SERVER['REQUEST_URI']) ? '' : $_SERVER['REQUEST_URI'];

        return [
            'web' => api_get_path(WEB_PATH),
            'web_url' => api_get_web_url(),
            'web_relative' => api_get_path(REL_PATH),
            'web_course' => api_get_path(WEB_COURSE_PATH),
            'web_main' => api_get_path(WEB_CODE_PATH),
            'web_css' => api_get_path(WEB_CSS_PATH),
            /*'web_css_theme' => api_get_path(WEB_CSS_PATH),*/
            'web_ajax' => api_get_path(WEB_AJAX_PATH),
            'web_img' => api_get_path(WEB_IMG_PATH),
            'web_plugin' => api_get_path(WEB_PLUGIN_PATH),
            'web_lib' => api_get_path(WEB_LIBRARY_PATH),
            'web_upload' => api_get_path(WEB_UPLOAD_PATH),
            'web_self' => api_get_self(),
            'self_basename' => basename(api_get_self()),
            'web_query_vars' => api_htmlentities($queryString),
            'web_self_query_vars' => api_htmlentities($requestURI),
            'web_cid_query' => api_get_cidreq(),
            'web_rel_code' => api_get_path(REL_CODE_PATH),
        ];
    }

    public function set_system_parameters(): void
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
        $this->assign('_p', $this->getWebPaths());
        $this->assign('_s', $_s);
    }

    private function set_user_parameters(): void
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
        $sql = "CREATE TABLE IF NOT EXISTS ".self::TABLE_SCHOOL_REQUEST." (
            id INT unsigned NOT NULL auto_increment PRIMARY KEY,
            title VARCHAR(250) NULL,
            board_id INT NULL NOT NULL,
            phase_id INT NULL NOT NULL,
            description MEDIUMTEXT NULL,
            session_id INT NULL NOT NULL,
            start_time DATETIME NULL,
            end_time DATETIME NULL,
            activate INT
        )";
        Database::query($sql);

        $sql2 = "CREATE TABLE IF NOT EXISTS ".self::TABLE_SCHOOL_SETTINGS." (
            id INT unsigned NOT NULL auto_increment PRIMARY KEY,
            variable VARCHAR(255) NOT NULL,
            value TEXT NULL,
            UNIQUE KEY unique_variable (variable)
        )";
        Database::query($sql2);

        // Add rewrite rules to .htaccess
        $this->addHtaccessRules();
    }

    public function uninstall()
    {
        $tablesToBeDeleted = [
            self::TABLE_SCHOOL_SETTINGS,
        ];

        foreach ($tablesToBeDeleted as $tableToBeDeleted) {
            $table = Database::get_main_table($tableToBeDeleted);
            $sql = "DROP TABLE IF EXISTS $table";
            Database::query($sql);
        }

        // Remove rewrite rules from .htaccess
        $this->removeHtaccessRules();
    }

    /**
     * Get the rewrite rules for the School plugin.
     */
    private function getHtaccessRules(): string
    {
        return
            "# BEGIN School Plugin\n".
            "RewriteRule ^dashboard$ plugin/school/start.php [L]\n".
            "RewriteRule ^previous$ plugin/school/previous.php [L]\n".
            "RewriteRule ^certified$ plugin/school/certificates.php [L]\n".
            "RewriteRule ^notifications$ plugin/school/notifications.php [L]\n".
            "RewriteRule ^profile$ plugin/school/profile.php [L]\n".
            "RewriteRule ^avatar$ plugin/school/avatar.php [L]\n".
            "RewriteRule ^password$ plugin/school/password.php [L]\n".
            "RewriteRule ^requests$ plugin/school/requests.php [L]\n".
            "RewriteRule ^shopping$ plugin/school/shopping.php [L]\n".
            "RewriteRule ^help$ plugin/school/help.php [L]\n".
            "RewriteRule ^school-admin$ plugin/school/admin.php [L]\n".
            "RewriteRule ^documents$ plugin/school/student_documents.php?%{QUERY_STRING} [L,QSA]\n".
            "RewriteRule ^view/course/(\\d{1,})$ plugin/school/view.php?session_id=$1 [L]\n".
            "RewriteRule ^home/course/([^/]+)$ plugin/school/home.php?cDir=$1 [L]\n".
            "RewriteRule ^reset/token/([^/]+)$ plugin/school/reset.php?token=$1 [L]\n".
            "# END School Plugin";
    }

    /**
     * Add School plugin rewrite rules to .htaccess.
     */
    private function addHtaccessRules(): bool
    {
        $htaccessPath = api_get_path(SYS_PATH).'.htaccess';

        if (!file_exists($htaccessPath) || !is_writable($htaccessPath)) {
            return false;
        }

        $content = file_get_contents($htaccessPath);

        // Already added
        if (strpos($content, '# BEGIN School Plugin') !== false) {
            return true;
        }

        $rules = $this->getHtaccessRules();

        // Insert after the certificates rewrite rule block
        $marker = "RewriteRule ^certificates/$ certificates/index.php?id=%1 [L]\n";
        $pos = strpos($content, $marker);

        if ($pos !== false) {
            $insertPos = $pos + strlen($marker);
            $content = substr($content, 0, $insertPos)."\n".$rules."\n".substr($content, $insertPos);
        } else {
            // Fallback: insert after RewriteEngine on
            $marker2 = "RewriteEngine on\n";
            $pos2 = strpos($content, $marker2);
            if ($pos2 !== false) {
                $insertPos = $pos2 + strlen($marker2);
                $content = substr($content, 0, $insertPos)."\n".$rules."\n".substr($content, $insertPos);
            } else {
                return false;
            }
        }

        return file_put_contents($htaccessPath, $content) !== false;
    }

    /**
     * Remove School plugin rewrite rules from .htaccess.
     */
    private function removeHtaccessRules(): bool
    {
        $htaccessPath = api_get_path(SYS_PATH).'.htaccess';

        if (!file_exists($htaccessPath) || !is_writable($htaccessPath)) {
            return false;
        }

        $content = file_get_contents($htaccessPath);

        // Remove the block between markers including surrounding blank lines
        $pattern = '/\n?# BEGIN School Plugin\n.*?# END School Plugin\n?/s';
        $content = preg_replace($pattern, "\n", $content);

        return file_put_contents($htaccessPath, $content) !== false;
    }

    /**
     * Get a setting from the plugin_school_settings table.
     */
    public function getSchoolSetting(string $variable): ?string
    {
        $table = self::TABLE_SCHOOL_SETTINGS;
        $variable = Database::escape_string($variable);
        $sql = "SELECT value FROM $table WHERE variable = '$variable' LIMIT 1";
        $result = Database::query($sql);
        if ($row = Database::fetch_assoc($result)) {
            return $row['value'];
        }
        return null;
    }

    /**
     * Save or update a setting in the plugin_school_settings table.
     */
    public function setSchoolSetting(string $variable, ?string $value): void
    {
        $table = self::TABLE_SCHOOL_SETTINGS;
        $variable = Database::escape_string($variable);
        $value = Database::escape_string($value ?? '');
        $sql = "INSERT INTO $table (variable, value) VALUES ('$variable', '$value')
                ON DUPLICATE KEY UPDATE value = '$value'";
        Database::query($sql);
    }

    /**
     * Get the custom logo URL, or null if not set.
     */
    public function getCustomLogo(): ?string
    {
        $logo = $this->getSchoolSetting('custom_logo');
        if (!empty($logo)) {
            $fullPath = api_get_path(SYS_UPLOAD_PATH).'plugins/school/'.$logo;
            if (file_exists($fullPath)) {
                return api_get_path(WEB_UPLOAD_PATH).'plugins/school/'.$logo;
            }
        }
        return null;
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

    /**
     * Call non-static for self::findTemplateFilePath.
     *
     * @see self::findTemplateFilePath()
     *
     * @param string $name
     *
     * @return string
     */
    public function get_template($name): string
    {
        return self::find_template($name);
    }
    /**
     * @throws Exception
     */
    public function find_template($name): string
    {
        return self::findTemplateFilePath($name);
    }

    /**
     * Returns the sub-folder and filename for the given tpl file.
     * @param string $name
     *
     * @return string
     */
    public static function findTemplateFilePath($name)
    {
        if (empty($name)) {
            throw new Exception('Template name cannot be empty');
        }

        $sysTemplatePath = api_get_path(SYS_PLUGIN_PATH);
        $filePath = $sysTemplatePath . "school/view/$name";

        if (file_exists($filePath)) {
            return $filePath;
        } else {
            throw new Exception("Template file not found: $filePath");
        }
    }

    public function getBreadCrumb(): string
    {
        global $interbreadcrumb, $language_file;
        $nameTools = $this->title;
        $breadcrumb = return_breadcrumb(
            $interbreadcrumb,
            $language_file,
            $nameTools
        );

        return $breadcrumb;
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

    public function display_none_template()
    {

        $tpl = $this->twig->loadTemplate('layout/none.tpl');
        $this->display($tpl);
    }

    public function setSidebar($section = '')
    {
        $institution = api_get_setting('Institution');
        $theme = api_get_visual_theme();
        $themeDir = Template::getThemeDir($theme);
        $logoPath = api_get_path(WEB_CSS_PATH).$themeDir."images/header-logo-vector.svg";
        $siteName = api_get_setting('siteName');
        $imageAttributes = [
            'title' => $siteName,
            'class' => 'logo-site',
            'id' => 'header-logo',
        ];

        // Use custom logo if set
        $customLogo = $this->getCustomLogo();
        if ($customLogo) {
            $logoPath = $customLogo;
        }

        $enabledSearch = false;
        if($this->get('activate_search') == 'true'){
            $enabledSearch = true;
        }

        $logoPathImg = Display::img($logoPath, $institution, $imageAttributes);

        $this->assign('logo', $logoPathImg);
        $this->assign('logo_svg', $customLogo ? $logoPathImg : self::display_logo());
        $this->assign('logo_icon', $customLogo ? $logoPathImg : self::display_logo_icon());
        $this->assign('enabled_search', $enabledSearch);

        $menus = self::getMenus($section);
        $this->assign('menus', $menus);

        $currentSectionLabel = '';
        foreach ($menus as $menu) {
            if (!empty($menu['class']) && $menu['class'] === 'active') {
                $currentSectionLabel = $menu['label'];
                break;
            }
        }
        $this->assign('current_section_label', $currentSectionLabel);

        // Custom logo dimensions from admin settings
        $this->assign('custom_logo_width', $this->getSchoolSetting('logo_width') ?? '');
        $this->assign('custom_logo_height', $this->getSchoolSetting('logo_height') ?? '');

        // Custom colors from admin settings
        $this->assign('custom_primary_color', $this->getSchoolSetting('primary_color') ?? '');
        $this->assign('custom_sidebar_brand_color', $this->getSchoolSetting('sidebar_brand_color') ?? '');
        $this->assign('custom_sidebar_color', $this->getSchoolSetting('sidebar_color') ?? '');
        $this->assign('custom_sidebar_item_color', $this->getSchoolSetting('sidebar_item_color') ?? '');
        $this->assign('custom_sidebar_item_active_text', $this->getSchoolSetting('sidebar_item_active_text') ?? '');
        $this->assign('custom_sidebar_text_color', $this->getSchoolSetting('sidebar_text_color') ?? '');

        $content = $this->fetch('/layout/sidebar.tpl');
        $this->assign('sidebar', $content);
    }

    public function setNavBar()
    {
        $content = $this->fetch('/layout/navbar.tpl');
        $this->assign('navbar', $content);
    }

    public function getSessionsByCategoryCount($userID, $history = false): int
    {
        $accessUrlId = api_get_current_access_url_id();
        $table_session = Database::get_main_table(TABLE_MAIN_SESSION);
        $table_session_category = Database::get_main_table(TABLE_MAIN_SESSION_CATEGORY);
        $table_session_user = Database::get_main_table(TABLE_MAIN_SESSION_USER);
        $table_session_course_user = Database::get_main_table(TABLE_MAIN_SESSION_COURSE_USER);
        $table_access_url_session = Database::get_main_table(TABLE_MAIN_ACCESS_URL_REL_SESSION);

        $sql = "
            SELECT COUNT(*) AS total_courses FROM (
                SELECT DISTINCT s.id
                FROM $table_session s
                INNER JOIN $table_session_user srs ON srs.session_id = s.id
                INNER JOIN $table_access_url_session aus ON aus.session_id = s.id
                WHERE srs.user_id = $userID AND aus.access_url_id = $accessUrlId
                UNION
                SELECT DISTINCT s.id
                FROM $table_session s
                INNER JOIN $table_session_course_user scru ON scru.session_id = s.id
                INNER JOIN $table_access_url_session aus ON aus.session_id = s.id
                WHERE scru.user_id = $userID AND scru.status = 2 AND aus.access_url_id = $accessUrlId
            ) AS user_sessions ";
        $result = Database::query($sql);

        if (empty($result)) {
            return 0;
        }
        $total = 0;
        if (Database::num_rows($result) > 0) {
            foreach ($result as $row) {
                $total = $row['total_courses'];
            }
        }
        return $total;

    }
    public function saveRequest($values): int
    {
        if (!is_array($values)) {
            return 0;
        }
        $table_request = Database::get_main_table(self::TABLE_SCHOOL_REQUEST);
        $params = [
            'title' => $values['title'],
            'board_id' => $values['board_id'],
            'phase_id' => $values['phase_id'],
            'description' => $values['description'],
            'session_id' => $values['session_id'],
            'start_time' => date('Y-m-d H:i:s'),
            'end_time' => $values['end_time'] ?? NULL,
            'user_id' => api_get_user_id(),
            'activate' => $values['activate'] ?? 1
        ];
        return Database::insert($table_request, $params);
    }
    public function getRequestUser($userID): array
    {
        $list = [];
        $table_request = self::TABLE_SCHOOL_REQUEST;
        $sql = "SELECT * FROM $table_request psr WHERE psr.user_id = $userID ";
        $result = Database::query($sql);
        if (Database::num_rows($result) > 0) {
            while ($row = Database::fetch_array($result)) {
                $list[] = [
                    'id' => $row['id'],
                    'title' => $row['title'],
                    'board_id' => $row['board_id'],
                    'phase_id' => $row['phase_id'],
                    'description' => $row['description'],
                    'session_id' => $row['session_id'],
                    'start_time' => $row['start_time'],
                    'end_time' => $row['end_time'],
                    'user_id' => $row['user_id'],
                    'activate' => $row['activate']
                ];
            }
        }
        return $list;
    }

    public function getSessionRelUser($userID): array
    {
        $table_session_user = Database::get_main_table(TABLE_MAIN_SESSION_USER);
        $table_session = Database::get_main_table(TABLE_MAIN_SESSION);

        $sql = "SELECT
                    sru.session_id,
                    s.name
                FROM $table_session_user sru
                INNER JOIN $table_session s
                ON s.id = sru.session_id
                WHERE sru.user_id = $userID;";

        $result = Database::query($sql);
        $list = [];
        if (Database::num_rows($result) > 0) {
            foreach ($result as $row) {
                $list[$row['session_id']] = $row['name'];
            }
        }
        return $list;
    }
    public function getSessionsByCategory($userID, $history = false, $alls = false): array
    {
        $total = 0;
        $categories = [];
        $accessUrlId = api_get_current_access_url_id();
        $table_session = Database::get_main_table(TABLE_MAIN_SESSION);
        $table_session_category = Database::get_main_table(TABLE_MAIN_SESSION_CATEGORY);
        $table_session_user = Database::get_main_table(TABLE_MAIN_SESSION_USER);
        $table_session_course_user = Database::get_main_table(TABLE_MAIN_SESSION_COURSE_USER);
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
                s.access_start_date,
                s.access_end_date,
                COALESCE(DATE(srs.registered_at), CURDATE()) AS 'registered_at',
                CASE
                    WHEN s.id_coach = $userID THEN 'true'
                    ELSE 'false'
                END AS coach
            FROM $table_session s
            LEFT JOIN $table_session_user srs ON srs.session_id = s.id AND srs.user_id = $userID
            LEFT JOIN $table_session_course_user scru ON scru.session_id = s.id AND scru.user_id = $userID AND scru.status = 2
            LEFT JOIN $table_session_category sc ON sc.id = s.session_category_id
            INNER JOIN $table_access_url_session aus ON aus.session_id = s.id
            WHERE (srs.user_id = $userID OR scru.user_id = $userID) AND aus.access_url_id = $accessUrlId
            GROUP BY s.id ";

        $result = Database::query($sql);

        if (empty($result)) {
            return [];
        }

        // Aquí obtenemos todos los resultados primero
        $rows = $result->fetchAll(PDO::FETCH_ASSOC);

        if (count($rows) > 0) {

            usort($rows, function($a, $b) {
                return strtotime($b['display_start_date']) <=> strtotime($a['display_start_date']);
            });

            $total = count($rows);
            foreach ($rows as $row) {
                $endDateSession = api_get_local_time($row['display_end_date']);
                $courseList = self::getCoursesListBySession($userID, $row['id']);
                $shortDate = $this->formatDateToSpanish($endDateSession);
                $dateRegister = api_format_date($row['registered_at'], DATE_FORMAT_SHORT);
                $row['registered_at'] = $dateRegister;
                $row['short_date'] = $shortDate;
                $row['number_courses'] = count($courseList);
                $row['courses'] = $courseList;
                $row['session_image'] = self::get_svg_icon('course', $row['name'], 32);
                $row['session_image_mobile'] = self::get_svg_icon('course', $row['name'], 22, true);
                $row['certificate_url'] = api_get_path(WEB_PLUGIN_PATH) . 'school/src/certificate_regular.php?id_session=' . $row['id'];
                if (is_null($row['id_category'])) {
                    $row['id_category'] = 4;
                    $row['category'] = self::get_lang('OnlineCourses');
                }
                if (!isset($categories[$row['id_category']])) {
                    $nameImage = 'category_' . $row['id_category'];
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

        return [
            'total' => $total,
            'categories' => $categories
        ];

    }

    public function getBaseCoursesByUser($userID): array
    {
        $courseList = CourseManager::get_courses_list_by_user_id($userID, false);

        // Order descending by id (most recent first)
        usort($courseList, function($a, $b) {
            return $b['real_id'] <=> $a['real_id'];
        });

        $courses = [];
        $count = 0;

        foreach ($courseList as $course) {
            $count++;
            $courseId = $course['real_id'];
            $courseCode = $course['code'];
            $courseTitle = $course['title'];

            $ribbon = ($count % 2 == 0) ? 'even' : 'odd';

            $courses[] = [
                'id' => $courseId,
                'code' => $courseCode,
                'title' => $courseTitle,
                'icon' => self::get_svg_icon('course', $courseTitle, 32),
                'icon_mobile' => self::get_svg_icon('course', $courseTitle, 22, true),
                'url' => api_get_path(WEB_PATH).'home/course/'.$courseCode,
                'ribbon' => $ribbon,
            ];
        }

        return [
            'total' => count($courses),
            'courses' => $courses,
        ];
    }

    function generateBarcode($code): string
    {
        $generator = new BarcodeGeneratorPNG();
        $barcode = $generator->getBarcode($code, $generator::TYPE_CODE_128);
        return base64_encode($barcode);
    }
    public function formatDateToSpanish($date)
    {
        $months = array(
            'Jan' => 'Ene', 'Feb' => 'Feb', 'Mar' => 'Mar', 'Apr' => 'Abr', 'May' => 'May', 'Jun' => 'Jun',
            'Jul' => 'Jul', 'Aug' => 'Ago', 'Sep' => 'Sep', 'Oct' => 'Oct', 'Nov' => 'Nov', 'Dec' => 'Dic'
        );

        $shortDate = date('d M Y', strtotime($date));
        $month = date('M', strtotime($date));
        return str_replace($month, $months[$month], $shortDate);
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
                    scu.session_id = $session_id AND
                    scu.status IN (0, 2)
                    $where_access_url ORDER BY sc.position ASC ";

        $myCourseList = [];
        $courses = [];

        $result = Database::query($sql);
        $rows = $result->fetchAll(PDO::FETCH_ASSOC);

        $count = 0;
        if (count($rows) > 0) {
            foreach ($rows as $result_row) {
                $count++;
                $result_row['status'] = 5;
                $result_row['visible'] = true;
                $result_row['icon'] = self::get_svg_icon('course', $result_row['title'],32);
                $result_row['icon_mobile'] = self::get_svg_icon('course', $result_row['title'],22, true);
                $result_row['url'] = api_get_path(WEB_PATH).'home/course/'.$result_row['course_code'].'&id_session='.$session_id;
                $result_row['position_number'] = $count-1;
                if ($count % 2 == 0) {
                    $result_row['ribbon'] = 'even';
                } else {
                    $result_row['ribbon'] = 'odd';
                }

                if($result_row['visible']){
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
        }

        if (!empty($myCourseList)) {
            ksort($myCourseList);
        }

        return $myCourseList;
    }

    public function get_sessions_by_user(
        $userId,
        $alls = false
    ): array
    {
        $sessionCategories = self::getSessionsByCategory($userId, false, $alls);

        $sessionArray = [];
        if (!empty($sessionCategories['categories'])) {
            foreach ($sessionCategories['categories'] as $category) {
                if (isset($category['sessions'])) {
                    foreach ($category['sessions'] as $session) {
                        $sessionArray[] = $session;
                    }
                }
            }
        }

        return $sessionArray;
    }

    public function getCertificatesInSessions($userId, $includeNonPublicCertificates = true): array
    {
        $userId = (int) $userId;
        $sessionList = [];
        $sessions = self::get_sessions_by_user($userId, true);

        foreach ($sessions as $session) {
            if (empty($session['courses'])) {
                continue;
            }

            $sessionCourses = SessionManager::get_course_list_by_session_id($session['id']);

            if (empty($sessionCourses)) {
                continue;
            }
            $courseList = [];
            $count = 0;
            $dateCertificateSession = '';
            foreach ($sessionCourses as $course) {
                $count++;
                if (!$includeNonPublicCertificates) {
                    $allowPublicCertificates = api_get_course_setting('allow_public_certificates');
                    if (empty($allowPublicCertificates)) {
                        continue;
                    }
                }

                $category = Category::load(
                    null,
                    null,
                    $course['code'],
                    null,
                    null,
                    $session['id']
                );

                if (empty($category)) {
                    continue;
                }

                if (!isset($category[0])) {
                    continue;
                }

                /** @var Category $category */
                $category = $category[0];

                if (empty($category->getGenerateCertificates())) {
                    continue;
                }

                $categoryId = $category->get_id();
                $certificateInfo = GradebookUtils::get_certificate_by_user_id(
                    $categoryId,
                    $userId
                );

                if (empty($certificateInfo)) {
                    continue;
                }
                if ($count % 2 == 0) {
                    $ribbon = 'even';
                } else {
                    $ribbon = 'odd';
                }
                $courseList[] = [
                    'id' => $course['id'],
                    'title' => $course['title'],
                    'code' => $course['code'],
                    'ribbon' => $ribbon,
                    'icon' => self::get_svg_icon('course', $course['title'],32),
                    'icon_mobile' => self::get_svg_icon('course', $course['title'],22, true),
                    'certificate' => [
                        'score' => $certificateInfo['score_certificate'],
                        'date' => api_format_date($certificateInfo['created_at'], DATE_FORMAT_SHORT),
                        'link_html' => api_get_path(WEB_PATH)."certificates/index.php?id={$certificateInfo['id']}&user_id={$userId}",
                        'link_share' => api_get_path(WEB_PLUGIN_PATH)."school/src/process.php?action=share&id={$certificateInfo['id']}",
                        'link_pdf' => api_get_path(WEB_PATH)."certificates/index.php?id={$certificateInfo['id']}&user_id={$userId}&action=export",
                    ],
                ];
                $dateCertificateSession = api_format_date($certificateInfo['created_at'], DATE_FORMAT_SHORT);

            }
            if(empty($courseList)){
                continue;
            }
            $sessionList[] = [
                'session_id' => intval($session['id']),
                'session_title' => $session['name'],
                'session_category_id' => $session['id_category'],
                'session_category' => $session['category'],
                'session_image' => self::get_svg_icon('course', $session['name'],32),
                'session_date_certificate' => $dateCertificateSession,
                'number_courses' => count($courseList),
                'courses' => $courseList
                ];

        }

        $groupedSessions = [];
        foreach ($sessionList as $session) {
            $category_id = $session['session_category_id'];
            $category_name = $session['session_category'];
            $nameImage = 'category_'.$session['session_category_id'];

            if (!isset($groupedSessions[$category_id])) {
                $groupedSessions[$category_id] = [
                    'category_id' => $category_id,
                    'category_name' => $category_name,
                    'category_image' => self::get_svg_icon($nameImage, $category_name, 50),
                    'sessions' => []
                ];
            }
            $groupedSessions[$category_id]['sessions'][] = [
                'id' => $session['session_id'],
                'name' => $session['session_title'],
                'session_image' => $session['session_image'],
                'date_certificate' => $session['session_date_certificate'],
                'number_courses' => $session['number_courses'],
                'courses' => $session['courses']
            ];
        }
        return $groupedSessions;
    }

    public function getAjaxMessages($userID, $cant = 5): array
    {

        $messageTable = Database::get_main_table(TABLE_MESSAGE);

        // Consulta con el COUNT y LIMIT
        $sql = "SELECT
                m.id,
                m.title,
                m.msg_status,
                m.send_date,
                m.type,
                m.user_sender_id,
                m.user_receiver_id,
                m.c_id,
                m.session_id
            FROM $messageTable m
            WHERE m.user_receiver_id = $userID AND m.msg_status = 1 " .
            // Si no es necesario filtrar por otro estado, se omite la parte de "AND m.msg_status = 1"
            "ORDER BY m.send_date DESC
            LIMIT $cant";

        $result = Database::query($sql);
        $messageList = [];

        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $userInfo = api_get_user_info($row['user_sender_id']);
            $title = Security::remove_XSS($row['title'], STUDENT, true);
            $title = cut($title, 80);

            $sessionName = api_get_session_name($row['session_id']);
            $courseName = null;
            if(!is_null($row['c_id'])){
                $courseInfo = api_get_course_info_by_id($row['c_id']);
                $courseName = $courseInfo['title'];
            }

            if(is_null($userInfo['avatar'])){
                $avatar =  self::get_svg_icon('avatar', $userInfo['complete_name_with_username'] , 50);
            } else {
                $avatar = Display::img($userInfo['avatar'],$userInfo['complete_name_with_username'],['width' => 50, 'height' => 50, 'class' => 'rounded-circle user-avatar']);
            }

            //$sendDate = api_convert_and_format_date($row['send_date'], DATE_TIME_FORMAT_LONG);
            $sendDate = api_format_date($row['send_date'], DATE_FORMAT_SHORT);
            $messageList[] = [
                'id' => $row['id'],
                'link' => '/notifications?action=view&id='.$row['id'],
                'title' => $title,
                'status' => $row['msg_status'],
                'send_date' => $sendDate,
                'user_avatar' => $avatar,
                'user_sender_id' => $userInfo['complete_name_with_username'],
                'user_receiver_id' => $row['user_receiver_id'],
                'course_id' => $row['c_id'],
                'course_title' => $courseName,
                'session_id' => $row['session_id'],
                'session_title' => $sessionName
            ];
        }

        $sqlTotal = "SELECT COUNT(*) as total_messages
                 FROM $messageTable m
                 WHERE m.user_receiver_id = $userID AND m.msg_status = 1";

        $resultTotal = Database::query($sqlTotal);
        $rowTotal = Database::fetch_array($resultTotal, 'ASSOC');
        $totalMessages = $rowTotal['total_messages'];

        return  [
            'messages' => $messageList,
            'totalMessages' => $totalMessages
        ];
    }

    public function getMessagesCount($userID, $all = false, $status = 1)
    {
        $messageTable = Database::get_main_table(TABLE_MESSAGE);
        $sql = "SELECT
                COUNT(*) AS total_messages
                FROM $messageTable m
                WHERE user_receiver_id = $userID ";

        if(!$all){
            $sql.= " AND msg_status = $status";
        }

        $result = Database::query($sql);
        $row = Database::fetch_array($result, 'ASSOC');
        return $row['total_messages'];
    }

    public function getMessages($userID, $page = 1, $perPage = 10, $all = false, $status = 1): array
    {
        $offset = ($page - 1) * $perPage;
        $messageTable = Database::get_main_table(TABLE_MESSAGE);
        $sql = "SELECT
                m.id,
                m.title,
                m.msg_status,
                m.send_date,
                m.type,
                m.user_sender_id,
                m.user_receiver_id,
                m.c_id,
                m.session_id
                FROM $messageTable m
                WHERE user_receiver_id = $userID ";

        if(!$all){
            $sql.= " AND msg_status = $status ";
        }

        $sql .= " ORDER BY send_date DESC LIMIT $offset, $perPage";

        $result = Database::query($sql);

        $messageList = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {

            $userInfo = api_get_user_info($row['user_sender_id']);
            $typeMessage = $row['type'];
            $title = Security::remove_XSS($row['title'], STUDENT, true);
            $title = cut($title, 80);
            $msgTypeLang = '';

            switch ($typeMessage){
                case MESSAGE_TYPE_COURSE_WORK:
                    $msgTypeLang = '<span title="'.$this->get_lang('CourseActivityMessage').'"><i class="fas fa-pencil-alt fa-lg"></i></span>';
                    break;
                case MESSAGE_TYPE_COURSE_EXERCISE:
                    $icon = Display::return_icon('quiz.png', get_lang('Exercise'));
                    $msgTypeLang = $icon;
                    break;
                case MESSAGE_TYPE_COURSE_FORUM:
                    $icon = '<span title="'.$this->get_lang('ForumMessage').'"><i class="fas fa-comments fa-lg"></i></span>';
                    $msgTypeLang = $icon;
                    break;
                case MESSAGE_TYPE_COURSE_ANNOUNCEMENT:
                    $icon = Display::return_icon('valves.png', get_lang('Announcements'));
                    $msgTypeLang = $icon;
                    break;
                case MESSAGE_TYPE_COURSE_SURVEY:
                    $icon = Display::return_icon('survey.png', get_lang('Survey'));
                    $msgTypeLang = $icon;
                    break;
                case MESSAGE_TYPE_SESSION_ANNOUNCEMENT:
                    $msgTypeLang = '<span title="'.$this->get_lang('PlatformMessage').'"><i class="fas fa-bell fa-lg"></i></span>';
                    break;
            }

            $sessionName = api_get_session_name($row['session_id']);
            $courseName = null;
            if(!is_null($row['c_id'])){
                $courseInfo = api_get_course_info_by_id($row['c_id']);
                $courseName = $courseInfo['title'];
            }

            if(is_null($userInfo['avatar'])){
                $avatar =  self::get_svg_icon('avatar', $userInfo['complete_name_with_username'] , 50);
            } else {
                $avatar = Display::img($userInfo['avatar'],$userInfo['complete_name_with_username'],['width' => 50, 'height' => 50, 'class' => 'rounded-circle user-avatar']);
            }

            $class = 'message-read';
            $rowClass = 'table-read';
            $action = '<a title="'.$this->get_lang('MarkAsUnread').'" href="/notifications?view=all&action=mark_as_unread&id[]='.$row['id'].'"><i class="far fa-envelope-open fa-lg"></i></a>';
            if($row['msg_status'] == 1){
                $class = 'message-unread';
                $rowClass = 'table-unread';
                $action = '<a title="'.$this->get_lang('MarkAsRead').'" href="/notifications?action=mark_as_read&id[]='.$row['id'].'"><i class="fas fa-envelope fa-lg"></i></a>';
            }

            $inputID = '<input type="checkbox" name="id[]" value="'.$row['id'].'" />';

            //$sendDate = api_convert_and_format_date($row['send_date'], DATE_TIME_FORMAT_LONG);
            $sendDate = api_format_date($row['send_date'], DATE_FORMAT_SHORT);
            $messageList[] = [
                'id' => $row['id'],
                'check_id' => $inputID,
                'link' => '/notifications?action=view&id='.$row['id'],
                'title' => $title,
                'status' => $row['msg_status'],
                'send_date' => $sendDate,
                'type' => $msgTypeLang,
                'user_avatar' => $avatar,
                'user_sender_id' => $userInfo['complete_name_with_username'],
                'user_receiver_id' => $row['user_receiver_id'],
                'course_id' => $row['c_id'],
                'course_title' => $courseName,
                'session_id' => $row['session_id'],
                'session_title' => $sessionName,
                'class' => $class,
                'row' => $rowClass,
                'action' => $action,
            ];
        }

        $sqlTotal = "SELECT COUNT(*) as total_messages FROM $messageTable m WHERE user_receiver_id = $userID ";

        if(!$all){
            $sqlTotal.= " AND msg_status = $status ";
        }

        $result = Database::query($sqlTotal);
        $row = Database::fetch_array($result, 'ASSOC');
        $totalMessages = $row['total_messages'];
        $totalPages = ceil($totalMessages / $perPage);

        return [
            'messages' => $messageList,
            'pagination' => [
                'currentPage' => $page,
                'totalPages' => $totalPages,
                'totalMessages' => $totalMessages,
            ]
        ];

    }

    public function viewMessage($messageId, $type): array
    {
        if (empty($messageId) || empty($type)) {
            return [];
        }

        $currentUserId = api_get_user_id();
        $table = Database::get_main_table(TABLE_MESSAGE);
        $status = 0;

        switch ($type) {
            case MessageManager::MESSAGE_TYPE_OUTBOX:
                $status = MESSAGE_STATUS_OUTBOX;
                $userCondition = " m.user_sender_id = $currentUserId AND ";
                break;
            case MessageManager::MESSAGE_TYPE_INBOX:
                $status = MESSAGE_STATUS_NEW;
                $userCondition = " m.user_receiver_id = $currentUserId AND ";

                $query = "UPDATE $table SET
                          msg_status = '".MESSAGE_STATUS_NEW."'
                          WHERE id = $messageId ";
                Database::query($query);
                break;
            case MessageManager::MESSAGE_TYPE_PROMOTED:
                $status = MESSAGE_STATUS_PROMOTED;
                $userCondition = " m.user_receiver_id = $currentUserId AND ";
                break;
        }
        if (empty($userCondition)) {
            return [];
        }
        $query = "SELECT * FROM $table m
                  WHERE
                    m.id = $messageId AND
                    $userCondition
                    m.msg_status = $status";

        $result = Database::query($query);
        $row = Database::fetch_array($result, 'ASSOC');

        if (empty($row)) {
            return [];
        }
        $typeMessage = !empty($row['type'])? $row['type'] : 0;

        $user_sender_id = $row['user_sender_id'];
        $fromUser = api_get_user_info($user_sender_id);
        $name = $userImage = '';
        if (!empty($user_sender_id) && !empty($fromUser)) {
            $name = $fromUser['firstName'].' '.$fromUser['lastName'];
            $userImage = Display::img(
                $fromUser['avatar_small'],
                $name,
                ['title' => $name, 'class' => 'rounded-circle', 'style' => 'max-width:32px'],
                false
            );
        }

        $receiverUserInfo = [];
        if (!empty($row['user_receiver_id'])) {
            $receiverUserInfo = api_get_user_info($row['user_receiver_id']);
        }
        $messageInfo = '';
        switch ($type) {
            case MessageManager::MESSAGE_TYPE_INBOX:
                $messageInfo = $userImage.'&nbsp;'.$name;
                break;
            case MessageManager::MESSAGE_TYPE_OUTBOX:
                $messageInfo= get_lang('From').':&nbsp;'.$name.'</b> '.api_strtolower(get_lang('To')).' <b>'.
                    $receiverUserInfo['complete_name_with_username'].'</b>';
                break;
        }

        // get file attachments by message id
        $files_attachments = MessageManager::getAttachmentLinkList($messageId, $type);

        $row['content'] = str_replace('</br>', '<br />', $row['content']);
        $title = Security::remove_XSS($row['title'], STUDENT, true);
        $content = Security::remove_XSS($row['content'], STUDENT, true);
        $sendDate = Display::dateToStringAgoAndLongDate($row['send_date']);
        $sessionName = api_get_session_name($row['session_id']);

        $message = [
            'title' => $title,
            'content' => $content,
            'send_date' => $sendDate,
            'date' => $this->formatDateToSpanish($row['send_date']),
            'info'=> $messageInfo,
            'type' => $typeMessage,
            'status' => $status,
            'files_attachments' => $files_attachments,
            'user_sender_id' => $user_sender_id,
            'user_avatar' => $userImage,
            'session_title' => self::get_svg_icon('course_white', $title,32) .' | '. $sessionName,
            'session_title_mobile' => $sessionName,
        ];

        return [
            'message' => $message,
        ];

    }
    public function getMenus(string $currentSection = ''): array
    {
        $menus = [
            [
                'id' => 1,
                'name' => 'dashboard',
                'label' => $this->get_lang('MyTrainings'),
                'current' => $currentSection === 'dashboard',
                'icon' => 'book-open',
                'class' => $currentSection === 'dashboard' ? 'active':'',
                'url' => '/dashboard',
                'items' => []
            ],
            [
                'id' => 2,
                'name' => 'notifications',
                'label' => $this->get_lang('MyNotifications'),
                'current' => false,
                'icon' => 'bell',
                'class' => $currentSection === 'notifications' ? 'active':'',
                'url' => '/notifications',
                'items' => []
            ],
        ];

        if ($this->get('show_certificates') == 'true') {
            $menus[] = [
                'id' => 3,
                'name' => 'certificates',
                'label' => $this->get_lang('MyCertificates'),
                'current' => false,
                'icon' => 'file',
                'url' => '/certified',
                'class' => $currentSection === 'certificates' ? 'active':'',
                'items' => []
            ];
        }

        $menus = array_merge($menus, [
            [
                'id' => 4,
                'name' => 'help',
                'label' => $this->get_lang('Help'),
                'current' => false,
                'icon' => 'question-circle',
                'url' => '/help',
                'class' => $currentSection === 'help' ? 'active':'',
                'items' => []
            ],
            [
                'id' => 5,
                'name' => 'shopping',
                'label' => $this->get_lang('BuyCourses'),
                'current' => false,
                'icon' => 'shopping-cart',
                'url' => '/shopping',
                'class' => $currentSection === 'shopping' ? 'active':'',
                'items' => []
            ]
        ]);

        if ($this->get('activate_shopping') == 'false') {
            $menus = array_filter($menus, function ($menu) {
                return $menu['name'] !== 'shopping';
            });
        }

        if (api_is_platform_admin()) {
            $menus[] = [
                'id' => 10,
                'name' => 'admin',
                'label' => $this->get_lang('PluginAdmin'),
                'current' => false,
                'icon' => 'cog',
                'url' => '/school-admin',
                'class' => $currentSection === 'admin' ? 'active' : '',
                'items' => []
            ];
        }

        return array_values($menus);
    }
    public function is_platform_authentication(string $auth_source): bool
    {
        return $auth_source === 'platform';
    }

    public function is_profile_editable(): bool
    {
        if (isset($GLOBALS['profileIsEditable'])) {
            return (bool) $GLOBALS['profileIsEditable'];
        }

        return true;
    }
    public function getTagsSession($idSession): string
    {
        if (empty($idSession)) {
            return '';
        }
        $tagsTable = Database::get_main_table(self::TABLE_SHORTIFY_TAGS);
        $tagsTableUrls = Database::get_main_table(self::TABLE_SHORTIFY_URL_TAGS);
        $sql = "SELECT pst.id, pst.tag FROM session s
                INNER JOIN  $tagsTableUrls psut ON s.reference_session = psut.reference
                INNER JOIN $tagsTable pst ON pst.id = psut.tag_id
                WHERE s.id = $idSession; ";

        $result = Database::query($sql);

        $tags = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $tags[$row['id']] = $row['tag'];
        }
        return implode(' | ', array_map('ucfirst', array_map('strtolower', $tags)));
    }

    /**
     * @throws \Doctrine\ORM\OptimisticLockException
     * @throws \Doctrine\ORM\TransactionRequiredException
     * @throws \Doctrine\ORM\ORMException
     */
    public function getInfoSession($item): array
    {
        if(empty($item)){
            return [];
        }
        $session = api_get_session_info($item);

        $em = Database::getManager();
        /** @var Session $session */
        $sessionEntity = $em->find('ChamiloCoreBundle:Session', $item);

        $courses = self::getSessionCourseList($sessionEntity);
        $n_course = count($courses);

        if ($n_course == 1) {
            $session['image'] = api_get_path(WEB_APP_PATH) . 'upload/import/' . $courses[0]['code'] . '.png';
        }

        $lists = self::getDescriptionCourse($session['id'], $courses[0]['id'],8);

        if(empty($session)){
            return [];
        }
        $category = self::getSessionCategoryID($session['id']);
        $sessionField = new ExtraFieldValue('session');
        $extraFieldData = $sessionField->getAllValuesForAnItem($item, null, true);
        $displayCategory = $category;
        $tags = '';
        $enabledPluginTags = api_get_plugin_setting('shortify', 'shortify_tool_enable');
        if($enabledPluginTags === 'true'){
            $tags = $this->getTagsSession($session['id']);
        }
        return [
            'id' => $session['id'],
            'name' => $session['name'],
            'description' => ucfirst(strtolower(strip_tags($session['description']))),
            'display_start_date' => $session['display_start_date_to_local_time'],
            'display_end_date' => $session['display_end_date_to_local_time'],
            'session_category_id' => $session['session_category_id'],
            'tags' => $tags,
            'session_category' => $category,
            'display_category' => $displayCategory,
            'n_courses' => $n_course,
            'image' => $session['image'] ?? '',
            'courses' => $courses,
            'link' => api_get_path(WEB_PATH).'session/'.$session['id'].'/about',
            'extra_fields' => $extraFieldData,
            'reference_session' => $session['reference_session'] ?? '',
            'calendar_course' => $lists,
        ];
    }

    function getSessionCourseList(Session $session): array
    {
        $return = [];
        $sessionID = $session->getId();
        foreach ($session->getCourses() as $sessionCourse) {
            /** @var Course $course */
            $course = $sessionCourse->getCourse();
            $courseID = $course->getId();
            $lists = self::getDescriptionCourse($sessionID, $courseID,8);
            $return[] = [
                'id' => $courseID,
                'name' => $course->getTitle(),
                'code' => $course->getCode(),
                'calendar' => $lists
            ];
        }

        return $return;
    }

    public function getSessionCategoryID($idCategory):string
    {
        $table_session_category = Database::get_main_table(TABLE_MAIN_SESSION_CATEGORY);
        $table_session = Database::get_main_table(TABLE_MAIN_SESSION);
        $sql = "SELECT sc.name FROM $table_session s INNER JOIN $table_session_category sc ON sc.id = s.session_category_id WHERE s.id = $idCategory;";
        $result = Database::query($sql);
        $category = $this->get_lang("Training");
        if (Database::num_rows($result) > 0) {
            while ($row = Database::fetch_array($result)) {
                $category = $row['name'];
            }
        }

        return  $category;
    }

    public function formatDateShortEs($date, $large = false): string
    {
        $monthsShorts = [
            'Jan' => 'Ene', 'Feb' => 'Feb', 'Mar' => 'Mar',
            'Apr' => 'Abr', 'May' => 'May', 'Jun' => 'Jun',
            'Jul' => 'Jul', 'Aug' => 'Ago', 'Sep' => 'Sep',
            'Oct' => 'Oct', 'Nov' => 'Nov', 'Dec' => 'Dic'
        ];

        $monthsLarge = [
            'Jan' => 'Enero', 'Feb' => 'Febrero', 'Mar' => 'Marzo',
            'Apr' => 'Abril', 'May' => 'Mayo', 'Jun' => 'Junio',
            'Jul' => 'Julio', 'Aug' => 'Agosto', 'Sep' => 'Septiembre',
            'Oct' => 'Octubre', 'Nov' => 'Noviembre', 'Dec' => 'Diciembre'
        ];

        if($large){
            return str_replace(array_keys($monthsLarge), array_values($monthsLarge), $date);
        } else {
            return str_replace(array_keys($monthsShorts), array_values($monthsShorts), $date);
        }

    }
    public function formatDateEs($date): string
    {
        $dateTime = new DateTime($date);

        $dias = [
            'Monday'    => 'lunes',
            'Tuesday'   => 'martes',
            'Wednesday' => 'miércoles',
            'Thursday'  => 'jueves',
            'Friday'    => 'viernes',
            'Saturday'  => 'sábado',
            'Sunday'    => 'domingo'
        ];

        $meses = [
            1  => 'enero',
            2  => 'febrero',
            3  => 'marzo',
            4  => 'abril',
            5  => 'mayo',
            6  => 'junio',
            7  => 'julio',
            8  => 'agosto',
            9  => 'septiembre',
            10 => 'octubre',
            11 => 'noviembre',
            12 => 'diciembre'
        ];

        $diaSemana = $dias[$dateTime->format('l')];
        $diaNumero = $dateTime->format('d');
        $mes = $meses[(int)$dateTime->format('m')];
        $anio = $dateTime->format('Y');

        $texto = "$diaSemana $diaNumero de $mes $anio";

        // Capitalizar la primera letra
        return ucfirst($texto);
    }

    /**
     * Actualiza el auth_source de un usuario
     *
     * @param int $userId ID del usuario
     * @param string $authSource Fuente de autenticación (ej: 'oauth2-google', 'platform', 'ldap')
     * @return bool true si se actualizó correctamente, false en caso contrario
     */
    function updateUserAuthSource($userId, $authSource): bool
    {
        $userId = (int) $userId;
        $authSource = Database::escape_string($authSource);

        if (empty($userId) || $userId <= 0) {
            return false;
        }

        if (empty($authSource)) {
            return false;
        }

        $userTable = Database::get_main_table(TABLE_MAIN_USER);

        $sql = "UPDATE $userTable
            SET auth_source = '$authSource'
            WHERE id = $userId";

        $result = Database::query($sql);

        return $result !== false;
    }

    public function getSessionTabURL($referenceSession)
    {
        if (empty($referenceSession)) {
            return '#';
        }
        $tagsTableUrls = Database::get_main_table(self::TABLE_SHORTIFY_URL);
        $sql = "SELECT psu.url_pdf FROM $tagsTableUrls psu WHERE psu.reference = '".$referenceSession ."'";
        $result = Database::query($sql);
        $url = Database::fetch_array($result);
        if($url){
            return  $url['url_pdf'];
        } else {
            return '#';
        }

    }
    public function getDescriptionCourse($sessionID, $courseID, $type = null, $term = null): array
    {
        if (empty($sessionID) || empty($courseID)) {
            return [];
        }
        $tableCourseDescription = Database::get_course_table(TABLE_COURSE_DESCRIPTION);
        $sql = "SELECT cc.* FROM $tableCourseDescription cc
                WHERE cc.c_id = $courseID ";
        if(!empty($type)){
            $sql .= " AND cc.description_type = $type ";
        }
        if(!empty($term)){
            $sql.= " AND cc.title LIKE '%".$term."%'";
        }

        $result = Database::query($sql);
        $description = [];
        if (Database::num_rows($result) > 0) {
            while ($row = Database::fetch_array($result)) {
                if($row['session_id'] == $sessionID || $row['session_id'] == 0){
                    $description[] = [
                        'id' => $row['id'],
                        'title' => $row['title'],
                        'description_type' => $row['description_type'],
                        'content' => $row['content']
                    ];
                }
            }
        }

        return  $description;
    }

    public function getTags(): array
    {
        $tagsTable = Database::get_main_table(self::TABLE_SHORTIFY_TAGS);
        $sql = "SELECT * FROM $tagsTable pst";
        $result = Database::query($sql);
        $tags = [
            '-1' => $this->get_lang('All')
        ];
        if (Database::num_rows($result) > 0) {
            while ($row = Database::fetch_array($result)) {
                $tags[$row['id']] = $row['tag'];
            }
        }
        return  $tags;
    }
    public function getSearchCourse($name): array
    {
        $yesterdayDateOne = date('Y-m-d', strtotime("+0 day"));
        $yesterdayDateTwo = date('Y-m-d', strtotime("+1 day"));
        $sessionTable = Database::get_main_table(TABLE_MAIN_SESSION);
        $itemTable = Database::get_main_table(self::TABLE_BUYCOURSE_ITEM);
        $urlsTable = Database::get_main_table(self::TABLE_SHORTIFY_URL);
        $sql = "SELECT s.id, s.name, s.description, s.session_category_id, s.reference_session, psu.ordering FROM $sessionTable s
                INNER JOIN $itemTable i ON s.id = i.product_id
                INNER JOIN $urlsTable psu ON s.reference_session = psu.reference
                WHERE i.product_type = '2'
                AND s.sale_start_date <= '".$yesterdayDateOne."'
                AND '".$yesterdayDateTwo."' <= s.sale_end_date
                AND s.name LIKE '%".$name."%'
                ORDER BY psu.ordering ASC";

        $result = Database::query($sql);
        $sessions = [];

        if (Database::num_rows($result) > 0) {
            while ($row = Database::fetch_array($result)) {
                $session = SessionManager::fetch($row['id']);
                $sessionField = new ExtraField('session');
                $extraFieldData = $sessionField->getDataAndFormattedValues($row['id']);
                $ResultExtraField = [];
                foreach ($extraFieldData as $item) {
                    if ($item['variable'] === 'image') {
                        // Extraer la URL de la imagen desde el atributo href
                        preg_match('/href="([^"]+)"/', $item['value'], $matches);
                        $ResultExtraField['image'] = $matches[1] ?? null;
                    } elseif ($item['variable'] === 'video_url_session') {
                        $ResultExtraField['video'] = $item['value'];
                    }
                }
                $session['ordering'] = intval($row['ordering']);
                $session['url'] = api_get_path(WEB_PATH).'view/course/'. $row['id'];
                $session['extra'] = $ResultExtraField;
                $session['description'] = ucfirst(strtolower(strip_tags($session['description'])));
                $sessions[] = $session;
            }
        }
        return $sessions;
    }
    private function filterSessionList( $categoryID = 0, $filterTag = -1): array
    {
        $itemTable = Database::get_main_table(self::TABLE_BUYCOURSE_ITEM);
        $urlsTable = Database::get_main_table(self::TABLE_SHORTIFY_URL);
        $sessionTable = Database::get_main_table(TABLE_MAIN_SESSION);
        $urlTagsTable = Database::get_main_table(self::TABLE_SHORTIFY_URL_TAGS);

        $yesterdayDateOne = date('Y-m-d', strtotime("+0 day"));
        $yesterdayDateTwo = date('Y-m-d', strtotime("+1 day"));

        $sql = "SELECT s.id, s.reference_session, psu.reference, psu.ordering,
                GROUP_CONCAT(psut.tag_id ORDER BY psut.tag_id ASC) AS tag_ids FROM $sessionTable s
                INNER JOIN $itemTable i ON s.id = i.product_id
                INNER JOIN $urlsTable psu ON s.reference_session = psu.reference
                LEFT JOIN $urlTagsTable psut ON psut.reference = s.reference_session ";
        $sql.= "WHERE i.product_type = '2' AND s.session_category_id = '".$categoryID."'
                AND s.sale_start_date <= '".$yesterdayDateOne."' AND '".$yesterdayDateTwo."' <= s.sale_end_date ";

        if ($filterTag != -1 && $filterTag != 0) {
            $sql.= "AND psut.tag_id = '".$filterTag."' ";
        }

        $sql.= "GROUP BY s.id, s.reference_session, psu.reference, psu.ordering ORDER BY psu.ordering ASC ";

        $result = Database::query($sql);

        $sessionIds = [];
        if (Database::num_rows($result) > 0) {
            while ($row = Database::fetch_array($result)) {
                $sessionIds[] = [
                    'id' => $row['id'],
                    'reference' => $row['reference'],
                    'ordering' => $row['ordering']
                ];
            }
        }
        $sessions = [];
        foreach ($sessionIds as $sessionId) {
            $sessions[] = Database::getManager()->find(
                'ChamiloCoreBundle:Session',
                $sessionId['id']
            );
        }
        return $sessions;
    }

    /**
     * @throws \Doctrine\ORM\OptimisticLockException
     * @throws \Doctrine\ORM\TransactionRequiredException
     * @throws \Doctrine\ORM\ORMException
     */
    public function getCoursesByFiltering ($categoryID, $filterTag): array
    {

        $buy = BuyCoursesPlugin::create();
        $sessionCatalog = [];

        $sessions = $this->filterSessionList($categoryID, $filterTag);

        foreach ($sessions as $session) {
            $sessionCourses = $session->getCourses();
            if (empty($sessionCourses)) {
                continue;
            }

            $item = $buy->getItemByProduct(
                $session->getId(),
                $buy::PRODUCT_TYPE_SESSION
            );

            if (empty($item)) {
                continue;
            }

            $sessionData = $buy->getSessionInfo($session->getId());
            $sessionData['coach'] = $session->getGeneralCoach()->getCompleteName();
            $sessionData['enrolled'] = $buy->getUserStatusForSession(
                api_get_user_id(),
                $session
            );
            $sessionData['category_id'] = $session->getCategory()->getId();
            $sessionData['courses'] = [];

            foreach ($sessionCourses as $sessionCourse) {
                $course = $sessionCourse->getCourse();
                $sessionCourseData = [
                    'title' => $course->getTitle(),
                    'coaches' => [],
                ];
                $userCourseSubscriptions = $session->getUserCourseSubscriptionsByStatus(
                    $course,
                    Chamilo\CoreBundle\Entity\Session::COACH
                );

                foreach ($userCourseSubscriptions as $userCourseSubscription) {
                    $user = $userCourseSubscription->getUser();
                    $sessionCourseData['coaches'][] = $user->getCompleteName();
                }

                $sessionData['courses'][] = $sessionCourseData;
            }
            $sessionCatalog[] = $sessionData;
        }

        return $sessionCatalog;

    }

    public function getToolsCourseHome($sessionId, $courseId): array
    {
        $session = $this->getInfoSession($sessionId);
        $cidReq = api_get_cidreq();
        $tools = CourseHome::get_tools_category(
            TOOL_STUDENT_VIEW,
            $courseId,
            $sessionId
        );

        $course = api_get_course_info_by_id($courseId);
        $textCalendar = self::getDescriptionCourse($sessionId, $courseId,8,'Calendario');

        $calendarCourseHTML = '<ul class="description-box">';
        foreach ($textCalendar as $calendar) {
            $calendarCourseHTML .= ' <li class="description-title"><h4 class="title">' . $course['name'] . '</h4>';
            $calendarCourseHTML .= '<div class="description-content">' . $calendar['content'] . '</div>';
            $calendarCourseHTML .= '</li>';
        }
        $calendarCourseHTML .= '</ul>';

        $sessionCategoryId = !empty($session['session_category_id']) ? $session['session_category_id'] : 0;
        if($sessionCategoryId != 5){
            $ArrayDescription = self::getDescriptionCourse($sessionId, $courseId);
            $ArrayDescription = array_filter($ArrayDescription, function($item) {
                return $item['description_type'] != '8';
            });
            $ArrayDescription = array_values($ArrayDescription);
        } else {
            $ArrayDescription = self::getDescriptionCourse($sessionId, $courseId, 8,'Desc');
        }

        $descriptionHTML = '<ul class="description-box">';
        foreach ($ArrayDescription as $description) {
            $descriptionHTML.= ' <li class="description-title"><h4 class="title">'.$description['title'].'</h4>';
            $descriptionHTML.= '<div class="description-content">'.$description['content'].'</div>';
            $descriptionHTML.= '</li>';
        }
        $descriptionHTML .= '</ul>';

        foreach ($tools as &$tool) {
            if (isset($tool['image'])) {
                $tool['label'] = pathinfo($tool['image'], PATHINFO_FILENAME); // elimina la extensión .gif
            } else {
                $tool['label'] = null;
            }
        }
        unset($tool);

        $tmpTools = [];
        $descriptionVisibility = false;
        foreach ($tools as &$tool) {

            if($tool['image'] === 'info.gif') {
                $descriptionVisibility = true;
            }

            $link = api_get_path(WEB_CODE_PATH).$tool['link'].'?&'.$cidReq;
            if($tool['category'] == 'plugin'){
                $link = api_get_path(WEB_PLUGIN_PATH).$tool['link'].'?&'.$cidReq;
            }
            $toolName = Security::remove_XSS(stripslashes(strip_tags($tool['name'])));
            $toolName = api_underscore_to_camel_case($toolName);

            if (isset($tool['category']) && 'plugin' !== $tool['category'] &&
                isset($GLOBALS['Tool'.$toolName])
            ) {
                $toolName = get_lang('Tool'.$toolName);
            }
            $newDocumentsLinks = api_get_path(WEB_PATH).'documents';
            $tmpTools[] = [
                'iid' => $tool['iid'],
                'id' => $tool['id'],
                'c_id' => $tool['c_id'],
                'name' => $toolName,
                'label' => $tool['label'],
                'icon' => self::get_svg_icon($tool['label'], self::get_lang('SupplementaryMaterial'), 64),
                'link' => ($tool['label'] === 'folder_document') ? $newDocumentsLinks : $link,
            ];
        }

        //$pdfURL = $this->getSessionTabURL($session['reference_session']);

        $toolsHome = [];
        if($descriptionVisibility){
            $toolsHome = [
                [
                    'iid' => 1,
                    'id' => 1,
                    'c_id' => $courseId,
                    'name' => self::get_lang('ToolCalendar'),
                    'label' => 'tool_calendar',
                    'icon' => self::get_svg_icon('tool_calendar', self::get_lang('ToolCalendar'), 64),
                    'link' => '#',
                    'data' => '<div id="data_tool_calendar" class="d-none">'.$calendarCourseHTML.'</div>',
                ],
                [
                    'iid' => 2,
                    'id' => 2,
                    'c_id' => $courseId,
                    'name' => self::get_lang('SeeFile'),
                    'label' => 'tool_chip',
                    'icon' => self::get_svg_icon('tool_chip', self::get_lang('SeeFile'), 64),
                    'link' => '#',
                    'data' => '<div id="data_tool_description" class="d-none">'.$descriptionHTML.'</div>',
                ]
            ];
        }


        $results = [
            'home' => $toolsHome,
            'scorm' => [],
            'tools' => []
        ];

        foreach ($tmpTools as $tool) {
            if (!isset($tool['label'])) {
                continue;
            }

            switch ($tool['label']) {
                case 'scormbuilder':
                    $results['scorm'][] = $tool;
                    break;

                case 'folder_document':
                    $tool['link'] = api_get_path(WEB_PATH).'documents?'.$cidReq;
                    $results['home'][] = $tool;
                    break;

                case 'info':
                    // No hacer nada, se excluye
                    break;

                default:
                    $results['tools'][] = $tool;
                    break;
            }
        }

        return $results;

    }

    public static function generateQRImage($text)
    {

        if (!empty($text) ) {
            $qrCode = new QrCode($text);
            $qrCode->setSize(120);
            $qrCode->setMargin(5);
            $qrCode->setErrorCorrectionLevel(ErrorCorrectionLevel::MEDIUM());
            $qrCode->setForegroundColor(['r' => 0, 'g' => 0, 'b' => 0, 'a' => 0]);
            $qrCode->setBackgroundColor(['r' => 255, 'g' => 255, 'b' => 255, 'a' => 0]);
            $qrCode->setValidateResult(false);
            $image = $qrCode->writeString();
            $imageQR=base64_encode($image);

            return $imageQR;
        }

        return false;
    }

    public function getHeaderTemplate(): string
    {
        $this->setCurrentSection('dashboard');
        $this->setSidebar('dashboard');
        return $this->fetch('layout/header.tpl');
    }

    public function getFooterTemplate(): string
    {
        $this->setCurrentSection('dashboard');
        $this->setSidebar('dashboard');
        return $this->fetch('layout/footer.tpl');
    }

    public  function getCountriesData(): array
    {
        require_once __DIR__.'/src/countries_data.php';

        // Obtener todos los países

        return getCountriesData();
    }
    public function registerCountryUser($idUser, $idCountry): void
    {
        $userTable = Database::get_main_table(
            TABLE_MAIN_USER
        );
        Database::update(
            $userTable,
            ['country' => $idCountry],
            ['id = ?' => (int)$idUser]
        );
    }

    public function requireLogin()
    {
        if (!api_get_user_id()) {
            $currentUrl = $_SERVER['REQUEST_URI'];
            $_SESSION['school_plugin_redirect'] = $currentUrl;

            // Apuntar al archivo intermedio que manejará la redirección
            $checkUrl = api_get_path(WEB_PLUGIN_PATH) . 'school/check_redirect.php';
            $_SESSION['redirect_after_login'] = $checkUrl;

            $loginUrl = api_get_path(WEB_PATH) . 'index.php';

            echo '<!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta http-equiv="refresh" content="0;url=' . htmlspecialchars($loginUrl) . '">
            <script type="text/javascript">
                if (window.top !== window.self) {
                    window.top.location.href = "' . htmlspecialchars($loginUrl) . '";
                } else {
                    window.location.href = "' . htmlspecialchars($loginUrl) . '";
                }
            </script>
        </head>
        <body>
            <p>Sesión expirada. Redirigiendo...</p>
        </body>
        </html>';
            exit;
        }
        return true;
    }

    /**
     * Procesa la redirección después del login
     * Llamar esto después de un login exitoso
     */
    public function handleLoginRedirect()
    {
        if (!empty($_SESSION['school_plugin_redirect'])) {
            $redirectUrl = $_SESSION['school_plugin_redirect'];
            unset($_SESSION['school_plugin_redirect']);
            header('Location: ' . $redirectUrl);
            exit;
        }
    }
}
