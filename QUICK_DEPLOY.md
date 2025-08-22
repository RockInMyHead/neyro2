# 🚀 Быстрый деплой проекта (без GitHub)

## 🎯 Самый простой способ: Render

### 1. Подготовка backend

Ваш проект уже подготовлен! Файлы готовы для деплоя.

### 2. Деплой на Render

1. **Перейдите на https://render.com**
2. **Зарегистрируйтесь** (email/Google/GitHub)
3. **Создайте новый Web Service:**
   - Нажмите "New" → "Web Service"
   - Выберите "Build and deploy from a Git repository"
   - Если нет Git репозитория, выберите "Deploy from uploaded files"

4. **Настройки для backend:**
   ```
   Name: neuro-backend
   Runtime: Python 3
   Build Command: pip install -r requirements.txt
   Start Command: uvicorn app:app --host 0.0.0.0 --port $PORT
   ```

5. **Добавьте переменные окружения:**
   - `STABILITY_API_KEY`: ваш ключ от Stability AI
   - `OPENAI_API_KEY`: ваш ключ от OpenAI (опционально)

### 3. Деплой frontend

1. **Соберите frontend:**
   ```bash
   cd frontend
   npm install
   npm run build
   ```

2. **На Render создайте Static Site:**
   - Нажмите "New" → "Static Site"
   - Загрузите папку `frontend/dist`
   - Или подключите Git и укажите:
     ```
     Build Command: cd frontend && npm install && npm run build
     Publish Directory: frontend/dist
     ```

### 4. Подключение frontend к backend

После деплоя у вас будет:
- Backend URL: `https://your-app.onrender.com`
- Frontend URL: `https://your-frontend.onrender.com`

Обновите API URLs в frontend коде, заменив `localhost:8000` на URL вашего backend.

## 🎯 Альтернатива: Railway

1. **Создайте аккаунт:** https://railway.app
2. **Авторизуйтесь через CLI:**
   ```bash
   railway login
   ```
3. **Создайте проект:**
   ```bash
   railway init
   railway up
   ```

## 🎯 Альтернатива: Vercel (только backend)

```bash
npm i -g vercel
vercel --prod
```

## 📋 Что готово для деплоя:

- ✅ `requirements.txt` - оптимизированные зависимости
- ✅ `railway.toml` - конфигурация Railway
- ✅ `render.yaml` - конфигурация Render
- ✅ `Procfile` - команда запуска
- ✅ `start.sh` - скрипт запуска
- ✅ Frontend собран и настроен

## 🔧 Нужные API ключи:

- **Stability AI API Key**: Получите на https://platform.stability.ai/
- **OpenAI API Key** (опционально): Получите на https://platform.openai.com/

## 📞 Поддержка

Если возникнут проблемы:
1. Проверьте логи в панели управления платформы
2. Убедитесь что API ключи правильно установлены
3. Проверьте что все файлы загружены

**Готово к деплою! 🎉**