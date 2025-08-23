# 🚨 Исправление проблем на TimeWeb сервере

## 📋 Текущие проблемы:

1. ✅ **API URL'ы исправлены** - фронтенд использует `http://194.87.226.56`
2. ❌ **502 Bad Gateway** - nginx не может проксировать запросы к backend
3. ❌ **404 Not Found** - файл `2.mp3` не найден

## 🔧 Решение проблем:

### Шаг 1: Загрузите обновленные файлы на сервер

Если файлы еще не загружены, выполните:

```bash
# Подключитесь к серверу
ssh root@194.87.226.56

# Перейдите в папку проекта
cd /var/www/timeweb-deploy

# Загрузите обновленные файлы (если их нет)
# Используйте scp или git clone для загрузки файлов
```

### Шаг 2: Примените исправления автоматически

```bash
# Сделайте скрипт исполняемым
chmod +x apply-nginx-fix.sh

# Запустите исправления
sudo ./apply-nginx-fix.sh
```

### Шаг 3: Или примените исправления вручную

Если автоматический скрипт не работает, выполните:

```bash
# Создайте резервную копию
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup

# Скопируйте новую конфигурацию
sudo cp nginx-simple.conf /etc/nginx/sites-available/default

# Проверьте синтаксис
sudo nginx -t

# Перезапустите nginx
sudo systemctl reload nginx
```

### Шаг 4: Проверьте backend сервер

```bash
# Проверьте статус backend
curl -I http://127.0.0.1:8000/docs

# Если не работает, запустите его
cd /var/www/timeweb-deploy
python app.py &
```

### Шаг 5: Проверьте работу API

```bash
# Проверьте доступность API
curl -I http://194.87.226.56/generate_dalle

# Должен быть ответ 200 OK или 405 Method Not Allowed
```

## 🔍 Диагностика проблем:

### Если все еще 502 Bad Gateway:

1. **Проверьте backend сервер:**
   ```bash
   curl -I http://127.0.0.1:8000/generate_dalle
   ```

2. **Проверьте nginx конфигурацию:**
   ```bash
   sudo nginx -t
   cat /etc/nginx/sites-available/default
   ```

3. **Проверьте логи nginx:**
   ```bash
   sudo tail -f /var/log/nginx/error.log
   ```

### Если 404 для статических файлов:

1. **Проверьте наличие файла:**
   ```bash
   ls -la /var/www/timeweb-deploy/public/assets/2.mp3
   ```

2. **Проверьте nginx конфигурацию для статических файлов:**
   ```bash
   cat /etc/nginx/sites-available/default | grep -A 5 "location.*mp3"
   ```

## 📋 Файлы для исправления:

- `nginx-simple.conf` - новая nginx конфигурация
- `apply-nginx-fix.sh` - автоматический скрипт исправлений
- `diagnose-server.sh` - скрипт диагностики

## 🎯 Ожидаемый результат:

После применения исправлений:
- ✅ API запросы должны работать
- ✅ Статические файлы должны загружаться
- ✅ WebSocket соединения должны работать

## 📞 Если проблемы остались:

1. **Проверьте логи backend:**
   ```bash
   tail -f /var/www/timeweb-deploy/backend.log
   ```

2. **Проверьте логи nginx:**
   ```bash
   sudo tail -f /var/log/nginx/error.log
   ```

3. **Перезапустите все сервисы:**
   ```bash
   sudo systemctl reload nginx
   pkill -f "python app.py"
   cd /var/www/timeweb-deploy && python app.py &
   ```

Теперь ваш сайт на `http://194.87.226.56` должен работать корректно! 🚀