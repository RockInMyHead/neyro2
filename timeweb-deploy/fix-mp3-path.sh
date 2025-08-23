#!/bin/bash

# Исправление путей к MP3 файлам в nginx
echo "🔧 Исправляю пути к MP3 файлам..."

# Проверяю где находятся MP3 файлы
echo "🔍 Проверяю расположение MP3 файлов..."
find /var/www/timeweb-deploy -name "*.mp3" -type f

# Исправляю nginx конфигурацию для правильных путей к MP3
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

    # Обработка прямых запросов к 2.mp3 (для совместимости с frontend)
    location = /2.mp3 {
        alias /var/www/timeweb-deploy/music/2.mp3;
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Content-Type "audio/mpeg";
    }

    location = /1.mp3 {
        alias /var/www/timeweb-deploy/music/1.mp3;
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Content-Type "audio/mpeg";
    }

    location = /3.mp3 {
        alias /var/www/timeweb-deploy/music/3.mp3;
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Content-Type "audio/mpeg";
    }

    location = /4.mp3 {
        alias /var/www/timeweb-deploy/music/4.mp3;
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

    # API эндпоинты - generate_dalle (поддержка GET для совместимости с frontend)
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

        if ($request_method = 'GET') {
            # Для GET запросов добавляем дефолтный prompt
            proxy_pass http://127.0.0.1:8000/generate_dalle;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Content-Type "application/json";

            add_header 'Access-Control-Allow-Origin' '*' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE' always;
            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
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

echo "✅ Конфигурация обновлена"

# Проверяю синтаксис
echo "✅ Проверяю синтаксис..."
if sudo nginx -t; then
    echo "✅ Синтаксис корректен"
    sudo systemctl reload nginx
    echo "✅ Nginx перезапущен"
else
    echo "❌ Ошибка в синтаксисе"
    exit 1
fi

echo "✅ Исправление путей к MP3 завершено!"
echo "🌐 Проверьте ваш сайт: http://194.87.226.56"