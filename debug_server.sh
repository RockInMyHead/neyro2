#!/bin/bash

echo "=== Диагностика сервера TimeWeb ==="
echo "Текущая директория: $(pwd)"
echo "Содержимое директории:"
ls -la

echo ""
echo "=== Проверка .env файла ==="
if [ -f ".env" ]; then
    echo "✅ .env файл найден"
    echo "Содержимое .env файла:"
    cat .env
else
    echo "❌ .env файл НЕ найден"
    echo "Создаем .env файл..."
    cat > .env << 'ENV_EOF'
STABILITY_API_KEY=sk-JKzHsKFvaXDx4QJGdkM8DMUiKH9em93G28pWK74Cwn6Cjc5q
OPENAI_API_KEY=your-openai-key-here
ENV_EOF
    echo "✅ .env файл создан"
fi

echo ""
echo "=== Тестируем переменные окружения ==="
python3 test_env.py

echo ""
echo "=== Тестируем API ключ ==="
curl -H "Authorization: Bearer sk-JKzHsKFvaXDx4QJGdkM8DMUiKH9em93G28pWK74Cwn6Cjc5q" https://api.stability.ai/v2beta/stable-image/generate/core -X POST -d '{}' -H "Content-Type: application/json" | head -20

echo ""
echo "=== Перезапускаем приложение ==="
pkill -f uvicorn || true
sleep 2
source venv/bin/activate && uvicorn app:app --host 0.0.0.0 --port 8000 --reload &
sleep 3

echo "✅ Сервер перезапущен"
echo "🌐 Проверьте: http://your-server.com/"
