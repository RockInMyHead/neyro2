# 🔧 Исправление nginx конфигурации для TimeWeb

## 🚨 Проблема
После исправления API URL'ов появились новые ошибки:
- ✅ API URL'ы исправлены: `http://194.87.226.56`
- ❌ **404 ошибка**: файл `2.mp3` не найден
- ❌ **502 Bad Gateway**: API запросы не проходят через nginx

## 🔍 Причина
Nginx не проксирует API запросы на backend сервер. Фронтенд обращается к `http://194.87.226.56/generate_dalle`, но nginx не знает, что делать с этим запросом.

## ✅ Решение

### 1. Обновлена конфигурация nginx
В файле `timeweb-deploy/nginx.conf` добавлено универсальное правило для всех API запросов:

```nginx
# Проксирование всех API запросов на backend
location ~ ^/(generate_dalle|session|enhance_prompt|ws|debug_openai) {
    # CORS и preflight обработка
    if ($request_method = 'OPTIONS') {
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE' always;
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
        add_header 'Access-Control-Max-Age' 1728000;
        add_header 'Content-Type' 'text/plain; charset=utf-8';
        add_header 'Content-Length' 0;
        return 204;
    }
    
    # WebSocket поддержка для /ws
    if ($uri ~ ^/ws) {
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    
    # Проксирование на backend
    proxy_pass http://localhost:8000;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Content-Type $http_content_type;

    # CORS headers
    add_header 'Access-Control-Allow-Origin' '*' always;
    add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE' always;
    add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
}
```

### 2. Создан автоматический скрипт
`timeweb-deploy/apply-nginx-fix.sh` - автоматически применяет исправления на сервере.

## 🚀 Как применить исправления

### Вариант 1: Автоматически (рекомендуется)
```bash
cd timeweb-deploy
chmod +x apply-nginx-fix.sh
sudo ./apply-nginx-fix.sh
```

### Вариант 2: Вручную
1. Скопируйте `nginx.conf` в `/etc/nginx/sites-available/default`
2. Проверьте синтаксис: `sudo nginx -t`
3. Перезапустите nginx: `sudo systemctl reload nginx`

## 📁 Что изменилось
- ✅ `timeweb-deploy/nginx.conf` - универсальное правило для API
- ✅ `timeweb-deploy/apply-nginx-fix.sh` - скрипт автоматизации
- ✅ Удалены дублирующиеся location блоки
- ✅ Добавлена WebSocket поддержка

## 🔍 Проверка после исправления
1. **API запросы**: `http://194.87.226.56/generate_dalle` должен работать
2. **WebSocket**: `ws://194.87.226.56/ws` должен работать
3. **Статические файлы**: изображения и музыка должны загружаться
4. **CORS**: ошибки должны исчезнуть

## 📝 Примечания
- Скрипт автоматически создает резервную копию конфигурации
- При ошибке автоматически восстанавливается предыдущая версия
- Все изменения безопасны и обратимы

## 🆘 Если проблемы остались
1. Проверьте логи nginx: `sudo tail -f /var/log/nginx/error.log`
2. Убедитесь что backend работает на порту 8000
3. Проверьте что nginx перезапустился
4. Проверьте права доступа к файлам

## 🎯 Ожидаемый результат
После применения исправлений:
- ✅ Фронтенд будет работать без ошибок
- ✅ API запросы будут проходить через nginx
- ✅ Генерация изображений будет функционировать
- ✅ WebSocket соединения будут работать 