#!/bin/bash

echo "🎵 Применение исправлений для MP3 файлов..."

# Шаг 1: Исправление структуры файлов
echo "📁 Шаг 1: Исправление структуры MP3 файлов..."
chmod +x fix-mp3-structure.sh
./fix-mp3-structure.sh

echo ""

# Шаг 2: Применение новой nginx конфигурации
echo "🔧 Шаг 2: Применение новой nginx конфигурации..."
cp nginx-simple.conf /etc/nginx/sites-available/neyro

# Проверка синтаксиса
echo "🔍 Проверка синтаксиса nginx..."
nginx -t

if [ $? -eq 0 ]; then
    echo "✅ Синтаксис корректен"
    
    # Перезапуск nginx
    echo "🔄 Перезапуск nginx..."
    systemctl restart nginx
    
    if [ $? -eq 0 ]; then
        echo "✅ Nginx успешно перезапущен"
    else
        echo "❌ Ошибка при перезапуске nginx"
        exit 1
    fi
    
else
    echo "❌ Ошибка синтаксиса nginx"
    exit 1
fi

echo ""

# Шаг 3: Тестирование исправлений
echo "🧪 Шаг 3: Тестирование исправлений..."
chmod +x test-mp3-access.sh
./test-mp3-access.sh

echo ""
echo "🎉 Все исправления применены!"
echo "🌐 Проверьте ваш сайт: http://194.87.226.56" 