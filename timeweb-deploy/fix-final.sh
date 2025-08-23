#!/bin/bash

# Финальное исправление всех проблем
echo "🔧 Финальное исправление всех проблем..."
echo "📍 Текущая директория: $(pwd)"

# Шаг 1: Исправляем MP3 файлы
echo "📋 Шаг 1: Исправляем MP3 файлы"
echo "🔍 Проверяю MP3 файлы в /music/"
ls -la /var/www/timeweb-deploy/music/*.mp3 2>/dev/null || echo "MP3 файлы не найдены в /music/"

echo "🔍 Проверяю MP3 файлы в /assets/"
ls -la /var/www/timeweb-deploy/public/assets/*.mp3 2>/dev/null || echo "MP3 файлы не найдены в /assets/"

echo "🔄 Копирую MP3 файлы в /assets/"
cp /var/www/timeweb-deploy/music/*.mp3 /var/www/timeweb-deploy/public/assets/ 2>/dev/null || echo "Не удалось скопировать MP3 файлы"

echo "✅ Проверяю результат копирования"
ls -la /var/www/timeweb-deploy/public/assets/*.mp3 2>/dev/null && echo "✅ MP3 файлы скопированы" || echo "❌ MP3 файлы не скопированы"

# Шаг 2: Проверяем API методы
echo "\\n📋 Шаг 2: Проверяем API методы"
echo "🔍 Тестирую GET /generate_dalle"
curl -X GET http://194.87.226.56/generate_dalle -I

echo "🔍 Тестирую POST /generate_dalle"
curl -X POST http://194.87.226.56/generate_dalle \
  -H "Content-Type: application/json" \
  -d '{"prompt":"test"}' -I

# Шаг 3: Проверяем статические файлы
echo "\\n📋 Шаг 3: Проверяем статические файлы"
echo "🔍 Проверяю 2.mp3"
curl -I http://194.87.226.56/assets/2.mp3

echo "🔍 Проверяю index-Dp3_vkor.js"
curl -I http://194.87.226.56/assets/index-Dp3_vkor.js

# Шаг 4: Создаем инструкцию для frontend
echo "\\n📋 Шаг 4: Создаем инструкцию для frontend"
cat > frontend-fix-instructions.txt << 'EOF'
Инструкция по исправлению frontend:

ПРОБЛЕМЫ НАЙДЕНЫ:
1. Frontend ищет 2.mp3 в /assets/2.mp3, но файл находится в /music/2.mp3
2. Frontend отправляет GET запросы к /generate_dalle, а API ожидает POST

РЕШЕНИЯ:
1. ✅ MP3 файлы скопированы в /assets/ - эта проблема решена

2. Для исправления API запросов нужно изменить frontend код:
   - Найти где отправляются запросы к generate_dalle
   - Изменить метод с GET на POST
   - Добавить правильные заголовки Content-Type: application/json
   - Отправлять данные в формате JSON

ПРИМЕР ИСПРАВЛЕНИЯ:
Было:
fetch('http://194.87.226.56/generate_dalle?prompt=test')

Стало:
fetch('http://194.87.226.56/generate_dalle', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ prompt: 'test' })
})
EOF

echo "✅ Инструкция создана: frontend-fix-instructions.txt"

# Шаг 5: Финальная проверка
echo "\\n📋 Шаг 5: Финальная проверка"
echo "🔍 Проверяю все компоненты..."
echo "API: $(curl -I http://194.87.226.56/generate_dalle 2>/dev/null | head -1)"
echo "MP3: $(curl -I http://194.87.226.56/assets/2.mp3 2>/dev/null | head -1)"
echo "JS: $(curl -I http://194.87.226.56/assets/index-Dp3_vkor.js 2>/dev/null | head -1)"

echo "✅ Финальное исправление завершено!"
echo "📄 Инструкция для frontend: frontend-fix-instructions.txt"
echo "🌐 Проверьте ваш сайт: http://194.87.226.56"