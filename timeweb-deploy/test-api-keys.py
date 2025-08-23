#!/usr/bin/env python3

import os
import sys
import asyncio
from dotenv import load_dotenv

# Загружаем переменные окружения
load_dotenv()

def check_api_keys():
    """Проверяем наличие и валидность API ключей"""

    print("🔍 Проверка API ключей...")
    print("=" * 50)

    # Проверяем Stability AI ключ
    stability_key = os.getenv("STABILITY_API_KEY", "")
    if stability_key and stability_key != "sk-9BlZisDvEvF9Jewp4AbNOfay24M44gTGdCTRAeN9WnCX5uld":
        print(f"✅ STABILITY_API_KEY: {stability_key[:20]}... (настроен)")
    else:
        print("❌ STABILITY_API_KEY: не настроен или использует тестовый ключ")

    # Проверяем OpenAI ключ
    openai_key = os.getenv("OPENAI_API_KEY", "")
    if openai_key and openai_key != "sk-your-openai-key-here":
        print(f"✅ OPENAI_API_KEY: {openai_key[:20]}... (настроен)")
    else:
        print("❌ OPENAI_API_KEY: не настроен или использует placeholder")

    # Проверяем другие переменные
    api_base_url = os.getenv("API_BASE_URL", "")
    print(f"✅ API_BASE_URL: {api_base_url}")

    timeout = os.getenv("STABILITY_TIMEOUT_SECONDS", "60")
    print(f"✅ STABILITY_TIMEOUT_SECONDS: {timeout}")

    print("=" * 50)

    # Проверяем, что хотя бы один ключ настроен
    has_keys = (stability_key and stability_key != "sk-9BlZisDvEvF9Jewp4AbNOfay24M44gTGdCTRAeN9WnCX5uld") or \
               (openai_key and openai_key != "sk-your-openai-key-here")

    if has_keys:
        print("🎉 API ключи настроены корректно!")
        return True
    else:
        print("⚠️  Необходимо настроить API ключи!")
        print("\n📝 Инструкция:")
        print("1. Отредактируйте файл timeweb-deploy/.env")
        print("2. Замените STABILITY_API_KEY на реальный ключ от Stability AI")
        print("3. Замените OPENAI_API_KEY на реальный ключ от OpenAI (опционально)")
        print("4. Перезапустите сервер: ./start.sh")
        return False

async def test_backend():
    """Тестируем backend сервер"""

    print("\n🔧 Тестирование backend сервера...")
    print("=" * 50)

    try:
        from app import app
        print("✅ FastAPI приложение загружено успешно")

        # Проверяем, что у нас есть эндпоинты
        routes = []
        for route in app.routes:
            if hasattr(route, 'path'):
                routes.append(route.path)

        print(f"✅ Найдено {len(routes)} маршрутов")

        # Проверяем конкретные эндпоинты
        important_routes = ['/generate_dalle', '/session', '/docs']
        for route in important_routes:
            if any(route in r for r in routes):
                print(f"✅ Эндпоинт {route} найден")
            else:
                print(f"❌ Эндпоинт {route} не найден")

    except Exception as e:
        print(f"❌ Ошибка загрузки FastAPI: {e}")
        return False

    return True

if __name__ == "__main__":
    print("🚀 Проверка конфигурации Neuro Event API")
    print("=" * 50)

    # Проверяем API ключи
    keys_ok = check_api_keys()

    # Проверяем backend
    backend_ok = asyncio.run(test_backend())

    print("\n" + "=" * 50)
    if keys_ok and backend_ok:
        print("🎉 Все проверки пройдены успешно!")
        print("Сервер готов к работе!")
        sys.exit(0)
    else:
        print("⚠️  Найдены проблемы в конфигурации")
        print("Исправьте проблемы и перезапустите сервер")
        sys.exit(1)