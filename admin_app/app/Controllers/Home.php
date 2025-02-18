<?php

namespace App\Controllers;

use Supabase\Functions as Supabase;

class Home extends BaseController
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

    public function index(): string
    {
        $listTransactions = $this->client->getAllData('transactions');
        // $listTransactions = $this->client->pages('transactions', ['limit' => 100]);
        // print_r($listTransactions);
        // $listTransactions = $listTransactions->{'date'};

        asort($listTransactions, SORT_ASC);

        // Hitung total pemasukan dan pengeluaran
        $totalPemasukan = 0;
        $totalPengeluaran = 0;
        foreach ($listTransactions as $transaction) {
            if ($transaction['type'] == 'Pemasukan') {
                $totalPemasukan += $transaction['amount'];
            } else {
                $totalPengeluaran += $transaction['amount'];
            }
        }

        // return view('welcome_message');
        return view('pages/home', [
            'listTransactions' => $listTransactions,
            'totalPemasukan' => $totalPemasukan,
            'totalPengeluaran' => $totalPengeluaran
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
            'date' => date('Y-m-d H:i:s', strtotime($_POST['date'] . ' ' . $_POST['time'])),
            'category' => $_POST['category'],
            // 'description' => $_POST['description'],
            'type' => $_POST['type']
        ];
        // echo json_encode($data); die();

        $this->client->updateData('transactions', $_POST['id'], $data);
        // $this->client->postData('transactions', $data, $_POST['id']);
        return redirect()->to('/')->with('success', 'Data berhasil diubah');
    }
}
