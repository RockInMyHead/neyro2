#!/bin/bash

# Скрипт для обновления API URL'ов в собранном фронтенде для TimeWeb

echo "🔄 Обновляю API URL'ы для TimeWeb..."

# Путь к собранному фронтенду
FRONTEND_DIR="public"
BACKUP_DIR="public_backup"

# Создаем резервную копию
if [ ! -d "$BACKUP_DIR" ]; then
    echo "📦 Создаю резервную копию..."
    cp -r "$FRONTEND_DIR" "$BACKUP_DIR"
fi

# Обновляем API URL'ы в JavaScript файлах
echo "🔧 Заменяю localhost:8000 на 194.87.226.56..."

# Находим все JS файлы и заменяем URL'ы
find "$FRONTEND_DIR" -name "*.js" -type f -exec sed -i '' 's|localhost:8000|194.87.226.56|g' {} \;
find "$FRONTEND_DIR" -name "*.js" -type f -exec sed -i '' 's|127.0.0.1:8000|194.87.226.56|g' {} \;

# Находим все CSS файлы и заменяем URL'ы (если есть)
find "$FRONTEND_DIR" -name "*.css" -type f -exec sed -i '' 's|localhost:8000|194.87.226.56|g' {} \;
find "$FRONTEND_DIR" -name "*.css" -type f -exec sed -i '' 's|127.0.0.1:8000|194.87.226.56|g' {} \;

echo "✅ API URL'ы обновлены!"
echo "🌐 Теперь фронтенд будет использовать: http://194.87.226.56"
echo "📁 Резервная копия сохранена в: $BACKUP_DIR" 