<?php

namespace App\Controllers;

use App\Controllers\BaseController;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\HTTP\RedirectResponse;
use Supabase\Functions as Supabase;
use DateTime;
use OpenAI\Client as OpenAI;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;

class Laporan extends BaseController
{   
    protected $client;
    protected $openai;

    public function __construct()
    {
        // config, https://github.com/CodeWithSushil/supabase-client
        $config = [
            'url' => $_ENV['SUPABASE_URL'],
            'apikey' => $_ENV['SUPABASE_KEY']
        ];
        $this->client = new Supabase($config['url'], $config['apikey']);
        // $this->openai = new OpenAI($_ENV['OPENAI_API_KEY']);
    }

    public function index()
    {
        // $listTransactions = $this->client->getAllData('transactions');
        // $currentMonth = $this->request->getVar('month');
        // $startDate = ($currentMonth) ? date('Y-m-26', strtotime('-1 month', strtotime($currentMonth))) : date('Y-m-26', strtotime('last month'));
        // $endDate = ($currentMonth) ? date('Y-m-25', strtotime($currentMonth)) : new DateTime('now', new \DateTimeZone("Asia/Jakarta"))->format('Y-m-d');

        // Mendapatkan tanggal hari ini
        $today = new DateTime();

        // Mendapatkan tanggal (1-31)
        $currentDay = (int)$today->format('d');

        // Mendapatkan bulan dan tahun saat ini
        $currentMonth = (int)$today->format('m');
        $currentYear = (int)$today->format('Y');

        // Menentukan tanggal awal dan akhir laporan
        if ($currentDay >= 25) {
            // Jika hari ini tanggal 25, mulai dari 25 bulan ini
            $startDate = new DateTime("$currentYear-$currentMonth-24");
            // $endDate = new DateTime("$currentYear-$currentMonth-24");
            // $endDate->modify('+1 month');
            $endDate = new DateTime();
        } else {
            // Jika bukan tanggal 25, mulai dari 25 bulan sebelumnya
            $startDate = new DateTime("$currentYear-$currentMonth-25");
            $startDate->modify('-1 month');
            
            $endDate = new DateTime("$currentYear-$currentMonth-24");
        }

        if($this->request->getVar('month')){
            $currentMonth = $this->request->getVar('month');
            list($currentYear, $currentMonth) = explode('-', $currentMonth);
            
            $startDate = new DateTime("$currentYear-$currentMonth-25");
            $startDate->modify('-1 month');
            
            $endDate = new DateTime("$currentYear-$currentMonth-24");
        }

        // Format tanggal untuk ditampilkan
        $startDate = $startDate->format('Y-m-d');
        $endDate = $endDate->format('Y-m-d');

        // echo "Periode Laporan: $formattedStart sampai $formattedEnd";

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
            'currentMonth' => $currentMonth,
            'startDate' => $startDate,
            'endDate' => $endDate,
            'listTransactions' => $listTransactions,
            'totalPemasukan' => $totalPemasukan,
            'totalPengeluaran' => $totalPengeluaran
        ]);
    }

    public function export()
    {
        // $listTransactions = $this->client->getAllData('transactions');
        $month = $this->request->getVar('month');
        $startDate = ($month) ? date('Y-m-25', strtotime('-1 month', strtotime($month))) : date('Y-m-25', strtotime('last month'));
        $endDate = ($month) ? date('Y-m-25', strtotime($month)) : new DateTime('now')->format('Y-m-d');

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

        // asort($listTransactions, SORT_ASC);
        // echo json_encode($listTransactions); exit;

        // Decode the JSON data into a PHP array
        $data = json_decode(json_encode($listTransactions), true);

        // Create a new Spreadsheet object
        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();

        // Define the headers for the Excel file
        $headers = ['ID', 'Title', 'Amount', 'Type', 'Category', 'Date', 'Created At'];
        $sheet->fromArray($headers, null, 'A1');

        // Populate the rows with the JSON data
        $rowIndex = 2; // Start from row 2 (row 1 is for headers)
        foreach ($data as $item) {
            $sheet->setCellValue('A' . $rowIndex, $item['id']);
            $sheet->setCellValue('B' . $rowIndex, $item['title']);
            $sheet->setCellValue('C' . $rowIndex, $item['amount']);
            $sheet->setCellValue('D' . $rowIndex, $item['type']);
            $sheet->setCellValue('E' . $rowIndex, $item['category']);
            $sheet->setCellValue('F' . $rowIndex, $item['date']);
            $sheet->setCellValue('G' . $rowIndex, $item['created_at']);
            $rowIndex++;
        }

        // Set the filename for the Excel file
        $filename = 'transactions.xlsx';

        // Create a writer to save the Excel file
        $writer = new Xlsx($spreadsheet);

        // Save the file to the server
        $writer->save($filename);

        // Output the file to the browser for download
        header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        header('Content-Disposition: attachment;filename="' . $filename . '"');
        header('Cache-Control: max-age=0');

        // Output the file contents
        $writer->save('php://output');
        exit;
    }

    public function aiSummary()
    {
        $instruction = $this->request->getVar('instruction');
        $data = $this->request->getVar('data');
        // $response = $this->client->aiSummary($instruction);

        // using openai api
        // ref: https://github.com/openai-php/client
        $yourApiKey = $_ENV['OPENAI_API_KEY'];
        // $client = \OpenAI::client($yourApiKey);
        // $response = $client->chat()->create([
        //     'model' => 'gpt-3.5-turbo',
        //     'messages' => [
        //         ['role' => 'user', 'content' => $data . "\n" . $instruction]
        //     ]
        // ]);

        $options = [
            CURLOPT_URL => "https://api.openai.com/v1/responses",
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_SSL_VERIFYPEER => false,
            CURLOPT_SSL_VERIFYHOST => false,
            CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
            CURLOPT_CUSTOMREQUEST => "POST",
            CURLOPT_POSTFIELDS => json_encode(array(
                "model" => "gpt-3.5-turbo",
                "input" => $data . "\n" . $instruction
            )),
            CURLOPT_HTTPHEADER => [
                "Authorization: Bearer " . $yourApiKey,
                "Content-Type: application/json"
            ],
        ];

        $curl = curl_init();
        curl_setopt_array($curl, $options);
        $response = curl_exec($curl);
        curl_close($curl);

        $http_code = curl_getinfo($curl, CURLINFO_HTTP_CODE);
        curl_close($curl);

        if ($http_code === 200) {
            $response = json_decode($response, true);
            echo $response['choices'][0]['message']['content'];
        } else {
            // return redirect()->to('/')->with('error', 'Failed to fetch data. Status code: ' . $http_code);
            echo $response;
        }
    }
}