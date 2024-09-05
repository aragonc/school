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

        $css[] = api_get_cdn_path(api_get_path(WEB_PLUGIN_PATH) . 'school/css/style.css');
        $css_file_to_string = null;
        foreach ($css as $file) {
            $css_file_to_string .= api_get_css($file);
        }
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
