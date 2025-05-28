import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';

export default defineConfig({
    plugins: [
        laravel({
            input: ['resources/scss/app.scss', 'resources/js/app.js'], //archivo de sass creado 27 may25
            refresh: true,
        }),
    ],
        // Si estás en Docker y tienes problemas de conexión para HMR
    // server: {
    //     host: '0.0.0.0',
    //     port: 5173,
    //     hmr: {
    //         host: 'localhost', // O la IP de tu servicio de Laravel/Apache en Docker
    //     },
    //     watch: {
    //         usePolling: true
    //     }
    // }
});
