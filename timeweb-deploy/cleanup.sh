#!/bin/bash

# Очистка проблемных резервных копий
echo "🧹 Очищаю проблемные резервные копии..."

# Удалить все резервные копии с ошибками
sudo rm -f /etc/nginx/sites-enabled/neyro.backup.*

echo "✅ Резервные копии удалены"

# Проверить синтаксис
echo "✅ Проверяю синтаксис..."
if sudo nginx -t; then
    echo "✅ Синтаксис корректен"
    sudo systemctl reload nginx
    echo "✅ Nginx перезапущен"
else
    echo "❌ Ошибка в синтаксисе"
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
    fi
fi

# Финальная проверка
echo "🔍 Финальная проверка..."
curl -I http://194.87.226.56/generate_dalle

echo "✅ Очистка завершена!"
echo "🌐 Проверьте ваш сайт: http://194.87.226.56"