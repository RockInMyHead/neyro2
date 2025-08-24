#!/bin/bash

echo "🔍 Глубокая диагностика backend проблем..."

echo ""
echo "=== 1. ПРОВЕРКА СИСТЕМНЫХ РЕСУРСОВ ==="
echo "💾 Память:"
free -h

echo ""
echo "💿 Дисковое пространство:"
df -h

echo ""
echo "🔥 CPU и процессы:"
top -bn1 | head -10

echo ""
echo "=== 2. ПРОВЕРКА СЕТИ И ПОРТОВ ==="
echo "🌐 Сетевые соединения:"
netstat -tlnp | grep -E ":(80|8003|8000)"

echo ""
echo "🔒 Firewall статус:"
ufw status 2>/dev/null || echo "Firewall не настроен"

echo ""
echo "=== 3. ПРОВЕРКА PYTHON И ЗАВИСИМОСТЕЙ ==="
echo "🐍 Python версия:"
python3 --version

echo ""
echo "📦 Установленные пакеты:"
python3 -c "
try:
    import fastapi
    print('✅ FastAPI:', fastapi.__version__)
except ImportError:
    print('❌ FastAPI не установлен')

try:
    import uvicorn
    print('✅ Uvicorn:', uvicorn.__version__)
except ImportError:
    print('❌ Uvicorn не установлен')

try:
    import requests
    print('✅ Requests:', requests.__version__)
except ImportError:
    print('❌ Requests не установлен')
"

echo ""
echo "=== 4. ПРОВЕРКА ПРОЦЕССОВ ==="
echo "🔄 Процессы uvicorn:"
ps aux | grep -E "uvicorn|python.*app" | grep -v grep

echo ""
echo "🔍 Процессы на порту 8003:"
lsof -i :8003 2>/dev/null || echo "Порт 8003 свободен"

echo ""
echo "=== 5. ПРОВЕРКА ФАЙЛОВ И ПРАВ ==="
echo "📁 Структура проекта:"
ls -la /home/neyro/neyro2/

echo ""
echo "📄 Файл app.py:"
if [ -f "/home/neyro/neyro2/app.py" ]; then
    echo "✅ app.py существует"
    ls -la /home/neyro/neyro2/app.py
    echo "📋 Первые строки app.py:"
    head -5 /home/neyro/neyro2/app.py
else
    echo "❌ app.py не найден"
fi

echo ""
echo "📋 requirements.txt:"
if [ -f "/home/neyro/neyro2/requirements.txt" ]; then
    echo "✅ requirements.txt существует"
    ls -la /home/neyro/neyro2/requirements.txt
else
    echo "❌ requirements.txt не найден"
fi

echo ""
echo "=== 6. ПРОВЕРКА ВИРТУАЛЬНОГО ОКРУЖЕНИЯ ==="
echo "🔧 Виртуальное окружение:"
if [ -d "/home/neyro/neyro2/venv" ]; then
    echo "✅ venv существует"
    ls -la /home/neyro/neyro2/venv/bin/python*
else
    echo "❌ venv не найден"
fi

echo ""
echo "=== 7. ПРОВЕРКА NGINX ==="
echo "📊 Статус nginx:"
systemctl status nginx --no-pager -l

echo ""
echo "🔍 Nginx конфигурация:"
nginx -t

echo ""
echo "📋 Nginx логи (последние 20 строк):"
journalctl -u nginx --no-pager -l | tail -20

echo ""
echo "=== 8. ПРОВЕРКА BACKEND API ==="
echo "🔗 Прямое подключение к localhost:8003:"
if curl -s --connect-timeout 5 http://localhost:8003/docs > /dev/null; then
    echo "✅ Backend доступен на localhost:8003"
else
    echo "❌ Backend недоступен на localhost:8003"
fi

echo ""
echo "🌐 Проверка через nginx:"
if curl -s --connect-timeout 5 http://194.87.226.56/generate_dalle > /dev/null; then
    echo "✅ API доступен через nginx"
else
    echo "❌ API недоступен через nginx"
fi

echo ""
echo "=== 9. ПОПЫТКА ЗАПУСКА BACKEND ==="
echo "🚀 Попытка запуска backend..."

cd /home/neyro/neyro2

# Останавливаем существующие процессы
pkill -f "uvicorn.*app:app" 2>/dev/null
sleep 2

# Активируем venv если есть
if [ -d "venv" ]; then
    echo "🔧 Активация venv..."
    source venv/bin/activate
fi

# Устанавливаем зависимости если нужно
echo "📦 Проверка зависимостей..."
pip install -r requirements.txt --quiet

# Запускаем сервер
echo "🚀 Запуск uvicorn..."
nohup uvicorn app:app --host 0.0.0.0 --port 8003 > backend.log 2>&1 &

# Ждем запуска
echo "⏳ Ожидание запуска..."
sleep 10

# Проверяем результат
if pgrep -f "uvicorn.*app:app" > /dev/null; then
    echo "✅ Backend запущен!"
    echo "📊 PID: $(pgrep -f 'uvicorn.*app:app')"
    
    # Проверяем доступность
    if curl -s --connect-timeout 5 http://localhost:8003/docs > /dev/null; then
        echo "✅ API доступен на localhost:8003"
    else
        echo "❌ API все еще недоступен"
        echo "📋 Логи backend:"
        tail -20 backend.log
    fi
else
    echo "❌ Backend не запустился"
    echo "📋 Логи backend:"
    tail -20 backend.log
fi

echo ""
echo "=== 10. ФИНАЛЬНАЯ ПРОВЕРКА ==="
echo "🔍 Проверка через nginx после запуска:"
if curl -s --connect-timeout 5 http://194.87.226.56/generate_dalle > /dev/null; then
    echo "✅ API теперь доступен через nginx!"
else
    echo "❌ API все еще недоступен через nginx"
    echo "📋 Последние логи nginx:"
    journalctl -u nginx --no-pager -l | tail -10
fi

echo ""
echo "🎉 Диагностика завершена!"
echo "📋 Если проблемы сохраняются, проверьте логи:"
echo "   - Backend: tail -f /home/neyro/neyro2/backend.log"
echo "   - Nginx: journalctl -u nginx -f" 