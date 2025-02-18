<?= $this->extend('layouts/main') ?>

<?= $this->section('content') ?>
    <!-- Your content here -->
    <div class="content">
        <div class="container-fluid">
            <h4 class="page-title">Edit</h4>
            <div class="row">
                <div class="col-md-12">
                    <div class="card">
                        <div class="card-body">
                            <!-- <h4 class="card-title">Edit</h4> -->
                            <?php
                            // echo json_encode($data);
                            $date = date('Y-m-d', strtotime($data[0]['date']));
                            $time = date('H:i', strtotime($data[0]['date']));
                            ?>
                            <form action="<?= base_url('update') ?>" method="post">
                                <input type="hidden" name="id" value="<?= $data[0]['id'] ?>">
                                <div class="form-group">
                                    <label for="title">Title</label>
                                    <input type="text" name="title" value="<?= $data[0]['title'] ?>" class="form-control">
                                </div>
                                <div class="form-group">
                                    <label for="amount">Amount</label>
                                    <input type="text" name="amount" value="<?= $data[0]['amount'] ?>" class="form-control">
                                </div>
                                <div class="form-group">
                                    <label for="description">Type</label>
                                    <select name="type" class="form-control">
                                        <option value="Pemasukan" <?= $data[0]['type'] == 'Pemasukan' ? 'selected' : '' ?>>Pemasukan</option>
                                        <option value="Pengeluaran" <?= $data[0]['type'] == 'Pengeluaran' ? 'selected' : '' ?>>Pengeluaran</option>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label for="category">Category</label>
                                    <input type="text" name="category" value="<?= $data[0]['category'] ?>" class="form-control">
                                </div>
                                <div class="d-flex">
                                    <div class="form-group col-md-6">
                                        <label for="date">Date</label>
                                        <input type="text" name="date" id="datepicker" value="<?= $date ?>" class="form-control">
                                    </div>
                                    <div class="form-group col-md-6">
                                        <label for="time">Time</label>
                                        <input type="text" name="time" id="timepicker" value="<?= $time ?>" class="form-control">
                                    </div>
                                </div>
                                <div class="form-group">
                                    <button type="submit" class="btn btn-primary">Update</button>
                                    <a href="<?= base_url('/') ?>" class="btn btn-secondary">Cancel</a>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
<?= $this->endSection() ?>

<?= $this->section('styles') ?>
<link href="https://unpkg.com/gijgo@1.9.14/css/gijgo.min.css" rel="stylesheet" type="text/css" />

<?= $this->endSection() ?>

<?= $this->section('scripts') ?>
<script src="https://unpkg.com/gijgo@1.9.14/js/gijgo.min.js" type="text/javascript"></script>
<script>
    $('#datepicker').datepicker({
        uiLibrary: 'bootstrap4',
        format: 'yyyy-mm-dd'
    });
</script>
<?= $this->endSection() ?>