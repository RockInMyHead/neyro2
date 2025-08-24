#!/bin/bash

echo "🔍 Диагностика nginx конфигурации..."

# Проверка статуса nginx
echo "📊 Статус nginx:"
systemctl status nginx --no-pager -l

echo ""

# Проверка активных конфигураций
echo "📁 Активные конфигурации nginx:"
echo "📍 sites-enabled:"
ls -la /etc/nginx/sites-enabled/

echo ""
echo "📍 sites-available:"
ls -la /etc/nginx/sites-available/

echo ""

# Проверка содержимого активной конфигурации
echo "📋 Содержимое активной конфигурации:"
if [ -L "/etc/nginx/sites-enabled/neyro" ]; then
    echo "🔗 Символическая ссылка:"
    ls -la /etc/nginx/sites-enabled/neyro
    
    echo ""
    echo "📄 Реальная конфигурация:"
    cat /etc/nginx/sites-enabled/neyro
else
    echo "❌ Символическая ссылка не найдена"
fi

echo ""

# Проверка синтаксиса
echo "🔍 Проверка синтаксиса nginx:"
nginx -t

echo ""

# Проверка процессов nginx
echo "🔄 Процессы nginx:"
ps aux | grep nginx

echo ""

# Проверка портов
echo "🌐 Проверка портов:"
netstat -tlnp | grep :80

echo ""

# Проверка логов
echo "📋 Последние логи nginx:"
journalctl -u nginx --no-pager -l | tail -10

echo ""
echo "✅ Диагностика завершена" 