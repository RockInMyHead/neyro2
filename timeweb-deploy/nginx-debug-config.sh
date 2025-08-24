#!/bin/bash

# Скрипт для диагностики и исправления nginx конфигурации
echo "🔍 Диагностика nginx конфигурации..."

# Показываем содержимое проблемного файла
echo "📄 Содержимое файла neyro:"
echo "========================================"
sudo cat /etc/nginx/sites-enabled/neyro
echo "========================================"

# Показываем строку с ошибкой
echo ""
echo "🔍 Строка 69 (proxy_http_version):"
sudo sed -n '69p' /etc/nginx/sites-enabled/neyro

echo ""
echo "🔍 Строка 70 (proxy_set_header):"
sudo sed -n '70p' /etc/nginx/sites-enabled/neyro

echo ""
echo "🔍 Контекст строк 65-75:"
sudo sed -n '65,75p' /etc/nginx/sites-enabled/neyro