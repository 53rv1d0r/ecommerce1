<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

/*
| Fecha 23 de Mayo 2025
| Controlador de login
| Se crea en esta ubicación cuando ejecutamos php artisan make:controller ConnectController en terminal
| El método getLogin lo creamos nosotros
*/

class ConnectController extends Controller
{
    public function getLogin()
    {
        return view('connect.login');
    }
}
