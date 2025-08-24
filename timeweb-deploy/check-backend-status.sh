#!/bin/bash

echo "🔍 Проверка статуса backend сервера..."

# Проверяем, запущен ли Python сервер
echo "📊 Проверка процессов Python сервера:"
ps aux | grep "uvicorn.*app:app" | grep -v grep

echo ""

# Проверяем, слушает ли что-то на порту 8003
echo "🌐 Проверка порта 8003:"
netstat -tlnp | grep :8003 || echo "❌ Порт 8003 не слушается"

echo ""

# Проверяем доступность backend напрямую
echo "🔗 Проверка backend API напрямую:"
if curl -s http://localhost:8003/docs > /dev/null; then
    echo "✅ Backend доступен на localhost:8003"
else
    echo "❌ Backend недоступен на localhost:8003"
fi

echo ""

# Проверяем доступность через nginx
echo "🌐 Проверка backend API через nginx:"
if curl -s http://194.87.226.56/generate_dalle > /dev/null; then
    echo "✅ Backend доступен через nginx"
else
    echo "❌ Backend недоступен через nginx"
fi

echo ""

# Проверяем логи nginx
echo "📋 Последние логи nginx:"
journalctl -u nginx --no-pager -l | tail -10

echo ""

# Проверяем статус nginx
echo "📊 Статус nginx:"
systemctl status nginx --no-pager -l

echo ""
echo "✅ Проверка завершена!" 