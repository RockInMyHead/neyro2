# Neuro Event - AI Video Generation Platform

Интерактивная платформа для генерации видео с использованием ИИ, созданная с использованием React, FastAPI и различных AI API.

## 🚀 Возможности

- **🎨 Генерация изображений** через Stability AI
- **🎵 Синхронизация с аудио** для создания видео
- **⚡ Real-time стриминг** через WebSocket
- **🔄 Интерактивное управление** видео последовательностью
- **📱 Современный UI** с drag-and-drop интерфейсом

## 🛠️ Технологии

- **Frontend:** React + TypeScript + Vite
- **Backend:** FastAPI (Python)
- **AI:** Stability AI, OpenAI API
- **Deployment:** Nginx + TimeWeb

## 📦 Быстрый старт

### Требования
- Python 3.8+
- Node.js 18+
- API ключи для Stability AI и OpenAI

### Установка

1. **Клонируйте репозиторий:**
   ```bash
   git clone https://github.com/your-username/neuro-event.git
   cd neuro-event
   ```

2. **Установите зависимости:**
   ```bash
   # Backend
   pip install -r requirements.txt

   # Frontend (если есть)
   cd timeweb-deploy/public && npm install
   ```

3. **Настройте переменные окружения:**
   ```bash
   cp timeweb-deploy/.env.example timeweb-deploy/.env
   # Отредактируйте .env файл с вашими API ключами
   ```

4. **Запустите приложение:**
   ```bash
   # Backend
   cd timeweb-deploy
   ./start.sh

   # Frontend (если отдельно)
   cd public && npm run dev
   ```

5. **Откройте в браузере:** `http://localhost:8000`

## 📁 Структура проекта

```
neuro-event/
├── timeweb-deploy/          # Production-ready приложение
│   ├── public/             # React frontend build
│   ├── images/             # Статические изображения
│   ├── music/              # Аудио файлы
│   ├── promts/             # Промпты для генерации
│   ├── app.py              # FastAPI приложение
│   ├── requirements.txt    # Python зависимости
│   ├── nginx.conf          # Nginx конфигурация
│   └── start.sh            # Скрипт запуска
├── app.py                  # Основной FastAPI файл
├── requirements.txt       # Зависимости
└── README.md              # Документация
```

## 🔧 Конфигурация

### Переменные окружения (.env)

```env
OPENAI_API_KEY=sk-your-openai-key-here
STABILITY_API_KEY=sk-your-stability-key-here
```

### Nginx конфигурация

Проект включает готовую конфигурацию Nginx для production развертывания на TimeWeb.

## 🚀 Деплой на TimeWeb

1. Загрузите папку `timeweb-deploy` на ваш сервер
2. Установите зависимости: `pip install -r requirements.txt`
3. Настройте Nginx согласно `nginx.conf`
4. Запустите приложение: `./start.sh`

Подробные инструкции см. в `timeweb-deploy/DEPLOY-INSTRUCTIONS.md`

## 📖 API Документация

### Основные эндпоинты

- `GET /` - Главная страница
- `GET /debug_openai` - Проверка статуса API
- `POST /generate_dalle` - Генерация изображений
- `GET /images/{filename}` - Получение изображений
- `GET /music/{filename}.mp3` - Получение аудио файлов
- `WebSocket /session/{sid}/stream` - Real-time стриминг

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 Лицензия

Этот проект лицензирован под MIT License - см. файл [LICENSE](LICENSE) для подробностей.

## 📧 Контакты

- **Email:** your-email@example.com
- **GitHub:** [your-username](https://github.com/your-username)
- **LinkedIn:** [your-profile](https://linkedin.com/in/your-profile)

## 🙏 Благодарности

- [Stability AI](https://stability.ai/) за API генерации изображений
- [OpenAI](https://openai.com/) за API моделей
- [TimeWeb](https://timeweb.com/) за хостинг