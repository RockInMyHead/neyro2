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
if [ -f "nginx-simple.conf" ]; then
    sudo cp nginx-simple.conf /etc/nginx/sites-available/default
else
    echo "❌ Файл nginx-simple.conf не найден, использую nginx.conf"
    sudo cp nginx.conf /etc/nginx/sites-available/default
fi

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

# Проверяем статус backend сервера
echo "🔍 Проверяю статус backend сервера..."
if curl -s http://127.0.0.1:8000/docs > /dev/null; then
    echo "✅ Backend сервер работает"
else
    echo "❌ Backend сервер не отвечает"
    echo "🔧 Попытка запустить backend..."
    cd /var/www/timeweb-deploy
    nohup python app.py > backend.log 2>&1 &
    sleep 5
    if curl -s http://127.0.0.1:8000/docs > /dev/null; then
        echo "✅ Backend сервер успешно запущен"
    else
        echo "❌ Не удалось запустить backend"
        echo "📄 Логи: $(cat backend.log 2>/dev/null || echo 'Лог файл не найден')"
    fi
fi

# Проверяем доступность API
echo "🔍 Проверяю доступность API..."
sleep 2
curl -I http://194.87.226.56/generate_dalle

echo "✅ Проверка завершена!"
echo "🌐 Теперь ваш сайт должен работать на http://194.87.226.56" 