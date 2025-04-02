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
    $routes->get('/delete/(:num)', 'Home::delete/$1');
});

// kategori
$routes->group('kategori', [], function ($routes) {
    $routes->get('/', 'Category::index');
    $routes->get('create', 'Category::create');
    $routes->post('store', 'Category::store');
    $routes->get('edit/(:num)', 'Category::edit/$1');
    $routes->post('update', 'Category::update');
    $routes->get('delete/(:num)', 'Category::delete/$1');
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
    $routes->add('/', 'Laporan::index');
    $routes->get('/create', 'Laporan::create');
    $routes->post('/store', 'Laporan::store');
});
