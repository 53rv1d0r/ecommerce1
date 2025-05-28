<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ConnectController;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});

/*
| Fecha 23 de Mayo 2025
| Definiendo ruta para la autenticación
| Método get de la fachada Route, que maneja las peticiónes get a la URL /login
| Nombré al controlador ConnectController y se escribe la estructura
| Se crea con php artisan make:controller ConnectController en terminal
| Así Laravel llama al método nombrado getLogin cuando se acceda a la ruta /login
*/

// Route::get('/login', 'ConnectController@getlogin');
Route::get('/login', [ConnectController::class, 'getLogin']);