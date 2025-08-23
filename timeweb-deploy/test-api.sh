#!/bin/bash

# Тестирование API и статических файлов
echo "🧪 Тестирование API и статических файлов..."
echo "📍 Текущая директория: $(pwd)"

# Тест 1: Backend API напрямую
echo "📋 Тест 1: Backend API напрямую"
echo "🔍 Проверяю /docs"
curl -s http://127.0.0.1:8000/docs > /dev/null && echo "✅ /docs работает" || echo "❌ /docs не работает"

echo "🔍 Проверяю /generate_dalle с правильными данными"
curl -X POST http://127.0.0.1:8000/generate_dalle \
  -H "Content-Type: application/json" \
  -d '{"prompt":"test prompt","model":"dalle"}' \
  -s | head -c 100
echo "..."

# Тест 2: Nginx прокси
echo "\\n📋 Тест 2: Nginx прокси"
echo "🔍 Проверяю /generate_dalle через nginx"
curl -I http://194.87.226.56/generate_dalle

# Тест 3: Статические файлы
echo "\\n📋 Тест 3: Статические файлы"
echo "🔍 Проверяю /music/2.mp3"
curl -I http://194.87.226.56/music/2.mp3

echo "🔍 Проверяю /assets/index-Dp3_vkor.js"
curl -I http://194.87.226.56/assets/index-Dp3_vkor.js

# Тест 4: OPTIONS запросы
echo "\\n📋 Тест 4: OPTIONS запросы"
echo "🔍 Проверяю OPTIONS для /generate_dalle"
curl -X OPTIONS -I http://194.87.226.56/generate_dalle

# Тест 5: Разные HTTP методы
echo "\\n📋 Тест 5: Разные HTTP методы"
echo "🔍 Проверяю GET /generate_dalle"
curl -X GET -I http://194.87.226.56/generate_dalle

echo "🔍 Проверяю POST /generate_dalle без данных"
curl -X POST -I http://194.87.226.56/generate_dalle

echo "🔍 Проверяю POST /generate_dalle с данными"
curl -X POST -I http://194.87.226.56/generate_dalle \
  -H "Content-Type: application/json" \
  -d '{"prompt":"test"}'

echo "✅ Тестирование завершено!"
echo "🌐 Проверьте ваш сайт: http://194.87.226.56"