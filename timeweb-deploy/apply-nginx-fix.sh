#!/bin/bash

# Скрипт для применения исправлений nginx на TimeWeb сервере

echo "🔧 Применяю исправления nginx для TimeWeb..."

# Проверяем права на выполнение
if [ ! -w /etc/nginx/sites-available/ ]; then
    echo "❌ Нет прав на запись в /etc/nginx/sites-available/"
    echo "Запустите скрипт с правами sudo"
    exit 1
fi

# Создаем резервную копию текущей конфигурации
echo "📦 Создаю резервную копию текущей конфигурации..."
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup.$(date +%Y%m%d_%H%M%S)

# Копируем исправленную конфигурацию
echo "🔧 Копирую исправленную конфигурацию nginx..."
sudo cp nginx.conf /etc/nginx/sites-available/default

# Проверяем синтаксис nginx
echo "✅ Проверяю синтаксис nginx..."
if sudo nginx -t; then
    echo "✅ Синтаксис nginx корректен"
else
    echo "❌ Ошибка в синтаксисе nginx"
    echo "Восстанавливаю резервную копию..."
    sudo cp /etc/nginx/sites-available/default.backup.* /etc/nginx/sites-available/default
    exit 1
fi

# Перезапускаем nginx
echo "🔄 Перезапускаю nginx..."
sudo systemctl reload nginx

if [ $? -eq 0 ]; then
    echo "✅ Nginx успешно перезапущен"
    echo "🌐 Теперь API запросы должны работать корректно"
else
    echo "❌ Ошибка при перезапуске nginx"
    echo "Восстанавливаю резервную копию..."
    sudo cp /etc/nginx/sites-available/default.backup.* /etc/nginx/sites-available/default
    sudo systemctl reload nginx
    exit 1
fi

echo "🎉 Исправления применены успешно!"
echo "📁 Резервная копия сохранена в /etc/nginx/sites-available/default.backup.*" 