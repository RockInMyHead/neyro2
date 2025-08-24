#!/bin/bash

# Расширенное исправление nginx для TimeWeb
# Исправляет проблемы с синтаксисом и кастомными конфигурациями

echo "🔧 Расширенное исправление nginx для TimeWeb..."
echo "📍 Текущая директория: $(pwd)"

# Функция для поиска всех конфигурационных файлов nginx
find_nginx_configs() {
    echo "🔍 Ищем конфигурационные файлы nginx..."

    # Ищем в sites-enabled
    if [ -d "/etc/nginx/sites-enabled" ]; then
        for file in /etc/nginx/sites-enabled/*; do
            if [ -f "$file" ] && [ -L "$file" ]; then
                echo "🔗 Найден symlink: $file -> $(readlink $file)"
            elif [ -f "$file" ]; then
                echo "📄 Найден файл: $file"
            fi
        done
    fi

    # Ищем в sites-available
    if [ -d "/etc/nginx/sites-available" ]; then
        for file in /etc/nginx/sites-available/*; do
            if [ -f "$file" ]; then
                echo "📄 Найден файл: $file"
            fi
        done
    fi
}

# Функция для исправления конкретного конфигурационного файла
fix_config_file() {
    local config_file="$1"
    local backup_file="${config_file}.backup.$(date +%Y%m%d_%H%M%S)"

    echo "🔧 Исправляем: $config_file"

    # Создаем резервную копию
    sudo cp "$config_file" "$backup_file"
    echo "📦 Резервная копия: $backup_file"

    # Создаем исправленную конфигурацию
    sudo tee "$config_file" > /dev/null << 'EOF'
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

    echo "✅ Конфигурация применена"
}

# Функция для создания минимальной конфигурации
create_minimal_config() {
    local config_file="/etc/nginx/sites-available/default"
    local backup_file="${config_file}.backup.$(date +%Y%m%d_%H%M%S)"

    echo "🔧 Создаем минимальную конфигурацию..."

    # Создаем резервную копию
    sudo cp "$config_file" "$backup_file" 2>/dev/null || echo "⚠️  Не удалось создать резервную копию"

    # Создаем минимальную конфигурацию
    sudo tee "$config_file" > /dev/null << 'EOF'
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
    }

    location /music/ {
        alias /var/www/timeweb-deploy/music/;
        add_header Content-Type "audio/mpeg";
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|mp3|wav)$ {
        try_files $uri =404;
    }

    location ~ ^/(generate_dalle|session|enhance_prompt|debug_openai)$ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE' always;
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
    }

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
}
EOF

    echo "✅ Минимальная конфигурация создана"
}

# Основная логика
main() {
    echo "🔍 Анализируем текущую ситуацию..."

    # Шаг 1: Находим все конфигурационные файлы
    echo "📋 Шаг 1: Поиск конфигурационных файлов"
    find_nginx_configs

    # Шаг 2: Проверяем backend
    echo "📋 Шаг 2: Проверяем backend сервер"
    if curl -s http://127.0.0.1:8000/docs > /dev/null; then
        echo "✅ Backend сервер работает"
    else
        echo "❌ Backend сервер не отвечает"
        echo "🔧 Попытка запустить backend..."
        nohup python app.py > backend.log 2>&1 &
        sleep 3
        if curl -s http://127.0.0.1:8000/docs > /dev/null; then
            echo "✅ Backend сервер успешно запущен"
        else
            echo "❌ Не удалось запустить backend"
            exit 1
        fi
    fi

    # Шаг 3: Исправляем конфигурацию
    echo "📋 Шаг 3: Исправляем nginx конфигурацию"

    # Проверяем кастомные конфигурации
    if [ -f "/etc/nginx/sites-enabled/neyro" ]; then
        echo "🔧 Найдена кастомная конфигурация: neyro"
        fix_config_file "/etc/nginx/sites-enabled/neyro"
    elif [ -f "/etc/nginx/sites-available/neyro" ]; then
        echo "🔧 Найдена кастомная конфигурация: neyro"
        fix_config_file "/etc/nginx/sites-available/neyro"
    else
        echo "🔧 Используем стандартную конфигурацию"
        create_minimal_config
    fi

    # Шаг 4: Проверяем синтаксис
    echo "📋 Шаг 4: Проверяем синтаксис nginx"
    if sudo nginx -t; then
        echo "✅ Синтаксис корректен"
    else
        echo "❌ Ошибка в синтаксисе"
        echo "🔧 Попытка создать минимальную конфигурацию..."
        create_minimal_config

        if sudo nginx -t; then
            echo "✅ Минимальная конфигурация работает"
        else
            echo "❌ Критическая ошибка конфигурации"
            echo "🔧 Восстанавливаем стандартную конфигурацию..."
            sudo cp /etc/nginx/sites-available/default.backup.* /etc/nginx/sites-available/default 2>/dev/null
            exit 1
        fi
    fi

    # Шаг 5: Перезапускаем nginx
    echo "📋 Шаг 5: Перезапускаем nginx"
    if sudo systemctl reload nginx; then
        echo "✅ Nginx успешно перезапущен"
    else
        echo "❌ Ошибка при перезапуске nginx"
        exit 1
    fi

    # Шаг 6: Финальная проверка
    echo "📋 Шаг 6: Финальная проверка"
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
        echo "⚠️  API возвращает 405 (нормально для HEAD)"
    elif echo "$RESPONSE" | grep -q "502"; then
        echo "❌ API возвращает 502 - проблема с backend"
    else
        echo "❌ API не отвечает: $RESPONSE"
    fi

    echo ""
    echo "🎉 Расширенное исправление завершено!"
    echo "🌐 Проверьте ваш сайт: http://194.87.226.56"
}

# Запуск основной функции
main "$@"