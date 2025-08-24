#!/bin/bash

# Скрипт для исправления проблем на сервере TimeWeb
# Запускать на сервере TimeWeb через SSH

echo "🔧 Исправление проблем на сервере TimeWeb..."
echo "📍 Текущая директория: $(pwd)"

# Проверяем, что мы в правильной папке
if [ ! -f "app.py" ]; then
    echo "❌ Файл app.py не найден. Перейдите в папку timeweb-deploy"
    exit 1
fi

# Шаг 1: Проверяем структуру папок
echo "📋 Шаг 1: Проверяю структуру папок"
if [ ! -d "music" ]; then
    echo "❌ Папка music не найдена"
    exit 1
fi

if [ ! -d "public" ]; then
    echo "❌ Папка public не найдена"
    exit 1
fi

if [ ! -d "images" ]; then
    echo "❌ Папка images не найдена"
    exit 1
fi

echo "✅ Структура папок корректна"

# Шаг 2: Проверяем наличие музыкальных файлов
echo "📋 Шаг 2: Проверяю музыкальные файлы"
if [ ! -f "music/2.mp3" ]; then
    echo "❌ Файл music/2.mp3 не найден"
    ls -la music/
    exit 1
fi
echo "✅ Музыкальные файлы найдены"

# Шаг 3: Проверяем backend
echo "📋 Шаг 3: Проверяю backend сервер"
if curl -s http://127.0.0.1:8000/docs > /dev/null; then
    echo "✅ Backend сервер работает"
else
    echo "❌ Backend сервер не отвечает"
    echo "🔧 Запускаю backend сервер..."
    nohup python app.py > backend.log 2>&1 &
    sleep 5
    if curl -s http://127.0.0.1:8000/docs > /dev/null; then
        echo "✅ Backend сервер успешно запущен"
    else
        echo "❌ Не удалось запустить backend"
        echo "📄 Логи: $(cat backend.log 2>/dev/null || echo 'Лог файл не найден')"
        exit 1
    fi
fi

# Шаг 4: Исправляем nginx конфигурацию
echo "📋 Шаг 4: Исправляю nginx конфигурацию"

# Находим конфигурационный файл
CONFIG_FILE=""
if [ -f "/etc/nginx/sites-available/default" ]; then
    CONFIG_FILE="/etc/nginx/sites-available/default"
elif [ -f "/etc/nginx/nginx.conf" ]; then
    CONFIG_FILE="/etc/nginx/nginx.conf"
else
    echo "❌ Конфигурационный файл nginx не найден"
    exit 1
fi

echo "🔧 Найден конфигурационный файл: $CONFIG_FILE"

# Создаем резервную копию
BACKUP_FILE="${CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
echo "📦 Создаю резервную копию: $BACKUP_FILE"
sudo cp "$CONFIG_FILE" "$BACKUP_FILE"

# Применяем исправленную конфигурацию
if [ -f "nginx-simple.conf" ]; then
    echo "🔧 Применяю nginx-simple.conf"
    sudo cp nginx-simple.conf "$CONFIG_FILE"
elif [ -f "nginx-fixed.conf" ]; then
    echo "🔧 Применяю nginx-fixed.conf"
    sudo cp nginx-fixed.conf "$CONFIG_FILE"
else
    echo "❌ Файл конфигурации не найден"
    exit 1
fi

# Проверяем синтаксис
echo "✅ Проверяю синтаксис nginx..."
if sudo nginx -t; then
    echo "✅ Синтаксис корректен"
else
    echo "❌ Ошибка в синтаксисе"
    echo "🔧 Восстанавливаю резервную копию..."
    sudo cp "$BACKUP_FILE" "$CONFIG_FILE"
    exit 1
fi

# Перезапускаем nginx
echo "🔄 Перезапускаю nginx..."
sudo systemctl reload nginx

if [ $? -eq 0 ]; then
    echo "✅ Nginx успешно перезапущен"
else
    echo "❌ Ошибка при перезапуске nginx"
    echo "🔧 Восстанавливаю резервную копию..."
    sudo cp "$BACKUP_FILE" "$CONFIG_FILE"
    sudo systemctl reload nginx
    exit 1
fi

# Шаг 5: Финальная проверка
echo "📋 Шаг 5: Финальная проверка"
sleep 3

echo "🔍 Проверяю /music/2.mp3..."
if curl -I http://194.87.226.56/music/2.mp3 2>/dev/null | grep -q "200 OK"; then
    echo "✅ Музыкальный файл доступен"
else
    echo "❌ Музыкальный файл недоступен"
fi

echo "🔍 Проверяю /generate_dalle..."
RESPONSE=$(curl -I http://194.87.226.56/generate_dalle 2>/dev/null | head -1)
if echo "$RESPONSE" | grep -q "200 OK"; then
    echo "✅ API generate_dalle работает"
elif echo "$RESPONSE" | grep -q "405"; then
    echo "⚠️  API generate_dalle отвечает 405 (Method Not Allowed) - это нормально для HEAD запроса"
elif echo "$RESPONSE" | grep -q "502"; then
    echo "❌ API generate_dalle возвращает 502 - backend проблема"
else
    echo "❌ API generate_dalle не отвечает: $RESPONSE"
fi

echo ""
echo "🎉 Исправления применены!"
echo "🌐 Проверьте ваш сайт: http://194.87.226.56"
echo "📁 Резервная копия сохранена: $BACKUP_FILE"
echo ""
echo "📋 Инструкции для проверки:"
echo "1. Откройте http://194.87.226.56 в браузере"
echo "2. Проверьте, загружается ли музыка"
echo "3. Попробуйте использовать функции генерации изображений"
echo ""
echo "Если проблемы остались, проверьте логи:"
echo "sudo tail -f /var/log/nginx/error.log"
echo "sudo tail -f backend.log"