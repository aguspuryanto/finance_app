<?php

namespace App\Controllers;

use Supabase\Functions as Supabase;

class Home extends BaseController
{
    protected $client;
    public function __construct()
    {
        // config
        $config = [
            'url' => $_ENV['SUPABASE_URL'],
            'apikey' => $_ENV['SUPABASE_KEY']
        ];
        $this->client = new Supabase($config['url'], $config['apikey']);
    }

    public function index(): string
    {
        $listTransactions = $this->client->pages('transactions', ['limit' => 100]);
        // print_r($listTransactions);
        // $listTransactions = $listTransactions->{'date'};

        asort($listTransactions, SORT_ASC);

        // return view('welcome_message');
        return view('pages/home', [
            'listTransactions' => $listTransactions
        ]);
    }
}
