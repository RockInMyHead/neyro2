#!/bin/bash

# Проверка MP3 файлов и путей
echo "🔍 Проверяю MP3 файлы и пути..."
echo "📍 Текущая директория: $(pwd)"

# Проверяем все возможные пути к MP3 файлам
echo "📋 Проверяю все возможные пути к 2.mp3:"

# Путь 1: /assets/2.mp3
echo "🔍 /assets/2.mp3:"
curl -I http://194.87.226.56/assets/2.mp3 2>/dev/null | head -1

# Путь 2: /2.mp3
echo "🔍 /2.mp3:"
curl -I http://194.87.226.56/2.mp3 2>/dev/null | head -1

# Путь 3: /music/2.mp3
echo "🔍 /music/2.mp3:"
curl -I http://194.87.226.56/music/2.mp3 2>/dev/null | head -1

# Проверяем все MP3 файлы
echo "\\n📋 Проверяю все MP3 файлы:"
for file in 1.mp3 2.mp3 3.mp3 4.mp3; do
    echo "🔍 $file:"
    curl -I http://194.87.226.56/assets/$file 2>/dev/null | head -1
done

# Проверяем физическое расположение файлов
echo "\\n📋 Физическое расположение файлов:"
echo "🔍 В /assets/:"
ls -la /var/www/timeweb-deploy/public/assets/*.mp3 2>/dev/null || echo "Файлы не найдены в /assets/"

echo "🔍 В /music/:"
ls -la /var/www/timeweb-deploy/music/*.mp3 2>/dev/null || echo "Файлы не найдены в /music/"

# Проверяем nginx конфигурацию
echo "\\n📋 Nginx конфигурация для статических файлов:"
grep -A 10 -B 5 "\.mp3" /etc/nginx/sites-enabled/neyro

echo "\\n✅ Проверка завершена!"