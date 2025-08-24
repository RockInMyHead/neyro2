#!/bin/bash

echo "🚀 Запуск backend сервера..."

# Переходим в директорию проекта
cd /home/neyro/neyro2

# Проверяем, запущен ли уже сервер
if pgrep -f "uvicorn.*app:app" > /dev/null; then
    echo "⚠️  Сервер уже запущен. Останавливаем..."
    pkill -f "uvicorn.*app:app"
    sleep 2
fi

# Активируем виртуальное окружение если есть
if [ -d "venv" ]; then
    echo "🔧 Активация виртуального окружения..."
    source venv/bin/activate
fi

# Создаем директории если их нет
mkdir -p images
mkdir -p music

# Проверяем зависимости
echo "📦 Проверка зависимостей..."
if ! python3 -c "import fastapi" 2>/dev/null; then
    echo "❌ FastAPI не установлен. Устанавливаем..."
    pip install -r requirements.txt
fi

# Запускаем сервер
echo "🚀 Запуск сервера на порту 8003..."
export PYTHONPATH=/app
nohup uvicorn app:app --host 0.0.0.0 --port 8003 > backend.log 2>&1 &

# Ждем запуска
echo "⏳ Ожидание запуска сервера..."
sleep 5

# Проверяем статус
if pgrep -f "uvicorn.*app:app" > /dev/null; then
    echo "✅ Сервер успешно запущен!"
    echo "📊 PID: $(pgrep -f 'uvicorn.*app:app')"
    echo "🌐 URL: http://localhost:8003"
    echo "📋 Логи: tail -f backend.log"
else
    echo "❌ Ошибка запуска сервера"
    echo "📋 Проверьте логи: cat backend.log"
    exit 1
fi

# Проверяем доступность
echo "🔍 Проверка доступности..."
if curl -s http://localhost:8003/docs > /dev/null; then
    echo "✅ API доступен на localhost:8003"
else
    echo "❌ API недоступен на localhost:8003"
fi

echo ""
echo "🎉 Backend сервер запущен!"
echo "🌐 Проверьте ваш сайт: http://194.87.226.56" 