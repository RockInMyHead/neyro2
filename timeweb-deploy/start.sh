#!/bin/bash
cd /var/www/timeweb-deploy

# Load environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk 'NF')
fi

# Активировать виртуальное окружение (если есть)
if [ -d "venv" ]; then
    source venv/bin/activate
fi

# Print loaded environment variables (without sensitive data)
echo "Starting Neuro Event Server..."
echo "STABILITY_TIMEOUT_SECONDS: $STABILITY_TIMEOUT_SECONDS"
echo "API_BASE_URL: $API_BASE_URL"

# Запустить FastAPI сервер
uvicorn app:app --host 0.0.0.0 --port 8000
