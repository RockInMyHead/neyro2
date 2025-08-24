#!/bin/bash

echo "🔍 Тестирование доступа к MP3 файлам..."

# Проверяем существование файлов
echo "📁 Проверка существования файлов:"
echo "📍 /home/neyro/neyro2/2.mp3:"
if [ -f "/home/neyro/neyro2/2.mp3" ]; then
    echo "✅ Файл существует"
    ls -la "/home/neyro/neyro2/2.mp3"
else
    echo "❌ Файл не найден"
fi

echo ""
echo "📍 /home/neyro/neyro2/music/2.mp3:"
if [ -f "/home/neyro/neyro2/music/2.mp3" ]; then
    echo "✅ Файл существует"
    ls -la "/home/neyro/neyro2/music/2.mp3"
else
    echo "❌ Файл не найден"
fi

echo ""
# Проверяем доступность через nginx
echo "🌐 Проверка доступности через nginx:"
echo "📍 http://194.87.226.56/music/2.mp3:"
curl -I "http://194.87.226.56/music/2.mp3"

echo ""
echo "📍 http://194.87.226.56/2.mp3:"
curl -I "http://194.87.226.56/2.mp3"

echo ""
# Проверяем права доступа
echo "🔐 Проверка прав доступа:"
echo "📍 Права на /home/neyro/neyro2/:"
ls -la "/home/neyro/neyro2/" | grep "2.mp3"

echo ""
echo "📍 Права на /home/neyro/neyro2/music/:"
ls -la "/home/neyro/neyro2/music/" | grep "2.mp3" 2>/dev/null || echo "Директория music/ не существует или пуста"

echo ""
echo "✅ Тестирование завершено!" 