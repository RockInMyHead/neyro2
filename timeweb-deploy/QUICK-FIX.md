# 🚀 Быстрое исправление nginx для TimeWeb

## ❌ Проблема
Ошибка синтаксиса nginx: `"proxy_http_version" directive is not allowed here`

## ✅ Решение
Используем упрощенную конфигурацию без проблемных `if` блоков.

## 🔧 Быстрое исправление

### 1. Применить исправления автоматически:
```bash
cd /home/neyro/neyro2/timeweb-deploy
./apply-nginx-fix.sh
```

### 2. Ручное исправление:
```bash
# Создать бэкап
sudo cp /etc/nginx/sites-available/neyro /etc/nginx/sites-available/neyro.backup

# Скопировать упрощенную конфигурацию
sudo cp /home/neyro/neyro2/timeweb-deploy/nginx-simple.conf /etc/nginx/sites-available/neyro

# Проверить синтаксис
sudo nginx -t

# Перезапустить nginx
sudo systemctl restart nginx
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