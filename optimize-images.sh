#!/bin/bash
# Скрипт для оптимизации изображений

echo "🖼️  Оптимизация изображений для веба..."

# Проверяем наличие ImageMagick
if ! command -v convert &> /dev/null; then
    echo "❌ ImageMagick не установлен. Установите его для оптимизации изображений:"
    echo "   macOS: brew install imagemagick"
    echo "   Ubuntu: sudo apt install imagemagick"
    exit 1
fi

cd timeweb-deploy/images

echo "📊 Размер до оптимизации:"
du -sh .

# Оптимизируем JPEG файлы
echo "🔄 Оптимизация JPEG файлов..."
find . -name "*.jpg" -o -name "*.jpeg" | while read file; do
    echo "Обработка $file..."
    convert "$file" -quality 80 -resize "1920x1080>" "$file"
done

# Оптимизируем PNG файлы
echo "🔄 Оптимизация PNG файлов..."
find . -name "*.png" | while read file; do
    echo "Обработка $file..."
    convert "$file" -quality 80 -resize "1920x1080>" "$file"
done

echo "📊 Размер после оптимизации:"
du -sh .

echo "✅ Оптимизация завершена!"
