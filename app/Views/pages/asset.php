<?= $this->extend('layouts/main') ?>

<?= $this->section('content') ?>
    <!-- Your content here -->
				<div class="content">
					<div class="container-fluid">
						<h4 class="page-title"><?= $title ?></h4>
                        
						<div class="row">
                            <div class="col-md-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4 class="card-title d-flex justify-content-between align-items-center">List Asset
                                            <a href="<?= base_url('asset/create') ?>" class="btn btn-primary">Tambah Asset</a>
                                        </h4>
                                    </div>
                                    <div class="card-body">
                                        <div class="table-responsive">
                                            <!-- <?= json_encode($listAssets) ?> -->
                                            <table class="table table-striped table-bordered" style="width:100%" id="listTransactions">
                                                <thead>
                                                    <tr>
                                                        <th>No</th>
                                                        <th>Nama</th>
                                                        <th>Harga Beli</th>
                                                        <th>Harga Sekarang</th>
                                                        <th>Tgl Beli</th>
                                                        <th>Status</th>
                                                        <th>Keterangan</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <?php foreach ($listAssets as $category) : ?>
                                                        <tr>
                                                            <td><?= $category['id'] ?></td>
                                                            <td><?= $category['name'] ?></td>
                                                            <td>Rp. <?= number_format($category['purchase_value'], 0, ',', '.') ?></td>
                                                            <td>Rp. <?= number_format($category['current_value'], 0, ',', '.') ?></td>
                                                            <td><?= $category['purchase_date'] ?></td>
                                                            <td><?= $category['status'] ?></td>
                                                            <td><?= $category['notes'] ?></td>
                                                            <td>
                                                                <a href="<?= base_url('asset/edit/' . $category['id']) ?>" class="btn btn-primary">Edit</a>
                                                                <a href="<?= base_url('asset/delete/' . $category['id']) ?>" class="btn btn-danger">Hapus</a>
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