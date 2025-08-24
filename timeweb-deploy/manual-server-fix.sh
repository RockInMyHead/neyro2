#!/bin/bash

# Ручное исправление проблем на сервере TimeWeb
# Создайте этот файл на сервере и запустите: sudo bash manual-server-fix.sh

echo "🔧 Ручное исправление проблем TimeWeb..."
echo "📍 Текущая директория: $(pwd)"

# Проверяем, что мы в правильной папке
if [ ! -f "app.py" ]; then
    echo "❌ Файл app.py не найден!"
    echo "Перейдите в папку /var/www/timeweb-deploy"
    echo "Команда: cd /var/www/timeweb-deploy"
    exit 1
fi

echo "✅ Находимся в правильной папке"

# Шаг 1: Проверяем backend
echo "📋 Шаг 1: Проверяем backend сервер"
if curl -s http://127.0.0.1:8000/docs > /dev/null; then
    echo "✅ Backend сервер работает"
else
    echo "❌ Backend сервер не отвечает, запускаем..."
    nohup python app.py > backend.log 2>&1 &
    sleep 3
    if curl -s http://127.0.0.1:8000/docs > /dev/null; then
        echo "✅ Backend сервер успешно запущен"
    else
        echo "❌ Не удалось запустить backend"
        echo "📄 Логи: $(tail -5 backend.log 2>/dev/null || echo 'Лог файл не найден')"
        exit 1
    fi
fi

# Шаг 2: Находим nginx конфигурацию
echo "📋 Шаг 2: Ищем nginx конфигурацию"
CONFIG_FILE=""
if [ -f "/etc/nginx/sites-available/default" ]; then
    CONFIG_FILE="/etc/nginx/sites-available/default"
elif [ -f "/etc/nginx/nginx.conf" ]; then
    CONFIG_FILE="/etc/nginx/nginx.conf"
else
    echo "❌ Nginx конфигурация не найдена"
    exit 1
fi

echo "✅ Найдена конфигурация: $CONFIG_FILE"

# Шаг 3: Создаем резервную копию
BACKUP_FILE="${CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
echo "📋 Шаг 3: Создаем резервную копию: $BACKUP_FILE"
sudo cp "$CONFIG_FILE" "$BACKUP_FILE"

# Шаг 4: Применяем исправленную конфигурацию
echo "📋 Шаг 4: Применяем новую конфигурацию"
if [ -f "nginx-simple.conf" ]; then
    sudo cp nginx-simple.conf "$CONFIG_FILE"
    echo "✅ Применена nginx-simple.conf"
elif [ -f "nginx-fixed.conf" ]; then
    sudo cp nginx-fixed.conf "$CONFIG_FILE"
    echo "✅ Применена nginx-fixed.conf"
else
    echo "❌ Файлы конфигурации не найдены"
    echo "Создаю простую конфигурацию..."

    # Создаем простую конфигурацию nginx
    sudo tee "$CONFIG_FILE" > /dev/null << 'EOF'
server {
    listen 80;
    server_name 194.87.226.56;
    root /var/www/timeweb-deploy/public;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /images/ {
        alias /var/www/timeweb-deploy/images/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    location /music/ {
        alias /var/www/timeweb-deploy/music/;
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Content-Type "audio/mpeg";
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|mp3|wav)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files $uri =404;
    }

    location ~ ^/(generate_dalle|session|enhance_prompt|ws|debug_openai)$ {
        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' '*' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE' always;
            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain; charset=utf-8';
            add_header 'Content-Length' 0;
            return 204;
        }

        if ($uri ~ ^/ws) {
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
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
}
EOF
    echo "✅ Создана простая конфигурация"
fi

# Шаг 5: Проверяем синтаксис
echo "📋 Шаг 5: Проверяем синтаксис nginx"
if sudo nginx -t; then
    echo "✅ Синтаксис корректен"
else
    echo "❌ Ошибка в синтаксисе, восстанавливаю резервную копию"
    sudo cp "$BACKUP_FILE" "$CONFIG_FILE"
    exit 1
fi

# Шаг 6: Перезапускаем nginx
echo "📋 Шаг 6: Перезапускаем nginx"
sudo systemctl reload nginx

if [ $? -eq 0 ]; then
    echo "✅ Nginx успешно перезапущен"
else
    echo "❌ Ошибка при перезапуске nginx, восстанавливаю резервную копию"
    sudo cp "$BACKUP_FILE" "$CONFIG_FILE"
    sudo systemctl reload nginx
    exit 1
fi

# Шаг 7: Финальная проверка
echo "📋 Шаг 7: Финальная проверка"
sleep 3

echo "🔍 Проверяю /music/2.mp3..."
if curl -I http://194.87.226.56/music/2.mp3 2>/dev/null | grep -q "200 OK"; then
    echo "✅ Музыка работает"
else
    echo "❌ Музыка не работает"
fi

echo "🔍 Проверяю /generate_dalle..."
RESPONSE=$(curl -I http://194.87.226.56/generate_dalle 2>/dev/null | head -1)
if echo "$RESPONSE" | grep -q "200 OK"; then
    echo "✅ API работает"
elif echo "$RESPONSE" | grep -q "405"; then
    echo "⚠️  API возвращает 405 (нормально для HEAD запроса)"
elif echo "$RESPONSE" | grep -q "502"; then
    echo "❌ API возвращает 502 - проблема с backend"
else
    echo "❌ API не отвечает: $RESPONSE"
fi

echo ""
echo "🎉 Исправления применены!"
echo "🌐 Проверьте сайт: http://194.87.226.56"
echo "📁 Резервная копия: $BACKUP_FILE"
echo ""
echo "📄 Полезные команды для диагностики:"
echo "tail -f backend.log"
echo "sudo tail -f /var/log/nginx/error.log"
echo "curl -I http://194.87.226.56/music/2.mp3"