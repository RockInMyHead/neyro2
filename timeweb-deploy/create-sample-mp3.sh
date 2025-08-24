#!/bin/bash

echo "🎵 Создание тестовых MP3 файлов..."

# Создаем директории
echo "📁 Создание директорий..."
mkdir -p /home/neyro/neyro2/music
mkdir -p /home/neyro/neyro2/timeweb-deploy/music

# Проверяем, есть ли ffmpeg для создания аудио
if command -v ffmpeg &> /dev/null; then
    echo "✅ ffmpeg найден, создаем тестовые MP3 файлы..."
    
    # Создаем тестовый MP3 файл (1 секунда тишины)
    echo "🎵 Создание 2.mp3..."
    ffmpeg -f lavfi -i anullsrc=r=44100:cl=stereo -t 1 -q:a 9 -acodec libmp3lame /home/neyro/neyro2/2.mp3 -y 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "✅ 2.mp3 создан успешно"
        # Копируем в music директорию
        cp /home/neyro/neyro2/2.mp3 /home/neyro/neyro2/music/
        echo "✅ 2.mp3 скопирован в /home/neyro/neyro2/music/"
    else
        echo "❌ Ошибка при создании 2.mp3"
    fi
    
    # Создаем дополнительные файлы
    for i in 1 3 4; do
        echo "🎵 Создание ${i}.mp3..."
        ffmpeg -f lavfi -i anullsrc=r=44100:cl=stereo -t 1 -q:a 9 -acodec libmp3lame /home/neyro/neyro2/${i}.mp3 -y 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "✅ ${i}.mp3 создан успешно"
            cp /home/neyro/neyro2/${i}.mp3 /home/neyro/neyro2/music/
        fi
    done
    
else
    echo "❌ ffmpeg не найден, создаем пустые файлы..."
    
    # Создаем пустые файлы как заглушки
    for i in 1 2 3 4; do
        echo "📄 Создание ${i}.mp3 (пустой файл)..."
        touch /home/neyro/neyro2/${i}.mp3
        touch /home/neyro/neyro2/music/${i}.mp3
        echo "✅ ${i}.mp3 создан"
    done
fi

# Устанавливаем права доступа
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
echo "🎉 Тестовые MP3 файлы созданы!"
echo "🚀 Теперь запустите: ./test-mp3-access.sh" 