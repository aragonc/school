<?php

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

    const TABLE_SCHOOL_ATTENDANCE_SCHEDULE = 'plugin_school_attendance_schedule';
    const TABLE_SCHOOL_ATTENDANCE_LOG = 'plugin_school_attendance_log';
    const TABLE_SCHOOL_ATTENDANCE_QR = 'plugin_school_attendance_qr_token';
    const TABLE_SCHOOL_EXTRA_PROFILE = 'plugin_school_extra_profile';

    const TABLE_SCHOOL_PAYMENT_PERIOD = 'plugin_school_payment_period';
    const TABLE_SCHOOL_PAYMENT = 'plugin_school_payment';
    const TABLE_SCHOOL_PAYMENT_DISCOUNT = 'plugin_school_payment_discount';

    const TABLE_SCHOOL_PRODUCT = 'plugin_school_product';
    const TABLE_SCHOOL_PRODUCT_SALE = 'plugin_school_product_sale';
    const TABLE_SCHOOL_PRODUCT_CATEGORY = 'plugin_school_product_category';

    const TABLE_SCHOOL_ACADEMIC_YEAR = 'plugin_school_academic_year';
    const TABLE_SCHOOL_ACADEMIC_LEVEL = 'plugin_school_academic_level';
    const TABLE_SCHOOL_ACADEMIC_GRADE = 'plugin_school_academic_grade';
    const TABLE_SCHOOL_ACADEMIC_SECTION = 'plugin_school_academic_section';
    const TABLE_SCHOOL_ACADEMIC_CLASSROOM = 'plugin_school_academic_classroom';
    const TABLE_SCHOOL_ACADEMIC_CLASSROOM_STUDENT = 'plugin_school_academic_classroom_student';
    const TABLE_SCHOOL_PAYMENT_PERIOD_PRICE = 'plugin_school_payment_period_price';

    const TABLE_SCHOOL_FICHA               = 'plugin_school_ficha';
    const TABLE_SCHOOL_MATRICULA           = 'plugin_school_matricula';
    const TABLE_SCHOOL_MATRICULA_PADRE     = 'plugin_school_matricula_padre';
    const TABLE_SCHOOL_MATRICULA_CONTACTO  = 'plugin_school_matricula_contacto';
    const TABLE_SCHOOL_MATRICULA_INFO      = 'plugin_school_matricula_info';

    const TEMPLATE_ZERO = 0;
    const INTERFACE_ONE = 1;
    protected function __construct()
    {
        parent::__construct(
            '1.5.0',
            'Alex Aragon <alex.aragon@tunqui.pe>',
            $this->extendAttributes([
                'tool_enable' => 'boolean',
                'activate_search' => 'boolean',
                'activate_shopping' => 'boolean',
                'email_help' => 'text',
                'enable_complete_profile' => 'boolean',
                'show_base_courses' => 'boolean',
                'show_certificates' => 'boolean',
                'show_notifications' => 'boolean',
                'show_help' => 'boolean',
                'show_previous_tab' => 'boolean',
                'template_certificate' => [
                    'type' => 'select',
                    'options' => [
                        self::TEMPLATE_ZERO => 'Plantilla por defecto',
                        self::INTERFACE_ONE => 'Plantilla Sence',
                    ],
                ],
                'google_client_id' => 'text',
                'google_client_secret' => 'text',
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

        $css[] = api_get_cdn_path(api_get_path(WEB_PUBLIC_PATH) . 'assets/jquery-ui/themes/smoothness/jquery-ui.min.css');
        $css[] = api_get_cdn_path(api_get_path(WEB_PUBLIC_PATH) . 'assets/jquery-ui/themes/smoothness/theme.css');
        $css[] = api_get_cdn_path(api_get_path(WEB_PUBLIC_PATH) . 'assets/jqueryui-timepicker-addon/dist/jquery-ui-timepicker-addon.min.css');
        $css[] = api_get_cdn_path(api_get_path(WEB_PUBLIC_PATH) . 'assets/select2/dist/css/select2.min.css');
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
            $this->assign('favicon_type', self::get_favicon_type());
        }
    }

    public function get_favicon($iconName): string
    {
        $uploadedPng = __DIR__ . '/uploads/favicon.png';
        if (file_exists($uploadedPng)) {
            return api_get_path(WEB_PLUGIN_PATH) . 'school/uploads/favicon.png';
        }
        $icon_path = __DIR__ . '/img/icons/' . $iconName . '.svg';
        if (file_exists($icon_path)) {
            return api_get_path(WEB_PLUGIN_PATH) . 'school/img/icons/' . $iconName . '.svg';
        }
        return '';
    }

    public function get_favicon_type(): string
    {
        $uploadedPng = __DIR__ . '/uploads/favicon.png';
        return file_exists($uploadedPng) ? 'image/png' : 'image/svg+xml';
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

        $sql3 = "CREATE TABLE IF NOT EXISTS ".self::TABLE_SCHOOL_ATTENDANCE_SCHEDULE." (
            id INT unsigned NOT NULL auto_increment PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            entry_time TIME NOT NULL,
            late_time TIME NOT NULL,
            applies_to VARCHAR(255) NOT NULL DEFAULT 'all',
            active TINYINT(1) NOT NULL DEFAULT 1,
            created_at DATETIME NOT NULL
        )";
        Database::query($sql3);

        $sql4 = "CREATE TABLE IF NOT EXISTS ".self::TABLE_SCHOOL_ATTENDANCE_LOG." (
            id INT unsigned NOT NULL auto_increment PRIMARY KEY,
            user_id INT NOT NULL,
            schedule_id INT unsigned NULL,
            check_in DATETIME NOT NULL,
            status ENUM('on_time','late','absent') NOT NULL DEFAULT 'on_time',
            method ENUM('qr','manual') NOT NULL DEFAULT 'manual',
            registered_by INT NULL,
            date DATE NOT NULL,
            notes TEXT NULL,
            created_at DATETIME NOT NULL,
            UNIQUE KEY unique_user_date (user_id, date)
        )";
        Database::query($sql4);

        $sql5 = "CREATE TABLE IF NOT EXISTS ".self::TABLE_SCHOOL_ATTENDANCE_QR." (
            id INT unsigned NOT NULL auto_increment PRIMARY KEY,
            token VARCHAR(64) NOT NULL,
            date DATE NOT NULL,
            created_by INT NOT NULL,
            expires_at DATETIME NOT NULL,
            created_at DATETIME NOT NULL,
            UNIQUE KEY unique_token (token)
        )";
        Database::query($sql5);

        $sql6 = "CREATE TABLE IF NOT EXISTS ".self::TABLE_SCHOOL_EXTRA_PROFILE." (
            id INT unsigned NOT NULL auto_increment PRIMARY KEY,
            user_id INT NOT NULL,
            document_type ENUM('DNI','CE','PASAPORTE','OTRO') NOT NULL DEFAULT 'DNI',
            document_number VARCHAR(50) NULL,
            birthdate DATE NULL,
            address VARCHAR(500) NULL,
            address_reference VARCHAR(255) NULL,
            phone VARCHAR(50) NULL,
            district VARCHAR(100) NULL,
            province VARCHAR(100) NULL,
            region VARCHAR(100) NULL,
            updated_at DATETIME NULL,
            UNIQUE KEY unique_user (user_id)
        )";
        Database::query($sql6);

        // Payment tables
        $sql7p = "CREATE TABLE IF NOT EXISTS ".self::TABLE_SCHOOL_PAYMENT_PERIOD." (
            id INT unsigned NOT NULL auto_increment PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            year SMALLINT NOT NULL,
            admission_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
            enrollment_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
            monthly_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
            months VARCHAR(100) NOT NULL DEFAULT '',
            active TINYINT(1) NOT NULL DEFAULT 1,
            created_at DATETIME NOT NULL
        )";
        Database::query($sql7p);

        // Add admission_amount column if not exists (migration)
        $periodTable = Database::get_main_table(self::TABLE_SCHOOL_PAYMENT_PERIOD);
        $colCheck = Database::query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '$periodTable' AND COLUMN_NAME = 'admission_amount'");
        if (Database::num_rows($colCheck) === 0) {
            Database::query("ALTER TABLE $periodTable ADD COLUMN admission_amount DECIMAL(10,2) NOT NULL DEFAULT 0 AFTER year");
        }

        $sql8p = "CREATE TABLE IF NOT EXISTS ".self::TABLE_SCHOOL_PAYMENT." (
            id INT unsigned NOT NULL auto_increment PRIMARY KEY,
            period_id INT unsigned NOT NULL,
            user_id INT NOT NULL,
            type ENUM('admission','enrollment','monthly') NOT NULL,
            month TINYINT NULL,
            amount DECIMAL(10,2) NOT NULL DEFAULT 0,
            discount DECIMAL(10,2) NOT NULL DEFAULT 0,
            original_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
            payment_date DATE NULL,
            payment_method VARCHAR(50) NULL,
            reference VARCHAR(255) NULL,
            receipt_number VARCHAR(20) NULL,
            voucher VARCHAR(255) NULL,
            notes TEXT NULL,
            status ENUM('paid','pending','partial') NOT NULL DEFAULT 'pending',
            registered_by INT NULL,
            created_at DATETIME NOT NULL,
            updated_at DATETIME NULL,
            UNIQUE KEY unique_payment (period_id, user_id, type, month)
        )";
        Database::query($sql8p);

        // Add receipt_number and voucher columns if not exists (migration)
        $payTable = Database::get_main_table(self::TABLE_SCHOOL_PAYMENT);
        $col8m = Database::query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '$payTable' AND COLUMN_NAME = 'receipt_number'");
        if (Database::num_rows($col8m) === 0) {
            Database::query("ALTER TABLE $payTable ADD COLUMN receipt_number VARCHAR(20) NULL AFTER reference");
        }
        $col8v = Database::query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '$payTable' AND COLUMN_NAME = 'voucher'");
        if (Database::num_rows($col8v) === 0) {
            Database::query("ALTER TABLE $payTable ADD COLUMN voucher VARCHAR(255) NULL AFTER receipt_number");
        }

        // Add admission to type ENUM (migration)
        @Database::query("ALTER TABLE $payTable MODIFY type ENUM('admission','enrollment','monthly') NOT NULL");

        $sql9p = "CREATE TABLE IF NOT EXISTS ".self::TABLE_SCHOOL_PAYMENT_DISCOUNT." (
            id INT unsigned NOT NULL auto_increment PRIMARY KEY,
            period_id INT unsigned NOT NULL,
            user_id INT NOT NULL,
            discount_type ENUM('percentage','fixed') NOT NULL DEFAULT 'fixed',
            discount_value DECIMAL(10,2) NOT NULL DEFAULT 0,
            applies_to ENUM('admission','enrollment','monthly','all') NOT NULL DEFAULT 'all',
            reason VARCHAR(255) NULL,
            excluded_months VARCHAR(100) NULL,
            created_by INT NOT NULL,
            created_at DATETIME NOT NULL
        )";
        Database::query($sql9p);

        // Migration: add excluded_months column to existing discount tables
        $discountTable = Database::get_main_table(self::TABLE_SCHOOL_PAYMENT_DISCOUNT);
        $colExcluded = Database::query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '$discountTable' AND COLUMN_NAME = 'excluded_months'");
        if (Database::num_rows($colExcluded) === 0) {
            Database::query("ALTER TABLE $discountTable ADD COLUMN excluded_months VARCHAR(100) NULL AFTER reason");
        }

        // Product tables
        $sqlProdCat = "CREATE TABLE IF NOT EXISTS ".self::TABLE_SCHOOL_PRODUCT_CATEGORY." (
            id INT unsigned NOT NULL auto_increment PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            active TINYINT(1) NOT NULL DEFAULT 1,
            created_at DATETIME NOT NULL
        )";
        Database::query($sqlProdCat);

        $sqlProd1 = "CREATE TABLE IF NOT EXISTS ".self::TABLE_SCHOOL_PRODUCT." (
            id INT unsigned NOT NULL auto_increment PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            description TEXT NULL,
            price DECIMAL(10,2) NOT NULL DEFAULT 0,
            category_id INT unsigned NULL,
            active TINYINT(1) NOT NULL DEFAULT 1,
            created_at DATETIME NOT NULL
        )";
        Database::query($sqlProd1);

        // Migration: rename category to category_id if needed
        $prodTable = Database::get_main_table(self::TABLE_SCHOOL_PRODUCT);
        $colCat = Database::query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '$prodTable' AND COLUMN_NAME = 'category'");
        if (Database::num_rows($colCat) > 0) {
            Database::query("ALTER TABLE $prodTable DROP COLUMN category");
        }
        $colCatId = Database::query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '$prodTable' AND COLUMN_NAME = 'category_id'");
        if (Database::num_rows($colCatId) === 0) {
            Database::query("ALTER TABLE $prodTable ADD COLUMN category_id INT unsigned NULL AFTER price");
        }

        $sqlProd2 = "CREATE TABLE IF NOT EXISTS ".self::TABLE_SCHOOL_PRODUCT_SALE." (
            id INT unsigned NOT NULL auto_increment PRIMARY KEY,
            product_id INT unsigned NOT NULL,
            user_id INT NOT NULL,
            quantity INT NOT NULL DEFAULT 1,
            unit_price DECIMAL(10,2) NOT NULL DEFAULT 0,
            discount DECIMAL(10,2) NOT NULL DEFAULT 0,
            total_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
            payment_method VARCHAR(50) NULL,
            reference VARCHAR(255) NULL,
            receipt_number VARCHAR(20) NULL,
            notes TEXT NULL,
            status ENUM('paid','pending') NOT NULL DEFAULT 'paid',
            registered_by INT NULL,
            created_at DATETIME NOT NULL
        )";
        Database::query($sqlProd2);

        // Migrate applies_to column from ENUM to VARCHAR if needed
        $scheduleTable = Database::get_main_table(self::TABLE_SCHOOL_ATTENDANCE_SCHEDULE);
        $sql7 = "ALTER TABLE $scheduleTable MODIFY applies_to VARCHAR(255) NOT NULL DEFAULT 'all'";
        @Database::query($sql7);

        // Migrate old values: 'staff' -> 'teacher,secretary,auxiliary', 'students' -> 'student'
        $sql8 = "UPDATE $scheduleTable SET applies_to = 'teacher,secretary,auxiliary' WHERE applies_to = 'staff'";
        @Database::query($sql8);
        $sql9 = "UPDATE $scheduleTable SET applies_to = 'student' WHERE applies_to = 'students'";
        @Database::query($sql9);

        // Academic tables
        $sqlAcad1 = "CREATE TABLE IF NOT EXISTS ".self::TABLE_SCHOOL_ACADEMIC_YEAR." (
            id INT unsigned NOT NULL auto_increment PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            year SMALLINT NOT NULL,
            active TINYINT(1) NOT NULL DEFAULT 1,
            created_at DATETIME NOT NULL
        )";
        Database::query($sqlAcad1);

        $sqlAcad2 = "CREATE TABLE IF NOT EXISTS ".self::TABLE_SCHOOL_ACADEMIC_LEVEL." (
            id INT unsigned NOT NULL auto_increment PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            order_index TINYINT NOT NULL DEFAULT 0,
            active TINYINT(1) NOT NULL DEFAULT 1,
            created_at DATETIME NOT NULL
        )";
        Database::query($sqlAcad2);

        $sqlAcad3 = "CREATE TABLE IF NOT EXISTS ".self::TABLE_SCHOOL_ACADEMIC_GRADE." (
            id INT unsigned NOT NULL auto_increment PRIMARY KEY,
            level_id INT unsigned NOT NULL,
            name VARCHAR(100) NOT NULL,
            order_index TINYINT NOT NULL DEFAULT 0,
            active TINYINT(1) NOT NULL DEFAULT 1,
            created_at DATETIME NOT NULL
        )";
        Database::query($sqlAcad3);

        $sqlAcad4 = "CREATE TABLE IF NOT EXISTS ".self::TABLE_SCHOOL_ACADEMIC_SECTION." (
            id INT unsigned NOT NULL auto_increment PRIMARY KEY,
            name VARCHAR(50) NOT NULL,
            active TINYINT(1) NOT NULL DEFAULT 1,
            created_at DATETIME NOT NULL
        )";
        Database::query($sqlAcad4);

        $sqlAcad5 = "CREATE TABLE IF NOT EXISTS ".self::TABLE_SCHOOL_ACADEMIC_CLASSROOM." (
            id INT unsigned NOT NULL auto_increment PRIMARY KEY,
            academic_year_id INT unsigned NOT NULL,
            grade_id INT unsigned NOT NULL,
            section_id INT unsigned NOT NULL,
            tutor_id INT NULL,
            capacity INT NOT NULL DEFAULT 30,
            active TINYINT(1) NOT NULL DEFAULT 1,
            created_at DATETIME NOT NULL,
            UNIQUE KEY unique_classroom (academic_year_id, grade_id, section_id)
        )";
        Database::query($sqlAcad5);

        $sqlAcad6 = "CREATE TABLE IF NOT EXISTS ".self::TABLE_SCHOOL_ACADEMIC_CLASSROOM_STUDENT." (
            id INT unsigned NOT NULL auto_increment PRIMARY KEY,
            classroom_id INT unsigned NOT NULL,
            user_id INT NOT NULL,
            enrolled_at DATETIME NOT NULL,
            UNIQUE KEY unique_student (classroom_id, user_id)
        )";
        Database::query($sqlAcad6);

        // Payment period pricing by level/grade
        $sqlPrice = "CREATE TABLE IF NOT EXISTS ".self::TABLE_SCHOOL_PAYMENT_PERIOD_PRICE." (
            id INT unsigned NOT NULL auto_increment PRIMARY KEY,
            period_id INT unsigned NOT NULL,
            level_id INT unsigned NOT NULL,
            grade_id INT unsigned NULL,
            admission_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
            enrollment_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
            monthly_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
            created_at DATETIME NOT NULL,
            UNIQUE KEY unique_price (period_id, level_id, grade_id)
        )";
        Database::query($sqlPrice);

        // =====================================================================
        // FICHA (datos personales permanentes del alumno)
        // =====================================================================
        $sqlFicha = "CREATE TABLE IF NOT EXISTS ".self::TABLE_SCHOOL_FICHA." (
            id INT unsigned NOT NULL auto_increment PRIMARY KEY,
            user_id INT NULL,
            apellido_paterno VARCHAR(100) NULL,
            apellido_materno VARCHAR(100) NULL,
            nombres VARCHAR(100) NOT NULL DEFAULT '',
            sexo ENUM('F','M') NULL,
            dni CHAR(8) NULL,
            tipo_documento VARCHAR(20) NULL,
            tipo_sangre VARCHAR(5) NULL,
            fecha_nacimiento DATE NULL,
            nacionalidad VARCHAR(50) NULL DEFAULT 'Peruana',
            peso DECIMAL(5,2) NULL,
            estatura DECIMAL(4,2) NULL,
            domicilio VARCHAR(255) NULL,
            region VARCHAR(10) NULL,
            provincia VARCHAR(10) NULL,
            distrito VARCHAR(10) NULL,
            tiene_alergias TINYINT(1) NOT NULL DEFAULT 0,
            alergias_detalle VARCHAR(255) NULL,
            usa_lentes TINYINT(1) NOT NULL DEFAULT 0,
            tiene_discapacidad TINYINT(1) NOT NULL DEFAULT 0,
            discapacidad_detalle VARCHAR(255) NULL,
            ie_procedencia VARCHAR(150) NULL,
            motivo_traslado TEXT NULL,
            foto VARCHAR(255) NULL,
            created_by INT NOT NULL DEFAULT 0,
            created_at DATETIME NOT NULL,
            updated_at DATETIME NULL,
            UNIQUE KEY unique_ficha_user (user_id)
        )";
        Database::query($sqlFicha);

        // =====================================================================
        // MATRÍCULA (datos anuales variables)
        // =====================================================================
        $sqlMat1 = "CREATE TABLE IF NOT EXISTS ".self::TABLE_SCHOOL_MATRICULA." (
            id INT unsigned NOT NULL auto_increment PRIMARY KEY,
            ficha_id INT unsigned NOT NULL,
            academic_year_id INT unsigned NULL,
            grade_id INT unsigned NULL,
            estado ENUM('ACTIVO','RETIRADO') NOT NULL DEFAULT 'ACTIVO',
            tipo_ingreso ENUM('NUEVO_INGRESO','REINGRESO','CONTINUACION') NOT NULL DEFAULT 'NUEVO_INGRESO',
            created_by INT NOT NULL DEFAULT 0,
            created_at DATETIME NOT NULL,
            updated_at DATETIME NULL,
            UNIQUE KEY unique_ficha_year (ficha_id, academic_year_id)
        )";
        Database::query($sqlMat1);

        // =====================================================================
        // MIGRATION: plugin_school_matricula → plugin_school_ficha + new matricula
        // =====================================================================
        $fichaTable = Database::get_main_table(self::TABLE_SCHOOL_FICHA);
        $matTable   = Database::get_main_table(self::TABLE_SCHOOL_MATRICULA);

        // Detect if this is a legacy install needing migration
        // (legacy has personal columns like 'nombres' in plugin_school_matricula)
        $chkNombres = Database::query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '$matTable' AND COLUMN_NAME = 'nombres'");
        $isLegacy = Database::num_rows($chkNombres) > 0;

        if ($isLegacy) {
            // --- Legacy schema migrations still needed on old matricula table ---
            // Rename old nombres_apellidos → nombres
            $colOld = Database::query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '$matTable' AND COLUMN_NAME = 'nombres_apellidos'");
            if (Database::num_rows($colOld) > 0) {
                Database::query("ALTER TABLE $matTable CHANGE nombres_apellidos nombres VARCHAR(100) NOT NULL DEFAULT ''");
            }
            // Ensure all personal columns exist before migration
            foreach ([
                'apellido_paterno' => "VARCHAR(100) NULL AFTER tipo_ingreso",
                'apellido_materno' => "VARCHAR(100) NULL AFTER apellido_paterno",
                'region'           => "VARCHAR(10) NULL AFTER domicilio",
                'provincia'        => "VARCHAR(10) NULL AFTER region",
                'distrito'         => "VARCHAR(10) NULL AFTER provincia",
                'academic_year_id' => "INT unsigned NULL AFTER user_id",
                'estado'           => "ENUM('ACTIVO','RETIRADO') NOT NULL DEFAULT 'ACTIVO' AFTER academic_year_id",
                'foto'             => "VARCHAR(255) NULL AFTER dni",
                'tipo_documento'   => "VARCHAR(20) NULL AFTER dni",
            ] as $col => $def) {
                $chk = Database::query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '$matTable' AND COLUMN_NAME = '$col'");
                if (Database::num_rows($chk) === 0) {
                    Database::query("ALTER TABLE $matTable ADD COLUMN $col $def");
                }
            }
            // Extend tipo_ingreso ENUM
            $chkEnum = Database::query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '$matTable' AND COLUMN_NAME = 'tipo_ingreso' AND COLUMN_TYPE LIKE '%CONTINUACION%'");
            if (Database::num_rows($chkEnum) === 0) {
                Database::query("ALTER TABLE $matTable MODIFY tipo_ingreso ENUM('NUEVO_INGRESO','REINGRESO','CONTINUACION') NOT NULL DEFAULT 'NUEVO_INGRESO'");
            }

            // Check if ficha_id already added to matricula (migration already ran partially)
            $chkFichaId = Database::query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '$matTable' AND COLUMN_NAME = 'ficha_id'");
            if (Database::num_rows($chkFichaId) === 0) {
                // Add ficha_id column to matricula
                Database::query("ALTER TABLE $matTable ADD COLUMN ficha_id INT unsigned NULL AFTER id");

                // Build fichas from existing matricula rows
                $userFichaMap = [];
                $allMat = Database::query("SELECT * FROM $matTable ORDER BY id ASC");
                while ($row = Database::fetch_array($allMat, 'ASSOC')) {
                    $uid = isset($row['user_id']) && $row['user_id'] ? (int) $row['user_id'] : null;
                    if ($uid !== null && isset($userFichaMap[$uid])) {
                        $fichaId = $userFichaMap[$uid];
                    } else {
                        $fichaParams = [
                            'user_id'              => $uid,
                            'apellido_paterno'     => $row['apellido_paterno'] ?? null,
                            'apellido_materno'     => $row['apellido_materno'] ?? null,
                            'nombres'              => $row['nombres'] ?? '',
                            'sexo'                 => $row['sexo'] ?? null,
                            'dni'                  => $row['dni'] ?? null,
                            'tipo_documento'       => $row['tipo_documento'] ?? null,
                            'tipo_sangre'          => $row['tipo_sangre'] ?? null,
                            'fecha_nacimiento'     => $row['fecha_nacimiento'] ?? null,
                            'nacionalidad'         => $row['nacionalidad'] ?? 'Peruana',
                            'peso'                 => isset($row['peso']) && $row['peso'] !== '' ? (float) $row['peso'] : null,
                            'estatura'             => isset($row['estatura']) && $row['estatura'] !== '' ? (float) $row['estatura'] : null,
                            'domicilio'            => $row['domicilio'] ?? null,
                            'region'               => $row['region'] ?? null,
                            'provincia'            => $row['provincia'] ?? null,
                            'distrito'             => $row['distrito'] ?? null,
                            'tiene_alergias'       => (int) ($row['tiene_alergias'] ?? 0),
                            'alergias_detalle'     => $row['alergias_detalle'] ?? null,
                            'usa_lentes'           => (int) ($row['usa_lentes'] ?? 0),
                            'tiene_discapacidad'   => (int) ($row['tiene_discapacidad'] ?? 0),
                            'discapacidad_detalle' => $row['discapacidad_detalle'] ?? null,
                            'ie_procedencia'       => $row['ie_procedencia'] ?? null,
                            'motivo_traslado'      => $row['motivo_traslado'] ?? null,
                            'foto'                 => $row['foto'] ?? null,
                            'created_by'           => (int) ($row['created_by'] ?? 0),
                            'created_at'           => $row['created_at'],
                            'updated_at'           => $row['updated_at'] ?? null,
                        ];
                        $fichaId = (int) Database::insert($fichaTable, $fichaParams);
                        if ($uid !== null && $fichaId > 0) {
                            $userFichaMap[$uid] = $fichaId;
                        }
                    }
                    if ($fichaId > 0) {
                        Database::query("UPDATE $matTable SET ficha_id = $fichaId WHERE id = " . (int) $row['id']);
                    }
                }

                // Migrate padre table: add ficha_id, populate, deduplicate
                $padreTable = Database::get_main_table(self::TABLE_SCHOOL_MATRICULA_PADRE);
                $chkPF = Database::query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
                    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '$padreTable' AND COLUMN_NAME = 'ficha_id'");
                if (Database::num_rows($chkPF) === 0) {
                    Database::query("ALTER TABLE $padreTable ADD COLUMN ficha_id INT unsigned NULL AFTER id");
                    Database::query("UPDATE $padreTable p JOIN $matTable m ON m.id = p.matricula_id SET p.ficha_id = m.ficha_id WHERE m.ficha_id IS NOT NULL");
                    Database::query("DELETE p1 FROM $padreTable p1
                        JOIN $padreTable p2 ON p2.ficha_id = p1.ficha_id AND p2.parentesco = p1.parentesco AND p2.id > p1.id
                        WHERE p1.ficha_id IS NOT NULL");
                }

                // Migrate contacto table
                $contactoTable = Database::get_main_table(self::TABLE_SCHOOL_MATRICULA_CONTACTO);
                $chkCF = Database::query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
                    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '$contactoTable' AND COLUMN_NAME = 'ficha_id'");
                if (Database::num_rows($chkCF) === 0) {
                    Database::query("ALTER TABLE $contactoTable ADD COLUMN ficha_id INT unsigned NULL AFTER id");
                    Database::query("UPDATE $contactoTable c JOIN $matTable m ON m.id = c.matricula_id SET c.ficha_id = m.ficha_id WHERE m.ficha_id IS NOT NULL");
                    Database::query("DELETE c1 FROM $contactoTable c1
                        JOIN $contactoTable c2 ON c2.ficha_id = c1.ficha_id AND c2.id > c1.id
                        WHERE c1.ficha_id IS NOT NULL");
                }

                // Migrate info table
                $infoTable = Database::get_main_table(self::TABLE_SCHOOL_MATRICULA_INFO);
                $chkIF = Database::query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
                    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '$infoTable' AND COLUMN_NAME = 'ficha_id'");
                if (Database::num_rows($chkIF) === 0) {
                    Database::query("ALTER TABLE $infoTable ADD COLUMN ficha_id INT unsigned NULL AFTER id");
                    Database::query("UPDATE $infoTable i JOIN $matTable m ON m.id = i.matricula_id SET i.ficha_id = m.ficha_id WHERE m.ficha_id IS NOT NULL");
                    Database::query("DELETE i1 FROM $infoTable i1
                        JOIN $infoTable i2 ON i2.ficha_id = i1.ficha_id AND i2.id > i1.id
                        WHERE i1.ficha_id IS NOT NULL");
                }

                // Add ficha_id column to padre/contacto/info for new-install path
                foreach ([
                    self::TABLE_SCHOOL_MATRICULA_PADRE    => $padreTable,
                    self::TABLE_SCHOOL_MATRICULA_CONTACTO => $contactoTable,
                    self::TABLE_SCHOOL_MATRICULA_INFO     => $infoTable,
                ] as $constName => $tbl) {
                    $chk = Database::query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
                        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '$tbl' AND COLUMN_NAME = 'ficha_id'");
                    if (Database::num_rows($chk) === 0) {
                        Database::query("ALTER TABLE $tbl ADD COLUMN ficha_id INT unsigned NULL AFTER id");
                    }
                }
            }
        }

        $sqlMat2 = "CREATE TABLE IF NOT EXISTS ".self::TABLE_SCHOOL_MATRICULA_PADRE." (
            id INT unsigned NOT NULL auto_increment PRIMARY KEY,
            ficha_id INT unsigned NOT NULL,
            matricula_id INT unsigned NULL,
            parentesco ENUM('MADRE','PADRE') NOT NULL,
            apellidos VARCHAR(100) NULL,
            nombres VARCHAR(100) NULL,
            celular VARCHAR(15) NULL,
            ocupacion VARCHAR(100) NULL,
            dni CHAR(8) NULL,
            edad TINYINT unsigned NULL,
            religion VARCHAR(50) NULL,
            tipo_parto ENUM('CESAREA','NORMAL') NULL,
            vive_con_menor TINYINT(1) NULL
        )";
        Database::query($sqlMat2);

        $sqlMat3 = "CREATE TABLE IF NOT EXISTS ".self::TABLE_SCHOOL_MATRICULA_CONTACTO." (
            id INT unsigned NOT NULL auto_increment PRIMARY KEY,
            ficha_id INT unsigned NOT NULL,
            matricula_id INT unsigned NULL,
            nombre_contacto VARCHAR(150) NULL,
            telefono VARCHAR(15) NULL,
            direccion VARCHAR(255) NULL
        )";
        Database::query($sqlMat3);

        $sqlMat4 = "CREATE TABLE IF NOT EXISTS ".self::TABLE_SCHOOL_MATRICULA_INFO." (
            id INT unsigned NOT NULL auto_increment PRIMARY KEY,
            ficha_id INT unsigned NOT NULL,
            matricula_id INT unsigned NULL,
            encargados_cuidado VARCHAR(255) NULL,
            familiar_en_institucion VARCHAR(150) NULL,
            observaciones TEXT NULL,
            UNIQUE KEY unique_mat_info (ficha_id)
        )";
        Database::query($sqlMat4);

        // Add rewrite rules to .htaccess
        $this->addHtaccessRules();
    }

    public function uninstall()
    {
        $tablesToBeDeleted = [
            self::TABLE_SCHOOL_MATRICULA_INFO,
            self::TABLE_SCHOOL_MATRICULA_CONTACTO,
            self::TABLE_SCHOOL_MATRICULA_PADRE,
            self::TABLE_SCHOOL_MATRICULA,
            self::TABLE_SCHOOL_FICHA,
            self::TABLE_SCHOOL_SETTINGS,
            self::TABLE_SCHOOL_ATTENDANCE_LOG,
            self::TABLE_SCHOOL_ATTENDANCE_SCHEDULE,
            self::TABLE_SCHOOL_ATTENDANCE_QR,
            self::TABLE_SCHOOL_EXTRA_PROFILE,
            self::TABLE_SCHOOL_PAYMENT,
            self::TABLE_SCHOOL_PAYMENT_DISCOUNT,
            self::TABLE_SCHOOL_PAYMENT_PERIOD,
            self::TABLE_SCHOOL_PRODUCT_SALE,
            self::TABLE_SCHOOL_PRODUCT,
            self::TABLE_SCHOOL_PRODUCT_CATEGORY,
            self::TABLE_SCHOOL_PAYMENT_PERIOD_PRICE,
            self::TABLE_SCHOOL_ACADEMIC_CLASSROOM_STUDENT,
            self::TABLE_SCHOOL_ACADEMIC_CLASSROOM,
            self::TABLE_SCHOOL_ACADEMIC_GRADE,
            self::TABLE_SCHOOL_ACADEMIC_SECTION,
            self::TABLE_SCHOOL_ACADEMIC_LEVEL,
            self::TABLE_SCHOOL_ACADEMIC_YEAR,
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
            "RewriteRule ^courses$ plugin/school/src/courses/courses.php [L]\n".
            "RewriteRule ^previous$ plugin/school/src/courses/previous.php [L]\n".
            "RewriteRule ^view/course/(\\d{1,})$ plugin/school/src/courses/view.php?session_id=$1 [L]\n".
            "RewriteRule ^home/course/([^/]+)$ plugin/school/src/courses/home.php?cDir=$1 [L]\n".
            "RewriteRule ^attendance$ plugin/school/src/attendance/today.php [L]\n".
            "RewriteRule ^attendance/today$ plugin/school/src/attendance/today.php [L]\n".
            "RewriteRule ^attendance/manual$ plugin/school/src/attendance/manual.php [L]\n".
            "RewriteRule ^attendance/schedules$ plugin/school/src/attendance/schedules.php [L]\n".
            "RewriteRule ^attendance/reports$ plugin/school/src/attendance/reports.php [L]\n".
            "RewriteRule ^attendance/my$ plugin/school/src/attendance/my.php [L]\n".
            "RewriteRule ^attendance/scan$ plugin/school/src/attendance/scan.php [L,QSA]\n".
            "RewriteRule ^attendance/kiosk$ plugin/school/src/attendance/kiosk.php [L]\n".
            "RewriteRule ^profile$ plugin/school/src/profile/profile.php [L]\n".
            "RewriteRule ^avatar$ plugin/school/src/profile/avatar.php [L]\n".
            "RewriteRule ^password$ plugin/school/src/profile/password.php [L]\n".
            "RewriteRule ^extra-profile$ plugin/school/src/profile/extra_profile_data.php [L]\n".
            "RewriteRule ^notifications$ plugin/school/src/notifications/notifications.php [L]\n".
            "RewriteRule ^shopping$ plugin/school/src/shopping/shopping.php [L]\n".
            "RewriteRule ^school-admin$ plugin/school/src/admin/admin.php [L]\n".
            "RewriteRule ^reset/token/([^/]+)$ plugin/school/src/auth/reset.php?token=$1 [L]\n".
            "RewriteRule ^certified$ plugin/school/src/misc/certificates.php [L]\n".
            "RewriteRule ^documents$ plugin/school/src/misc/student_documents.php?%{QUERY_STRING} [L,QSA]\n".
            "RewriteRule ^requests$ plugin/school/src/misc/requests.php [L]\n".
            "RewriteRule ^help$ plugin/school/src/misc/help.php [L]\n".
            "RewriteRule ^payments$ plugin/school/src/payments/payments.php [L]\n".
            "RewriteRule ^payments/students$ plugin/school/src/payments/students.php [L,QSA]\n".
            "RewriteRule ^payments/register$ plugin/school/src/payments/register.php [L,QSA]\n".
            "RewriteRule ^payments/discounts$ plugin/school/src/payments/discounts.php [L,QSA]\n".
            "RewriteRule ^payments/my$ plugin/school/src/payments/my_payments.php [L]\n".
            "RewriteRule ^payments/reports$ plugin/school/src/payments/reports.php [L,QSA]\n".
            "RewriteRule ^payments/receipt$ plugin/school/src/payments/receipt.php [L,QSA]\n".
            "RewriteRule ^payments/pricing$ plugin/school/src/payments/pricing.php [L,QSA]\n".
            "RewriteRule ^products$ plugin/school/src/products/products.php [L]\n".
            "RewriteRule ^products/categories$ plugin/school/src/products/categories.php [L]\n".
            "RewriteRule ^products/sell$ plugin/school/src/products/sell.php [L,QSA]\n".
            "RewriteRule ^products/sales$ plugin/school/src/products/sales.php [L,QSA]\n".
            "RewriteRule ^products/my$ plugin/school/src/products/my_purchases.php [L]\n".
            "RewriteRule ^products/receipt$ plugin/school/src/products/receipt.php [L,QSA]\n".
            "RewriteRule ^academic$ plugin/school/src/academic/index.php [L]\n".
            "RewriteRule ^academic/settings$ plugin/school/src/academic/settings.php [L]\n".
            "RewriteRule ^academic/classroom$ plugin/school/src/academic/classroom.php [L,QSA]\n".
            "RewriteRule ^payments/pricing$ plugin/school/src/payments/pricing.php [L,QSA]\n".
            "RewriteRule ^matricula$ plugin/school/src/matricula/list.php [L]\n".
            "RewriteRule ^matricula/nueva$ plugin/school/src/matricula/form.php [L]\n".
            "RewriteRule ^matricula/editar$ plugin/school/src/matricula/form.php [L,QSA]\n".
            "RewriteRule ^matricula/ver$ plugin/school/src/matricula/view.php [L,QSA]\n".
            "RewriteRule ^matricula/alumnos$ plugin/school/src/matricula/alumnos.php [L,QSA]\n".
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

    public function display_login_template()
    {
        $tpl = $this->twig->loadTemplate('layout/login.tpl');
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

        // Sidebar icon for collapsed state
        $sidebarIcon = $this->getSchoolSetting('sidebar_icon');
        if ($sidebarIcon) {
            $sidebarIconUrl = api_get_path(WEB_UPLOAD_PATH).'plugins/school/'.$sidebarIcon;
            $this->assign('sidebar_icon_url', $sidebarIconUrl);
        } else {
            $this->assign('sidebar_icon_url', '');
        }

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
        $this->assign('platform_name', api_get_setting('siteName'));
        $this->assign('institution_name', api_get_setting('Institution'));

        // Custom logo dimensions from admin settings
        $this->assign('custom_logo_width', $this->getSchoolSetting('logo_width') ?? '');
        $this->assign('custom_logo_height', $this->getSchoolSetting('logo_height') ?? '');

        // Custom colors from admin settings
        $this->assign('custom_primary_color', $this->getSchoolSetting('primary_color') ?? '');
        $this->assign('custom_sidebar_brand_color', $this->getSchoolSetting('sidebar_brand_color') ?? '');
        $this->assign('custom_sidebar_color', $this->getSchoolSetting('sidebar_color') ?? '');
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

            $coursePicSys = api_get_path(SYS_COURSE_PATH) . $courseCode . '/course-pic.png';
            $courses[] = [
                'id' => $courseId,
                'code' => $courseCode,
                'title' => $courseTitle,
                'icon' => self::get_svg_icon('course', $courseTitle, 32),
                'icon_mobile' => self::get_svg_icon('course', $courseTitle, 22, true),
                'url' => api_get_path(WEB_PATH).'home/course/'.$courseCode,
                'ribbon' => $ribbon,
                'image_url' => file_exists($coursePicSys)
                    ? api_get_path(WEB_COURSE_PATH) . $courseCode . '/course-pic.png'
                    : '',
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
                $coursePicSys = api_get_path(SYS_COURSE_PATH) . $result_row['course_code'] . '/course-pic.png';
                $result_row['image_url'] = file_exists($coursePicSys)
                    ? api_get_path(WEB_COURSE_PATH) . $result_row['course_code'] . '/course-pic.png'
                    : '';
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
                'id' => 0,
                'name' => 'dashboard',
                'label' => $this->get_lang('Dashboard'),
                'current' => $currentSection === 'dashboard',
                'icon' => 'home',
                'class' => $currentSection === 'dashboard' ? 'active':'',
                'url' => '/dashboard',
                'items' => []
            ],
            [
                'id' => 1,
                'name' => 'courses',
                'label' => $this->get_lang('MyCourses'),
                'current' => $currentSection === 'courses',
                'icon' => 'book-open',
                'class' => $currentSection === 'courses' ? 'active':'',
                'url' => '/courses',
                'items' => []
            ],
        ];

        if ($this->get('show_notifications') !== 'false') {
            $menus[] = [
                'id' => 2,
                'name' => 'notifications',
                'label' => $this->get_lang('MyNotifications'),
                'current' => false,
                'icon' => 'bell',
                'class' => $currentSection === 'notifications' ? 'active':'',
                'url' => '/notifications',
                'items' => []
            ];
        }

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

        if ($this->get('show_help') !== 'false') {
            $menus[] = [
                'id' => 4,
                'name' => 'help',
                'label' => $this->get_lang('Help'),
                'current' => false,
                'icon' => 'question-circle',
                'url' => '/help',
                'class' => $currentSection === 'help' ? 'active':'',
                'items' => []
            ];
        }

        $menus[] = [
            'id' => 5,
            'name' => 'shopping',
            'label' => $this->get_lang('BuyCourses'),
            'current' => false,
            'icon' => 'shopping-cart',
            'url' => '/shopping',
            'class' => $currentSection === 'shopping' ? 'active':'',
            'items' => []
        ];

        if ($this->get('activate_shopping') == 'false' || api_get_user_status() == STUDENT) {
            $menus = array_filter($menus, function ($menu) {
                return $menu['name'] !== 'shopping';
            });
        }

        $attendanceItems = [];
        if (api_is_platform_admin()) {
            $attendanceItems = [
                ['name' => 'attendance-today', 'label' => $this->get_lang('TodayAttendance'), 'url' => '/attendance/today'],
                ['name' => 'attendance-manual', 'label' => $this->get_lang('ManualRegistration'), 'url' => '/attendance/manual'],
                ['name' => 'attendance-schedules', 'label' => $this->get_lang('Schedules'), 'url' => '/attendance/schedules'],
                ['name' => 'attendance-reports', 'label' => $this->get_lang('Reports'), 'url' => '/attendance/reports'],
                ['name' => 'attendance-my', 'label' => $this->get_lang('MyAttendance'), 'url' => '/attendance/my'],
            ];
        } else {
            $attendanceItems = [
                ['name' => 'attendance-my', 'label' => $this->get_lang('MyAttendance'), 'url' => '/attendance/my'],
            ];
        }

        $menus[] = [
            'id' => 6,
            'name' => 'attendance',
            'label' => $this->get_lang('Attendance'),
            'current' => $currentSection === 'attendance',
            'icon' => 'clipboard-check',
            'class' => $currentSection === 'attendance' ? 'show' : '',
            'url' => '/attendance',
            'items' => $attendanceItems
        ];

        // Payments & Products: only admin, secretary and student
        $userInfo = api_get_user_info();
        $isAdminOrSecretary = api_is_platform_admin() || ($userInfo && $userInfo['status'] == SCHOOL_SECRETARY);
        $isStudent = $userInfo && (int) $userInfo['status'] === STUDENT;
        $canAccessPayments = $isAdminOrSecretary || $isStudent;

        if ($canAccessPayments) {
            $paymentItems = [];
            if ($isAdminOrSecretary) {
                $paymentItems = [
                    ['name' => 'payments-periods', 'label' => $this->get_lang('PaymentPeriods'), 'url' => '/payments'],
                    ['name' => 'payments-pricing', 'label' => $this->get_lang('Pricing'), 'url' => '/payments/pricing'],
                    ['name' => 'payments-discounts', 'label' => $this->get_lang('Discounts'), 'url' => '/payments/discounts'],
                    ['name' => 'payments-reports', 'label' => $this->get_lang('PaymentReports'), 'url' => '/payments/reports'],
                ];
            }
            $menus[] = [
                'id' => 7,
                'name' => 'payments',
                'label' => $this->get_lang('Payments'),
                'current' => $currentSection === 'payments',
                'icon' => 'money-bill-wave',
                'class' => $currentSection === 'payments' ? 'show' : '',
                'url' => $isAdminOrSecretary ? '/payments' : '/payments/my',
                'items' => $paymentItems
            ];

            if ($isAdminOrSecretary) {
                $menus[] = [
                    'id' => 8,
                    'name' => 'products',
                    'label' => $this->get_lang('Products'),
                    'current' => $currentSection === 'products',
                    'icon' => 'box-open',
                    'class' => $currentSection === 'products' ? 'show' : '',
                    'url' => '/products',
                    'items' => [
                        ['name' => 'products-catalog', 'label' => $this->get_lang('ProductCatalog'), 'url' => '/products'],
                        ['name' => 'products-categories', 'label' => $this->get_lang('Categories'), 'url' => '/products/categories'],
                        ['name' => 'products-sell', 'label' => $this->get_lang('SellProduct'), 'url' => '/products/sell'],
                        ['name' => 'products-sales', 'label' => $this->get_lang('SalesHistory'), 'url' => '/products/sales'],
                    ]
                ];
            }
        }

        // Matricula menu (admin and secretary only)
        if ($isAdminOrSecretary) {
            $menus[] = [
                'id' => 11,
                'name' => 'matricula',
                'label' => $this->get_lang('Enrollment'),
                'current' => $currentSection === 'matricula',
                'icon' => 'user-plus',
                'class' => $currentSection === 'matricula' ? 'show' : '',
                'url' => '/matricula',
                'items' => [
                    ['name' => 'matricula-list',      'label' => $this->get_lang('EnrollmentList'),          'url' => '/matricula'],
                    ['name' => 'matricula-nueva',     'label' => $this->get_lang('NewEnrollment'),            'url' => '/matricula/nueva'],
                    ['name' => 'matricula-alumnos',   'label' => $this->get_lang('Students'),       'url' => '/matricula/alumnos'],
                ]
            ];
        }

        // Academic menu
        if ($isAdminOrSecretary) {
            $academicItems = [
                ['name' => 'academic-classrooms', 'label' => $this->get_lang('Classrooms'), 'url' => '/academic'],
            ];
            if (api_is_platform_admin()) {
                $academicItems[] = ['name' => 'academic-settings', 'label' => $this->get_lang('AcademicSettings'), 'url' => '/academic/settings'];
            }
            $menus[] = [
                'id' => 9,
                'name' => 'academic',
                'label' => $this->get_lang('Academic'),
                'current' => $currentSection === 'academic',
                'icon' => 'school',
                'class' => $currentSection === 'academic' ? 'show' : '',
                'url' => '/academic',
                'items' => $academicItems
            ];
        }

        if (api_is_platform_admin()) {
            $menus[] = [
                'id' => 10,
                'name' => 'admin',
                'label' => 'Administración',
                'current' => $currentSection === 'admin',
                'icon' => 'cog',
                'url' => '/school-admin',
                'class' => $currentSection === 'admin' ? 'show' : '',
                'items' => [
                    ['name' => 'admin-personalizacion', 'label' => 'Personalización', 'url' => '/school-admin'],
                    ['name' => 'admin-usuarios', 'label' => 'Usuarios', 'url' => '/admin/usuarios'],
                ]
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

            $loginUrl = api_get_path(WEB_PATH) . 'login';

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

    // ==================== ATTENDANCE METHODS ====================

    /**
     * Get all attendance schedules.
     */
    public function getSchedules(bool $activeOnly = false): array
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_ATTENDANCE_SCHEDULE);
        $where = $activeOnly ? "WHERE active = 1" : "";
        $sql = "SELECT * FROM $table $where ORDER BY entry_time ASC";
        $result = Database::query($sql);
        $schedules = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $schedules[] = $row;
        }
        return $schedules;
    }

    /**
     * Save or update an attendance schedule.
     */
    public function saveSchedule(array $data): bool
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_ATTENDANCE_SCHEDULE);

        $validRoles = ['all', 'teacher', 'student', 'parent', 'secretary', 'auxiliary'];
        $appliesTo = 'all';
        if (!empty($data['applies_to'])) {
            if (is_array($data['applies_to'])) {
                $roles = array_intersect($data['applies_to'], $validRoles);
                $appliesTo = !empty($roles) ? implode(',', $roles) : 'all';
            } else {
                $roles = array_intersect(explode(',', $data['applies_to']), $validRoles);
                $appliesTo = !empty($roles) ? implode(',', $roles) : 'all';
            }
        }

        $params = [
            'name' => Database::escape_string($data['name']),
            'entry_time' => Database::escape_string($data['entry_time']),
            'late_time' => Database::escape_string($data['late_time']),
            'applies_to' => Database::escape_string($appliesTo),
            'active' => isset($data['active']) ? (int) $data['active'] : 1,
        ];

        if (!empty($data['id'])) {
            $id = (int) $data['id'];
            Database::update($table, $params, ['id = ?' => $id]);
        } else {
            $params['created_at'] = api_get_utc_datetime();
            Database::insert($table, $params);
        }
        return true;
    }

    /**
     * Delete an attendance schedule.
     */
    public function deleteSchedule(int $id): bool
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_ATTENDANCE_SCHEDULE);
        Database::delete($table, ['id = ?' => $id]);
        return true;
    }

    /**
     * Get the applicable schedule for a user based on their role.
     */
    public function getApplicableSchedule(int $userId): ?array
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_ATTENDANCE_SCHEDULE);

        $user = api_get_user_info($userId);
        $userRole = 'student';
        if ($user) {
            if ($user['status'] == COURSEMANAGER || api_is_platform_admin_by_id($userId)) {
                $userRole = 'teacher';
            } elseif ($user['status'] == SCHOOL_SECRETARY) {
                $userRole = 'secretary';
            } elseif ($user['status'] == SCHOOL_AUXILIARY) {
                $userRole = 'auxiliary';
            } elseif (in_array($user['status'], [SCHOOL_PARENT, SCHOOL_GUARDIAN])) {
                $userRole = 'parent';
            } elseif ($user['status'] == DRH) {
                $userRole = 'teacher';
            }
        }

        $userRole = Database::escape_string($userRole);
        $sql = "SELECT * FROM $table
                WHERE active = 1 AND (applies_to = 'all' OR FIND_IN_SET('$userRole', applies_to))
                ORDER BY entry_time ASC LIMIT 1";
        $result = Database::query($sql);
        $row = Database::fetch_array($result, 'ASSOC');
        return $row ?: null;
    }

    /**
     * Calculate attendance status based on check-in time and schedule.
     */
    public function calculateAttendanceStatus(string $checkInTime, ?int $scheduleId): string
    {
        if (!$scheduleId) {
            return 'on_time';
        }

        $table = Database::get_main_table(self::TABLE_SCHOOL_ATTENDANCE_SCHEDULE);
        $sql = "SELECT * FROM $table WHERE id = $scheduleId LIMIT 1";
        $result = Database::query($sql);
        $schedule = Database::fetch_array($result, 'ASSOC');

        if (!$schedule) {
            return 'on_time';
        }

        // Convert UTC check-in time to local time for comparison
        // Schedule times are stored as local "wall clock" times
        $localCheckIn = api_get_local_time($checkInTime);
        $checkTime = strtotime(date('H:i:s', strtotime($localCheckIn)));
        $lateTime = strtotime($schedule['late_time']);

        if ($checkTime > $lateTime) {
            return 'late';
        }

        return 'on_time';
    }

    /**
     * Mark attendance for a user.
     */
    public function markAttendance(
        int $userId,
        string $method = 'manual',
        ?int $registeredBy = null,
        ?string $notes = null,
        ?string $forcedStatus = null
    ): array {
        $table = Database::get_main_table(self::TABLE_SCHOOL_ATTENDANCE_LOG);
        $today = date('Y-m-d');
        $now = api_get_utc_datetime();

        // Check if already registered today
        $existingSQL = "SELECT id, status FROM $table WHERE user_id = $userId AND date = '$today' LIMIT 1";
        $existingResult = Database::query($existingSQL);
        $existing = Database::fetch_array($existingResult, 'ASSOC');

        if ($existing) {
            // If manual and forcing a different status, update the existing record
            if ($method === 'manual' && $forcedStatus && $existing['status'] !== $forcedStatus) {
                Database::update(
                    $table,
                    [
                        'status' => $forcedStatus,
                        'registered_by' => $registeredBy,
                        'notes' => $notes ? Database::escape_string($notes) : null,
                    ],
                    ['id = ?' => (int) $existing['id']]
                );
                return [
                    'success' => true,
                    'message' => 'AttendanceUpdated',
                    'status' => $forcedStatus,
                    'id' => (int) $existing['id'],
                ];
            }

            return [
                'success' => false,
                'message' => 'AttendanceAlreadyRegistered',
                'status' => $existing['status'],
            ];
        }

        $schedule = $this->getApplicableSchedule($userId);
        $scheduleId = $schedule ? (int) $schedule['id'] : null;

        // Use forced status for manual registration, auto-calculate for QR
        if ($forcedStatus && in_array($forcedStatus, ['on_time', 'late', 'absent'])) {
            $status = $forcedStatus;
        } else {
            $status = $this->calculateAttendanceStatus($now, $scheduleId);
        }

        $checkIn = $status === 'absent' ? $today . ' 00:00:00' : $now;

        $params = [
            'user_id' => $userId,
            'schedule_id' => $scheduleId,
            'check_in' => $checkIn,
            'status' => $status,
            'method' => $method,
            'registered_by' => $registeredBy,
            'date' => $today,
            'notes' => $notes ? Database::escape_string($notes) : null,
            'created_at' => $now,
        ];

        $id = Database::insert($table, $params);

        if ($id) {
            return [
                'success' => true,
                'message' => 'AttendanceRegistered',
                'status' => $status,
                'id' => $id,
            ];
        }

        return ['success' => false, 'message' => 'AttendanceError'];
    }

    /**
     * Mark a user as absent for a given date.
     */
    public function markAbsent(int $userId, ?string $date = null): array
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_ATTENDANCE_LOG);
        $date = $date ?: date('Y-m-d');
        $now = api_get_utc_datetime();

        // Check existing
        $sql = "SELECT id FROM $table WHERE user_id = $userId AND date = '$date' LIMIT 1";
        $result = Database::query($sql);
        $existing = Database::fetch_array($result, 'ASSOC');

        if ($existing) {
            Database::update(
                $table,
                ['status' => 'absent', 'notes' => 'Marcado como ausente'],
                ['id = ?' => (int) $existing['id']]
            );
            return ['success' => true, 'message' => 'MarkedAsAbsent'];
        }

        $params = [
            'user_id' => $userId,
            'schedule_id' => null,
            'check_in' => $date . ' 00:00:00',
            'status' => 'absent',
            'method' => 'manual',
            'registered_by' => api_get_user_id(),
            'date' => $date,
            'notes' => 'Marcado como ausente',
            'created_at' => $now,
        ];

        Database::insert($table, $params);
        return ['success' => true, 'message' => 'MarkedAsAbsent'];
    }

    /**
     * Get attendance records for a specific date.
     */
    public function getAttendanceByDate(string $date): array
    {
        $logTable = Database::get_main_table(self::TABLE_SCHOOL_ATTENDANCE_LOG);
        $userTable = Database::get_main_table(TABLE_MAIN_USER);

        $sql = "SELECT al.*, u.firstname, u.lastname, u.username, u.status as user_status
                FROM $logTable al
                INNER JOIN $userTable u ON al.user_id = u.id
                WHERE al.date = '".Database::escape_string($date)."'
                ORDER BY al.check_in ASC";
        $result = Database::query($sql);
        $records = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $records[] = $row;
        }
        return $records;
    }

    /**
     * Get attendance history for a specific user.
     */
    public function getAttendanceByUser(int $userId, ?string $startDate = null, ?string $endDate = null): array
    {
        $logTable = Database::get_main_table(self::TABLE_SCHOOL_ATTENDANCE_LOG);
        $scheduleTable = Database::get_main_table(self::TABLE_SCHOOL_ATTENDANCE_SCHEDULE);

        $where = "WHERE al.user_id = $userId";
        if ($startDate) {
            $where .= " AND al.date >= '".Database::escape_string($startDate)."'";
        }
        if ($endDate) {
            $where .= " AND al.date <= '".Database::escape_string($endDate)."'";
        }

        $sql = "SELECT al.*, s.name as schedule_name
                FROM $logTable al
                LEFT JOIN $scheduleTable s ON al.schedule_id = s.id
                $where
                ORDER BY al.date DESC";
        $result = Database::query($sql);
        $records = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $records[] = $row;
        }
        return $records;
    }

    /**
     * Build SQL WHERE clause fragment to filter by user type/role.
     */
    private function getUserTypeFilter(?string $userType): string
    {
        if (empty($userType)) {
            return '';
        }
        $filterMap = [
            'staff' => " AND (u.status IN (".COURSEMANAGER.", ".DRH.", ".SCHOOL_SECRETARY.", ".SCHOOL_AUXILIARY."))",
            'students' => " AND u.status = ".STUDENT,
            'teacher' => " AND u.status = ".COURSEMANAGER,
            'secretary' => " AND u.status = ".SCHOOL_SECRETARY,
            'auxiliary' => " AND u.status = ".SCHOOL_AUXILIARY,
            'parent' => " AND u.status = ".SCHOOL_PARENT,
            'guardian' => " AND u.status = ".SCHOOL_GUARDIAN,
        ];
        return isset($filterMap[$userType]) ? $filterMap[$userType] : '';
    }

    /**
     * Get attendance statistics for a date range.
     */
    public function getAttendanceStats(?string $startDate = null, ?string $endDate = null, ?string $userType = null): array
    {
        $logTable = Database::get_main_table(self::TABLE_SCHOOL_ATTENDANCE_LOG);
        $userTable = Database::get_main_table(TABLE_MAIN_USER);

        $where = "WHERE 1=1";
        if ($startDate) {
            $where .= " AND al.date >= '".Database::escape_string($startDate)."'";
        }
        if ($endDate) {
            $where .= " AND al.date <= '".Database::escape_string($endDate)."'";
        }
        $where .= $this->getUserTypeFilter($userType);

        $sql = "SELECT
                    COUNT(*) as total,
                    SUM(CASE WHEN al.status = 'on_time' THEN 1 ELSE 0 END) as on_time,
                    SUM(CASE WHEN al.status = 'late' THEN 1 ELSE 0 END) as late,
                    SUM(CASE WHEN al.status = 'absent' THEN 1 ELSE 0 END) as absent
                FROM $logTable al
                INNER JOIN $userTable u ON al.user_id = u.id
                $where";
        $result = Database::query($sql);
        return Database::fetch_array($result, 'ASSOC') ?: ['total' => 0, 'on_time' => 0, 'late' => 0, 'absent' => 0];
    }

    /**
     * Generate a daily QR token for attendance scanning.
     */
    public function generateDailyQRToken(): array
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_ATTENDANCE_QR);
        $today = date('Y-m-d');
        $userId = api_get_user_id();

        // Check if a valid token already exists for today
        $now = api_get_utc_datetime();
        $sql = "SELECT * FROM $table WHERE date = '$today' AND expires_at > '$now' ORDER BY id DESC LIMIT 1";
        $result = Database::query($sql);
        $existing = Database::fetch_array($result, 'ASSOC');

        if ($existing) {
            $scanUrl = api_get_path(WEB_PATH) . 'attendance/scan?token=' . $existing['token'];
            $qrImage = self::generateQRImage($scanUrl);
            return [
                'token' => $existing['token'],
                'qr_image' => $qrImage,
                'scan_url' => $scanUrl,
                'expires_at' => $existing['expires_at'],
                'is_new' => false,
            ];
        }

        // Generate new token
        $token = bin2hex(random_bytes(32));
        $expiresAt = date('Y-m-d 23:59:59');

        $params = [
            'token' => $token,
            'date' => $today,
            'created_by' => $userId,
            'expires_at' => $expiresAt,
            'created_at' => $now,
        ];
        Database::insert($table, $params);

        $scanUrl = api_get_path(WEB_PATH) . 'attendance/scan?token=' . $token;
        $qrImage = self::generateQRImage($scanUrl);

        return [
            'token' => $token,
            'qr_image' => $qrImage,
            'scan_url' => $scanUrl,
            'expires_at' => $expiresAt,
            'is_new' => true,
        ];
    }

    /**
     * Validate a QR token for attendance.
     */
    public function validateQRToken(string $token): ?array
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_ATTENDANCE_QR);
        $token = Database::escape_string($token);
        $now = api_get_utc_datetime();

        $sql = "SELECT * FROM $table WHERE token = '$token' AND expires_at > '$now' LIMIT 1";
        $result = Database::query($sql);
        $row = Database::fetch_array($result, 'ASSOC');
        return $row ?: null;
    }

    /**
     * Get all platform users for manual attendance (teachers and students).
     */
    public function getUsersForAttendance(?string $type = null): array
    {
        $userTable = Database::get_main_table(TABLE_MAIN_USER);
        $adminTable = Database::get_main_table(TABLE_MAIN_ADMIN);
        $logTable = Database::get_main_table(self::TABLE_SCHOOL_ATTENDANCE_LOG);
        $today = date('Y-m-d');

        // Include teachers (COURSEMANAGER), DRH, students, school roles, and platform admins
        $allStatuses = COURSEMANAGER.", ".STUDENT.", ".DRH.", ".SCHOOL_PARENT.", ".SCHOOL_GUARDIAN.", ".SCHOOL_SECRETARY.", ".SCHOOL_AUXILIARY;
        $staffStatuses = COURSEMANAGER.", ".DRH.", ".SCHOOL_SECRETARY.", ".SCHOOL_AUXILIARY;
        $where = "WHERE u.active = 1 AND (u.status IN ($allStatuses) OR a.user_id IS NOT NULL)";
        if ($type === 'staff') {
            $where = "WHERE u.active = 1 AND (u.status IN ($staffStatuses) OR a.user_id IS NOT NULL)";
        } elseif ($type === 'students') {
            $where = "WHERE u.active = 1 AND u.status = ".STUDENT." AND a.user_id IS NULL";
        }

        $sql = "SELECT u.id, u.firstname, u.lastname, u.username, u.status,
                       CASE WHEN a.user_id IS NOT NULL THEN 1 ELSE 0 END as is_admin,
                       al.id as attendance_id, al.check_in, al.status as attendance_status, al.method
                FROM $userTable u
                LEFT JOIN $adminTable a ON u.id = a.user_id
                LEFT JOIN $logTable al ON u.id = al.user_id AND al.date = '$today'
                $where
                ORDER BY u.lastname ASC, u.firstname ASC";
        $result = Database::query($sql);
        $users = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            if ($row['status'] == COURSEMANAGER) {
                $row['role_label'] = $this->get_lang('RoleTeacher');
                $row['role_type'] = 'teacher';
            } elseif ($row['status'] == SCHOOL_SECRETARY) {
                $row['role_label'] = $this->get_lang('RoleSecretary');
                $row['role_type'] = 'secretary';
            } elseif ($row['status'] == SCHOOL_AUXILIARY) {
                $row['role_label'] = $this->get_lang('RoleAuxiliary');
                $row['role_type'] = 'auxiliary';
            } elseif ($row['is_admin'] || $row['status'] == DRH) {
                $row['role_label'] = $this->get_lang('RoleAdmin');
                $row['role_type'] = 'admin';
            } elseif (in_array($row['status'], [SCHOOL_PARENT, SCHOOL_GUARDIAN])) {
                $row['role_label'] = $row['status'] == SCHOOL_PARENT ? $this->get_lang('RoleParent') : $this->get_lang('RoleGuardian');
                $row['role_type'] = 'family';
            } else {
                $row['role_label'] = $this->get_lang('RoleStudent');
                $row['role_type'] = 'students';
            }
            $users[] = $row;
        }
        return $users;
    }

    /**
     * Export attendance data to CSV.
     */
    public function exportAttendanceCSV(?string $startDate = null, ?string $endDate = null, ?string $userType = null): void
    {
        $logTable = Database::get_main_table(self::TABLE_SCHOOL_ATTENDANCE_LOG);
        $userTable = Database::get_main_table(TABLE_MAIN_USER);
        $scheduleTable = Database::get_main_table(self::TABLE_SCHOOL_ATTENDANCE_SCHEDULE);

        $where = "WHERE 1=1";
        if ($startDate) {
            $where .= " AND al.date >= '".Database::escape_string($startDate)."'";
        }
        if ($endDate) {
            $where .= " AND al.date <= '".Database::escape_string($endDate)."'";
        }
        $where .= $this->getUserTypeFilter($userType);

        $adminTable = Database::get_main_table(TABLE_MAIN_ADMIN);
        $sql = "SELECT al.date, u.lastname, u.firstname, u.username,
                       CASE
                           WHEN adm.user_id IS NOT NULL THEN 'Administrativo'
                           WHEN u.status = ".COURSEMANAGER." THEN 'Docente'
                           WHEN u.status = ".DRH." THEN 'Administrativo'
                           WHEN u.status = ".SCHOOL_SECRETARY." THEN 'Secretaria'
                           WHEN u.status = ".SCHOOL_AUXILIARY." THEN 'Auxiliar'
                           WHEN u.status = ".SCHOOL_PARENT." THEN 'Padre de familia'
                           WHEN u.status = ".SCHOOL_GUARDIAN." THEN 'Apoderado'
                           ELSE 'Alumno'
                       END as role,
                       al.check_in, al.status, al.method, s.name as schedule_name, al.notes
                FROM $logTable al
                INNER JOIN $userTable u ON al.user_id = u.id
                LEFT JOIN $adminTable adm ON u.id = adm.user_id
                LEFT JOIN $scheduleTable s ON al.schedule_id = s.id
                $where
                ORDER BY al.date DESC, u.lastname ASC";
        $result = Database::query($sql);

        $filename = 'asistencia_' . date('Y-m-d_His') . '.csv';
        header('Content-Type: text/csv; charset=utf-8');
        header('Content-Disposition: attachment; filename="' . $filename . '"');

        $output = fopen('php://output', 'w');
        fprintf($output, chr(0xEF).chr(0xBB).chr(0xBF)); // UTF-8 BOM
        fputcsv($output, ['Fecha', 'Apellidos', 'Nombres', 'Usuario', 'Rol', 'Hora Ingreso', 'Estado', 'Metodo', 'Turno', 'Notas'], ';');

        $statusLabels = ['on_time' => 'Asistio puntualmente', 'late' => 'Asistio con tardanza', 'absent' => 'No asistio'];
        $methodLabels = ['qr' => 'QR', 'manual' => 'Manual'];

        while ($row = Database::fetch_array($result, 'ASSOC')) {
            fputcsv($output, [
                $row['date'],
                $row['lastname'],
                $row['firstname'],
                $row['username'],
                $row['role'],
                date('H:i:s', strtotime($row['check_in'])),
                $statusLabels[$row['status']] ?? $row['status'],
                $methodLabels[$row['method']] ?? $row['method'],
                $row['schedule_name'] ?? '-',
                $row['notes'] ?? '',
            ], ';');
        }
        fclose($output);
        exit;
    }

    /**
     * Export attendance data to PDF.
     */
    public function exportAttendancePDF(?string $startDate = null, ?string $endDate = null, ?string $userType = null): void
    {
        $logTable = Database::get_main_table(self::TABLE_SCHOOL_ATTENDANCE_LOG);
        $userTable = Database::get_main_table(TABLE_MAIN_USER);
        $scheduleTable = Database::get_main_table(self::TABLE_SCHOOL_ATTENDANCE_SCHEDULE);

        $where = "WHERE 1=1";
        if ($startDate) {
            $where .= " AND al.date >= '".Database::escape_string($startDate)."'";
        }
        if ($endDate) {
            $where .= " AND al.date <= '".Database::escape_string($endDate)."'";
        }
        $where .= $this->getUserTypeFilter($userType);

        $adminTable = Database::get_main_table(TABLE_MAIN_ADMIN);
        $sql = "SELECT al.date, u.lastname, u.firstname, u.username,
                       CASE
                           WHEN adm.user_id IS NOT NULL THEN 'Administrativo'
                           WHEN u.status = ".COURSEMANAGER." THEN 'Docente'
                           WHEN u.status = ".DRH." THEN 'Administrativo'
                           WHEN u.status = ".SCHOOL_SECRETARY." THEN 'Secretaria'
                           WHEN u.status = ".SCHOOL_AUXILIARY." THEN 'Auxiliar'
                           WHEN u.status = ".SCHOOL_PARENT." THEN 'Padre de familia'
                           WHEN u.status = ".SCHOOL_GUARDIAN." THEN 'Apoderado'
                           ELSE 'Alumno'
                       END as role,
                       al.check_in, al.status, al.method, s.name as schedule_name, al.notes
                FROM $logTable al
                INNER JOIN $userTable u ON al.user_id = u.id
                LEFT JOIN $adminTable adm ON u.id = adm.user_id
                LEFT JOIN $scheduleTable s ON al.schedule_id = s.id
                $where
                ORDER BY al.date DESC, u.lastname ASC";
        $result = Database::query($sql);

        $statusLabels = ['on_time' => 'Asistió puntualmente', 'late' => 'Asistió con tardanza', 'absent' => 'No asistió'];
        $methodLabels = ['qr' => 'QR', 'manual' => 'Manual'];

        $records = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $row['status_label'] = $statusLabels[$row['status']] ?? $row['status'];
            $row['method_label'] = $methodLabels[$row['method']] ?? $row['method'];
            $row['check_in_time'] = date('H:i:s', strtotime($row['check_in']));
            $records[] = $row;
        }

        $dateRange = '';
        if ($startDate && $endDate) {
            $dateRange = "Del $startDate al $endDate";
        } elseif ($startDate) {
            $dateRange = "Desde $startDate";
        } elseif ($endDate) {
            $dateRange = "Hasta $endDate";
        }

        $this->assign('records', $records);
        $this->assign('date_range', $dateRange);
        $this->assign('report_date', date('Y-m-d H:i:s'));
        $this->assign('institution', api_get_setting('Institution'));

        $content = $this->fetch('attendance/pdf.tpl');

        $filename = 'asistencia_' . date('Y-m-d_His');

        $params = [
            'filename' => $filename,
            'pdf_title' => 'Reporte de Asistencia',
            'pdf_description' => $dateRange,
            'format' => 'A4-L',
            'orientation' => 'L',
        ];

        $pdf = new PDF($params['format'], $params['orientation']);
        $pdf->content_to_pdf($content, null, $filename, null, 'D');
    }

    // ==================== EXTRA PROFILE METHODS ====================

    /**
     * Get extra profile data for a user.
     */
    public function getExtraProfileData(int $userId): array
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_EXTRA_PROFILE);
        $sql = "SELECT * FROM $table WHERE user_id = $userId LIMIT 1";
        $result = Database::query($sql);
        $row = Database::fetch_array($result, 'ASSOC');

        if (!$row) {
            return [
                'user_id' => $userId,
                'document_type' => '',
                'document_number' => '',
                'birthdate' => '',
                'address' => '',
                'address_reference' => '',
                'phone' => '',
                'district' => '',
                'province' => '',
                'region' => '',
            ];
        }
        return $row;
    }

    /**
     * Save extra profile data for a user.
     */
    public function saveExtraProfileData(int $userId, array $data): bool
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_EXTRA_PROFILE);
        $now = api_get_utc_datetime();

        $validDocTypes = ['DNI', 'CE', 'PASAPORTE', 'OTRO'];
        $docType = in_array($data['document_type'], $validDocTypes) ? $data['document_type'] : 'DNI';

        $params = [
            'document_type' => $docType,
            'document_number' => Database::escape_string(trim($data['document_number'] ?? '')),
            'birthdate' => !empty($data['birthdate']) ? Database::escape_string($data['birthdate']) : null,
            'address' => Database::escape_string(trim($data['address'] ?? '')),
            'address_reference' => Database::escape_string(trim($data['address_reference'] ?? '')),
            'phone' => Database::escape_string(trim($data['phone'] ?? '')),
            'district' => Database::escape_string(trim($data['district'] ?? '')),
            'province' => Database::escape_string(trim($data['province'] ?? '')),
            'region' => Database::escape_string(trim($data['region'] ?? '')),
            'updated_at' => $now,
        ];

        // Check if record exists
        $sql = "SELECT id FROM $table WHERE user_id = $userId LIMIT 1";
        $result = Database::query($sql);
        $existing = Database::fetch_array($result, 'ASSOC');

        if ($existing) {
            Database::update($table, $params, ['user_id = ?' => $userId]);
        } else {
            $params['user_id'] = $userId;
            Database::insert($table, $params);
        }

        return true;
    }

    // ==================== PAYMENT METHODS ====================

    /**
     * Get payment periods.
     */
    public function getPaymentPeriods(bool $activeOnly = false): array
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_PAYMENT_PERIOD);
        $where = $activeOnly ? " WHERE active = 1" : "";
        $sql = "SELECT * FROM $table $where ORDER BY year DESC, name ASC";
        $result = Database::query($sql);
        $periods = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $periods[] = $row;
        }
        return $periods;
    }

    /**
     * Save a payment period (create or update).
     */
    public function savePeriod(array $data): bool
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_PAYMENT_PERIOD);

        $params = [
            'name' => Database::escape_string(trim($data['name'] ?? '')),
            'year' => (int) ($data['year'] ?? date('Y')),
            'admission_amount' => (float) ($data['admission_amount'] ?? 0),
            'enrollment_amount' => (float) ($data['enrollment_amount'] ?? 0),
            'monthly_amount' => (float) ($data['monthly_amount'] ?? 0),
            'months' => Database::escape_string(trim($data['months'] ?? '')),
            'active' => isset($data['active']) ? (int) $data['active'] : 1,
        ];

        if (empty($params['name'])) {
            return false;
        }

        $id = isset($data['id']) ? (int) $data['id'] : 0;

        if ($id > 0) {
            Database::update($table, $params, ['id = ?' => $id]);
        } else {
            $params['created_at'] = api_get_utc_datetime();
            Database::insert($table, $params);
        }

        return true;
    }

    /**
     * Delete a payment period and its related payments/discounts.
     */
    public function deletePeriod(int $id): bool
    {
        $periodTable = Database::get_main_table(self::TABLE_SCHOOL_PAYMENT_PERIOD);
        $paymentTable = Database::get_main_table(self::TABLE_SCHOOL_PAYMENT);
        $discountTable = Database::get_main_table(self::TABLE_SCHOOL_PAYMENT_DISCOUNT);

        Database::delete($discountTable, ['period_id = ?' => $id]);
        Database::delete($paymentTable, ['period_id = ?' => $id]);
        Database::delete($periodTable, ['id = ?' => $id]);

        return true;
    }

    /**
     * Get students with payment status for a given period.
     */
    public function getStudentsByPeriod(int $periodId, ?string $search = null): array
    {
        $periodTable = Database::get_main_table(self::TABLE_SCHOOL_PAYMENT_PERIOD);
        $paymentTable = Database::get_main_table(self::TABLE_SCHOOL_PAYMENT);
        $userTable = Database::get_main_table(TABLE_MAIN_USER);

        // Get the period info
        $sql = "SELECT * FROM $periodTable WHERE id = $periodId";
        $result = Database::query($sql);
        $period = Database::fetch_array($result, 'ASSOC');
        if (!$period) {
            return [];
        }

        $months = !empty($period['months']) ? explode(',', $period['months']) : [];

        // Get all students (STUDENT status)
        $searchFilter = '';
        if (!empty($search)) {
            $search = Database::escape_string($search);
            $searchFilter = " AND (u.firstname LIKE '%$search%' OR u.lastname LIKE '%$search%' OR u.username LIKE '%$search%')";
        }

        $sql = "SELECT u.user_id, u.firstname, u.lastname, u.username
                FROM $userTable u
                WHERE u.status = ".STUDENT."
                AND u.active = 1
                $searchFilter
                ORDER BY u.lastname, u.firstname";
        $result = Database::query($sql);

        $students = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $userId = (int) $row['user_id'];

            // Get payments for this student
            $sqlPayments = "SELECT type, month, status, amount, discount
                           FROM $paymentTable
                           WHERE period_id = $periodId AND user_id = $userId";
            $resPayments = Database::query($sqlPayments);

            $payments = ['enrollment' => null, 'months' => []];
            while ($p = Database::fetch_array($resPayments, 'ASSOC')) {
                if ($p['type'] === 'enrollment') {
                    $payments['enrollment'] = $p;
                } else {
                    $payments['months'][(int) $p['month']] = $p;
                }
            }

            $row['payments'] = $payments;
            $students[] = $row;
        }

        return $students;
    }

    /**
     * Get all payments for a specific student in a period.
     */
    public function getStudentPayments(int $periodId, int $userId): array
    {
        $periodTable = Database::get_main_table(self::TABLE_SCHOOL_PAYMENT_PERIOD);
        $paymentTable = Database::get_main_table(self::TABLE_SCHOOL_PAYMENT);
        $discountTable = Database::get_main_table(self::TABLE_SCHOOL_PAYMENT_DISCOUNT);

        // Get period
        $sql = "SELECT * FROM $periodTable WHERE id = $periodId";
        $result = Database::query($sql);
        $period = Database::fetch_array($result, 'ASSOC');
        if (!$period) {
            return [];
        }

        $months = !empty($period['months']) ? explode(',', $period['months']) : [];

        // Get discounts
        $discounts = $this->getDiscounts($periodId, $userId);

        // Get existing payments
        $sql = "SELECT * FROM $paymentTable WHERE period_id = $periodId AND user_id = $userId ORDER BY type, month";
        $result = Database::query($sql);
        $existingPayments = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            if ($row['type'] === 'admission') {
                $existingPayments['admission'] = $row;
            } elseif ($row['type'] === 'enrollment') {
                $existingPayments['enrollment'] = $row;
            } else {
                $existingPayments['month_' . $row['month']] = $row;
            }
        }

        // Build complete payment info
        $paymentInfo = [
            'period' => $period,
            'admission' => null,
            'enrollment' => null,
            'monthly' => [],
            'discounts' => $discounts,
            'total_paid' => 0,
            'total_pending' => 0,
            'total_discount' => 0,
        ];

        // Admission
        $admissionAmount = $this->getEffectiveAmount($periodId, $userId, 'admission');
        if (isset($existingPayments['admission'])) {
            $paymentInfo['admission'] = $existingPayments['admission'];
            if ($existingPayments['admission']['status'] === 'paid') {
                $paymentInfo['total_paid'] += (float) $existingPayments['admission']['amount'];
            } else {
                $paymentInfo['total_pending'] += $admissionAmount['final_amount'];
            }
            $paymentInfo['total_discount'] += (float) $existingPayments['admission']['discount'];
        } else {
            $paymentInfo['admission'] = [
                'status' => 'pending',
                'original_amount' => $admissionAmount['original_amount'],
                'discount' => $admissionAmount['discount_amount'],
                'amount' => $admissionAmount['final_amount'],
            ];
            $paymentInfo['total_pending'] += $admissionAmount['final_amount'];
        }

        // Enrollment
        $enrollAmount = $this->getEffectiveAmount($periodId, $userId, 'enrollment');
        if (isset($existingPayments['enrollment'])) {
            $paymentInfo['enrollment'] = $existingPayments['enrollment'];
            if ($existingPayments['enrollment']['status'] === 'paid') {
                $paymentInfo['total_paid'] += (float) $existingPayments['enrollment']['amount'];
            } else {
                $paymentInfo['total_pending'] += $enrollAmount['final_amount'];
            }
            $paymentInfo['total_discount'] += (float) $existingPayments['enrollment']['discount'];
        } else {
            $paymentInfo['enrollment'] = [
                'status' => 'pending',
                'original_amount' => $enrollAmount['original_amount'],
                'discount' => $enrollAmount['discount_amount'],
                'amount' => $enrollAmount['final_amount'],
            ];
            $paymentInfo['total_pending'] += $enrollAmount['final_amount'];
        }

        // Monthly
        foreach ($months as $m) {
            $m = (int) $m;
            $monthAmount = $this->getEffectiveAmount($periodId, $userId, 'monthly', $m);

            if (isset($existingPayments['month_' . $m])) {
                $paymentInfo['monthly'][$m] = $existingPayments['month_' . $m];
                if ($existingPayments['month_' . $m]['status'] === 'paid') {
                    $paymentInfo['total_paid'] += (float) $existingPayments['month_' . $m]['amount'];
                } else {
                    $paymentInfo['total_pending'] += $monthAmount['final_amount'];
                }
                $paymentInfo['total_discount'] += (float) $existingPayments['month_' . $m]['discount'];
            } else {
                $paymentInfo['monthly'][$m] = [
                    'status' => 'pending',
                    'original_amount' => $monthAmount['original_amount'],
                    'discount' => $monthAmount['discount_amount'],
                    'amount' => $monthAmount['final_amount'],
                ];
                $paymentInfo['total_pending'] += $monthAmount['final_amount'];
            }
        }

        return $paymentInfo;
    }

    /**
     * Save a payment record.
     */
    public function savePayment(array $data): int
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_PAYMENT);

        $periodId = (int) ($data['period_id'] ?? 0);
        $userId = (int) ($data['user_id'] ?? 0);
        $type = in_array($data['type'] ?? '', ['admission', 'enrollment', 'monthly']) ? $data['type'] : '';
        $month = $type === 'monthly' ? (int) ($data['month'] ?? 0) : null;

        if (!$periodId || !$userId || !$type) {
            return 0;
        }

        // Calculate effective amount (with discounts)
        $amountInfo = $this->getEffectiveAmount($periodId, $userId, $type, $month);
        $finalAmount = $amountInfo['final_amount'];

        $newPayment = isset($data['amount']) ? (float) $data['amount'] : $finalAmount;

        // Check if a previous payment exists
        $monthCondition = $month !== null ? " AND month = $month" : " AND month IS NULL";
        $sql = "SELECT id, amount, notes, receipt_number, voucher FROM $table WHERE period_id = $periodId AND user_id = $userId AND type = '$type' $monthCondition LIMIT 1";
        $result = Database::query($sql);
        $existing = Database::fetch_array($result, 'ASSOC');

        // Accumulate: previous paid + new payment
        $previousAmount = $existing ? (float) $existing['amount'] : 0;
        $totalAmount = $previousAmount + $newPayment;

        // Cap at the effective amount
        if ($totalAmount > $finalAmount) {
            $totalAmount = $finalAmount;
        }

        $status = $totalAmount >= $finalAmount ? 'paid' : ($totalAmount > 0 ? 'partial' : 'pending');

        // Build notes with payment history
        $paymentDate = !empty($data['payment_date']) ? Database::escape_string($data['payment_date']) : date('Y-m-d');
        $paymentMethod = Database::escape_string($data['payment_method'] ?? 'cash');
        $reference = Database::escape_string($data['reference'] ?? '');
        $userNotes = Database::escape_string($data['notes'] ?? '');

        // Append payment entry to notes history
        $historyEntry = '[' . $paymentDate . '] S/' . number_format($newPayment, 2) . ' ' . $paymentMethod;
        if (!empty($reference)) {
            $historyEntry .= ' Ref:' . $reference;
        }
        if (!empty($userNotes)) {
            $historyEntry .= ' - ' . $userNotes;
        }

        $previousNotes = $existing ? ($existing['notes'] ?? '') : '';
        $allNotes = !empty($previousNotes) ? $previousNotes . "\n" . $historyEntry : $historyEntry;

        // Generate receipt number
        $receiptNumber = $this->generateReceiptNumber();

        $params = [
            'period_id' => $periodId,
            'user_id' => $userId,
            'type' => $type,
            'month' => $month,
            'amount' => $totalAmount,
            'discount' => $amountInfo['discount_amount'],
            'original_amount' => $amountInfo['original_amount'],
            'payment_date' => $paymentDate,
            'payment_method' => $paymentMethod,
            'reference' => $reference,
            'receipt_number' => $receiptNumber,
            'notes' => $allNotes,
            'status' => $status,
            'registered_by' => api_get_user_id(),
        ];

        // Add voucher if provided
        if (!empty($data['voucher'])) {
            $params['voucher'] = Database::escape_string($data['voucher']);
        }

        if ($existing) {
            $params['updated_at'] = api_get_utc_datetime();
            // Keep original receipt_number if exists
            if (!empty($existing['receipt_number'])) {
                unset($params['receipt_number']);
            }
            Database::update($table, $params, ['id = ?' => (int) $existing['id']]);
            return (int) $existing['id'];
        } else {
            $params['created_at'] = api_get_utc_datetime();
            $id = Database::insert($table, $params);
            return (int) $id;
        }
    }

    /**
     * Delete a payment record.
     */
    public function deletePayment(int $id): bool
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_PAYMENT);
        Database::delete($table, ['id = ?' => $id]);
        return true;
    }

    /**
     * Get payment summary/statistics for a period.
     */
    public function getPaymentSummary(int $periodId): array
    {
        $paymentTable = Database::get_main_table(self::TABLE_SCHOOL_PAYMENT);

        $sql = "SELECT
                    COUNT(DISTINCT user_id) as total_students,
                    SUM(CASE WHEN status = 'paid' THEN amount ELSE 0 END) as total_collected,
                    SUM(CASE WHEN status = 'pending' THEN original_amount - discount ELSE 0 END) as total_pending,
                    SUM(discount) as total_discounts,
                    COUNT(CASE WHEN type = 'enrollment' AND status = 'paid' THEN 1 END) as enrollments_paid,
                    COUNT(CASE WHEN type = 'monthly' AND status = 'paid' THEN 1 END) as monthly_paid
                FROM $paymentTable
                WHERE period_id = $periodId";
        $result = Database::query($sql);
        $stats = Database::fetch_array($result, 'ASSOC');

        return $stats ?: [
            'total_students' => 0,
            'total_collected' => 0,
            'total_pending' => 0,
            'total_discounts' => 0,
            'enrollments_paid' => 0,
            'monthly_paid' => 0,
        ];
    }

    /**
     * Get discounts for a period (optionally filtered by user).
     */
    public function getDiscounts(int $periodId, ?int $userId = null): array
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_PAYMENT_DISCOUNT);
        $userTable = Database::get_main_table(TABLE_MAIN_USER);

        $userFilter = $userId ? " AND d.user_id = $userId" : "";
        $sql = "SELECT d.*, u.firstname, u.lastname, u.username
                FROM $table d
                INNER JOIN $userTable u ON d.user_id = u.user_id
                WHERE d.period_id = $periodId $userFilter
                ORDER BY u.lastname, u.firstname";
        $result = Database::query($sql);
        $discounts = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $discounts[] = $row;
        }
        return $discounts;
    }

    /**
     * Save a discount.
     */
    public function saveDiscount(array $data): bool
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_PAYMENT_DISCOUNT);

        // Sanitize excluded_months: keep only comma-separated integers 1-12
        $excludedMonthsRaw = $data['excluded_months'] ?? '';
        $excludedMonths = '';
        if (!empty($excludedMonthsRaw)) {
            $parts = array_filter(array_map('intval', explode(',', $excludedMonthsRaw)), function ($m) {
                return $m >= 1 && $m <= 12;
            });
            $excludedMonths = implode(',', array_unique($parts));
        }

        $params = [
            'period_id' => (int) ($data['period_id'] ?? 0),
            'user_id' => (int) ($data['user_id'] ?? 0),
            'discount_type' => in_array($data['discount_type'] ?? '', ['percentage', 'fixed']) ? $data['discount_type'] : 'fixed',
            'discount_value' => (float) ($data['discount_value'] ?? 0),
            'applies_to' => in_array($data['applies_to'] ?? '', ['enrollment', 'monthly', 'all']) ? $data['applies_to'] : 'all',
            'reason' => Database::escape_string($data['reason'] ?? ''),
            'excluded_months' => $excludedMonths,
            'created_by' => api_get_user_id(),
            'created_at' => api_get_utc_datetime(),
        ];

        if (!$params['period_id'] || !$params['user_id'] || $params['discount_value'] <= 0) {
            return false;
        }

        $id = isset($data['id']) ? (int) $data['id'] : 0;
        if ($id > 0) {
            unset($params['created_by'], $params['created_at']);
            Database::update($table, $params, ['id = ?' => $id]);
        } else {
            Database::insert($table, $params);
        }

        return true;
    }

    /**
     * Delete a discount.
     */
    public function deleteDiscount(int $id): bool
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_PAYMENT_DISCOUNT);
        Database::delete($table, ['id = ?' => $id]);
        return true;
    }

    /**
     * Calculate the effective amount after discounts.
     */
    public function getEffectiveAmount(int $periodId, int $userId, string $type, ?int $month = null): array
    {
        $periodTable = Database::get_main_table(self::TABLE_SCHOOL_PAYMENT_PERIOD);

        // Get period
        $sql = "SELECT * FROM $periodTable WHERE id = $periodId";
        $result = Database::query($sql);
        $period = Database::fetch_array($result, 'ASSOC');

        if (!$period) {
            return ['original_amount' => 0, 'discount_amount' => 0, 'final_amount' => 0];
        }

        // Try to resolve price by student's level/grade
        $resolvedPrice = $this->resolveStudentPriceInternal($periodId, $userId, $period);

        if ($type === 'admission') {
            $originalAmount = (float) $resolvedPrice['admission_amount'];
        } elseif ($type === 'enrollment') {
            $originalAmount = (float) $resolvedPrice['enrollment_amount'];
        } else {
            $originalAmount = (float) $resolvedPrice['monthly_amount'];
        }

        // Get applicable discounts
        $discounts = $this->getDiscounts($periodId, $userId);

        $totalDiscount = 0;
        foreach ($discounts as $d) {
            $appliesTo = $d['applies_to'];
            if ($appliesTo === 'all' || $appliesTo === $type) {
                // Skip if this month is excluded for monthly discounts
                if ($type === 'monthly' && $month !== null && !empty($d['excluded_months'])) {
                    $excludedList = array_map('intval', explode(',', $d['excluded_months']));
                    if (in_array($month, $excludedList)) {
                        continue;
                    }
                }
                if ($d['discount_type'] === 'percentage') {
                    $totalDiscount += $originalAmount * ((float) $d['discount_value'] / 100);
                } else {
                    $totalDiscount += (float) $d['discount_value'];
                }
            }
        }

        $totalDiscount = min($totalDiscount, $originalAmount);
        $finalAmount = $originalAmount - $totalDiscount;

        return [
            'original_amount' => $originalAmount,
            'discount_amount' => $totalDiscount,
            'final_amount' => $finalAmount,
        ];
    }

    /**
     * Resolve student price based on their classroom level/grade.
     * Priority: 1) Grade override, 2) Level price, 3) Period defaults.
     */
    private function resolveStudentPriceInternal(int $periodId, int $userId, array $period): array
    {
        $defaults = [
            'admission_amount' => (float) $period['admission_amount'],
            'enrollment_amount' => (float) $period['enrollment_amount'],
            'monthly_amount' => (float) $period['monthly_amount'],
        ];

        $priceTable = Database::get_main_table(self::TABLE_SCHOOL_PAYMENT_PERIOD_PRICE);
        $classroomTable = Database::get_main_table(self::TABLE_SCHOOL_ACADEMIC_CLASSROOM);
        $csTable = Database::get_main_table(self::TABLE_SCHOOL_ACADEMIC_CLASSROOM_STUDENT);
        $yearTable = Database::get_main_table(self::TABLE_SCHOOL_ACADEMIC_YEAR);
        $gradeTable = Database::get_main_table(self::TABLE_SCHOOL_ACADEMIC_GRADE);

        // Find student's classroom for this period's year
        $sql = "SELECT c.grade_id, g.level_id
                FROM $csTable cs
                INNER JOIN $classroomTable c ON cs.classroom_id = c.id
                INNER JOIN $yearTable y ON c.academic_year_id = y.id
                INNER JOIN $gradeTable g ON c.grade_id = g.id
                WHERE cs.user_id = " . (int) $userId . "
                AND y.year = " . (int) $period['year'] . "
                LIMIT 1";
        $result = Database::query($sql);
        $classroom = Database::fetch_array($result, 'ASSOC');

        if (!$classroom) {
            return $defaults;
        }

        $gradeId = (int) $classroom['grade_id'];
        $levelId = (int) $classroom['level_id'];

        // 1) Grade-specific price
        $sql = "SELECT * FROM $priceTable
                WHERE period_id = $periodId AND level_id = $levelId AND grade_id = $gradeId
                LIMIT 1";
        $result = Database::query($sql);
        $gradePrice = Database::fetch_array($result, 'ASSOC');
        if ($gradePrice) {
            return [
                'admission_amount' => (float) $gradePrice['admission_amount'],
                'enrollment_amount' => (float) $gradePrice['enrollment_amount'],
                'monthly_amount' => (float) $gradePrice['monthly_amount'],
            ];
        }

        // 2) Level price
        $sql = "SELECT * FROM $priceTable
                WHERE period_id = $periodId AND level_id = $levelId AND grade_id IS NULL
                LIMIT 1";
        $result = Database::query($sql);
        $levelPrice = Database::fetch_array($result, 'ASSOC');
        if ($levelPrice) {
            return [
                'admission_amount' => (float) $levelPrice['admission_amount'],
                'enrollment_amount' => (float) $levelPrice['enrollment_amount'],
                'monthly_amount' => (float) $levelPrice['monthly_amount'],
            ];
        }

        // 3) Period defaults
        return $defaults;
    }

    /**
     * Get payment report data for a period, optionally filtered by month.
     */
    public function getPaymentReport(int $periodId, ?int $month = null): array
    {
        $periodTable = Database::get_main_table(self::TABLE_SCHOOL_PAYMENT_PERIOD);
        $paymentTable = Database::get_main_table(self::TABLE_SCHOOL_PAYMENT);
        $userTable = Database::get_main_table(TABLE_MAIN_USER);

        // Get period
        $sql = "SELECT * FROM $periodTable WHERE id = $periodId";
        $result = Database::query($sql);
        $period = Database::fetch_array($result, 'ASSOC');
        if (!$period) {
            return [];
        }

        $months = !empty($period['months']) ? explode(',', $period['months']) : [];

        // Get all active students
        $sql = "SELECT u.user_id, u.firstname, u.lastname, u.username
                FROM $userTable u
                WHERE u.status = ".STUDENT." AND u.active = 1
                ORDER BY u.lastname, u.firstname";
        $result = Database::query($sql);

        $students = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $students[$row['user_id']] = $row;
        }

        if (empty($students)) {
            return ['period' => $period, 'months' => $months, 'paid' => [], 'debtors' => [], 'summary' => [], 'chart_data' => []];
        }

        $userIds = implode(',', array_keys($students));

        // Build month filter
        $monthFilter = '';
        if ($month !== null) {
            $monthFilter = " AND ((p.type = 'monthly' AND p.month = $month) OR p.type = 'enrollment')";
        }

        // Get all payments for the period
        $sql = "SELECT p.user_id, p.type, p.month, p.status, p.amount, p.discount, p.original_amount,
                       p.payment_date, p.payment_method, p.reference
                FROM $paymentTable p
                WHERE p.period_id = $periodId AND p.user_id IN ($userIds) $monthFilter";
        $result = Database::query($sql);

        $paymentsByUser = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $uid = (int) $row['user_id'];
            if (!isset($paymentsByUser[$uid])) {
                $paymentsByUser[$uid] = [];
            }
            $key = $row['type'] === 'enrollment' ? 'enrollment' : 'month_' . $row['month'];
            $paymentsByUser[$uid][$key] = $row;
        }

        // Classify students
        $paid = [];
        $debtors = [];

        // Per-month summary for chart
        $monthSummary = [];
        foreach ($months as $m) {
            $m = (int) $m;
            $monthSummary[$m] = ['paid_count' => 0, 'pending_count' => 0, 'paid_amount' => 0, 'pending_amount' => 0];
        }

        foreach ($students as $uid => $student) {
            $userPayments = $paymentsByUser[$uid] ?? [];
            $studentDebt = 0;
            $studentPaid = 0;
            $studentDetail = $student;
            $studentDetail['items'] = [];

            // Check enrollment
            if (isset($userPayments['enrollment']) && $userPayments['enrollment']['status'] === 'paid') {
                $studentPaid += (float) $userPayments['enrollment']['amount'];
            } else {
                $studentDebt += (float) $period['enrollment_amount'];
            }

            // Check monthly
            $targetMonths = $month !== null ? [$month] : $months;
            foreach ($targetMonths as $m) {
                $m = (int) $m;
                $key = 'month_' . $m;
                if (isset($userPayments[$key]) && $userPayments[$key]['status'] === 'paid') {
                    $studentPaid += (float) $userPayments[$key]['amount'];
                    if (isset($monthSummary[$m])) {
                        $monthSummary[$m]['paid_count']++;
                        $monthSummary[$m]['paid_amount'] += (float) $userPayments[$key]['amount'];
                    }
                    $studentDetail['items'][] = [
                        'month' => $m,
                        'status' => 'paid',
                        'amount' => (float) $userPayments[$key]['amount'],
                        'payment_date' => $userPayments[$key]['payment_date'],
                        'reference' => $userPayments[$key]['reference'],
                        'payment_method' => $userPayments[$key]['payment_method'],
                    ];
                } else {
                    $effectiveAmount = (float) $period['monthly_amount'];
                    $partialAmount = 0;
                    $status = 'pending';

                    if (isset($userPayments[$key]) && $userPayments[$key]['status'] === 'partial') {
                        $partialAmount = (float) $userPayments[$key]['amount'];
                        $studentPaid += $partialAmount;
                        $studentDebt += $effectiveAmount - $partialAmount;
                        $status = 'partial';
                        if (isset($monthSummary[$m])) {
                            $monthSummary[$m]['paid_amount'] += $partialAmount;
                            $monthSummary[$m]['pending_amount'] += $effectiveAmount - $partialAmount;
                            $monthSummary[$m]['pending_count']++;
                        }
                    } else {
                        $studentDebt += $effectiveAmount;
                        if (isset($monthSummary[$m])) {
                            $monthSummary[$m]['pending_count']++;
                            $monthSummary[$m]['pending_amount'] += $effectiveAmount;
                        }
                    }

                    $studentDetail['items'][] = [
                        'month' => $m,
                        'status' => $status,
                        'amount' => $partialAmount,
                        'pending' => $effectiveAmount - $partialAmount,
                        'payment_date' => null,
                        'reference' => null,
                        'payment_method' => null,
                    ];
                }
            }

            $studentDetail['total_paid'] = $studentPaid;
            $studentDetail['total_debt'] = $studentDebt;

            if ($studentDebt > 0) {
                $debtors[] = $studentDetail;
            } else {
                $paid[] = $studentDetail;
            }
        }

        // Chart data
        $chartLabels = [];
        $chartPaid = [];
        $chartPending = [];
        $chartPaidCount = [];
        $chartPendingCount = [];

        $monthNames = [
            1 => 'Ene', 2 => 'Feb', 3 => 'Mar', 4 => 'Abr', 5 => 'May', 6 => 'Jun',
            7 => 'Jul', 8 => 'Ago', 9 => 'Sep', 10 => 'Oct', 11 => 'Nov', 12 => 'Dic'
        ];

        foreach ($months as $m) {
            $m = (int) $m;
            $chartLabels[] = $monthNames[$m] ?? $m;
            $chartPaid[] = round($monthSummary[$m]['paid_amount'], 2);
            $chartPending[] = round($monthSummary[$m]['pending_amount'], 2);
            $chartPaidCount[] = $monthSummary[$m]['paid_count'];
            $chartPendingCount[] = $monthSummary[$m]['pending_count'];
        }

        $totalStudents = count($students);
        $totalPaidStudents = count($paid);
        $totalDebtors = count($debtors);
        $totalCollected = array_sum($chartPaid);
        $totalPending = array_sum($chartPending);

        return [
            'period' => $period,
            'months' => $months,
            'paid' => $paid,
            'debtors' => $debtors,
            'summary' => [
                'total_students' => $totalStudents,
                'total_paid_students' => $totalPaidStudents,
                'total_debtors' => $totalDebtors,
                'total_collected' => $totalCollected,
                'total_pending' => $totalPending,
            ],
            'chart_data' => [
                'labels' => $chartLabels,
                'paid' => $chartPaid,
                'pending' => $chartPending,
                'paid_count' => $chartPaidCount,
                'pending_count' => $chartPendingCount,
            ],
        ];
    }

    /**
     * Export payment report as CSV.
     */
    public function exportPaymentReportCSV(int $periodId, ?int $month = null, string $filter = 'all'): void
    {
        $report = $this->getPaymentReport($periodId, $month);
        if (empty($report)) {
            return;
        }

        $period = $report['period'];
        $monthNames = [
            1 => 'Enero', 2 => 'Febrero', 3 => 'Marzo', 4 => 'Abril',
            5 => 'Mayo', 6 => 'Junio', 7 => 'Julio', 8 => 'Agosto',
            9 => 'Septiembre', 10 => 'Octubre', 11 => 'Noviembre', 12 => 'Diciembre'
        ];

        $filterLabel = $filter === 'debtors' ? 'deudores' : ($filter === 'paid' ? 'pagados' : 'todos');
        $monthLabel = $month !== null ? '_' . ($monthNames[$month] ?? $month) : '';
        $filename = 'reporte_pagos_' . $period['name'] . $monthLabel . '_' . $filterLabel . '_' . date('Y-m-d') . '.csv';
        $filename = str_replace(' ', '_', $filename);

        header('Content-Type: text/csv; charset=utf-8');
        header('Content-Disposition: attachment; filename="' . $filename . '"');

        $output = fopen('php://output', 'w');
        fprintf($output, chr(0xEF).chr(0xBB).chr(0xBF));

        // Header
        fputcsv($output, [
            'Apellidos', 'Nombres', 'Usuario', 'Mes', 'Estado',
            'Monto Pagado', 'Monto Pendiente', 'Fecha de Pago', 'Metodo', 'Referencia'
        ], ';');

        $students = [];
        if ($filter === 'debtors') {
            $students = $report['debtors'];
        } elseif ($filter === 'paid') {
            $students = $report['paid'];
        } else {
            $students = array_merge($report['paid'], $report['debtors']);
        }

        usort($students, function ($a, $b) {
            return strcmp($a['lastname'], $b['lastname']);
        });

        foreach ($students as $student) {
            foreach ($student['items'] as $item) {
                $mName = $monthNames[$item['month']] ?? $item['month'];
                $statusLabel = $item['status'] === 'paid' ? 'Pagado' : ($item['status'] === 'partial' ? 'Parcial' : 'Pendiente');
                $pending = $item['pending'] ?? ($item['status'] === 'paid' ? 0 : (float) $period['monthly_amount'] - (float) $item['amount']);

                fputcsv($output, [
                    $student['lastname'],
                    $student['firstname'],
                    $student['username'],
                    $mName,
                    $statusLabel,
                    number_format((float) $item['amount'], 2, '.', ''),
                    number_format($pending, 2, '.', ''),
                    $item['payment_date'] ?? '-',
                    $item['payment_method'] ?? '-',
                    $item['reference'] ?? '-',
                ], ';');
            }
        }

        // Summary row
        fputcsv($output, [], ';');
        fputcsv($output, ['RESUMEN'], ';');
        fputcsv($output, ['Total Alumnos', $report['summary']['total_students']], ';');
        fputcsv($output, ['Al dia', $report['summary']['total_paid_students']], ';');
        fputcsv($output, ['Con deuda', $report['summary']['total_debtors']], ';');
        fputcsv($output, ['Total Recaudado', 'S/ ' . number_format($report['summary']['total_collected'], 2, '.', '')], ';');
        fputcsv($output, ['Total Pendiente', 'S/ ' . number_format($report['summary']['total_pending'], 2, '.', '')], ';');

        fclose($output);
        exit;
    }

    /**
     * Generate a unique correlative receipt number.
     * Format: YYYY-NNNNN (e.g., 2026-00001)
     */
    public function generateReceiptNumber(): string
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_PAYMENT);
        $year = date('Y');
        $prefix = $year . '-';

        $sql = "SELECT receipt_number FROM $table
                WHERE receipt_number LIKE '$prefix%'
                ORDER BY receipt_number DESC LIMIT 1";
        $result = Database::query($sql);
        $row = Database::fetch_array($result, 'ASSOC');

        if ($row && !empty($row['receipt_number'])) {
            $lastNumber = (int) substr($row['receipt_number'], strlen($prefix));
            $nextNumber = $lastNumber + 1;
        } else {
            $nextNumber = 1;
        }

        return $prefix . str_pad($nextNumber, 5, '0', STR_PAD_LEFT);
    }

    // ==================== PRODUCTS ====================

    /**
     * Get all product categories.
     */
    public function getProductCategories(bool $activeOnly = false): array
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_PRODUCT_CATEGORY);
        $where = $activeOnly ? "WHERE active = 1" : "";
        $sql = "SELECT * FROM $table $where ORDER BY name ASC";
        $result = Database::query($sql);
        $categories = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $categories[] = $row;
        }
        return $categories;
    }

    /**
     * Save (create or update) a product category.
     */
    public function saveProductCategory(array $data): bool
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_PRODUCT_CATEGORY);
        $id = isset($data['id']) ? (int) $data['id'] : 0;

        $params = [
            'name' => Database::escape_string($data['name']),
            'active' => isset($data['active']) ? (int) $data['active'] : 1,
        ];

        if ($id > 0) {
            Database::update($table, $params, ['id = ?' => $id]);
        } else {
            $params['created_at'] = date('Y-m-d H:i:s');
            Database::insert($table, $params);
        }
        return true;
    }

    /**
     * Delete a product category.
     */
    public function deleteProductCategory(int $id): bool
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_PRODUCT_CATEGORY);
        Database::delete($table, ['id = ?' => $id]);
        return true;
    }

    /**
     * Get all products with category name.
     */
    public function getProducts(bool $activeOnly = false): array
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_PRODUCT);
        $catTable = Database::get_main_table(self::TABLE_SCHOOL_PRODUCT_CATEGORY);
        $where = $activeOnly ? "WHERE p.active = 1" : "";
        $sql = "SELECT p.*, c.name as category_name
                FROM $table p
                LEFT JOIN $catTable c ON p.category_id = c.id
                $where ORDER BY p.name ASC";
        $result = Database::query($sql);
        $products = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $products[] = $row;
        }
        return $products;
    }

    /**
     * Get a single product by ID.
     */
    public function getProduct(int $id): ?array
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_PRODUCT);
        $sql = "SELECT * FROM $table WHERE id = $id";
        $result = Database::query($sql);
        $row = Database::fetch_array($result, 'ASSOC');
        return $row ?: null;
    }

    /**
     * Save (create or update) a product.
     */
    public function saveProduct(array $data): bool
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_PRODUCT);
        $id = isset($data['id']) ? (int) $data['id'] : 0;

        $params = [
            'name' => Database::escape_string($data['name']),
            'description' => Database::escape_string($data['description'] ?? ''),
            'price' => (float) $data['price'],
            'category_id' => !empty($data['category_id']) ? (int) $data['category_id'] : null,
            'active' => isset($data['active']) ? (int) $data['active'] : 1,
        ];

        if ($id > 0) {
            Database::update($table, $params, ['id = ?' => $id]);
        } else {
            $params['created_at'] = date('Y-m-d H:i:s');
            Database::insert($table, $params);
        }
        return true;
    }

    /**
     * Delete a product.
     */
    public function deleteProduct(int $id): bool
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_PRODUCT);
        Database::delete($table, ['id = ?' => $id]);
        return true;
    }

    /**
     * Get product sales with filters.
     */
    public function getProductSales(array $filters = []): array
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_PRODUCT_SALE);
        $productTable = Database::get_main_table(self::TABLE_SCHOOL_PRODUCT);
        $userTable = Database::get_main_table(TABLE_MAIN_USER);

        $where = "1=1";
        if (!empty($filters['product_id'])) {
            $where .= " AND s.product_id = " . (int) $filters['product_id'];
        }
        if (!empty($filters['user_id'])) {
            $where .= " AND s.user_id = " . (int) $filters['user_id'];
        }
        if (!empty($filters['date_from'])) {
            $dateFrom = Database::escape_string($filters['date_from']);
            $where .= " AND DATE(s.created_at) >= '$dateFrom'";
        }
        if (!empty($filters['date_to'])) {
            $dateTo = Database::escape_string($filters['date_to']);
            $where .= " AND DATE(s.created_at) <= '$dateTo'";
        }

        $catTable = Database::get_main_table(self::TABLE_SCHOOL_PRODUCT_CATEGORY);
        $sql = "SELECT s.*, p.name as product_name, c.name as category_name,
                       u.firstname, u.lastname, u.username
                FROM $table s
                INNER JOIN $productTable p ON s.product_id = p.id
                LEFT JOIN $catTable c ON p.category_id = c.id
                INNER JOIN $userTable u ON s.user_id = u.user_id
                WHERE $where
                ORDER BY s.created_at DESC";
        $result = Database::query($sql);
        $sales = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $sales[] = $row;
        }
        return $sales;
    }

    /**
     * Save a product sale.
     */
    public function saveProductSale(array $data): int
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_PRODUCT_SALE);

        $unitPrice = (float) $data['unit_price'];
        $quantity = max(1, (int) $data['quantity']);
        $discount = (float) ($data['discount'] ?? 0);
        $totalAmount = ($unitPrice * $quantity) - $discount;
        if ($totalAmount < 0) {
            $totalAmount = 0;
        }

        $params = [
            'product_id' => (int) $data['product_id'],
            'user_id' => (int) $data['user_id'],
            'quantity' => $quantity,
            'unit_price' => $unitPrice,
            'discount' => $discount,
            'total_amount' => $totalAmount,
            'payment_method' => Database::escape_string($data['payment_method'] ?? 'cash'),
            'reference' => Database::escape_string($data['reference'] ?? ''),
            'receipt_number' => $this->generateReceiptNumber(),
            'notes' => Database::escape_string($data['notes'] ?? ''),
            'status' => 'paid',
            'registered_by' => api_get_user_id(),
            'created_at' => date('Y-m-d H:i:s'),
        ];

        $id = Database::insert($table, $params);
        return (int) $id;
    }

    /**
     * Delete a product sale.
     */
    public function deleteProductSale(int $id): bool
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_PRODUCT_SALE);
        Database::delete($table, ['id = ?' => $id]);
        return true;
    }

    /**
     * Get a product sale by ID with full details.
     */
    public function getProductSaleById(int $id): ?array
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_PRODUCT_SALE);
        $productTable = Database::get_main_table(self::TABLE_SCHOOL_PRODUCT);
        $userTable = Database::get_main_table(TABLE_MAIN_USER);

        $sql = "SELECT s.*, p.name as product_name, p.category,
                       u.firstname, u.lastname, u.username, u.email
                FROM $table s
                INNER JOIN $productTable p ON s.product_id = p.id
                INNER JOIN $userTable u ON s.user_id = u.user_id
                WHERE s.id = $id";
        $result = Database::query($sql);
        $row = Database::fetch_array($result, 'ASSOC');

        if (!$row) {
            return null;
        }

        $extraProfile = $this->getExtraProfileData((int) $row['user_id']);
        $row['document_type'] = $extraProfile['document_type'] ?? '';
        $row['document_number'] = $extraProfile['document_number'] ?? '';

        return $row;
    }

    /**
     * Get product sales for a student (for student view).
     */
    public function getMyProductSales(int $userId): array
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_PRODUCT_SALE);
        $productTable = Database::get_main_table(self::TABLE_SCHOOL_PRODUCT);

        $catTable = Database::get_main_table(self::TABLE_SCHOOL_PRODUCT_CATEGORY);
        $sql = "SELECT s.*, p.name as product_name, c.name as category_name
                FROM $table s
                INNER JOIN $productTable p ON s.product_id = p.id
                LEFT JOIN $catTable c ON p.category_id = c.id
                WHERE s.user_id = $userId
                ORDER BY s.created_at DESC";
        $result = Database::query($sql);
        $sales = [];
        while ($row = Database::fetch_array($result, 'ASSOC')) {
            $sales[] = $row;
        }
        return $sales;
    }

    /**
     * Get a payment record by ID with full details.
     */
    public function getPaymentById(int $id): ?array
    {
        $table = Database::get_main_table(self::TABLE_SCHOOL_PAYMENT);
        $periodTable = Database::get_main_table(self::TABLE_SCHOOL_PAYMENT_PERIOD);
        $userTable = Database::get_main_table(TABLE_MAIN_USER);

        $sql = "SELECT p.*, pp.name as period_name, pp.year as period_year,
                       u.firstname, u.lastname, u.username, u.email
                FROM $table p
                INNER JOIN $periodTable pp ON p.period_id = pp.id
                INNER JOIN $userTable u ON p.user_id = u.user_id
                WHERE p.id = $id";
        $result = Database::query($sql);
        $row = Database::fetch_array($result, 'ASSOC');

        if (!$row) {
            return null;
        }

        // Get extra profile data (DNI)
        $extraProfile = $this->getExtraProfileData((int) $row['user_id']);
        $row['document_type'] = $extraProfile['document_type'] ?? '';
        $row['document_number'] = $extraProfile['document_number'] ?? '';

        return $row;
    }
}
