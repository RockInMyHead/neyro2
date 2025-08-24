#!/bin/bash

echo "🎵 Полное исправление проблемы с MP3 файлами..."

# Шаг 1: Поиск существующих MP3 файлов
echo "🔍 Шаг 1: Поиск существующих MP3 файлов..."
chmod +x find-mp3-files.sh
./find-mp3-files.sh

echo ""

# Шаг 2: Создание тестовых MP3 файлов если не найдены
echo "📁 Шаг 2: Создание тестовых MP3 файлов..."
chmod +x create-sample-mp3.sh
./create-sample-mp3.sh

echo ""

# Шаг 3: Применение nginx конфигурации
echo "🔧 Шаг 3: Применение nginx конфигурации..."
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

# Шаг 4: Тестирование исправлений
echo "🧪 Шаг 4: Тестирование исправлений..."
chmod +x test-mp3-access.sh
./test-mp3-access.sh

echo ""
echo "🎉 Все исправления применены!"
echo "🌐 Проверьте ваш сайт: http://194.87.226.56"
echo "🎵 MP3 файлы должны теперь загружаться без ошибок 404" 