#!/bin/bash

echo "🚨 Принудительное исправление nginx..."

# Остановка nginx
echo "🛑 Остановка nginx..."
systemctl stop nginx

# Пути к конфигурации
NGINX_CONF="/etc/nginx/sites-available/neyro"
NGINX_ENABLED="/etc/nginx/sites-enabled/neyro"
NGINX_BACKUP="/etc/nginx/sites-available/neyro.backup.$(date +%Y%m%d_%H%M%S)"

# Создание бэкапа
if [ -f "$NGINX_CONF" ]; then
    echo "📋 Создание бэкапа..."
    cp "$NGINX_CONF" "$NGINX_BACKUP"
    echo "✅ Бэкап создан: $NGINX_BACKUP"
fi

# Удаление старой конфигурации
echo "🗑️ Удаление старой конфигурации..."
rm -f "$NGINX_ENABLED"
rm -f "$NGINX_CONF"

# Полная очистка всех nginx конфигураций
echo "🧹 Полная очистка nginx конфигураций..."
rm -f /etc/nginx/sites-enabled/*
rm -f /etc/nginx/sites-available/neyro*
find /etc/nginx -name "*neyro*" -type f -delete

# Очистка кэша nginx
echo "🧽 Очистка кэша nginx..."
rm -rf /var/cache/nginx/*
rm -rf /var/lib/nginx/*

# Перезагрузка systemd для nginx
echo "🔄 Перезагрузка systemd..."
systemctl daemon-reload

# Копирование новой конфигурации
echo "📋 Копирование новой конфигурации..."
cp "/home/neyro/neyro2/timeweb-deploy/nginx-simple.conf" "$NGINX_CONF"

# Создание символической ссылки
echo "🔗 Создание символической ссылки..."
ln -sf "$NGINX_CONF" "$NGINX_ENABLED"

# Проверка синтаксиса
echo "🔍 Проверка синтаксиса..."
nginx -t

if [ $? -eq 0 ]; then
    echo "✅ Синтаксис корректен"
    
    # Запуск nginx
    echo "🚀 Запуск nginx..."
    systemctl start nginx
    
    if [ $? -eq 0 ]; then
        echo "✅ Nginx успешно запущен"
        
        # Проверка статуса
        echo "📊 Статус nginx:"
        systemctl status nginx --no-pager -l
        
        # Проверка доступности
        echo "🌐 Проверка доступности сайта..."
        sleep 3
        curl -I http://194.87.226.56
        
    else
        echo "❌ Ошибка при запуске nginx"
        echo "📋 Логи nginx:"
        journalctl -u nginx --no-pager -l | tail -20
        exit 1
    fi
    
else
    echo "❌ Ошибка синтаксиса nginx"
    echo "📋 Восстанавливаем бэкап..."
    if [ -f "$NGINX_BACKUP" ]; then
        cp "$NGINX_BACKUP" "$NGINX_CONF"
        ln -sf "$NGINX_CONF" "$NGINX_ENABLED"
        echo "✅ Конфигурация восстановлена из бэкапа"
    fi
    exit 1
fi

echo "🎉 Принудительное исправление завершено!" 