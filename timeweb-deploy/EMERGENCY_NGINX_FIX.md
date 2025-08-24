# 🚨 Экстренное исправление nginx на TimeWeb

## ❌ Проблема
Nginx не запускается из-за синтаксической ошибки в конфигурации.

## 🚨 Экстренные действия

### Шаг 1: Перейти в правильную директорию
```bash
cd /home/neyro/neyro2/timeweb-deploy
```

### Шаг 2: Диагностика
```bash
chmod +x check-nginx-config.sh
./check-nginx-config.sh
```

### Шаг 3: Принудительное исправление
```bash
chmod +x force-nginx-fix.sh
./force-nginx-fix.sh
```

### Шаг 3.5: Альтернатива - полный сброс nginx
```bash
chmod +x nginx-reset.sh
./nginx-reset.sh
```

### Шаг 4: Если автоматическое исправление не работает

#### 4.1 Остановить nginx
```bash
systemctl stop nginx
```

#### 4.2 Удалить старую конфигурацию
```bash
rm -f /etc/nginx/sites-enabled/neyro
rm -f /etc/nginx/sites-available/neyro
```

#### 4.3 Скопировать новую конфигурацию
```bash
cp /home/neyro/neyro2/timeweb-deploy/nginx-simple.conf /etc/nginx/sites-available/neyro
```

#### 4.4 Создать символическую ссылку
```bash
ln -sf /etc/nginx/sites-available/neyro /etc/nginx/sites-enabled/neyro
```

#### 4.5 Проверить синтаксис
```bash
nginx -t
```

#### 4.6 Запустить nginx
```bash
systemctl start nginx
```

### Шаг 5: Проверка
```bash
# Статус nginx
systemctl status nginx

# Доступность сайта
curl -I http://194.87.226.56

# Проверка MP3 файлов
curl -I http://194.87.226.56/2.mp3
```

## 🔍 Возможные причины ошибки

1. **Кэширование конфигурации** - nginx может использовать старую конфигурацию
2. **Неправильные пути** - файлы могут быть скопированы не в те директории
3. **Права доступа** - недостаточно прав для изменения конфигурации
4. **Символические ссылки** - неправильные ссылки между sites-available и sites-enabled
5. **Неправильная директория** - файлы находятся в `/home/neyro/neyro2/timeweb-deploy/`, НЕ в `/var/www/timeweb-deploy/`

## 🆘 Если ничего не помогает

### Вариант 1: Полная переустановка nginx
```bash
apt update
apt install --reinstall nginx
```

### Вариант 2: Использование дефолтной конфигурации
```bash
# Удалить все пользовательские конфигурации
rm -f /etc/nginx/sites-enabled/*
rm -f /etc/nginx/sites-available/neyro

# Перезапустить nginx
systemctl restart nginx
```

### Вариант 3: Ручная настройка
```bash
# Создать минимальную конфигурацию
cat > /etc/nginx/sites-available/neyro << 'EOF'
server {
    listen 80;
    server_name 194.87.226.56;
    
    location / {
        proxy_pass http://localhost:8003;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

# Активировать
ln -sf /etc/nginx/sites-available/neyro /etc/nginx/sites-enabled/
nginx -t
systemctl start nginx
```

## 📋 Контакты для поддержки
Если проблема не решается, предоставьте:
1. Вывод команды `./check-nginx-config.sh`
2. Логи nginx: `journalctl -u nginx --no-pager -l`
3. Содержимое `/etc/nginx/sites-enabled/` и `/etc/nginx/sites-available/`
4. Текущую директорию: `pwd`

## 📁 ВАЖНО: Правильные пути
- **Всегда используйте:** `cd /home/neyro/neyro2/timeweb-deploy`
- **НЕ используйте:** `cd /var/www/timeweb-deploy`
- **Файлы конфигурации находятся в:** `/home/neyro/neyro2/timeweb-deploy/` 