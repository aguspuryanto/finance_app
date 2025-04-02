<?php

namespace App\Controllers;

use Supabase\Functions as Supabase;
use PHPSupabase\Service as Service;
use DateTime;
class Home extends BaseController
{
    protected $client;
    protected $service;

    public function __construct()
    {
        // config, https://github.com/CodeWithSushil/supabase-client
        $config = [
            'url' => $_ENV['SUPABASE_URL'],
            'apikey' => $_ENV['SUPABASE_KEY']
        ];
        $this->client = new Supabase($config['url'], $config['apikey']);
        $this->service = new Service($config['apikey'], $config['url'] . '/rest/v1');
    }

    public function index(): string
    {
        $listTransactions = $this->client->getAllData('transactions');
        // $listTransactions = $this->client->pages('transactions', ['limit' => 100]);
        // echo json_encode($listTransactions);
        // $listTransactions = $listTransactions->{'date'};

        asort($listTransactions, SORT_ASC);

        // Tanggal awal
        $dateStart = new DateTime();

        // Kurangi satu bulan dari tanggal awal
        $dateEnd = clone $dateStart;
        $dateEnd->modify('-1 month');

        // Format tanggal untuk filter
        $dateStartFormatted = $dateStart->format('Y-m-d');
        $dateEndFormatted = $dateEnd->format('Y-m-d');

        // Filter data berdasarkan rentang tanggal
        // $listTransactions = array_filter($listTransactions, function ($transaction) use ($dateStartFormatted, $dateEndFormatted) {
        //     return $transaction['date'] >= $dateEndFormatted && $transaction['date'] <= $dateStartFormatted;
        // });

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
            'totalPengeluaran' => $totalPengeluaran,
            'dateStartFormatted' => $dateStartFormatted,
            'dateEndFormatted' => $dateEndFormatted
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
        $response = $this->goCurl($data);
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
        // $response = $this->client->updateData('transactions', $_POST['id'], $data);

        try {
            $options = [
                CURLOPT_URL => $_ENV['SUPABASE_URL'] . '/rest/v1/transactions?id=eq.' . $_POST['id'],
                CURLOPT_RETURNTRANSFER => true,
                CURLOPT_CUSTOMREQUEST => 'PATCH',
                CURLOPT_SSL_VERIFYPEER => false,
                CURLOPT_SSL_VERIFYHOST => false,
                CURLOPT_HTTPHEADER => [
                    'apikey: ' . $_ENV['SUPABASE_KEY'],
                    'Authorization: Bearer ' . $_ENV['SUPABASE_KEY'],
                    'Content-Type: application/json',
                    'Prefer: return=minimal'
                ],
                CURLOPT_POSTFIELDS => json_encode($data)
            ];

            $ch = curl_init();
            curl_setopt_array($ch, $options);
            $response = curl_exec($ch);

            if (curl_errno($ch)) {
                throw new \Exception(curl_error($ch));
            }

            $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);

            if ($http_code === 204) {
                return redirect()->to('/')->with('success', 'Data berhasil diubah');
            } else {
                throw new \Exception('Failed to update data. Status code: ' . $http_code);
            }
        } catch (\Exception $e) {
            return redirect()->to('/')->with('error', $e->getMessage());
        }
    }

    public function delete($id)
    {
        // $this->client->deleteData('transactions', $id);
        $options = [
            CURLOPT_URL => $_ENV['SUPABASE_URL'] . '/rest/v1/transactions?id=eq.' . $id,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_CUSTOMREQUEST => 'DELETE',
            CURLOPT_SSL_VERIFYPEER => false, // Disable SSL verification
            CURLOPT_SSL_VERIFYHOST => false, // Disable host verification
            CURLOPT_HTTPHEADER => [
                'apikey: ' . $_ENV['SUPABASE_KEY'],
                'Authorization: Bearer ' . $_ENV['SUPABASE_KEY'],
                'Content-Type: application/json'
            ]
        ];

        $ch = curl_init();
        curl_setopt_array($ch, $options);
        $response = curl_exec($ch);

        if (curl_errno($ch)) {
            $error = curl_error($ch);
            curl_close($ch);
            return redirect()->to('/')->with('error', $error);
        }

        $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($http_code === 204) {
            return redirect()->to('/')->with('success', 'Data berhasil dihapus');
        } else {
            return redirect()->to('/')->with('error', 'Failed to delete data. Status code: ' . $http_code);
        }
    }

    public function goCurl($data)
    {

        // User-Agent
        $options = [
            CURLOPT_URL => $_ENV['SUPABASE_URL'] . '/rest/v1/transactions',
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
        return ($html);
    }
}
