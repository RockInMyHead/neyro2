# 🚨 Исправление проблем на сервере TimeWeb

## ❌ Проблема: файл не найден

**Ошибка:** `chmod: cannot access 'fix-timeweb-server.sh': No such file or directory`

**Причина:** Файл находится не в той директории, или его нужно создать на сервере.

## ✅ Решение 1: Правильный путь к файлу

```bash
# Переходим в папку с проектом
cd /var/www/timeweb-deploy

# Проверяем, что файл есть
ls -la fix-timeweb-server.sh

# Даем права на выполнение
chmod +x fix-timeweb-server.sh

# Запускаем исправление
sudo bash fix-timeweb-server.sh
```

## ✅ Решение 2: Создание скрипта на сервере

Если файл отсутствует, создайте его на сервере:

```bash
# Переходим в папку проекта
cd /var/www/timeweb-deploy

# Создаем скрипт исправления
nano manual-server-fix.sh
```

**Скопируйте содержимое файла `manual-server-fix.sh` в редактор и сохраните (Ctrl+X, Y, Enter)**

```bash
# Даем права на выполнение
chmod +x manual-server-fix.sh

# Запускаем исправление
sudo bash manual-server-fix.sh
```

## ✅ Решение 3: Использование существующих скриптов

```bash
# Переходим в папку проекта
cd /var/www/timeweb-deploy

# Даем права на выполнение всех скриптов
chmod +x *.sh

# Запускаем универсальное исправление
sudo bash fix-nginx-universal.sh
```

## ✅ Решение 4: Быстрое исправление

```bash
# Переходим в папку проекта
cd /var/www/timeweb-deploy

# Запускаем быстрый старт
sudo bash quick-start.sh
```

## 📋 Проверка результатов

После любого из исправлений проверьте статус:

```bash
# Проверка статуса
bash check-server-status.sh

# Или ручная проверка
curl -I http://194.87.226.56/music/2.mp3
curl -I http://194.87.226.56/generate_dalle
curl -I http://194.87.226.56/assets/index-Dp3_vkor.js
```

## 🔧 Если ничего не работает

### Вариант A: Ручное исправление nginx

```bash
# Найдите конфигурацию nginx
sudo find /etc/nginx -name "*.conf" -type f

# Создайте резервную копию
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup

# Отредактируйте конфигурацию
sudo nano /etc/nginx/sites-available/default
```

### Вариант B: Перезапуск сервисов

```bash
# Перезапустите nginx
sudo systemctl reload nginx

# Перезапустите backend
pkill -f "python app.py"
nohup python app.py > backend.log 2>&1 &
```

## 📞 Диагностика проблем

```bash
# Логи backend
tail -f backend.log

# Логи nginx
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log

# Проверка синтаксиса nginx
sudo nginx -t

# Проверка backend
curl -s http://127.0.0.1:8000/docs > /dev/null && echo "Backend OK" || echo "Backend ERROR"
```

## 🎯 Ожидаемые результаты

После успешного исправления:

- ✅ `http://194.87.226.56/music/2.mp3` - музыка загружается
- ✅ `http://194.87.226.56/generate_dalle` - API работает
- ✅ `http://194.87.226.56/assets/index-Dp3_vkor.js` - статические файлы доступны
- ✅ Главная страница загружается без ошибок

## 📁 Важные файлы

- `fix-timeweb-server.sh` - основной скрипт исправления
- `manual-server-fix.sh` - ручной скрипт исправления
- `check-server-status.sh` - проверка статуса
- `server-fix-commands.txt` - команды для исправления

## 🚨 Если нужны файлы

Если какой-то файл отсутствует на сервере, скачайте его:

```bash
# Скачать файл с GitHub (замените URL на свой)
wget https://raw.githubusercontent.com/your-repo/fix-timeweb-server.sh

# Или создайте файл локально и загрузите через SCP/FTP
```

**Нужна помощь с конкретными шагами?** Сообщите, на каком этапе возникли проблемы! 🎯