<?php

namespace App\Controllers;

use App\Controllers\BaseController;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\HTTP\RedirectResponse;
use Supabase\Functions as Supabase;

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
        $listTransactions = $this->client->getAllData('transactions');

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
            'listTransactions' => $listTransactions,
            'totalPemasukan' => $totalPemasukan,
            'totalPengeluaran' => $totalPengeluaran
        ]);
    }
}