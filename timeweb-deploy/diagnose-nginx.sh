#!/bin/bash

# Диагностика nginx конфигурации на TimeWeb сервере

echo "🔍 Диагностика nginx конфигурации..."
echo "📍 Текущая директория: $(pwd)"

# Проверим структуру nginx
echo "\\n📋 1. Структура nginx директорий:"
ls -la /etc/nginx/

echo "\\n📋 2. Доступные конфигурации:"
ls -la /etc/nginx/sites-available/ 2>/dev/null || echo "sites-available не существует"
ls -la /etc/nginx/sites-enabled/ 2>/dev/null || echo "sites-enabled не существует"

echo "\\n📋 3. Текущие конфигурационные файлы:"
find /etc/nginx -name "*.conf" -type f -exec echo "📄 {}" \\;

echo "\\n📋 4. Активные конфигурации:"
find /etc/nginx/sites-enabled -type l -exec echo "🔗 {} -> $(readlink {})" \\; 2>/dev/null || echo "sites-enabled не существует"

echo "\\n📋 5. Основная конфигурация nginx:"
cat /etc/nginx/nginx.conf | grep -E "(include|server_name|listen)" | head -10

echo "\\n📋 6. Текущий статус nginx:"
systemctl status nginx --no-pager -l | head -5

echo "\\n📋 7. Проверка синтаксиса:"
nginx -t 2>&1 || echo "❌ Синтаксис некорректен"

echo "\\n🎉 Диагностика завершена!"