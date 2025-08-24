#!/bin/bash

# Скрипт для проверки статуса сервера после исправлений

echo "🔍 Проверка статуса сервера TimeWeb..."
echo "🌐 URL: http://194.87.226.56"
echo ""

# Проверка 1: Доступность главной страницы
echo "📋 Проверка 1: Главная страница"
RESPONSE=$(curl -I http://194.87.226.56 2>/dev/null | head -1)
if echo "$RESPONSE" | grep -q "200 OK"; then
    echo "✅ Главная страница доступна"
else
    echo "❌ Главная страница недоступна: $RESPONSE"
fi

# Проверка 2: Музыкальные файлы
echo ""
echo "📋 Проверка 2: Музыкальные файлы"
for i in {1..4}; do
    RESPONSE=$(curl -I http://194.87.226.56/music/${i}.mp3 2>/dev/null | head -1)
    if echo "$RESPONSE" | grep -q "200 OK"; then
        echo "✅ music/${i}.mp3 доступен"
    else
        echo "❌ music/${i}.mp3 недоступен: $RESPONSE"
    fi
done

# Проверка 3: API эндпоинты
echo ""
echo "📋 Проверка 3: API эндпоинты"
ENDPOINTS=("generate_dalle" "session" "enhance_prompt" "ws")

for endpoint in "${ENDPOINTS[@]}"; do
    RESPONSE=$(curl -I http://194.87.226.56/${endpoint} 2>/dev/null | head -1)
    if echo "$RESPONSE" | grep -q "200 OK"; then
        echo "✅ /${endpoint} работает"
    elif echo "$RESPONSE" | grep -q "405"; then
        echo "⚠️  /${endpoint} возвращает 405 (нормально для HEAD)"
    elif echo "$RESPONSE" | grep -q "502"; then
        echo "❌ /${endpoint} возвращает 502 - backend проблема"
    else
        echo "❌ /${endpoint} не отвечает: $RESPONSE"
    fi
done

# Проверка 4: Статические ресурсы
echo ""
echo "📋 Проверка 4: Статические ресурсы"
STATIC_FILES=("assets/index-Dp3_vkor.js" "images/")

for file in "${STATIC_FILES[@]}"; do
    RESPONSE=$(curl -I http://194.87.226.56/${file} 2>/dev/null | head -1)
    if echo "$RESPONSE" | grep -q "200 OK"; then
        echo "✅ /${file} доступен"
    else
        echo "❌ /${file} недоступен: $RESPONSE"
    fi
done

# Проверка 5: Backend сервер
echo ""
echo "📋 Проверка 5: Backend сервер"
if curl -s http://127.0.0.1:8000/docs > /dev/null; then
    echo "✅ Backend сервер работает (локально)"
else
    echo "❌ Backend сервер не отвечает (локально)"
fi

# Проверка 6: CORS заголовки
echo ""
echo "📋 Проверка 6: CORS заголовки"
RESPONSE=$(curl -I -X OPTIONS http://194.87.226.56/generate_dalle 2>/dev/null)
if echo "$RESPONSE" | grep -q "Access-Control-Allow-Origin"; then
    echo "✅ CORS заголовки настроены"
else
    echo "❌ CORS заголовки отсутствуют"
fi

echo ""
echo "🎉 Проверка завершена!"
echo "🌐 Полный отчет доступен выше"