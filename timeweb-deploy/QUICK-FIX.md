# 🚀 Быстрое исправление nginx для TimeWeb

## ❌ Проблема
Ошибка синтаксиса nginx: `"proxy_http_version" directive is not allowed here`

## ✅ Решение
Используем упрощенную конфигурацию без проблемных `if` блоков.

## 🔧 Быстрое исправление

### 1. Перейти в правильную директорию:
```bash
cd /home/neyro/neyro2/timeweb-deploy
```

### 2. Применить исправления автоматически:
```bash
chmod +x apply-nginx-fix.sh
./apply-nginx-fix.sh
```

### 3. Если автоматическое не работает - принудительное исправление:
```bash
chmod +x force-nginx-fix.sh
./force-nginx-fix.sh
```

### 4. Ручное исправление (если скрипты не работают):
```bash
# Остановить nginx
systemctl stop nginx

# Создать бэкап
sudo cp /etc/nginx/sites-available/neyro /etc/nginx/sites-available/neyro.backup

# Удалить старую конфигурацию
rm -f /etc/nginx/sites-enabled/neyro
rm -f /etc/nginx/sites-available/neyro

# Скопировать упрощенную конфигурацию
cp /home/neyro/neyro2/timeweb-deploy/nginx-simple.conf /etc/nginx/sites-available/neyro

# Создать символическую ссылку
ln -sf /etc/nginx/sites-available/neyro /etc/nginx/sites-enabled/neyro

# Проверить синтаксис
nginx -t

# Запустить nginx
systemctl start nginx
```

## 📋 Что исправлено в nginx-simple.conf:
- ✅ Убраны проблемные `if` блоки
- ✅ WebSocket поддержка вынесена в отдельную секцию
- ✅ Правильные пути к статическим файлам
- ✅ Проксирование на порт 8003
- ✅ CORS заголовки для API

## 🔍 Проверка:
```bash
# Проверить статус nginx
sudo systemctl status nginx

# Проверить доступность сайта
curl -I http://194.87.226.56

# Проверить MP3 файлы
curl -I http://194.87.226.56/2.mp3
```

## 🆘 Если проблемы:
```bash
# Проверить логи nginx
sudo journalctl -u nginx -f

# Восстановить бэкап
sudo cp /etc/nginx/sites-available/neyro.backup /etc/nginx/sites-available/neyro
sudo systemctl restart nginx
```

## 📁 Важно: правильные пути
- **Файлы конфигурации находятся в:** `/home/neyro/neyro2/timeweb-deploy/`
- **НЕ в:** `/var/www/timeweb-deploy/`
- **Всегда используйте:** `cd /home/neyro/neyro2/timeweb-deploy`