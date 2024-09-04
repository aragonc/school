<?php

class SchoolPlugin extends Plugin
{
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
}
