<?php

use CodeIgniter\Router\RouteCollection;

/**
 * @var RouteCollection $routes
 */
$routes->get('/', 'Home::index');
$routes->get('/edit/(:num)', 'Home::edit/$1');
$routes->post('/update', 'Home::update');
