# 🚨 Экстренное исправление Backend проблем

## ❌ Критическая проблема
Ошибка 502 Bad Gateway для API эндпоинтов не решается стандартными методами.

## 🚨 Экстренные действия

### Шаг 1: Глубокая диагностика
```bash
cd /home/neyro/neyro2/timeweb-deploy
chmod +x deep-backend-diagnosis.sh
./deep-backend-diagnosis.sh
```

### Шаг 2: Экстренное исправление
```bash
chmod +x emergency-backend-fix.sh
./emergency-backend-fix.sh
```

### Шаг 3: Если автоматическое не работает

#### 3.1 Полная остановка всех процессов
```bash
# Остановить все uvicorn процессы
pkill -f "uvicorn.*app:app"
pkill -f "python.*app.py"

# Проверить, что процессы остановлены
ps aux | grep -E "uvicorn|python.*app" | grep -v grep
```

#### 3.2 Проверка системных ресурсов
```bash
# Память
free -h

# Дисковое пространство
df -h

# CPU нагрузка
top -bn1
```

#### 3.3 Пересоздание виртуального окружения
```bash
cd /home/neyro/neyro2

# Удалить старое venv
rm -rf venv

# Создать новое
python3 -m venv venv
source venv/bin/activate

# Установить зависимости
pip install --upgrade pip
pip install -r requirements.txt
```

#### 3.4 Ручной запуск с логированием
```bash
cd /home/neyro/neyro2
source venv/bin/activate

# Запуск с подробным логированием
uvicorn app:app --host 0.0.0.0 --port 8003 --log-level debug
```

## 🔍 Возможные причины 502 ошибки

### 1. Системные проблемы
- **Недостаточно памяти** - сервер не может запуститься
- **Недостаточно дискового пространства** - логи не могут записываться
- **Высокая CPU нагрузка** - система перегружена

### 2. Python проблемы
- **Неправильная версия Python** - несовместимость с зависимостями
- **Поврежденные пакеты** - FastAPI или Uvicorn не работают
- **Проблемы с виртуальным окружением** - конфликты зависимостей

### 3. Сетевые проблемы
- **Порт 8003 занят** другим процессом
- **Firewall блокирует** подключения
- **Nginx не может** проксировать на localhost:8003

### 4. Проблемы с файлами
- **app.py поврежден** или содержит синтаксические ошибки
- **requirements.txt неполный** или содержит несовместимые версии
- **Права доступа** недостаточны для запуска

## 🆘 Критические исправления

### Вариант 1: Перезагрузка системы
```bash
# Если ничего не помогает
reboot

# После перезагрузки
cd /home/neyro/neyro2/timeweb-deploy
./emergency-backend-fix.sh
```

### Вариант 2: Использование другого порта
```bash
# Изменить порт в app.py
sed -i 's/port=8003/port=8004/' app.py

# Обновить nginx конфигурацию
sed -i 's/8003/8004/' nginx-simple.conf

# Перезапустить nginx
systemctl restart nginx

# Запустить backend на новом порту
cd /home/neyro/neyro2
source venv/bin/activate
uvicorn app:app --host 0.0.0.0 --port 8004
```

### Вариант 3: Минимальная конфигурация
```bash
# Создать минимальный app.py для тестирования
cat > /home/neyro/neyro2/app.py << 'EOF'
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Hello World"}

@app.get("/test")
async def test():
    return {"status": "ok"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8003)
EOF

# Запустить минимальный сервер
cd /home/neyro/neyro2
source venv/bin/activate
uvicorn app:app --host 0.0.0.0 --port 8003
```

## 📋 Проверка исправления

После применения исправлений:

1. **Проверить процессы:**
   ```bash
   ps aux | grep uvicorn
   netstat -tlnp | grep :8003
   ```

2. **Проверить API напрямую:**
   ```bash
   curl http://localhost:8003/test
   curl http://localhost:8003/docs
   ```

3. **Проверить через nginx:**
   ```bash
   curl http://194.87.226.56/test
   ```

4. **Проверить в браузере:**
   - Открыть `http://194.87.226.56`
   - Проверить консоль на ошибки
   - Попробовать сгенерировать изображение

## 🎯 Ожидаемый результат
После экстренного исправления:
- ✅ Backend сервер должен запуститься на порту 8003
- ✅ `http://localhost:8003/test` должен возвращать `{"status": "ok"}`
- ✅ `http://194.87.226.56/test` должен работать через nginx
- ✅ Ошибки 502 Bad Gateway должны исчезнуть
- ✅ Генерация изображений должна функционировать

## 📞 Контакты для поддержки
Если проблема не решается, предоставьте:
1. Вывод команды `./deep-backend-diagnosis.sh`
2. Логи backend: `tail -50 /home/neyro/neyro2/backend.log`
3. Логи nginx: `journalctl -u nginx --no-pager -l | tail -20`
4. Системную информацию: `free -h && df -h && top -bn1` 