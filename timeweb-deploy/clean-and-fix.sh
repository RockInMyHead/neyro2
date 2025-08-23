#!/bin/bash

# Полная очистка и исправление nginx
echo "🧹 Полная очистка и исправление nginx..."
echo "📍 Текущая директория: $(pwd)"

# Шаг 1: Удаляем все резервные копии с ошибками
echo "📋 Шаг 1: Удаляем проблемные резервные копии"
sudo rm -f /etc/nginx/sites-enabled/neyro.backup.*
echo "✅ Резервные копии удалены"

# Шаг 2: Создаем правильную конфигурацию
echo "📋 Шаг 2: Создаем правильную конфигурацию"
sudo tee /etc/nginx/sites-enabled/neyro > /dev/null << 'EOF'
server {
    listen 80;
    server_name 194.87.226.56;
    index index.html;
    root /var/www/timeweb-deploy/public;

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

    # Статические ресурсы (CSS, JS, изображения, аудио)
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|mp3|wav|mp4|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files $uri =404;
    }

    # WebSocket - ws
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

    # API эндпоинты - generate_dalle
    location /generate_dalle {
        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' '*' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE' always;
            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain; charset=utf-8';
            add_header 'Content-Length' 0;
            return 204;
        }

        proxy_pass http://127.0.0.1:8000/generate_dalle;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Content-Type $http_content_type;

        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE' always;
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
    }

    # API эндпоинты - session
    location /session {
        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' '*' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE' always;
            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain; charset=utf-8';
            add_header 'Content-Length' 0;
            return 204;
        }

        proxy_pass http://127.0.0.1:8000/session;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Content-Type $http_content_type;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE' always;
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
    }

    # API эндпоинты - enhance_prompt
    location /enhance_prompt {
        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' '*' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE' always;
            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain; charset=utf-8';
            add_header 'Content-Length' 0;
            return 204;
        }

        proxy_pass http://127.0.0.1:8000/enhance_prompt;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Content-Type $http_content_type;

        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE' always;
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
    }

    # API эндпоинты - debug_openai
    location /debug_openai {
        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' '*' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE' always;
            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain; charset=utf-8';
            add_header 'Content-Length' 0;
            return 204;
        }

        proxy_pass http://127.0.0.1:8000/debug_openai;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Content-Type $http_content_type;

        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE' always;
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
    }

    # SPA fallback для React Router
    location / {
        try_files $uri $uri/ /index.html;
        add_header Cache-Control "no-cache, no-store, must-revalidate";
    }
}
EOF

echo "✅ Конфигурация создана"

# Шаг 3: Проверяем синтаксис
echo "📋 Шаг 3: Проверяем синтаксис"
if sudo nginx -t; then
    echo "✅ Синтаксис корректен"
    sudo systemctl reload nginx
    echo "✅ Nginx перезапущен"
else
    echo "❌ Ошибка в синтаксисе"
    exit 1
fi

# Шаг 4: Финальная проверка
echo "📋 Шаг 4: Финальная проверка"
echo "🔍 Проверяю MP3 файл..."
curl -I http://194.87.226.56/assets/2.mp3 2>/dev/null | head -1 || echo "❌ Ошибка подключения"

echo "🔍 Проверяю JavaScript файл..."
curl -I http://194.87.226.56/assets/index-Dp3_vkor.js 2>/dev/null | head -1 || echo "❌ Ошибка подключения"

echo "🔍 Проверяю API..."
curl -I http://194.87.226.56/generate_dalle 2>/dev/null | head -1 || echo "❌ Ошибка подключения"

echo "✅ Скрипт завершен!"
echo "🌐 Проверьте ваш сайт: http://194.87.226.56"