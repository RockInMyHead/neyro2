#!/bin/bash

# Быстрое исправление синтаксической ошибки nginx
echo "🔧 Исправляем синтаксическую ошибку nginx..."

# Проверяем, где находится проблемный файл
PROBLEM_FILE=""
if [ -f "/etc/nginx/sites-enabled/neyro" ]; then
    PROBLEM_FILE="/etc/nginx/sites-enabled/neyro"
    echo "📄 Найден проблемный файл: $PROBLEM_FILE"
elif [ -f "/etc/nginx/sites-available/neyro" ]; then
    PROBLEM_FILE="/etc/nginx/sites-available/neyro"
    echo "📄 Найден проблемный файл: $PROBLEM_FILE"
else
    echo "❌ Файл neyro не найден"
    echo "🔧 Используем стандартную конфигурацию"
    PROBLEM_FILE="/etc/nginx/sites-available/default"
fi

# Создаем резервную копию
BACKUP_FILE="${PROBLEM_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
sudo cp "$PROBLEM_FILE" "$BACKUP_FILE"
echo "📦 Резервная копия: $BACKUP_FILE"

# Исправляем конфигурацию - убираем proxy_http_version из неправильного места
sudo sed -i 's/proxy_http_version 1\.1;//g' "$PROBLEM_FILE"

# Добавляем proxy_http_version только в правильном месте (в location /ws)
sudo sed -i '/location \/ws {/a \        proxy_http_version 1.1;' "$PROBLEM_FILE"

echo "✅ Конфигурация исправлена"

# Проверяем синтаксис
if sudo nginx -t; then
    echo "✅ Синтаксис корректен"
    sudo systemctl reload nginx
    echo "✅ Nginx перезапущен"
else
    echo "❌ Синтаксис все еще неправильный"
    echo "🔧 Восстанавливаем резервную копию"
    sudo cp "$BACKUP_FILE" "$PROBLEM_FILE"
fi