#!/bin/bash
cd /home/neyro/neyro2/timeweb-deploy

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

# Проверяем API ключи перед запуском
echo "Checking API keys..."
python3 -c "
import os
from dotenv import load_dotenv
load_dotenv()

stability_key = os.getenv('STABILITY_API_KEY', '')
openai_key = os.getenv('OPENAI_API_KEY', '')

if stability_key and stability_key != 'sk-9BlZisDvEvF9Jewp4AbNOfay24M44gTGdCTRAeN9WnCX5uld':
    print('✅ STABILITY_API_KEY loaded')
else:
    print('❌ STABILITY_API_KEY not configured or using test key')

if openai_key and openai_key != 'sk-your-openai-key-here':
    print('✅ OPENAI_API_KEY loaded')
else:
    print('❌ OPENAI_API_KEY not configured (optional)')
"

# Запустить FastAPI сервер
uvicorn app:app --host 0.0.0.0 --port 8003
