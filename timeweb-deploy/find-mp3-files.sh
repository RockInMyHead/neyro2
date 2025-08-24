#!/bin/bash

echo "🔍 Поиск MP3 файлов на сервере..."

# Список возможных мест для поиска
SEARCH_PATHS=(
    "/"
    "/var/www"
    "/var/www/html"
    "/home/neyro"
    "/home/neyro/neyro2"
    "/home/neyro/neyro2/timeweb-deploy"
    "/usr/share/nginx"
    "/opt"
    "/tmp"
    "/root"
)

echo "📁 Поиск в стандартных директориях..."
for path in "${SEARCH_PATHS[@]}"; do
    if [ -d "$path" ]; then
        echo "🔍 Поиск в $path..."
        MP3_FOUND=$(find "$path" -name "*.mp3" -type f 2>/dev/null | head -5)
        if [ -n "$MP3_FOUND" ]; then
            echo "✅ Найдены MP3 файлы в $path:"
            echo "$MP3_FOUND"
            echo ""
        fi
    fi
done

echo "🔍 Поиск в текущей директории и поддиректориях..."
CURRENT_MP3=$(find . -name "*.mp3" -type f 2>/dev/null)
if [ -n "$CURRENT_MP3" ]; then
    echo "✅ Найдены MP3 файлы в текущей директории:"
    echo "$CURRENT_MP3"
    echo ""
fi

echo "🔍 Поиск в домашней директории пользователя..."
HOME_MP3=$(find ~ -name "*.mp3" -type f 2>/dev/null | head -5)
if [ -n "$HOME_MP3" ]; then
    echo "✅ Найдены MP3 файлы в домашней директории:"
    echo "$HOME_MP3"
    echo ""
fi

echo "🔍 Поиск в корневой директории системы..."
ROOT_MP3=$(find / -name "*.mp3" -type f 2>/dev/null | grep -v "/proc\|/sys\|/dev" | head -10)
if [ -n "$ROOT_MP3" ]; then
    echo "✅ Найдены MP3 файлы в системе:"
    echo "$ROOT_MP3"
    echo ""
fi

echo "🔍 Проверка содержимого текущей директории..."
echo "📍 Текущая директория: $(pwd)"
echo "📍 Содержимое:"
ls -la

echo ""
echo "🔍 Проверка содержимого /home/neyro/neyro2/:"
if [ -d "/home/neyro/neyro2" ]; then
    ls -la /home/neyro/neyro2/ | head -20
else
    echo "❌ Директория /home/neyro/neyro2/ не существует"
fi

echo ""
echo "�� Поиск завершен!" 