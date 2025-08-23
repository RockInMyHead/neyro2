# 🔧 Исправление проблемы с API URL'ами на TimeWeb

## 🚨 Проблема
На TimeWeb сервере `http://194.87.226.56` фронтенд пытался подключиться к `localhost:8000`, что вызывало ошибки:
- `Preflight response is not successful. Status code: 400`
- `Fetch API cannot load http://localhost:8000/generate_dalle due to access control checks`

## ✅ Решение

### 1. Обновлены CORS настройки в backend
В файле `app.py` добавлен домен TimeWeb:
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:8000", 
        "http://127.0.0.1:8000", 
        "http://localhost:3000", 
        "http://127.0.0.1:3000",
        "http://194.87.226.56",      # ← Добавлено
        "https://194.87.226.56"      # ← Добавлено
    ],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"],
    allow_headers=["*"],
)
```

### 2. Обновлены API URL'ы в фронтенде
Все вхождения `localhost:8000` заменены на `194.87.226.56` в собранных файлах фронтенда.

### 3. Создан скрипт для автоматического обновления
`timeweb-deploy/update-frontend-urls.sh` - автоматически обновляет URL'ы в собранном фронтенде.

## 🚀 Как применить исправления

### Вариант 1: Автоматически (рекомендуется)
```bash
cd timeweb-deploy
chmod +x update-frontend-urls.sh
./update-frontend-urls.sh
```

### Вариант 2: Вручную
1. Обновите CORS настройки в `app.py`
2. Запустите скрипт обновления URL'ов
3. Перезапустите backend сервер

## 📁 Что изменилось
- ✅ `app.py` - обновлены CORS настройки
- ✅ `timeweb-deploy/public/assets/*.js` - заменены API URL'ы
- ✅ `timeweb-deploy/update-frontend-urls.sh` - скрипт автоматизации
- ✅ `timeweb-deploy/current_api_url.txt` - обновлен текущий API URL

## 🔍 Проверка
После применения исправлений:
1. Фронтенд должен использовать `http://194.87.226.56` вместо `localhost:8000`
2. Ошибки CORS должны исчезнуть
3. API запросы должны работать корректно

## 📝 Примечания
- Резервная копия фронтенда сохранена в `timeweb-deploy/public_backup/`
- Скрипт автоматически создает резервную копию перед изменениями
- Все изменения загружены на GitHub в коммите `634e635`

## 🆘 Если проблемы остались
1. Проверьте логи backend сервера
2. Убедитесь что CORS настройки применены
3. Проверьте что фронтенд обновлен
4. Перезапустите backend сервер 