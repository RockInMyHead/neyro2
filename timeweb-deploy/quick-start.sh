#!/bin/bash

# Быстрый старт исправления nginx для TimeWeb
echo "🚀 Быстрый старт исправления nginx..."
echo "📍 Текущая директория: $(pwd)"

# Шаг 1: Сделаем все скрипты исполняемыми
echo "📋 Шаг 1: Подготовка скриптов"
chmod +x diagnose-nginx.sh
chmod +x manual-fix.sh
chmod +x fix-nginx-universal.sh
echo "✅ Скрипты подготовлены"

# Шаг 2: Запустим диагностику
echo "📋 Шаг 2: Диагностика"
sudo ./diagnose-nginx.sh

# Шаг 3: Спросим пользователя какой метод использовать
echo "📋 Шаг 3: Выбор метода исправления"
echo "Выберите метод исправления:"
echo "1) Ручное исправление (для файла /etc/nginx/sites-enabled/neyro)"
echo "2) Универсальное исправление (автоматический поиск конфига)"
echo "3) Пропустить исправления и только запустить backend"

read -p "Введите номер метода (1-3): " choice

case $choice in
    1)
        echo "🔧 Запускаю ручное исправление..."
        sudo ./manual-fix.sh
        ;;
    2)
        echo "🔧 Запускаю универсальное исправление..."
        sudo ./fix-nginx-universal.sh
        ;;
    3)
        echo "⏭️  Пропускаю исправления nginx"
        ;;
    *)
        echo "❌ Неверный выбор, использую ручное исправление"
        sudo ./manual-fix.sh
        ;;
esac

# Шаг 4: Финальная проверка
echo "📋 Шаг 4: Финальная проверка"
echo "🔍 Проверяю backend сервер..."
if curl -s http://127.0.0.1:8000/docs > /dev/null; then
    echo "✅ Backend сервер работает"
else
    echo "❌ Backend сервер не отвечает"
    echo "🔧 Попытка запустить backend..."
    nohup python app.py > backend.log 2>&1 &
    sleep 3
    if curl -s http://127.0.0.1:8000/docs > /dev/null; then
        echo "✅ Backend сервер успешно запущен"
    else
        echo "❌ Не удалось запустить backend"
        echo "📄 Логи: $(cat backend.log 2>/dev/null || echo 'Лог файл не найден')"
    fi
fi

echo "🔍 Проверяю API доступность..."
curl -I http://194.87.226.56/generate_dalle

echo "✅ Быстрый старт завершен!"
echo "🌐 Проверьте ваш сайт: http://194.87.226.56"
echo "📄 Подробная инструкция: QUICK-FIX.md"