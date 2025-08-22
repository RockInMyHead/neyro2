# Инструкции по деплою проекта

## Вариант 1: Railway (Рекомендуется)

Railway отлично подходит для полного стека приложений.

### Шаги:

1. **Создание аккаунта:**
   - Перейдите на https://railway.app
   - Зарегистрируйтесь через GitHub, Google или email
   - Подтвердите аккаунт

2. **Авторизация через CLI:**
   ```bash
   railway login
   ```
   - Откроется браузер для авторизации
   - Подтвердите вход

3. **Создание проекта:**
   ```bash
   railway init
   ```
   - Выберите "Empty Project"
   - Дайте название проекту (например: "neuro-app")

4. **Деплой backend:**
   ```bash
   # Переместите production requirements
   cp requirements-prod.txt requirements.txt
   
   # Создайте сервис для backend
   railway up
   ```

5. **Настройка переменных окружения:**
   - Откройте панель Railway в браузере
   - Перейдите в Variables
   - Добавьте:
     - `STABILITY_API_KEY`: ваш ключ Stability AI
     - `OPENAI_API_KEY`: ваш ключ OpenAI (опционально)

6. **Деплой frontend:**
   ```bash
   cd frontend
   railway add
   ```

## Вариант 2: Render

1. Перейдите на https://render.com
2. Создайте аккаунт
3. Нажмите "New" → "Web Service"
4. Подключите ваш репозиторий или загрузите файлы
5. Используйте настройки из `render.yaml`

## Вариант 3: Vercel (только для backend)

```bash
npm i -g vercel
vercel --prod
```

## Переменные окружения

Для всех платформ нужно добавить:

- `STABILITY_API_KEY`: API ключ от Stability AI
- `OPENAI_API_KEY`: API ключ от OpenAI (опционально)

## После деплоя

1. Обновите URL backend в frontend (замените localhost на URL вашего backend)
2. Протестируйте генерацию изображений
3. Проверьте CORS настройки если нужно

## Troubleshooting

- Если возникают проблемы с зависимостями, используйте `requirements-prod.txt`
- Проверьте логи в панели управления платформы
- Убедитесь что API ключи правильно установлены