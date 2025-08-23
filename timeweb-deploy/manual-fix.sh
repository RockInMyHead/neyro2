#!/bin/bash

# Ручное исправление nginx для TimeWeb
# Используйте этот скрипт если автоматический не работает

echo "🔧 Ручное исправление nginx для TimeWeb..."
echo "📍 Текущая директория: $(pwd)"

# Шаг 1: Диагностика текущей конфигурации
echo "\\n📋 Шаг 1: Диагностика"
echo "🔍 Проверяю структуру nginx..."

ls -la /etc/nginx/sites-available/ 2>/dev/null || echo "sites-available не существует"
ls -la /etc/nginx/sites-enabled/ 2>/dev/null || echo "sites-enabled не существует"

# Найдем активный конфигурационный файл
ACTIVE_CONFIG=""
if [ -f "/etc/nginx/sites-enabled/neyro" ]; then
    ACTIVE_CONFIG="/etc/nginx/sites-enabled/neyro"
    echo "✅ Найден активный конфиг: $ACTIVE_CONFIG"
elif [ -f "/etc/nginx/sites-available/default" ]; then
    ACTIVE_CONFIG="/etc/nginx/sites-available/default"
    echo "✅ Найден конфиг: $ACTIVE_CONFIG"
else
    echo "❌ Активный конфиг не найден"
    exit 1
fi

# Шаг 2: Создание резервной копии
echo "\\n📋 Шаг 2: Резервная копия"
BACKUP_FILE="${ACTIVE_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
sudo cp "$ACTIVE_CONFIG" "$BACKUP_FILE"
echo "✅ Резервная копия: $BACKUP_FILE"

# Шаг 3: Применение исправленной конфигурации
echo "\\n📋 Шаг 3: Применение исправлений"
if [ -f "nginx-fixed.conf" ]; then
    echo "🔧 Использую nginx-fixed.conf"
    sudo cp nginx-fixed.conf "$ACTIVE_CONFIG"
else
    echo "❌ Файл nginx-fixed.conf не найден"
    exit 1
fi

# Шаг 4: Проверка синтаксиса
echo "\\n📋 Шаг 4: Проверка синтаксиса"
if sudo nginx -t; then
    echo "✅ Синтаксис корректен"
else
    echo "❌ Ошибка в синтаксисе"
    echo "🔧 Восстанавливаю резервную копию..."
    sudo cp "$BACKUP_FILE" "$ACTIVE_CONFIG"
    exit 1
fi

# Шаг 5: Перезапуск nginx
echo "\\n📋 Шаг 5: Перезапуск nginx"
if sudo systemctl reload nginx; then
    echo "✅ Nginx перезапущен"
else
    echo "❌ Ошибка при перезапуске"
    echo "🔧 Восстанавливаю резервную копию..."
    sudo cp "$BACKUP_FILE" "$ACTIVE_CONFIG"
    sudo systemctl reload nginx
    exit 1
fi

# Шаг 6: Проверка backend
echo "\\n📋 Шаг 6: Проверка backend"
if curl -s http://127.0.0.1:8000/docs > /dev/null; then
    echo "✅ Backend работает"
else
    echo "❌ Backend не отвечает"
    echo "🔧 Запускаю backend..."
    nohup python app.py > backend.log 2>&1 &
    sleep 3
    if curl -s http://127.0.0.1:8000/docs > /dev/null; then
        echo "✅ Backend запущен"
    else
        echo "❌ Не удалось запустить backend"
    fi
fi

# Шаг 7: Финальная проверка
echo "\\n📋 Шаг 7: Финальная проверка"
echo "🔍 Проверяю API доступность..."
curl -I http://194.87.226.56/generate_dalle

echo "\\n✅ Ручное исправление завершено!"
echo "🌐 Проверьте ваш сайт: http://194.87.226.56"
echo "📁 Резервная копия: $BACKUP_FILE"