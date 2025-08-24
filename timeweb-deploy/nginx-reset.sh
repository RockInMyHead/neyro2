#!/bin/bash

echo "🔥 Полный сброс nginx..."

# Остановка nginx
systemctl stop nginx

# Очистка всех конфигураций
rm -f /etc/nginx/sites-enabled/*
rm -f /etc/nginx/sites-available/neyro*

# Создание минимальной рабочей конфигурации
cat > /etc/nginx/sites-available/neyro << 'EOF'
server {
    listen 80;
    server_name 194.87.226.56;
    index index.html;
    root /home/neyro/neyro2/timeweb-deploy/public;

    # Статические файлы - изображения
    location /images/ {
        alias /home/neyro/neyro2/timeweb-deploy/images/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Статические файлы - музыка (из корневой директории)
    location /music/ {
        alias /home/neyro/neyro2/;
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Content-Type "audio/mpeg";
    }

    # Прямой доступ к статическим файлам в корневой директории (для mp3 файлов)
    location ~* \.(mp3)$ {
        root /home/neyro/neyro2;
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Content-Type "audio/mpeg";
        try_files $uri =404;
    }

    # API эндпоинты
    location ~ ^/(generate_dalle|session|enhance_prompt|debug_openai) {
        proxy_pass http://localhost:8003;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # CORS headers
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE' always;
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
    }

    # Основные статические файлы
    location / {
        try_files $uri $uri/ /index.html;
        add_header Cache-Control "no-cache, no-store, must-revalidate";
    }
}
EOF

# Активация конфигурации
ln -sf /etc/nginx/sites-available/neyro /etc/nginx/sites-enabled/

# Проверка синтаксиса
echo "🔍 Проверка синтаксиса..."
nginx -t

if [ $? -eq 0 ]; then
    echo "✅ Синтаксис корректен"

    # Запуск nginx
    systemctl start nginx

    if [ $? -eq 0 ]; then
        echo "✅ Nginx успешно запущен"
        systemctl status nginx --no-pager -l
    else
        echo "❌ Ошибка при запуске nginx"
        journalctl -u nginx --no-pager -l | tail -10
    fi
else
    echo "❌ Ошибка синтаксиса"
    nginx -t
fi

echo "🎉 Сброс nginx завершен!"