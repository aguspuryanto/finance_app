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

    public function edit($id)
    {
        $data = $this->client->filter('transactions', $id);
        // print_r($data);
        return view('pages/edit', [
            'data' => $data
        ]);
    }

    public function update()
    {
        // print_r($_POST);
        // updated data
        $data = [
            'title' => $_POST['title'],
            'amount' => $_POST['amount'],
            'date' => date('Y-m-d H:i:s', strtotime($_POST['date'])),
            'category' => $_POST['category'],
            // 'description' => $_POST['description'],
            'type' => $_POST['type']
        ];

        $this->client->updateData('transactions', $_POST['id'], $data);
        return redirect()->to('/')->with('success', 'Data berhasil diubah');
    }
}
