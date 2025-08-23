# 🚀 Финальный гайд по деплою на TimeWeb

## 📦 Что готово к загрузке

После рефакторинга в проекте остались только файлы, необходимые для работы на TimeWeb:

### Структура проекта:
```
neuro — копия/
├── timeweb-deploy/          # Готовый production build
│   ├── public/             # React frontend (production build)
│   ├── images/             # Оптимизированные изображения
│   ├── music/              # Аудио файлы
│   ├── promts/             # Промпты для генерации
│   ├── app.py              # FastAPI backend
│   ├── shemas.py           # Схемы данных
│   ├── requirements.txt    # Python зависимости
│   ├── nginx.conf          # Nginx конфигурация
│   ├── .env               # Переменные окружения
│   ├── start.sh           # Скрипт запуска
│   ├── README.md          # Инструкции
│   └── DEPLOY-INSTRUCTIONS.md # Подробные инструкции
├── app.py                  # Основной FastAPI файл
├── shemas.py              # Схемы данных
├── requirements.txt       # Зависимости
├── images/                # Исходные изображения
├── music/                 # Исходные аудио файлы
└── promts/                # Промпты
```

## 📤 Загрузка на TimeWeb

### Вариант 1: Через FileZilla (FTP)
1. Скачайте [FileZilla](https://filezilla-project.org/)
2. Подключитесь к вашему серверу TimeWeb:
   - **Хост:** ваш-домен.com или IP-адрес сервера
   - **Пользователь:** ваш FTP логин
   - **Пароль:** ваш FTP пароль
   - **Порт:** 21
3. Загрузите **только папку `timeweb-deploy`** в `/var/www/`

### Вариант 2: Через SCP (если есть SSH доступ)
```bash
# С вашего компьютера
scp -r timeweb-deploy/* username@your-server:/var/www/
```

### Вариант 3: Через TimeWeb панель управления
1. Войдите в [панель управления TimeWeb](https://panel.timeweb.com)
2. Перейдите в раздел "Файловый менеджер"
3. Загрузите содержимое папки `timeweb-deploy` в папку `/var/www/`

## ⚙️ Настройка после загрузки

### 1. Настройка переменных окружения
```bash
# Подключитесь по SSH и отредактируйте .env файл
nano /var/www/timeweb-deploy/.env
```

Укажите ваши API ключи:
```env
OPENAI_API_KEY=sk-your-openai-key-here
STABILITY_API_KEY=sk-your-stability-key-here
```

### 2. Установка зависимостей
```bash
cd /var/www/timeweb-deploy
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 3. Настройка прав доступа
```bash
chmod +x start.sh
chmod 755 /var/www/timeweb-deploy
chmod 644 /var/www/timeweb-deploy/.env
```

## 🌐 Настройка Nginx

1. Скопируйте конфигурацию:
```bash
sudo cp nginx.conf /etc/nginx/sites-available/your-domain.com
```

2. Создайте символическую ссылку:
```bash
sudo ln -s /etc/nginx/sites-available/your-domain.com /etc/nginx/sites-enabled/
```

3. Перезапустите Nginx:
```bash
sudo systemctl restart nginx
```

## 🚀 Запуск приложения

### Вариант 1: Ручной запуск
```bash
cd /var/www/timeweb-deploy
source venv/bin/activate
./start.sh
```

### Вариант 2: Автоматический запуск (systemd)
Создайте файл `/etc/systemd/system/neuro-app.service`:
```ini
[Unit]
Description=Neuro Event App
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/var/www/timeweb-deploy
ExecStart=/var/www/timeweb-deploy/venv/bin/uvicorn app:app --host 0.0.0.0 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
```

Включите и запустите:
```bash
sudo systemctl daemon-reload
sudo systemctl enable neuro-app
sudo systemctl start neuro-app
```

## ✅ Проверка работы

1. **Frontend:** `http://ваш-домен.com`
2. **API:** `http://ваш-домен.com/api/debug_openai`

## 🧹 Очистка (опционально)

После успешного деплоя вы можете удалить исходную папку `neuro — копия`, оставив только `timeweb-deploy` на сервере.

## 📞 Поддержка

Если возникли проблемы:
1. Проверьте логи: `sudo journalctl -u neuro-app -n 50`
2. Проверьте Nginx статус: `sudo systemctl status nginx`
3. Обратитесь в TimeWeb поддержку: support@timeweb.com

---

**🎉 Проект готов к продакшену! Загружайте папку `timeweb-deploy` на ваш сервер и следуйте инструкциям выше.**