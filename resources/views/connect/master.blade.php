<!-- /*
| Fecha 23 de Mayo 2025
| Definiendo plantilla maestra para las vistas de la carpeta connect
*/ -->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!--<link rel="stylesheet" href="{{ url('/static/css/connect.css?v='.time()) }}">-->
    <title>@yield('title')</title>
    <!-- Vite se encargará de esto 💪-->
    @vite(['resources/scss/app.scss',
    'resources/js/app.js'
    ])
</head>
<body>
    <!-- Aquí es donde se inyectará el contenido de las vistas que extienden esta plantilla -->
    @yield('content')
    
    <!-- Si quieres un mensaje general en el master, ponlo fuera de un yield o show -->
    <!-- <h1>¡Hola desde el Master!</h1> -->
    
</body>
</html>