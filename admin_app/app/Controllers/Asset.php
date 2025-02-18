<?php

namespace App\Controllers;

use App\Controllers\BaseController;
use CodeIgniter\HTTP\ResponseInterface;
use Supabase\Functions as Supabase;

class Asset extends BaseController
{
    protected $client;

    public function __construct()
    {
        // config, https://github.com/CodeWithSushil/supabase-client
        $config = [
            'url' => $_ENV['SUPABASE_URL'],
            'apikey' => $_ENV['SUPABASE_KEY']
        ];
        $this->client = new Supabase($config['url'], $config['apikey']);
    }

    public function index()
    {
        $listAssets = $this->client->getAllData('assets');
        return view('pages/asset', [
            'title' => 'Asset',
            'listAssets' => $listAssets
        ]);
    }
}
