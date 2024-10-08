#!/bin/sh

initialStuff() {
    echo "Running initial setup... $(pwd)"
    php artisan storage:link
    php artisan optimize:clear
    php artisan event:cache
    php artisan config:cache
    php artisan route:cache
    php artisan livewire:publish --assets
}

# Run initial setup
initialStuff

# Start PHP-FPM
php-fpm &

# Start Nginx in the foreground
nginx -g "daemon off;"

