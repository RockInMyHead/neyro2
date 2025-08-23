#!/usr/bin/env python3
import os
from dotenv import load_dotenv

# Загружаем переменные окружения
load_dotenv()

# Проверяем API ключи
print("=== Проверка переменных окружения ===")
stability_key = os.getenv("STABILITY_API_KEY")
openai_key = os.getenv("OPENAI_API_KEY")

print(f"STABILITY_API_KEY: {stability_key[:20]}..." if stability_key else "STABILITY_API_KEY: НЕ НАЙДЕН")
print(f"OPENAI_API_KEY: {openai_key[:20]}..." if openai_key else "OPENAI_API_KEY: НЕ НАЙДЕН")

# Проверяем длину ключа
if stability_key:
    print(f"Длина STABILITY_API_KEY: {len(stability_key)} символов")
    if len(stability_key) != 56:
        print("⚠️  ВНИМАНИЕ: Ключ должен быть 56 символов!")
    else:
        print("✅ Длина ключа корректная")
else:
    print("❌ STABILITY_API_KEY не найден")

print(f"Текущая директория: {os.getcwd()}")
print(f"Содержимое директории: {os.listdir('.')}")
