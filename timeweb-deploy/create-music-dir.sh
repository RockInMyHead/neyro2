#!/bin/bash

echo "🎵 Создание директории music и копирование MP3 файлов..."

# Создаем директорию music
echo "📁 Создание директории music..."
mkdir -p /home/neyro/neyro2/music

# Копируем MP3 файлы в music директорию
echo "📋 Копирование MP3 файлов..."
if [ -f "/home/neyro/neyro2/2.mp3" ]; then
    cp /home/neyro/neyro2/2.mp3 /home/neyro/neyro2/music/
    echo "✅ 2.mp3 скопирован"
fi

if [ -f "/home/neyro/neyro2/1.mp3" ]; then
    cp /home/neyro/neyro2/1.mp3 /home/neyro/neyro2/music/
    echo "✅ 1.mp3 скопирован"
fi

if [ -f "/home/neyro/neyro2/3.mp3" ]; then
    cp /home/neyro/neyro2/3.mp3 /home/neyro/neyro2/music/
    echo "✅ 3.mp3 скопирован"
fi

if [ -f "/home/neyro/neyro2/4.mp3" ]; then
    cp /home/neyro/neyro2/4.mp3 /home/neyro/neyro2/music/
    echo "✅ 4.mp3 скопирован"
fi

# Устанавливаем права доступа
echo "🔐 Установка прав доступа..."
chmod 644 /home/neyro/neyro2/music/*.mp3

# Проверяем результат
echo "📊 Проверка результата..."
echo "📍 Файлы в music директории:"
ls -la /home/neyro/neyro2/music/*.mp3

echo ""
echo "🎉 Директория music создана и заполнена!"
echo "🚀 Теперь запустите: ./test-mp3-access.sh" 