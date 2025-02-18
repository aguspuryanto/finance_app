<?php

use CodeIgniter\Router\RouteCollection;

/**
 * @var RouteCollection $routes
 */

// group
$routes->group('', [], function ($routes) {
    $routes->get('/', 'Home::index');
    $routes->get('/create', 'Home::create');
    $routes->post('/store', 'Home::store');
    $routes->get('/edit/(:num)', 'Home::edit/$1');
    $routes->post('/update', 'Home::update');
});

// kategori
$routes->group('kategori', [], function ($routes) {
    $routes->get('/', 'Category::index');
    $routes->get('/create', 'Category::create');
    $routes->post('/store', 'Category::store');
});

// asset
$routes->group('asset', [], function ($routes) {
    $routes->get('/', 'Asset::index');
    $routes->get('/create', 'Asset::create');
    $routes->post('/store', 'Asset::store');
});

// tabungan
$routes->group('tabungan', [], function ($routes) {
    $routes->get('/', 'Tabungan::index');
    $routes->get('/create', 'Tabungan::create');
    $routes->post('/store', 'Tabungan::store');
});

// laporan
$routes->group('laporan', [], function ($routes) {
    $routes->get('/', 'Laporan::index');
});
