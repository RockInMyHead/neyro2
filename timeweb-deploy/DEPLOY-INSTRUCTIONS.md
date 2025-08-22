# 🚀 Деплой на TimeWeb - Подробная инструкция

## 📋 Содержание
1. [Подготовка к деплою](#подготовка-к-деплою)
2. [Настройка TimeWeb хостинга](#настройка-timeweb-хостинга)
3. [Загрузка файлов](#загрузка-файлов)
4. [Настройка окружения](#настройка-окружения)
5. [Настройка веб-сервера](#настройка-веб-сервера)
6. [Запуск приложения](#запуск-приложения)
7. [Проверка работы](#проверка-работы)
8. [Устранение проблем](#устранение-проблем)

## 🛠️ Подготовка к деплою

### Требования к хостингу TimeWeb:
- **Операционная система**: Linux (Ubuntu/Debian)
- **Python**: версия 3.8+
- **Веб-сервер**: Nginx или Apache
- **Доступ**: SSH/FTP
- **Свободное место**: минимум 1GB
- **Порты**: 80, 443 (HTTP/HTTPS)

## ⚙️ Настройка TimeWeb хостинга

### 1. Заказ хостинга
1. Перейдите на [timeweb.com](https://timeweb.com)
2. Выберите тариф с поддержкой Python
3. Оформите заказ и получите доступ

### 2. Доступ по SSH
```bash
ssh username@your-domain.com
# или
ssh username@server-ip
```

### 3. Установка системных зависимостей
```bash
# Обновление системы
sudo apt update && sudo apt upgrade -y

# Установка Python и pip
sudo apt install python3 python3-pip python3-venv -y

# Установка Node.js (если нужно для сборки)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Установка Nginx
sudo apt install nginx -y
```

## 📤 Загрузка файлов

### Вариант 1: Через SCP
```bash
# С вашего компьютера
scp -r timeweb-deploy/* username@your-server:/var/www/
```

### Вариант 2: Через FTP
1. Используйте FileZilla или другой FTP клиент
2. Подключитесь к вашему серверу
3. Загрузите содержимое папки `timeweb-deploy` в `/var/www/`

### Вариант 3: Через Git
```bash
# На сервере
cd /var/www/
git clone https://github.com/your-repo/neuro-deploy.git .
```

## 🔧 Настройка окружения

### 1. Настройка переменных окружения
```bash
cd /var/www/timeweb-deploy
nano .env
```

Добавьте ваши API ключи:
```env
OPENAI_API_KEY=sk-your-openai-key-here
STABILITY_API_KEY=sk-your-stability-key-here
```

### 2. Установка Python зависимостей
```bash
# Создание виртуального окружения
python3 -m venv venv

# Активация окружения
source venv/bin/activate

# Установка зависимостей
pip install -r requirements.txt
```

### 3. Оптимизация изображений (опционально)
```bash
# Если установлен ImageMagick
sudo apt install imagemagick -y

# Запуск оптимизации
bash optimize-images.sh
```

## 🌐 Настройка веб-сервера

### Nginx конфигурация

1. Скопируйте конфигурацию:
```bash
sudo cp nginx.conf /etc/nginx/sites-available/your-domain.com
```

2. Создайте символическую ссылку:
```bash
sudo ln -s /etc/nginx/sites-available/your-domain.com /etc/nginx/sites-enabled/
```

3. Удалите дефолтную конфигурацию:
```bash
sudo rm /etc/nginx/sites-enabled/default
```

4. Проверьте конфигурацию:
```bash
sudo nginx -t
```

5. Перезапустите Nginx:
```bash
sudo systemctl restart nginx
sudo systemctl enable nginx
```

### Apache конфигурация (альтернатива)

Если используете Apache, создайте файл конфигурации:
```apache
<VirtualHost *:80>
    ServerName your-domain.com
    DocumentRoot /var/www/timeweb-deploy/public

    <Directory /var/www/timeweb-deploy/public>
        AllowOverride All
        Require all granted
    </Directory>

    ProxyPass /api http://localhost:8000/api
    ProxyPassReverse /api http://localhost:8000/api
</VirtualHost>
```

## 🚀 Запуск приложения

### 1. Сделайте скрипт запуска исполняемым
```bash
chmod +x start.sh
```

### 2. Запустите приложение
```bash
./start.sh
```

### 3. Или запустите вручную
```bash
source venv/bin/activate
uvicorn app:app --host 0.0.0.0 --port 8000
```

### 4. Автозапуск при перезагрузке сервера

Создайте systemd service:
```bash
sudo nano /etc/systemd/system/neuro-app.service
```

Добавьте:
```ini
[Unit]
Description=Neuro Event App
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/var/www/timeweb-deploy
ExecStart=/var/www/timeweb-deploy/venv/bin/uvicorn app:app --host 0.0.0.0 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
```

Включите и запустите:
```bash
sudo systemctl daemon-reload
sudo systemctl enable neuro-app
sudo systemctl start neuro-app
```

## ✅ Проверка работы

### 1. Проверка статических файлов
```
http://your-domain.com
```

### 2. Проверка API
```
http://your-domain.com/api/debug_openai
```

### 3. Проверка статуса сервиса
```bash
sudo systemctl status neuro-app
sudo systemctl status nginx
```

### 4. Проверка логов
```bash
# Nginx логи
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log

# Приложение логи
sudo journalctl -u neuro-app -f
```

## 🔧 Устранение проблем

### Проблема: 502 Bad Gateway
```bash
# Проверьте работает ли приложение
curl http://localhost:8000/debug_openai

# Проверьте Nginx конфигурацию
sudo nginx -t
sudo systemctl restart nginx
```

### Проблема: 404 Not Found
```bash
# Проверьте права доступа
ls -la /var/www/timeweb-deploy/public/

# Проверьте Nginx root директорию
sudo nano /etc/nginx/sites-available/your-domain.com
```

### Проблема: Приложение не запускается
```bash
# Проверьте логи
sudo journalctl -u neuro-app -n 50

# Проверьте Python путь
which python3

# Проверьте виртуальное окружение
source venv/bin/activate && which python
```

### Проблема: Изображения не загружаются
```bash
# Проверьте права на папку images
ls -la /var/www/timeweb-deploy/images/

# Проверьте Nginx конфигурацию для статических файлов
sudo nano /etc/nginx/sites-available/your-domain.com
```

## 📊 Мониторинг и обслуживание

### 1. Проверка использования ресурсов
```bash
# Память
free -h

# Диск
df -h

# Процессы
ps aux | grep uvicorn
```

### 2. Резервное копирование
```bash
# Создание бэкапа
cd /var/www/
tar -czf neuro-backup-$(date +%Y%m%d).tar.gz timeweb-deploy/
```

### 3. Обновление приложения
```bash
# Остановка сервиса
sudo systemctl stop neuro-app

# Обновление файлов
# ... загрузите новые файлы ...

# Установка обновленных зависимостей
source venv/bin/activate
pip install -r requirements.txt

# Запуск сервиса
sudo systemctl start neuro-app
```

## 🎯 Оптимизация производительности

### 1. Настройка Nginx для статических файлов
```nginx
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

### 2. Настройка Gzip сжатия
```nginx
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_proxied any;
gzip_comp_level 6;
gzip_types
    text/plain
    text/css
    text/xml
    text/javascript
    application/json
    application/javascript
    application/xml+rss
    application/atom+xml
    image/svg+xml;
```

### 3. Настройка SSL (Let's Encrypt)
```bash
# Установка certbot
sudo apt install certbot python3-certbot-nginx -y

# Получение сертификата
sudo certbot --nginx -d your-domain.com
```

## 📞 Поддержка

Если возникли проблемы:
1. Проверьте логи приложения и Nginx
2. Убедитесь что все порты открыты
3. Проверьте конфигурацию Nginx
4. Убедитесь что приложение запущено

**TimeWeb поддержка**: support@timeweb.com