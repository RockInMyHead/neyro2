#!/bin/bash

echo "🔄 Перезапуск сервера Neuro Event..."

# Остановка текущих процессов сервера
echo "🛑 Остановка текущих процессов..."
pkill -f "uvicorn.*app:app" || true
sleep 2

# Переход в директорию проекта
cd "/Users/artembutko/Desktop/Нейро/neuro — копия"

# Активация виртуального окружения если есть
if [ -d "venv" ]; then
    source venv/bin/activate
    echo "✅ Виртуальное окружение активировано"
fi

# Создание директорий если их нет
mkdir -p images
mkdir -p music

# Запуск сервера с правильным портом
echo "🚀 Запуск сервера на порту 8003..."
export PYTHONPATH=/app
uvicorn app:app --host 0.0.0.0 --port 8003 &

echo "✅ Сервер запущен!"
echo "🌐 Проверьте ваш сайт: http://194.87.226.56:8003"
echo "📊 Документация API: http://194.87.226.56:8003/docs"