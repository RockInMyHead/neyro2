#!/bin/bash
cd /var/www/timeweb-deploy

# Активировать виртуальное окружение (если есть)
# source venv/bin/activate

# Запустить FastAPI сервер
uvicorn app:app --host 0.0.0.0 --port 8000 &
