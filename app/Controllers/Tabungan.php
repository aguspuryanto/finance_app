<?php

namespace App\Controllers;

use App\Controllers\BaseController;
use CodeIgniter\HTTP\ResponseInterface;
use Supabase\Functions as Supabase;

class Tabungan extends BaseController
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
        $listTabungan = $this->client->getAllData('savings');
        asort($listTabungan, SORT_ASC);
        
        return view('pages/tabungan', [
            'title' => 'Tabungan',
            'listTabungan' => $listTabungan
        ]);
    }
}
