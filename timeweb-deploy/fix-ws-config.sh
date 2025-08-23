#!/bin/bash

# Исправление WebSocket конфигурации в nginx
echo "🔧 Исправляю WebSocket конфигурацию..."

# Создадим исправленную конфигурацию
cat > /etc/nginx/sites-enabled/neyro << 'EOF'
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

echo "✅ Конфигурация исправлена"

# Проверить синтаксис
echo "✅ Проверяю синтаксис..."
if sudo nginx -t; then
    echo "✅ Синтаксис корректен"
    sudo systemctl reload nginx
    echo "✅ Nginx перезапущен"
else
    echo "❌ Ошибка в синтаксисе"
    echo "🔧 Показываю содержимое конфигурации для диагностики..."
    cat /etc/nginx/sites-enabled/neyro
    exit 1
fi

# Проверить backend
echo "🔍 Проверяю backend сервер..."
if curl -s http://127.0.0.1:8000/docs > /dev/null; then
    echo "✅ Backend сервер работает"
else
    echo "❌ Backend сервер не отвечает"
    echo "🔧 Запускаю backend..."
    nohup python app.py > backend.log 2>&1 &
    sleep 5
    if curl -s http://127.0.0.1:8000/docs > /dev/null; then
        echo "✅ Backend сервер запущен"
    else
        echo "❌ Не удалось запустить backend"
        echo "📄 Логи: $(cat backend.log 2>/dev/null || echo 'Лог файл не найден')"
    fi
fi

# Финальная проверка
echo "🔍 Финальная проверка..."
curl -I http://194.87.226.56/generate_dalle

echo "✅ Исправление WebSocket конфигурации завершено!"
echo "🌐 Проверьте ваш сайт: http://194.87.226.56"