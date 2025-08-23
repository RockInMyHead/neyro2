# 🚨 Быстрое исправление nginx на TimeWeb

## ❌ Проблема:
- `nginx: [emerg] "proxy_http_version" directive is not allowed here`
- `/etc/nginx/sites-available/default` не существует

## ✅ Быстрое решение:

### Шаг 1: Подключитесь к серверу
```bash
ssh root@194.87.226.56
cd /var/www/timeweb-deploy
```

### Шаг 2: Запустите диагностику
```bash
chmod +x diagnose-nginx.sh
sudo ./diagnose-nginx.sh
```

### Шаг 3: Ручное исправление
```bash
chmod +x manual-fix.sh
sudo ./manual-fix.sh
```

### Шаг 4: Если не работает, используйте универсальный скрипт
```bash
chmod +x fix-nginx-universal.sh
sudo ./fix-nginx-universal.sh
```

## 🔍 Альтернативный ручной способ:

Если скрипты не работают, выполните:

```bash
# Найдите активный конфиг
ls -la /etc/nginx/sites-enabled/

# Создайте резервную копию
sudo cp /etc/nginx/sites-enabled/neyro /etc/nginx/sites-enabled/neyro.backup

# Примените исправленную конфигурацию
sudo cp nginx-fixed.conf /etc/nginx/sites-enabled/neyro

# Проверьте синтаксис
sudo nginx -t

# Перезапустите nginx
sudo systemctl reload nginx
```

## 📋 Проверка работы:

```bash
# Проверьте backend
curl -I http://127.0.0.1:8000/generate_dalle

# Проверьте API через nginx
curl -I http://194.87.226.56/generate_dalle
```

## 🎯 Ожидаемый результат:

После исправления:
- ✅ 502 Bad Gateway исчезнет
- ✅ API запросы будут работать
- ✅ Статические файлы будут загружаться

**Ваш сайт на `http://194.87.226.56` должен заработать!** 🚀