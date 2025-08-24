#!/bin/bash

echo "🎵 Исправление структуры MP3 файлов..."

# Создаем директории если их нет
echo "📁 Создание директорий..."
mkdir -p /home/neyro/neyro2/music
mkdir -p /home/neyro/neyro2/timeweb-deploy/music

# Проверяем, где находятся MP3 файлы
echo "🔍 Поиск MP3 файлов..."
MP3_FILES=$(find /home/neyro/neyro2 -name "*.mp3" -type f 2>/dev/null)

if [ -z "$MP3_FILES" ]; then
    echo "❌ MP3 файлы не найдены в /home/neyro/neyro2/"
    echo "🔍 Ищем в других местах..."
    
    # Ищем в корневой директории
    if [ -f "/2.mp3" ]; then
        echo "✅ Найдены MP3 файлы в корневой директории"
        cp /2.mp3 /home/neyro/neyro2/
        cp /1.mp3 /home/neyro/neyro2/ 2>/dev/null || true
        cp /3.mp3 /home/neyro/neyro2/ 2>/dev/null || true
        cp /4.mp3 /home/neyro/neyro2/ 2>/dev/null || true
    fi
    
    # Ищем в /var/www/
    if [ -f "/var/www/2.mp3" ]; then
        echo "✅ Найдены MP3 файлы в /var/www/"
        cp /var/www/2.mp3 /home/neyro/neyro2/
        cp /var/www/1.mp3 /home/neyro/neyro2/ 2>/dev/null || true
        cp /var/www/3.mp3 /home/neyro/neyro2/ 2>/dev/null || true
        cp /var/www/4.mp3 /home/neyro/neyro2/ 2>/dev/null || true
    fi
else
    echo "✅ MP3 файлы найдены:"
    echo "$MP3_FILES"
fi

# Копируем файлы в music директорию
echo "📋 Копирование MP3 файлов в music директорию..."
if [ -f "/home/neyro/neyro2/2.mp3" ]; then
    cp /home/neyro/neyro2/2.mp3 /home/neyro/neyro2/music/
    cp /home/neyro/neyro2/1.mp3 /home/neyro/neyro2/music/ 2>/dev/null || true
    cp /home/neyro/neyro2/3.mp3 /home/neyro/neyro2/music/ 2>/dev/null || true
    cp /home/neyro/neyro2/4.mp3 /home/neyro/neyro2/music/ 2>/dev/null || true
    echo "✅ Файлы скопированы в /home/neyro/neyro2/music/"
fi

# Проверяем права доступа
echo "🔐 Установка прав доступа..."
chmod 644 /home/neyro/neyro2/*.mp3 2>/dev/null || true
chmod 644 /home/neyro/neyro2/music/*.mp3 2>/dev/null || true

# Проверяем результат
echo "📊 Проверка результата..."
echo "📍 Файлы в корневой директории:"
ls -la /home/neyro/neyro2/*.mp3 2>/dev/null || echo "Файлы не найдены"

echo ""
echo "📍 Файлы в music директории:"
ls -la /home/neyro/neyro2/music/*.mp3 2>/dev/null || echo "Файлы не найдены"

echo ""
echo "🎉 Структура MP3 файлов исправлена!"
echo "🚀 Теперь запустите: ./test-mp3-access.sh" 