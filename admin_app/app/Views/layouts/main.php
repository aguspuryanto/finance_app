<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
	<title><?= $this->renderSection('title') ?? 'Ready Bootstrap Dashboard' ?></title>
	<meta content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0, shrink-to-fit=no' name='viewport' />
	<link rel="stylesheet" href="<?= base_url('assets/css/bootstrap.min.css') ?>">
	<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Nunito:200,200i,300,300i,400,400i,600,600i,700,700i,800,800i,900,900i">
	<link rel="stylesheet" href="<?= base_url('assets/css/ready.css') ?>">
	<link rel="stylesheet" href="<?= base_url('assets/css/demo.css') ?>">
	<?= $this->renderSection('styles') ?>
</head>
<body>
	<div class="wrapper">
		<div class="main-header">
			<div class="logo-header">
				<a href="<?= base_url('home') ?>" class="logo">
					Ready Dashboard
				</a>
				<button class="navbar-toggler sidenav-toggler ml-auto" type="button" data-toggle="collapse" data-target="collapse" aria-controls="sidebar" aria-expanded="false" aria-label="Toggle navigation">
					<span class="navbar-toggler-icon"></span>
				</button>
				<button class="topbar-toggler more"><i class="la la-ellipsis-v"></i></button>
			</div>

			<!-- Navbar -->
			<?= $this->include('layouts/navbar') ?>

			<!-- Sidebar -->
			<?= $this->include('layouts/sidebar') ?>

			<div class="main-panel">
				<?= $this->include('components/alerts') ?>
				<?= $this->renderSection('content') ?>

				<!-- Footer -->
				<?= $this->include('layouts/footer') ?>
			</div>
		</div>
	</div>

	<!-- Modal -->
	<?= $this->include('components/modals') ?>

	<script src="<?= base_url('assets/js/core/jquery.3.2.1.min.js') ?>"></script>
	<script src="<?= base_url('assets/js/plugin/jquery-ui-1.12.1.custom/jquery-ui.min.js') ?>"></script>
	<script src="<?= base_url('assets/js/core/popper.min.js') ?>"></script>
	<script src="<?= base_url('assets/js/core/bootstrap.min.js') ?>"></script>
	<script src="<?= base_url('assets/js/plugin/chartist/chartist.min.js') ?>"></script>
	<script src="<?= base_url('assets/js/plugin/chartist/plugin/chartist-plugin-tooltip.min.js') ?>"></script>
	<script src="<?= base_url('assets/js/plugin/bootstrap-notify/bootstrap-notify.min.js') ?>"></script>
	<script src="<?= base_url('assets/js/plugin/bootstrap-toggle/bootstrap-toggle.min.js') ?>"></script>
	<script src="<?= base_url('assets/js/plugin/jquery-mapael/jquery.mapael.min.js') ?>"></script>
	<script src="<?= base_url('assets/js/plugin/jquery-mapael/maps/world_countries.min.js') ?>"></script>
	<script src="<?= base_url('assets/js/plugin/chart-circle/circles.min.js') ?>"></script>
	<script src="<?= base_url('assets/js/plugin/jquery-scrollbar/jquery.scrollbar.min.js') ?>"></script>
	<script src="<?= base_url('assets/js/ready.min.js') ?>"></script>
	<!-- <script src="<?= base_url('assets/js/demo.js') ?>"></script> -->
	<?= $this->renderSection('scripts') ?>
</body>
</html>