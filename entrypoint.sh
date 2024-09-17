#!/bin/sh

initialStuff() {
    echo "Running initial setup... $(pwd)"
    php artisan storage:link
    php artisan optimize:clear
    php artisan event:cache
    php artisan config:cache
    php artisan route:cache
    php artisan livewire:publish --assets

    if [ "${RUN_MIGRATIONS}" = "true" ]; then
        echo "Running migrations..."
        php artisan migrate --isolated --force
    fi

    if [ "${RUN_SEEDERS}" = "true" ]; then
        echo "Seeding database..."
        php artisan db:seed --force
    fi
}

# Run initial setup
initialStuff

# Start PHP-FPM
php-fpm &

# Start Nginx in the foreground
nginx -g "daemon off;"

