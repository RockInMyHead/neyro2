#!/bin/bash

# Активируем виртуальное окружение если есть
if [ -d "venv" ]; then
    source venv/bin/activate
fi

# Создаем директории если их нет
mkdir -p images
mkdir -p music

# Запускаем сервер с переменными окружения
export PYTHONPATH=/app
uvicorn app:app --host 0.0.0.0 --port ${PORT:-8000}