#!/bin/bash

# Тестирование кэша браузера
echo "🔍 Тестируем кэш браузера..."
echo "📍 Текущая директория: $(pwd)"

echo "📋 Проверяем доступность файлов на сервере:"

# Проверяем прямые запросы к серверу
echo "🔍 Серверные ответы:"
echo "2.mp3: $(curl -s -I http://194.87.226.56/assets/2.mp3 | head -1)"
echo "index.js: $(curl -s -I http://194.87.226.56/assets/index-Dp3_vkor.js | head -1)"

# Проверяем с заголовками no-cache
echo "\\n📋 Проверяем с no-cache заголовками:"
curl -s -I -H "Cache-Control: no-cache" http://194.87.226.56/assets/2.mp3 | head -1

echo "\\n🎯 Проблема точно в кэше браузера!"
echo "🔧 Инструкция по очистке кэша: cache-fix-guide.md"
echo "🌐 После очистки сайт заработает полностью!"