#!/bin/bash

# Универсальный скрипт исправления nginx для TimeWeb
# Работает с любой структурой конфигурации

echo "🔧 Универсальное исправление nginx для TimeWeb..."
echo "📍 Текущая директория: $(pwd)"

# Функция для поиска конфигурационного файла
find_config_file() {
    echo "🔍 Ищу конфигурационный файл..."

    # Проверим sites-available
    if [ -d "/etc/nginx/sites-available" ]; then
        CONFIG_FILE="/etc/nginx/sites-available/default"
        if [ -f "$CONFIG_FILE" ]; then
            echo "✅ Найден: $CONFIG_FILE"
            echo "$CONFIG_FILE"
            return 0
        fi
    fi

    # Проверим sites-enabled
    if [ -d "/etc/nginx/sites-enabled" ]; then
        for file in /etc/nginx/sites-enabled/*; do
            if [ -f "$file" ]; then
                echo "✅ Найден: $file"
                echo "$file"
                return 0
            fi
        done
    fi

    # Проверим основной nginx.conf
    if [ -f "/etc/nginx/nginx.conf" ]; then
        echo "✅ Использую основной: /etc/nginx/nginx.conf"
        echo "/etc/nginx/nginx.conf"
        return 0
    fi

    echo "❌ Конфигурационный файл не найден"
    return 1
}

# Функция для резервного копирования
backup_config() {
    local config_file="$1"
    local backup_file="${config_file}.backup.$(date +%Y%m%d_%H%M%S)"

    echo "📦 Создаю резервную копию: $backup_file"
    if sudo cp "$config_file" "$backup_file"; then
        echo "✅ Резервная копия создана"
        echo "$backup_file"
        return 0
    else
        echo "❌ Не удалось создать резервную копию"
        return 1
    fi
}

# Функция для применения конфигурации
apply_config() {
    local config_file="$1"
    local backup_file="$2"

    echo "🔧 Применяю конфигурацию..."

    # Определяем, какой файл использовать
    if [ -f "nginx-fixed.conf" ]; then
        NEW_CONFIG="nginx-fixed.conf"
    elif [ -f "nginx-simple.conf" ]; then
        NEW_CONFIG="nginx-simple.conf"
    else
        echo "❌ Файл конфигурации не найден в текущей директории"
        return 1
    fi

    echo "📄 Использую: $NEW_CONFIG"

    # Создаем новую конфигурацию
    if [ "$config_file" = "/etc/nginx/nginx.conf" ]; then
        # Для основного файла создаем новую секцию server
        echo "🔧 Обновляю основной nginx.conf..."

        # Создаем временный файл с новой конфигурацией
        sudo cp "$NEW_CONFIG" "/tmp/nginx_server_block.conf"

        # Добавляем server блок в конец файла (перед последней скобкой)
        sudo sed -i '$ d' "$config_file"  # Удаляем последнюю строку (})
        sudo cat "/tmp/nginx_server_block.conf" >> "$config_file"
        echo "}" >> "$config_file"
    else
        # Для обычного файла заменяем полностью
        sudo cp "$NEW_CONFIG" "$config_file"
    fi

    echo "✅ Конфигурация применена"
    return 0
}

# Функция для проверки синтаксиса
check_syntax() {
    echo "✅ Проверяю синтаксис nginx..."

    if sudo nginx -t; then
        echo "✅ Синтаксис корректен"
        return 0
    else
        echo "❌ Ошибка в синтаксисе"
        return 1
    fi
}

# Функция для перезапуска nginx
restart_nginx() {
    echo "🔄 Перезапускаю nginx..."

    if sudo systemctl reload nginx; then
        echo "✅ Nginx перезапущен успешно"
        return 0
    else
        echo "❌ Ошибка при перезапуске nginx"
        return 1
    fi
}

# Основная логика
main() {
    # Шаг 1: Найти конфигурационный файл
    CONFIG_FILE=$(find_config_file)
    if [ $? -ne 0 ]; then
        echo "❌ Не найден конфигурационный файл"
        exit 1
    fi

    # Шаг 2: Создать резервную копию
    BACKUP_FILE=$(backup_config "$CONFIG_FILE")
    if [ $? -ne 0 ]; then
        echo "❌ Не удалось создать резервную копию"
        exit 1
    fi

    # Шаг 3: Применить новую конфигурацию
    if ! apply_config "$CONFIG_FILE" "$BACKUP_FILE"; then
        echo "❌ Не удалось применить конфигурацию"
        echo "🔧 Восстанавливаю резервную копию..."
        sudo cp "$BACKUP_FILE" "$CONFIG_FILE"
        exit 1
    fi

    # Шаг 4: Проверить синтаксис
    if ! check_syntax; then
        echo "🔧 Восстанавливаю резервную копию..."
        sudo cp "$BACKUP_FILE" "$CONFIG_FILE"
        exit 1
    fi

    # Шаг 5: Перезапустить nginx
    if ! restart_nginx; then
        echo "🔧 Восстанавливаю резервную копию..."
        sudo cp "$BACKUP_FILE" "$CONFIG_FILE"
        sudo systemctl reload nginx
        exit 1
    fi

    # Шаг 6: Проверить backend
    echo "🔍 Проверяю backend сервер..."
    if curl -s http://127.0.0.1:8000/docs > /dev/null; then
        echo "✅ Backend сервер работает"
    else
        echo "❌ Backend сервер не отвечает"
        echo "🔧 Попытка запустить backend..."
        nohup python app.py > backend.log 2>&1 &
        sleep 5
        if curl -s http://127.0.0.1:8000/docs > /dev/null; then
            echo "✅ Backend сервер успешно запущен"
        else
            echo "❌ Не удалось запустить backend"
        fi
    fi

    # Шаг 7: Финальная проверка
    echo "🔍 Проверяю доступность API..."
    sleep 2
    curl -I http://194.87.226.56/generate_dalle

    echo "✅ Исправления применены успешно!"
    echo "🌐 Теперь ваш сайт должен работать на http://194.87.226.56"
    echo "📁 Резервная копия сохранена: $BACKUP_FILE"
}

# Запуск основной функции
main "$@"