#!/bin/bash

echo "🔍 Диагностика ошибки 405 Not Allowed для /generate_dalle"
echo "=========================================================="

# Проверяем статус backend сервера
echo "1. Проверка backend сервера (порт 8000):"
if netstat -tlnp | grep :8000 > /dev/null; then
    echo "✅ Backend сервер работает на порту 8000"
    netstat -tlnp | grep :8000
else
    echo "❌ Backend сервер НЕ работает на порту 8000"
    echo "   Запустите: cd /home/neyro/neyro2/timeweb-deploy && ./start.sh"
fi

echo ""

# Проверяем процессы uvicorn
echo "2. Проверка процессов uvicorn:"
uvicorn_processes=$(ps aux | grep uvicorn | grep -v grep)
if [ -n "$uvicorn_processes" ]; then
    echo "✅ Uvicorn процессы найдены:"
    echo "$uvicorn_processes"
else
    echo "❌ Uvicorn процессы не найдены"
fi

echo ""

# Проверяем nginx статус
echo "3. Проверка nginx:"
if systemctl is-active nginx > /dev/null; then
    echo "✅ Nginx работает"
    echo "   Статус: $(systemctl status nginx --no-pager -l | head -3)"
else
    echo "❌ Nginx не работает"
fi

echo ""

# Проверяем nginx конфигурацию
echo "4. Проверка nginx конфигурации:"
if nginx -t > /dev/null 2>&1; then
    echo "✅ Nginx конфигурация валидна"
else
    echo "❌ Nginx конфигурация содержит ошибки:"
    nginx -t
fi

echo ""

# Проверяем доступность backend API
echo "5. Тестирование backend API:"
echo "   Проверка /docs:"
if curl -s http://localhost:8000/docs > /dev/null; then
    echo "   ✅ FastAPI docs доступны"
else
    echo "   ❌ FastAPI docs недоступны"
fi

echo "   Проверка /generate_dalle:"
if curl -s -X POST http://localhost:8000/generate_dalle -H "Content-Type: application/json" -d '{"prompt":"test"}' > /dev/null 2>&1; then
    echo "   ✅ /generate_dalle отвечает (возможно ошибка валидации, но эндпоинт работает)"
else
    echo "   ❌ /generate_dalle не отвечает"
fi

echo ""

# Проверяем логи nginx
echo "6. Последние ошибки nginx:"
echo "   Последние 10 строк error.log:"
if [ -f /var/log/nginx/error.log ]; then
    tail -10 /var/log/nginx/error.log
else
    echo "   ❌ Файл /var/log/nginx/error.log не найден"
fi

echo ""

# Проверяем доступность через nginx
echo "7. Тестирование через nginx:"
echo "   Проверка /generate_dalle через nginx:"
nginx_response=$(curl -s -X POST http://194.87.226.56/generate_dalle -H "Content-Type: application/json" -d '{"prompt":"test"}' 2>&1)
if echo "$nginx_response" | grep -q "405 Not Allowed"; then
    echo "   ❌ Получаем 405 Not Allowed - проблема в nginx конфигурации"
    echo "   Ответ: $nginx_response"
elif echo "$nginx_response" | grep -q "error\|Error"; then
    echo "   ⚠️  Получаем ошибку, но не 405: $nginx_response"
else
    echo "   ✅ Nginx проксирует запрос успешно"
fi

echo ""

# Проверяем права доступа к файлам
echo "8. Проверка прав доступа:"
echo "   Директория timeweb-deploy:"
ls -la /home/neyro/neyro2/timeweb-deploy/ | head -5

echo "   Nginx конфигурация:"
ls -la /home/neyro/neyro2/timeweb-deploy/nginx.conf

echo ""

# Рекомендации
echo "📋 РЕКОМЕНДАЦИИ ПО ИСПРАВЛЕНИЮ:"
echo "=================================="

if ! netstat -tlnp | grep :8000 > /dev/null; then
    echo "1. 🚨 Запустите backend сервер:"
    echo "   cd /home/neyro/neyro2/timeweb-deploy && ./start.sh"
fi

if ! systemctl is-active nginx > /dev/null; then
    echo "2. 🚨 Запустите nginx:"
    echo "   sudo systemctl start nginx"
fi

if ! nginx -t > /dev/null 2>&1; then
    echo "3. 🚨 Исправьте nginx конфигурацию и перезапустите:"
    echo "   sudo nginx -t"
    echo "   sudo systemctl reload nginx"
fi

echo "4. 🔄 Перезапустите nginx после исправлений:"
echo "   sudo systemctl reload nginx"

echo "5. 🔄 Перезапустите backend после исправлений:"
echo "   pkill -f uvicorn && cd /home/neyro/neyro2/timeweb-deploy && ./start.sh"

echo ""
echo "=========================================================="
echo "Диагностика завершена" 