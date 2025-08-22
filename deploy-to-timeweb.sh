#!/bin/bash

# Скрипт для деплоя на TimeWeb
echo "🚀 Подготовка к деплою на TimeWeb..."

# 1. Создать production build frontend
echo "📦 Создание production build frontend..."
cd frontend
NODE_ENV=production npm run build
cd ..

# 2. Копировать необходимые файлы
echo "📋 Копирование файлов для деплоя..."

# Создать директорию для деплоя
mkdir -p timeweb-deploy

# Копировать frontend build
cp -r frontend/dist timeweb-deploy/public

# Копировать backend
cp -r app.py timeweb-deploy/
cp -r shemas.py timeweb-deploy/ 2>/dev/null || echo "Файл shemas.py не найден"

# Копировать необходимые директории
cp -r images timeweb-deploy/
cp -r music timeweb-deploy/
cp -r promts timeweb-deploy/ 2>/dev/null || echo "Директория promts не найдена"

# 3. Создать конфигурационные файлы для TimeWeb
echo "⚙️  Создание конфигурационных файлов..."

# Создать requirements.txt для Python зависимостей
cat > timeweb-deploy/requirements.txt << 'EOF'
fastapi==0.104.1
uvicorn[standard]==0.24.0
python-dotenv==1.0.0
httpx==0.25.2
requests==2.31.0
beautifulsoup4==4.13.4
Pillow==10.1.0
python-multipart==0.0.6
transliterate==1.10.2
deep-translator==1.11.4
EOF

# Создать .env файл для production
cat > timeweb-deploy/.env << 'EOF'
OPENAI_API_KEY=your_openai_key_here
STABILITY_API_KEY=your_stability_key_here
EOF

# Создать nginx конфигурацию
cat > timeweb-deploy/nginx.conf << 'EOF'
server {
    listen 80;
    server_name your-domain.com;
    root /var/www/timeweb-deploy/public;

    # Статические файлы
    location / {
        try_files $uri $uri/ /index.html;
        add_header Cache-Control "no-cache, no-store, must-revalidate";
    }

    # API прокси
    location /api/ {
        proxy_pass http://localhost:8000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # WebSocket прокси
    location /session/ {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }
}
EOF

# Создать startup скрипт
cat > timeweb-deploy/start.sh << 'EOF'
#!/bin/bash
cd /var/www/timeweb-deploy

# Активировать виртуальное окружение (если есть)
# source venv/bin/activate

# Запустить FastAPI сервер
uvicorn app:app --host 0.0.0.0 --port 8000 &
EOF

chmod +x timeweb-deploy/start.sh

# 4. Создать инструкции по деплою
cat > timeweb-deploy/README.md << 'EOF'
# Инструкции по деплою на TimeWeb

## 1. Подготовка

1. Закажите хостинг на TimeWeb с поддержкой Python
2. Убедитесь что у вас есть доступ по SSH/FTP
3. Загрузите содержимое папки `timeweb-deploy` на ваш хостинг

## 2. Настройка окружения

1. В файле `.env` укажите ваши API ключи:
   - `OPENAI_API_KEY` - ваш OpenAI API ключ
   - `STABILITY_API_KEY` - ваш Stability AI API ключ

2. Установите Python зависимости:
   ```bash
   pip install -r requirements.txt
   ```

## 3. Настройка Nginx

1. Скопируйте `nginx.conf` в `/etc/nginx/sites-available/`
2. Создайте символическую ссылку:
   ```bash
   sudo ln -s /etc/nginx/sites-available/nginx.conf /etc/nginx/sites-enabled/
   ```

3. Перезапустите Nginx:
   ```bash
   sudo systemctl restart nginx
   ```

## 4. Запуск приложения

1. Сделайте скрипт запуска исполняемым:
   ```bash
   chmod +x start.sh
   ```

2. Запустите приложение:
   ```bash
   ./start.sh
   ```

## 5. Проверка

- Frontend: `http://ваш-домен.com`
- API: `http://ваш-домен.com/api/debug_openai`

## Важные моменты

- Убедитесь что порт 8000 открыт в firewall
- Настройте SSL сертификат через TimeWeb панель
- Регулярно обновляйте зависимости
EOF

echo "✅ Подготовка к деплою завершена!"
echo "📁 Содержимое папки timeweb-deploy:"
ls -la timeweb-deploy/

echo ""
echo "📋 Следующие шаги:"
echo "1. Загрузите папку timeweb-deploy на ваш TimeWeb хостинг"
echo "2. Настройте переменные окружения в .env файле"
echo "3. Следуйте инструкциям в README.md"