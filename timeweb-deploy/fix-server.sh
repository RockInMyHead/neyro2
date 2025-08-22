#!/bin/bash

echo "🔧 Исправление сервера Neuro Event..."
echo "====================================="

# Обновляем код из GitHub
echo "1. Обновляем код из GitHub..."
cd /home/neyro/neyro2
git pull origin main

# Исправляем права доступа
echo "2. Исправляем права доступа..."
sudo chown -R neyro:neyro /home/neyro/neyro2/timeweb-deploy/
sudo chmod -R 755 /home/neyro/neyro2/timeweb-deploy/
sudo chmod 644 /home/neyro/neyro2/timeweb-deploy/public/index.html

# Проверяем nginx конфигурацию
echo "3. Проверяем nginx конфигурацию..."
sudo nginx -t
if [ $? -eq 0 ]; then
    echo "✅ Nginx конфигурация валидна"
else
    echo "❌ Ошибка в nginx конфигурации"
    exit 1
fi

# Перезапускаем nginx
echo "4. Перезапускаем nginx..."
sudo systemctl reload nginx
sudo systemctl restart nginx

# Останавливаем старые процессы
echo "5. Останавливаем старые процессы..."
pkill -f uvicorn
sleep 2

# Запускаем backend
echo "6. Запускаем backend сервер..."
cd /home/neyro/neyro2/timeweb-deploy
./start.sh

# Ждем запуска
sleep 3

# Проверяем работу
echo "7. Проверяем работу серверов..."
echo "Проверка порта 8000:"
netstat -tlnp | grep :8000

echo "Проверка nginx:"
sudo systemctl status nginx --no-pager -l

echo "Проверка API эндпоинтов:"
curl -s http://localhost:8000/docs > /dev/null && echo "✅ FastAPI работает" || echo "❌ FastAPI не работает"

echo "====================================="
echo "✅ Сервер исправлен и перезапущен!"
echo "Теперь попробуйте открыть: http://194.87.226.56"