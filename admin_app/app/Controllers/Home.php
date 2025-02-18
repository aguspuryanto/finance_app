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

    public function create()
    {
        $listCategories = $this->client->getAllData('categories');

        return view('pages/create', [
            'title' => 'Tambah Transaksi',
            'listCategories' => $listCategories
        ]);
    }

    public function store()
    {
        $data = [
            'title' => $_POST['title'],
            'amount' => $_POST['amount'],
            'date' => date('Y-m-d H:i:s', strtotime($_POST['date'] . ' ' . $_POST['time'])),
            'category' => $_POST['category'],
            'type' => $_POST['type']
        ];
        // print_r($data);
        // $response = $this->client->postData('transactions', $data, 'id');
        // print_r($response); //{"code":"PGRST102","details":null,"hint":null,"message":"Content-Type not acceptable: application/json, application/json"}
        
        // curl 'https://cltgxntkqfjwuoyqeqmk.supabase.co/rest/v1/' \
        // -H "apikey: SUPABASE_CLIENT_API_KEY" 

        // User-Agent
        $options = [
            CURLOPT_URL => 'https://cltgxntkqfjwuoyqeqmk.supabase.co/rest/v1/transactions',
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_SSL_VERIFYPEER => false,
            CURLOPT_SSL_VERIFYHOST => false,
            CURLOPT_FOLLOWLOCATION => true,
            CURLOPT_USERAGENT => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            CURLOPT_HTTPHEADER => [
                'apikey: ' . $_ENV['SUPABASE_KEY'],
                'Content-Type: application/json',
                'Authorization: Bearer ' . $_ENV['SUPABASE_KEY'],
                'Prefer: return=minimal'
            ],
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => json_encode($data)
        ];

        // Post data
        $ch = curl_init();
        curl_setopt_array($ch, $options);
        $html = curl_exec($ch);

        if(curl_errno($ch)){
          $error = curl_error($ch);
          echo json_encode($error, JSON_PRETTY_PRINT);
        }

        // Validate HTTP status code 
        $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        
        if ($http_code !== 201) {
            echo "Request failed with status code $http_code" . PHP_EOL;
            echo "Error: " . curl_error($ch) . PHP_EOL;
            curl_close($ch);
            exit;
        }
        curl_close($ch);
        print_r($html);
        return redirect()->to('/')->with('success', 'Data berhasil ditambahkan');
    }

    public function edit($id)
    {
        $data = $this->client->filter('transactions', $id);
        // print_r($data);
        $listCategories = $this->client->getAllData('categories');
        
        return view('pages/edit', [
            'data' => $data,
            'listCategories' => $listCategories
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

    public function delete($id)
    {
        $this->client->deleteData('transactions', $id);
        return redirect()->to('/')->with('success', 'Data berhasil dihapus');
    }
}
