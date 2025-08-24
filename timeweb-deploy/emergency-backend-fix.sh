#!/bin/bash

echo "🚨 Экстренное исправление backend проблем..."

# Останавливаем все процессы uvicorn
echo "🛑 Остановка всех процессов uvicorn..."
pkill -f "uvicorn.*app:app" 2>/dev/null
sleep 3

# Переходим в директорию проекта
cd /home/neyro/neyro2

echo "📁 Текущая директория: $(pwd)"

# Проверяем существование файлов
echo "📋 Проверка критических файлов..."
if [ ! -f "app.py" ]; then
    echo "❌ app.py не найден! Проверьте структуру проекта."
    exit 1
fi

if [ ! -f "requirements.txt" ]; then
    echo "❌ requirements.txt не найден! Проверьте структуру проекта."
    exit 1
fi

# Создаем виртуальное окружение если его нет
if [ ! -d "venv" ]; then
    echo "🔧 Создание виртуального окружения..."
    python3 -m venv venv
fi

# Активируем виртуальное окружение
echo "🔧 Активация виртуального окружения..."
source venv/bin/activate

# Обновляем pip
echo "📦 Обновление pip..."
pip install --upgrade pip --quiet

# Устанавливаем зависимости
echo "📦 Установка зависимостей..."
pip install -r requirements.txt --quiet

# Проверяем установку критических пакетов
echo "🔍 Проверка установки пакетов..."
python3 -c "
import sys
print(f'Python: {sys.version}')

try:
    import fastapi
    print(f'✅ FastAPI: {fastapi.__version__}')
except ImportError as e:
    print(f'❌ FastAPI: {e}')
    sys.exit(1)

try:
    import uvicorn
    print(f'✅ Uvicorn: {uvicorn.__version__}')
except ImportError as e:
    print(f'❌ Uvicorn: {e}')
    sys.exit(1)
"

if [ $? -ne 0 ]; then
    echo "❌ Критические пакеты не установлены!"
    exit 1
fi

# Создаем директории
echo "📁 Создание необходимых директорий..."
mkdir -p images
mkdir -p music
mkdir -p logs

# Очищаем старые логи
echo "🧹 Очистка старых логов..."
rm -f backend.log
rm -f logs/*.log

# Запускаем сервер с подробным логированием
echo "🚀 Запуск backend сервера..."
nohup uvicorn app:app --host 0.0.0.0 --port 8003 --log-level debug > backend.log 2>&1 &

# Ждем запуска
echo "⏳ Ожидание запуска сервера..."
sleep 15

# Проверяем результат
if pgrep -f "uvicorn.*app:app" > /dev/null; then
    echo "✅ Backend запущен!"
    echo "📊 PID: $(pgrep -f 'uvicorn.*app:app')"
    
    # Проверяем доступность
    echo "🔍 Проверка доступности API..."
    if curl -s --connect-timeout 10 http://localhost:8003/docs > /dev/null; then
        echo "✅ API доступен на localhost:8003"
        
        # Проверяем через nginx
        echo "🌐 Проверка через nginx..."
        if curl -s --connect-timeout 10 http://194.87.226.56/generate_dalle > /dev/null; then
            echo "✅ API доступен через nginx!"
            echo "🎉 Проблема решена!"
        else
            echo "❌ API недоступен через nginx"
            echo "📋 Проверяем nginx логи..."
            journalctl -u nginx --no-pager -l | tail -10
        fi
    else
        echo "❌ API недоступен на localhost:8003"
        echo "📋 Логи backend:"
        tail -30 backend.log
    fi
else
    echo "❌ Backend не запустился!"
    echo "📋 Логи backend:"
    tail -30 backend.log
    exit 1
fi

# Показываем статус
echo ""
echo "📊 Финальный статус:"
echo "📍 Процессы uvicorn:"
ps aux | grep "uvicorn.*app:app" | grep -v grep

echo ""
echo "📍 Порт 8003:"
netstat -tlnp | grep :8003

echo ""
echo "📍 Логи backend (последние 10 строк):"
tail -10 backend.log

echo ""
echo "🎉 Экстренное исправление завершено!"
echo "🌐 Проверьте ваш сайт: http://194.87.226.56"
echo "📋 Для мониторинга используйте: tail -f backend.log" 