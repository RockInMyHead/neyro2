#!/bin/bash

echo "🔧 Применение исправленной nginx конфигурации..."

# Путь к конфигурации
NGINX_CONF="/etc/nginx/sites-available/neyro"
NGINX_CONF_BACKUP="/etc/nginx/sites-available/neyro.backup.$(date +%Y%m%d_%H%M%S)"

# Создаем бэкап текущей конфигурации
if [ -f "$NGINX_CONF" ]; then
    echo "📋 Создание бэкапа текущей конфигурации..."
    cp "$NGINX_CONF" "$NGINX_CONF_BACKUP"
    echo "✅ Бэкап создан: $NGINX_CONF_BACKUP"
fi

# Копируем новую конфигурацию
echo "📋 Копирование новой конфигурации..."
cp "/home/neyro/neyro2/timeweb-deploy/nginx.conf" "$NGINX_CONF"

# Проверяем синтаксис
echo "🔍 Проверка синтаксиса nginx..."
nginx -t -c /etc/nginx/nginx.conf

if [ $? -eq 0 ]; then
    echo "✅ Синтаксис nginx корректен"

    # Перезапускаем nginx
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
    echo "📋 Восстанавливаем бэкап..."
    if [ -f "$NGINX_CONF_BACKUP" ]; then
        cp "$NGINX_CONF_BACKUP" "$NGINX_CONF"
        echo "✅ Конфигурация восстановлена из бэкапа"
    fi
    exit 1
fi

echo "🎉 Nginx конфигурация успешно применена!"
echo "🌐 Проверьте ваш сайт: http://194.87.226.56"