<?= $this->extend('layouts/main') ?>

<?= $this->section('content') ?>
<?php
    $months = [
        '01' => 'Januari', '02' => 'Februari', '03' => 'Maret', '04' => 'April',
        '05' => 'Mei', '06' => 'Juni', '07' => 'Juli', '08' => 'Agustus',
        '09' => 'September', '10' => 'Oktober', '11' => 'November', '12' => 'Desember'
    ];
    $currentYear = date('Y');
    $currentMonth = date('m');

    // echo esc($month);
    $startDate = ($getMonth) ? date('Y-m-24', strtotime('-1 month', strtotime($getMonth))) : date('Y-m-24', strtotime('last month'));
    $endDate = ($getMonth) ? date('Y-m-24', strtotime($getMonth)) : date('Y-m-24');
    if($getMonth) $currentMonth = date('m', strtotime($getMonth));
?>
    <!-- Your content here -->
				<div class="content">
                    <?php
                    // echo "startDate: ". $startDate. "<br>";
                    // echo "endDate: ". $endDate. "<br>";
                    // echo json_encode($listTransactions);
                    ?>
					<div class="container-fluid">
						<h4 class="page-title mb-0">Dashboard</h4>
                        <p>Periode: <?= $startDate ?> - <?= $endDate ?></p>
						<div class="row">
                            <div class="col-md-6">
                                <div class="card bg-success">
                                    <div class="card-body">
                                        <h4 class="card-title">Total Pemasukan</h4>
                                        <h5 class="card-text">Rp. <?= number_format($totalPemasukan, 0, ',', '.') ?></h5>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="card bg-danger">
                                    <div class="card-body">
                                        <h4 class="card-title">Total Pengeluaran</h4>
                                        <h5 class="card-text">Rp. <?= number_format($totalPengeluaran, 0, ',', '.') ?></h5>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
						<div class="row">
                            <div class="col-md-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4 class="card-title">Transaction Chart</h4>
                                    </div>
                                    <div class="card-body">
                                        <canvas id="transactionChart"></canvas>
                                    </div>
                                </div>
                            </div>

                            <div class="col-md-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4 class="card-title float-left">List Transactions</h4>
                                        <div class="float-right">
                                            <form action="<?= base_url('laporan') ?>" method="get">
                                                <select name="month" class="form-control" onchange="this.form.submit()">
                                                    <?php foreach ($months as $num => $name): ?>
                                                        <option value="<?= $currentYear . '-' . $num ?>" <?= ($num == $currentMonth) ? 'selected' : '' ?> <?= ($num > $currentMonth) ? 'disabled' : '' ?>>
                                                            <?= $name . ', ' . $currentYear ?>
                                                        </option>
                                                    <?php endforeach; ?>
                                                </select>
                                            </form>
                                        </div>
                                    </div>
                                    <div class="card-body">
                                        <div class="table-responsive">
                                            <table class="table table-striped table-bordered" style="width:100%" id="listTransactions">
                                                <thead>
                                                    <tr>
                                                        <th>ID</th>
                                                        <th>Date</th>
                                                        <th>Title</th>
                                                        <th>Type</th>
                                                        <th>Amount</th>
                                                        <th>Aksi</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <?php foreach ($listTransactions as $transaction) : ?>
                                                        <tr>
                                                            <td><?= $transaction['id'] ?></td>
                                                            <td><?= $transaction['date'] ?></td>
                                                            <td><?= $transaction['title'] ?></td>
                                                            <td><?= $transaction['type'] . ' -' . $transaction['category'] ?></td>
                                                            <td>Rp. <span class="float-right"><?= number_format($transaction['amount'], 0, ',', '.') ?></span></td>
                                                            <td>
                                                                <a href="<?= base_url('edit/' . $transaction['id']) ?>" class="btn btn-primary"><i class="la la-edit"></i></a>
                                                            </td>
                                                        </tr>
                                                    <?php endforeach; ?>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            </div>
						</div>
					</div>
				</div>

<?php

// echo json_encode($listTransactions);
$dataChart = [];
foreach ($listTransactions as $transaction) {
    $dataChart[] = [
        'title' => strtoupper($transaction['title']),
        'amount' => $transaction['amount'],
        'type' => $transaction['type']
    ];
}
// echo json_encode($dataChart);
// Gabungkan jumlah amount jika title sama
// $mergedData = array_reduce($dataChart, function ($acc, $curr) {
//     $existing = array_filter($acc, function ($item) use ($curr) {
//         return $item['title'] === $curr['title'];
//     });
//     if ($existing) {
//         $existing[0]['amount'] += $curr['amount'];
//     } else {
//         $acc[] = $curr;
//     }
//     return $acc;
// }, []);
// echo json_encode($mergedData);
?>
<?= $this->endSection() ?>
<!-- register js -->
<?= $this->section('scripts') ?>
<script src="https://cdn.datatables.net/2.2.2/js/dataTables.js"></script>
<script src="https://cdn.datatables.net/2.2.2/js/dataTables.bootstrap4.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
    $(document).ready(function() {
        // $('#listTransactions').DataTable();
        let table = new DataTable('#listTransactions', {
            order: [[1, 'desc']]
        });

        const ctx = document.getElementById('transactionChart').getContext('2d');

        const data = <?=json_encode($dataChart) ?>;
        // Gabungkan jumlah amount jika title sama
        const mergedData = data.reduce((acc, curr) => {
            const existing = acc.find(item => item.title === curr.title);
            if (existing) {
                existing.amount += curr.amount;
            } else {
                acc.push({ ...curr });
            }
            return acc;
        }, []);

        // Sort data dari terbesar ke terkecil
        mergedData.sort((a, b) => b.amount - a.amount);

        const labels = mergedData.map(item => item.title);
        const pemasukanData = mergedData.map(item => item.type === "Pemasukan" ? item.amount : 0);
        const pengeluaranData = mergedData.map(item => item.type === "Pengeluaran" ? item.amount : 0);

        const transactionChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: 'Pemasukan',
                        data: pemasukanData,
                        backgroundColor: 'rgba(54, 162, 235, 0.5)',
                        borderColor: 'rgba(54, 162, 235, 1)',
                        borderWidth: 1
                    },
                    {
                        label: 'Pengeluaran',
                        data: pengeluaranData,
                        backgroundColor: 'rgba(255, 99, 132, 0.5)',
                        borderColor: 'rgba(255, 99, 132, 1)',
                        borderWidth: 1
                    }
                ]
            },
            options: {
                responsive: true,
                indexAxis: 'y', // Mengubah chart menjadi vertikal
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
    });
</script>
<?= $this->endSection() ?>