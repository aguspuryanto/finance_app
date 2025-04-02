<?php

namespace App\Controllers;

use App\Controllers\BaseController;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\HTTP\RedirectResponse;
use Supabase\Functions as Supabase;
use DateTime;
class Laporan extends BaseController
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
        // $listTransactions = $this->client->getAllData('transactions');
        $month = $this->request->getVar('month');
        $startDate = ($month) ? date('Y-m-24', strtotime('-1 month', strtotime($month))) : date('Y-m-24', strtotime('last month'));
        $endDate = ($month) ? date('Y-m-24', strtotime($month)) : new DateTime('now')->format('Y-m-d');

        // echo "startDate: ". $startDate. "<br>";
        // echo "endDate: ". $endDate. "<br>";
        $options = [
            CURLOPT_URL => $_ENV['SUPABASE_URL'] . '/rest/v1/transactions?select=*&date=gte.' . $startDate . '&date=lte.' . $endDate . '&order=date.asc',
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_SSL_VERIFYPEER => false,
            CURLOPT_SSL_VERIFYHOST => false,
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
            return redirect()->to('/')->with('error', curl_error($ch));
        }

        $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($http_code === 200) {
            $listTransactions = json_decode($response, true);
        } else {
            return redirect()->to('/')->with('error', 'Failed to fetch data. Status code: ' . $http_code);
        }

        asort($listTransactions, SORT_ASC);

        $totalPemasukan = 0;
        $totalPengeluaran = 0;
        foreach ($listTransactions as $transaction) {
            if ($transaction['type'] == 'Pemasukan') {
                $totalPemasukan += $transaction['amount'];
            } else {
                $totalPengeluaran += $transaction['amount'];
            }
        }

        return view('pages/laporan', [
            'title' => 'Laporan',
            'getMonth' => $month,
            'listTransactions' => $listTransactions,
            'totalPemasukan' => $totalPemasukan,
            'totalPengeluaran' => $totalPengeluaran
        ]);
    }
}