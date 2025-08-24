#!/bin/bash

echo "🔍 Проверка исправлений nginx..."

# Проверяем статус nginx
echo "📋 Проверка статуса nginx..."
systemctl status nginx --no-pager -l

# Проверяем доступность сайта
echo "🌐 Проверка доступности сайта..."
curl -I http://194.87.226.56

# Проверяем API эндпоинты
echo "🔍 Проверка API эндпоинтов..."
echo "📋 Проверка /docs..."
curl -s http://194.87.226.56/docs | head -1

echo "📋 Проверка /generate_dalle..."
curl -X OPTIONS -I http://194.87.226.56/generate_dalle

# Проверяем статические файлы
echo "📋 Проверка статических файлов..."
echo "🔍 Проверка 2.mp3..."
curl -I http://194.87.226.56/2.mp3

echo "🔍 Проверка /music/2.mp3..."
curl -I http://194.87.226.56/music/2.mp3

# Проверяем WebSocket
echo "📋 Проверка WebSocket..."
curl -I http://194.87.226.56/session/test/stream

echo "✅ Проверка завершена!"