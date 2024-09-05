<?php

use Twig\Error\LoaderError;
use Twig\Error\RuntimeError;
use Twig\Error\SyntaxError;

class SchoolPlugin extends Plugin
{
    public $twig = null;
    public $params = [];
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
            api_get_path(SYS_CODE_PATH).'template/overrides', // user defined templates
            api_get_path(SYS_CODE_PATH).'template', //template folder
            api_get_path(SYS_PLUGIN_PATH), // plugin folder
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

        $js_file_to_string .= '<script src="'.api_get_cdn_path(api_get_path(WEB_PLUGIN_PATH).'school/js/sb-admin-2.min.js').'"></script>'."\n";

        $vendor = api_get_path(WEB_PLUGIN_PATH).'school/vendor/';
        $this->assign('assets', $vendor);
        $this->assign('js_files', $js_file_to_string);
        $this->assign('css_files', $css_file_to_string);

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
    public function get_template($name): string
    {
        return api_find_template($name);
    }

    /**
     * @throws RuntimeError
     * @throws SyntaxError
     * @throws LoaderError
     */
    public function display_blank_template()
    {
        $tpl = $this->twig->loadTemplate('school/view/layout/blank.tpl');
        $this->display($tpl);
    }
}
