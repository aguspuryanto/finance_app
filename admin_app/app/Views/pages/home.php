<?= $this->extend('layouts/main') ?>

<?= $this->section('content') ?>
    <!-- Your content here -->
				<div class="content">
					<div class="container-fluid">
						<h4 class="page-title">Dashboard</h4>
						<div class="row">
                            <div class="col-md-4">
                                <div class="card bg-primary">
                                    <div class="card-body text-white">
                                        <h4 class="card-title text-white">Saldo</h4>
                                        <h5 class="card-text">Rp. <?= number_format($totalPemasukan - $totalPengeluaran, 0, ',', '.') ?></h5>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="card bg-success">
                                    <div class="card-body">
                                        <h4 class="card-title">Total Pemasukan</h4>
                                        <h5 class="card-text">Rp. <?= number_format($totalPemasukan, 0, ',', '.') ?></h5>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4">
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
                                        <h4 class="card-title d-flex justify-content-between align-items-center">List Transactions
                                            <a href="<?= base_url('create') ?>" class="btn btn-primary">Tambah Transaksi</a>
                                        </h4>
                                    </div>
                                    <div class="card-body">
                                        <div class="table-responsive">
                                            <!-- <?= json_encode($listTransactions) ?> -->
                                            <table class="table table-striped table-bordered" style="width:100%" id="listTransactions">
                                                <thead>
                                                    <tr>
                                                        <th>ID</th>
                                                        <th>Title</th>
                                                        <th>Amount</th>
                                                        <th>Type</th>
                                                        <th>Date</th>
                                                        <th>Aksi</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <?php foreach ($listTransactions as $transaction) : ?>
                                                        <tr>
                                                            <td><?= $transaction['id'] ?></td>
                                                            <td><?= $transaction['title'] ?></td>
                                                            <td>Rp. <?= number_format($transaction['amount'], 0, ',', '.') ?></td>
                                                            <td><?= $transaction['type'] . ' -' . $transaction['category'] ?></td>
                                                            <td><?= $transaction['date'] ?></td>
                                                            <td>
                                                                <a href="<?= base_url('edit/' . $transaction['id']) ?>" class="btn btn-primary"><i class="la la-edit"></i></a>
                                                                <a href="<?= base_url('delete/' . $transaction['id']) ?>" class="btn btn-danger" onclick="return confirm('Apakah anda yakin ingin menghapus data ini?')"><i class="la la-trash"></i></a>
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
<?= $this->endSection() ?>

<!-- register js -->
<?= $this->section('scripts') ?>
<script src="https://cdn.datatables.net/2.2.2/js/dataTables.js"></script>
<script src="https://cdn.datatables.net/2.2.2/js/dataTables.bootstrap4.js"></script>
<script>
    $(document).ready(function() {
        // $('#listTransactions').DataTable();
        let table = new DataTable('#listTransactions', {
            order: [[4, 'desc']]
        });
    });
</script>
<?= $this->endSection() ?>