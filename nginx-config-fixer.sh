#!/bin/bash

# Скрипт для исправления nginx конфигурации с правильным размещением директив
echo "🔧 Исправляем nginx конфигурацию..."

# Создаем резервную копию
sudo cp /etc/nginx/sites-enabled/neyro /etc/nginx/sites-enabled/neyro.backup.$(date +%Y%m%d_%H%M%S)

# Создаем правильную конфигурацию
sudo tee /etc/nginx/sites-enabled/neyro > /dev/null << 'EOF'
server {
    listen 80;
    server_name 194.87.226.56;
    root /var/www/timeweb-deploy/public;
    index index.html;

    # Логирование
    access_log /var/log/nginx/timeweb-deploy_access.log;
    error_log /var/log/nginx/timeweb-deploy_error.log;

    # Статические файлы - изображения
    location /images/ {
        alias /var/www/timeweb-deploy/images/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Статические файлы - музыка
    location /music/ {
        alias /var/www/timeweb-deploy/music/;
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Content-Type "audio/mpeg";
    }

    # Статические ресурсы (CSS, JS, изображения)
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|mp3|wav)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files $uri =404;
    }

    # API эндпоинты - обработка preflight OPTIONS запросов
    location ~ ^/(generate_dalle|session|enhance_prompt|debug_openai)$ {
        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' '*' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE' always;
            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain; charset=utf-8';
            add_header 'Content-Length' 0;
            return 204;
        }

        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Content-Type $http_content_type;

        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE' always;
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
    }

    # WebSocket поддержка
    location /ws {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # SPA fallback для React Router
    location / {
        try_files $uri $uri/ /index.html;
        add_header Cache-Control "no-cache, no-store, must-revalidate";
    }
}
EOF

echo "✅ Конфигурация исправлена"
echo "🔍 Проверяем синтаксис..."

# Проверяем синтаксис
if sudo nginx -t; then
    echo "✅ Синтаксис корректен"
    echo "🔄 Перезапускаем nginx..."
    sudo systemctl reload nginx
    if [ $? -eq 0 ]; then
        echo "✅ Nginx успешно перезапущен"
    else
        echo "❌ Ошибка при перезапуске nginx"
    fi
else
    echo "❌ Синтаксис все еще неправильный"
    echo "🔧 Восстанавливаем резервную копию"
    sudo cp /etc/nginx/sites-enabled/neyro.backup.* /etc/nginx/sites-enabled/neyro
fi

echo ""
echo "🎯 Исправление завершено!"
echo "🌐 Проверьте сайт: http://194.87.226.56"