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
                                        <h4 class="card-title d-flex justify-content-between align-items-center">List Tabungan
                                            <a href="<?= base_url('tabungan/create') ?>" class="btn btn-primary">Tambah Tabungan</a>
                                        </h4>
                                    </div>
                                    <div class="card-body">
                                        <div class="table-responsive">
                                            <!-- <?= json_encode($listTabungan); ?> -->
                                            <table class="table table-striped table-bordered" style="width:100%" id="listTransactions">
                                                <thead>
                                                    <tr>
                                                        <th>No</th>
                                                        <th>Nama</th>
                                                        <th>Tipe</th>
                                                        <th>Aksi</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <?php if (!empty($listTabungan)) : ?>
                                                        <?php foreach ($listTabungan as $tabungan) : ?>
                                                            <tr>
                                                                <td><?= $tabungan['id'] ?></td>
                                                            <td><?= $tabungan['name'] ?></td>
                                                            <td><?= $tabungan['type'] ?></td>
                                                            <td>
                                                                <a href="<?= base_url('kategori/edit/' . $category['id']) ?>" class="btn btn-primary">Edit</a>
                                                                <a href="<?= base_url('kategori/delete/' . $category['id']) ?>" class="btn btn-danger">Hapus</a>
                                                            </td>
                                                        </tr>
                                                    <?php endforeach; ?>
                                                    <?php else : ?>
                                                        <tr>
                                                            <td colspan="4" class="text-center">Tidak ada data</td>
                                                        </tr>
                                                    <?php endif; ?>
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