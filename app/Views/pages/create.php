<?= $this->extend('layouts/main') ?>

<?= $this->section('content') ?>
    <!-- Your content here -->
    <div class="content">
        <div class="container-fluid">
            <h4 class="page-title"><?= $title ?></h4>
            <div class="row">
                <div class="col-md-12">
                    <div class="card">
                        <div class="card-body">
                            <!-- <h4 class="card-title">Edit</h4> -->
                            <?php
                            // echo json_encode($listCategories);
                            ?>
                            <form action="<?= base_url('store') ?>" method="post">
                                <input type="hidden" name="id" value="">
                                <div class="form-group">
                                    <label for="title">Title</label>
                                    <input type="text" name="title" value="" class="form-control">
                                </div>
                                <div class="form-group">
                                    <label for="amount">Amount</label>
                                    <input type="text" name="amount" value="" class="form-control">
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="description">Type</label>
                                            <select name="type" class="form-control">
                                                <option value="Pemasukan">Pemasukan</option>
                                                <option value="Pengeluaran">Pengeluaran</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="category">Category</label>
                                            <select name="category" class="form-control">
                                            <?php foreach ($listCategories as $category) : ?>
                                                <option value="<?= $category['name'] ?>"><?= $category['name'] ?></option>
                                            <?php endforeach; ?>
                                            </select>
                                        </div>
                                    </div>
                                </div>
                                <div class="d-flex">
                                    <div class="form-group col-md-6">
                                        <label for="date">Date</label>
                                        <input type="text" name="date" id="datepicker" value="" class="form-control" autocomplete="off">
                                    </div>
                                    <div class="form-group col-md-6">
                                        <label for="time">Time</label>
                                        <input type="text" name="time" id="timepicker" value="" class="form-control" autocomplete="off">
                                    </div>
                                </div>
                                <div class="form-group">
                                    <button type="submit" class="btn btn-primary">Save</button>
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