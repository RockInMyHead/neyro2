import asyncio
import os
import uuid
import base64
import re
from datetime import datetime
from collections import OrderedDict
import httpx
from typing import Dict, List, Optional

import uvicorn
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, JSONResponse, Response
from fastapi.staticfiles import StaticFiles

from shemas import SessionCreateIn, PromptIn

# ────────────────────────────────────
# Stability AI Core image generation config
# ────────────────────────────────────
STABILITY_API_KEY = (
    "sk-9BlZisDvEvF9Jewp4AbNOfay24M44gTGdCTRAeN9WnCX5uld"
)
STABILITY_URL = "https://api.stability.ai/v2beta/stable-image/generate/core"
STABILITY_HEADERS = {
    "Authorization": f"Bearer {STABILITY_API_KEY}",
    "Accept": "image/*",
}
STABILITY_TIMEOUT_SECONDS = 60

# Опционально: загрузка переменных окружения из .env, если установлен python-dotenv
try:  # pragma: no cover
    from dotenv import load_dotenv  # type: ignore
    load_dotenv()
except Exception:
    pass
from fastapi import Body
try:
    import requests  # type: ignore
    _stability_session = requests.Session()
except Exception:
    requests = None  # type: ignore
    _stability_session = None  # type: ignore

# Простой LRU-кэш для результатов генерации: ключ → имя файла
_IMAGE_CACHE_MAX = 32
_image_cache: "OrderedDict[str, str]" = OrderedDict()

def _cache_get(key: str) -> Optional[str]:
    path = _image_cache.get(key)
    if path:
        # поднимаем вверх (LRU)
        _image_cache.move_to_end(key)
    return path

def _cache_put(key: str, path: str) -> None:
    _image_cache[key] = path
    _image_cache.move_to_end(key)
    while len(_image_cache) > _IMAGE_CACHE_MAX:
        _image_cache.popitem(last=False)

# ────────────────────────────────────
# Prompt helpers: truncate, RU→EN translation, cyrillic check
# ────────────────────────────────────
def _truncate(text: str, max_len: int) -> str:
    if len(text) <= max_len:
        return text
    return text[: max_len - 3].rstrip() + "..."

def _contains_cyrillic(text: str) -> bool:
    return any('а' <= ch.lower() <= 'я' for ch in text)

def _extract_key_objects_for_space(base_prompt: str) -> str:
    """Извлекает только ключевые объекты из базового промпта для космических сцен, убирая детали окружения"""
    if not base_prompt:
        return ""
    
    # Ключевые объекты, которые стоит сохранить в космических сценах
    creatures = ['dragon', 'knight', 'wizard', 'warrior', 'hero', 'character', 'person', 'figure', 'being', 'ognedyshaschij']
    vehicles = ['train', 'car', 'ship', 'vehicle', 'aircraft', 'spaceship', 'rocket']
    architecture = ['castle', 'tower', 'bridge', 'temple', 'building', 'structure']
    objects = ['sword', 'crystal', 'orb', 'artifact', 'weapon', 'treasure']
    
    # Слова окружения, которые нужно убрать из космических сцен
    environment_words = ['forest', 'mountain', 'valley', 'fog', 'atmosphere', 'autumn', 'golden', 'foliage', 
                        'mystical', 'stone', 'viaduct', 'rails', 'steam', 'god rays', 'warm', 'cold']
    
    all_key_words = creatures + vehicles + architecture + objects
    
    # Извлекаем только ключевые объекты, исключая окружение
    key_objects = []
    text_lower = base_prompt.lower()
    
    # Ищем ключевые слова и извлекаем их с минимальным контекстом
    for key_word in all_key_words:
        if key_word in text_lower:
            # Находим предложения или части с этим ключевым словом
            sentences = base_prompt.replace(';', '.').split('.')
            for sentence in sentences:
                if key_word.lower() in sentence.lower():
                    # Очищаем предложение от деталей окружения
                    clean_sentence = sentence.strip()
                    
                    # Убираем слова окружения
                    words = clean_sentence.split()
                    filtered_words = []
                    for word in words:
                        word_clean = re.sub(r'[^\w\s]', '', word.lower())
                        if word_clean not in environment_words:
                            filtered_words.append(word)
                    
                    if filtered_words:
                        clean_obj = ' '.join(filtered_words).strip()
                        # Убираем технические детали
                        clean_obj = re.sub(r'\b(4K|16:9|Ultra detail|Volumetric Lighting|Gi|AO|Photo Real|Aerovid|wide angle|zoom)\b', '', clean_obj, flags=re.IGNORECASE)
                        clean_obj = re.sub(r'\s+', ' ', clean_obj).strip()
                        
                        if clean_obj and clean_obj not in key_objects:
                            key_objects.append(clean_obj)
                    break
    
    # Если ничего не найдено, берем только первые 2-3 слова (основной объект)
    if not key_objects and base_prompt:
        first_words = base_prompt.split()[:3]
        # Фильтруем слова окружения
        filtered_first = [word for word in first_words if re.sub(r'[^\w\s]', '', word.lower()) not in environment_words]
        if filtered_first:
            key_objects.append(' '.join(filtered_first))
    
    return ', '.join(key_objects) if key_objects else ""

def _translate_to_english(text: str, timeout: int = 10) -> str:
    """
    Универсальный перевод русских промптов на английский.
    Покрывает ВСЕ слова русского языка через многоуровневую систему.
    """
    try:
        # Импортируем универсальную систему перевода
        from universal_translator import translate_russian_text
        
        # Используем универсальную систему
        translated = translate_russian_text(text)
        
        # Если перевод изменился, возвращаем его
        if translated.lower() != text.lower():
            return translated
            
    except ImportError:
        pass
    except Exception:
        pass
    
    # Fallback: используем старый локальный словарь
    try:
        from russian_english_dict import translate_phrase, get_translation
        
        # Специальные случаи для повторяющихся слов
        low = text.strip().lower()
        if " " in low:
            words = low.split()
            if len(set(words)) == 1:  # Все слова одинаковые
                single_word = words[0]
                translated_word = get_translation(single_word)
                return " ".join([translated_word] * len(words))
        
        # Используем полный словарь для перевода фразы
        translated = translate_phrase(text)
        if translated.lower() != text.lower():
            return translated
            
    except ImportError:
        pass
    except Exception:
        pass
    
    # Последний fallback: используем transliterate
    try:
        import transliterate
        transliterated = transliterate.translit(text, 'ru', reversed=True)
        if transliterated and not _contains_cyrillic(transliterated):
            return transliterated
    except ImportError:
        pass
    except Exception:
        pass
    
    # Возвращаем исходный текст если ничего не помогло
    return text

def _to_english_or_empty(text: str) -> str:
    src = (text or "").strip()
    if not src:
        return ""
    if _contains_cyrillic(src):
        en = _translate_to_english(src)
        if _contains_cyrillic(en):
            return ""
        return en
    return src

# Поддержка и нового SDK (v1), и legacy-клиента
_openai_available = False
_use_v1_client = False
try:  # v1 стиль
    from openai import OpenAI  # type: ignore
    _openai_available = True
    _use_v1_client = True
except Exception:  # pragma: no cover
    try:
        import openai as openai_legacy  # type: ignore
        _openai_available = True
        _use_v1_client = False
    except Exception:
        OpenAI = None  # type: ignore
        openai_legacy = None  # type: ignore
        _openai_available = False

# ────────────────────────────────────
# Минимальная серверная заготовка без алгоритмов генерации
# ────────────────────────────────────

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:8000", "http://127.0.0.1:8000", "http://localhost:3000", "http://127.0.0.1:3000"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"],
    allow_headers=["*"],
)

# Альтернативный способ обслуживания статических файлов
import os

# Простые эндпоинты для статических файлов
@app.get("/assets/{filename}")
async def get_asset(filename: str):
    assets_path = os.path.join(os.path.dirname(__file__), "timeweb-deploy", "public", "assets", filename)
    if os.path.exists(assets_path):
        return FileResponse(assets_path)
    raise HTTPException(status_code=404, detail="Asset not found")

@app.get("/images/{filename}")
async def get_image_file(filename: str):
    images_path = os.path.join(os.path.dirname(__file__), "timeweb-deploy", "public", "images", filename)
    if os.path.exists(images_path):
        return FileResponse(images_path)
    raise HTTPException(status_code=404, detail="Image not found")

# Эндпоинты для других статических файлов
@app.get("/{filename}")
async def get_static_file(filename: str):
    # Обслуживаем статические файлы из public директории
    if filename.endswith(('.svg', '.png', '.jpg', '.jpeg', '.gif', '.mp4', '.mp3', '.ico', '.woff', '.woff2')):
        file_path = os.path.join(os.path.dirname(__file__), "timeweb-deploy", "public", filename)
        if os.path.exists(file_path):
            return FileResponse(file_path)
    raise HTTPException(status_code=404, detail="File not found")

@app.get("/music/{filename}.mp3")
async def get_music_file(filename: str):
    music_path = os.path.join(os.path.dirname(__file__), "timeweb-deploy", "music", f"{filename}.mp3")
    if os.path.exists(music_path):
        return FileResponse(music_path, media_type="audio/mpeg")
    raise HTTPException(status_code=404, detail="Music file not found")

# Маршрут для главной страницы
@app.get("/")
async def read_root():
    return FileResponse("timeweb-deploy/public/index.html", media_type="text/html")

# Простейшее хранилище сессий: sid → список промптов
sessions: Dict[str, List[str]] = {}

# Хранилище для накопления пользовательских промптов по изображениям
# Структура: {session_id: {current_image_index: [user_prompts]}}
user_prompts_storage: Dict[str, Dict[int, List[str]]] = {}

# Хранилище текущего индекса изображения для каждой сессии
current_image_index: Dict[str, int] = {}


# ────────────────────────────────────
# Пример: отдача статичных mp3 (не алгоритм)
# ────────────────────────────────────
@app.get("/music/{filename}.mp3")
async def get_music(filename: str):
    base = os.path.dirname(__file__)
    # Ищем сначала в папке music/, затем в корне проекта
    candidate_paths = [
        os.path.join(base, "music", f"{filename}.mp3"),
        os.path.join(base, f"{filename}.mp3"),
    ]
    for fp in candidate_paths:
        if os.path.isfile(fp):
            return FileResponse(fp, media_type="audio/mpeg")
    raise HTTPException(status_code=404, detail="Music not found")


@app.get("/images/{filename}")
async def get_image(filename: str):
    base = os.path.dirname(__file__)
    file_path = os.path.join(base, "images", filename)
    if not os.path.isfile(file_path):
        raise HTTPException(status_code=404, detail="Image not found")

    # Определяем mime по расширению
    lower = filename.lower()
    if lower.endswith(".png"):
        media_type = "image/png"
    elif lower.endswith(".jpg") or lower.endswith(".jpeg"):
        media_type = "image/jpeg"
    else:
        media_type = "application/octet-stream"

    return FileResponse(file_path, media_type=media_type)


# ────────────────────────────────────
# REST: создание сессии и добавление промптов (без генерации)
# ────────────────────────────────────
@app.post("/session")
async def create_session(data: SessionCreateIn):
    initial = data.prompts or ["Demo"]
    sid = str(uuid.uuid4())
    sessions[sid] = list(initial)
    return JSONResponse({"session_id": sid, "prompts": initial})


@app.post("/session/{sid}/prompt")
async def add_prompt(sid: str, data: PromptIn):
    if sid not in sessions:
        raise HTTPException(status_code=404, detail="Session not found")
    sessions[sid].append(data.prompt)
    return {"status": "accepted", "prompt": data.prompt}

# Новые эндпоинты для управления пользовательскими промптами
@app.post("/session/{sid}/user_prompt")
async def add_user_prompt(sid: str, data: PromptIn):
    """Добавляет пользовательский промпт для текущего изображения"""
    if sid not in sessions:
        raise HTTPException(status_code=404, detail="Session not found")
    
    # Инициализируем хранилища если нужно
    if sid not in user_prompts_storage:
        user_prompts_storage[sid] = {}
    if sid not in current_image_index:
        current_image_index[sid] = 0
    
    current_idx = current_image_index[sid]
    
    # Инициализируем список промптов для текущего изображения
    if current_idx not in user_prompts_storage[sid]:
        user_prompts_storage[sid][current_idx] = []
    
    # Добавляем промпт
    user_prompts_storage[sid][current_idx].append(data.prompt)
    
    return {
        "status": "accepted", 
        "prompt": data.prompt,
        "image_index": current_idx,
        "accumulated_prompts": user_prompts_storage[sid][current_idx]
    }

@app.post("/session/{sid}/next_image")
async def next_image(sid: str):
    """Переключает на следующее изображение, сбрасывая накопленные промпты"""
    if sid not in sessions:
        raise HTTPException(status_code=404, detail="Session not found")
    
    if sid not in current_image_index:
        current_image_index[sid] = 0
    
    # Переходим к следующему изображению
    current_image_index[sid] += 1
    
    return {
        "status": "switched",
        "new_image_index": current_image_index[sid]
    }

@app.get("/session/{sid}/accumulated_prompts")
async def get_accumulated_prompts(sid: str):
    """Получает все накопленные промпты для текущего изображения"""
    if sid not in sessions:
        raise HTTPException(status_code=404, detail="Session not found")
    
    if sid not in user_prompts_storage:
        return {"image_index": 0, "prompts": []}
    
    current_idx = current_image_index.get(sid, 0)
    prompts = user_prompts_storage[sid].get(current_idx, [])
    
    return {
        "image_index": current_idx,
        "prompts": prompts,
        "combined_prompt": " + ".join(prompts) if prompts else ""
    }


# ────────────────────────────────────
# REST: генерация изображения через OpenAI DALL·E (gpt-image-1)
# ────────────────────────────────────
@app.get("/debug_openai")
async def debug_openai():
    return {
        "openai_available": _openai_available,
        "use_v1_client": _use_v1_client,
        "has_env_key": bool(os.getenv("OPENAI_API_KEY")),
    }

@app.post("/generate_dalle")
async def generate_dalle(
    payload: Dict = Body(..., embed=False),
):
    """
    Ожидает JSON: {"prompt": str, "base_prompt": str, "session_id": str (опционально)}
    Возвращает: {"image_url": str}
    """
    user_prompt = (payload.get("prompt") or "").strip()
    base_prompt = (payload.get("base_prompt") or "").strip()
    session_id = payload.get("session_id")
    
    # Если есть session_id, получаем накопленные промпты для текущего изображения
    if session_id and session_id in user_prompts_storage:
        current_idx = current_image_index.get(session_id, 0)
        accumulated_prompts = user_prompts_storage[session_id].get(current_idx, [])
        
        if accumulated_prompts:
            # Объединяем все накопленные промпты с новым
            all_user_prompts = accumulated_prompts.copy()
            if user_prompt:
                all_user_prompts.append(user_prompt)
            user_prompt = " + ".join(all_user_prompts)
            print(f"[PROMPTS] Combined user prompts for image {current_idx}: {user_prompt}")
    fast_flag_raw = payload.get("fast")
    fast_mode = str(fast_flag_raw).lower() in ("1", "true", "yes", "on")
    # Управление переводом и типом ответа (по умолчанию true для лучшего усиления промптов)
    no_translate = str(payload.get("no_translate", "true")).lower() in ("1", "true", "yes", "on")
    return_binary = str(payload.get("binary", "false")).lower() in ("1", "true", "yes", "on")

    if not user_prompt:
        raise HTTPException(status_code=400, detail="prompt is required")

    # 1) Отключаем усиление промта: используем исходный текст без LLM
    import time
    start_time = time.time()
    print(f"[TIMING] Starting generation at {time.strftime('%H:%M:%S')}")
    enhanced_user_prompt = user_prompt
    enhance_ms = 0

    # 2) Комбинируем промт: пользовательский ; базовый (без "Style:")
    if base_prompt:
        combined_prompt = f"{enhanced_user_prompt} ; {base_prompt}"
    else:
        combined_prompt = enhanced_user_prompt

    # 3) Кэш ключ для всех режимов
    cache_key = f"p={combined_prompt}|ar=16:9|size={(payload.get('size') or 'lg')}|q={(payload.get('jpeg_quality') or payload.get('q') or payload.get('quality') or 'high')}|fast={(str(payload.get('fast', '')).lower())}"
    
    # Кэш только для JSON-режима (не для binary)
    if not return_binary:
        cached = _cache_get(cache_key)
        if cached and os.path.isfile(cached):
            rel = "/images/" + os.path.basename(cached)
            return JSONResponse({"image_url": rel})

    # 4) Готовим финальный промт для Stability и логируем
    if no_translate:
        # Если no_translate=true, используем исходный промпт, но base_prompt переводим если содержит кириллицу
        # Пользовательский промпт тоже переводим если содержит кириллицу
        user_en = _translate_to_english(user_prompt) if _contains_cyrillic(user_prompt) else user_prompt
        
        # Универсальная логика: пользовательский промпт всегда приоритетен
        # Усиливаем пользовательский промпт для лучшей видимости
        user_en_enhanced = f"{user_en} prominently featured, {user_en} as main subject, {user_en}"
        
        # Получаем базовый промпт
        if _contains_cyrillic(base_prompt):
            base_en = _translate_to_english(base_prompt)
        else:
            base_en = base_prompt
        
        # Проверяем космическую тематику для добавления специальных элементов
        space_words_en = ['space', 'cosmic', 'universe', 'galaxy', 'star', 'cosmos']
        space_words_ru = ['космос', 'космический', 'вселенная', 'галактика', 'звезда', 'звезды']
        is_space_theme = (any(space_word in user_en.lower() for space_word in space_words_en) or 
                         any(space_word in user_prompt.lower() for space_word in space_words_ru))
        
        # Универсальная формула: пользовательский промпт + базовый контекст + специальные элементы (если нужно)
        if base_en and base_en.strip():
            stability_prompt = f"{user_en_enhanced} ; {base_en}"
        else:
            stability_prompt = user_en_enhanced
            
        # Добавляем космические элементы только если тематика космическая
        if is_space_theme:
            space_context = "cosmic environment, starfield background, deep space"
            stability_prompt = f"{stability_prompt} ; {space_context}"
    else:
        user_en = _to_english_or_empty(enhanced_user_prompt)
        base_en = _to_english_or_empty(base_prompt)
        if user_en and base_en:
            stability_prompt = f"{user_en} ; {base_en}"
        else:
            stability_prompt = user_en or base_en or _translate_to_english(combined_prompt)
    stability_prompt = _truncate(stability_prompt, 4000)
    try:
        pass
    except Exception:
        pass

    # Логируем финальный промпт для Stability AI
    print(f"[PROMPT] Final prompt sent to Stability AI:")
    print(f"[PROMPT] {stability_prompt}")
    print(f"[PROMPT] Length: {len(stability_prompt)} characters")
    
    # Отправляем в Stability AI
    t1 = time.perf_counter()

    # Путь сохранения
    base_dir = os.path.dirname(__file__)
    images_dir = os.path.join(base_dir, "images")
    os.makedirs(images_dir, exist_ok=True)

    # Инициализируем, чтобы избежать UnboundLocal при неожиданных ветках
    image_bytes: bytes = b""
    try:
        used_model = "stability-core"
        # аспект-рацио можно переопределить через payload["ar"|"aspect_ratio"]
        requested_ar = "16:9"
        used_size = requested_ar
        used_quality = "jpeg"
        t1 = time.perf_counter()
        # Запрос к Stability Core с системой повторных попыток
        files = {
            "prompt": (None, stability_prompt),
            "aspect_ratio": (None, requested_ar),
            "output_format": (None, "jpeg"),
        }
        
        # Система повторных попыток
        max_retries = 3
        retry_delay = 2  # секунды
        
        for attempt in range(max_retries):
            try:
                print(f"[API] Attempt {attempt + 1}/{max_retries} to Stability AI")
                
                if _stability_session is not None:
                    r = _stability_session.post(
                        STABILITY_URL,
                        headers=STABILITY_HEADERS,
                        files=files,
                        timeout=STABILITY_TIMEOUT_SECONDS,
                        stream=False,
                    )
                else:
                    import requests as _rq  # type: ignore
                    r = _rq.post(
                        STABILITY_URL,
                        headers=STABILITY_HEADERS,
                        files=files,
                        timeout=STABILITY_TIMEOUT_SECONDS,
                        stream=False,
                    )
                r.raise_for_status()
                image_bytes = r.content
                print(f"[API] Success on attempt {attempt + 1}")
                break
                
            except (requests.exceptions.ConnectionError, 
                    requests.exceptions.Timeout,
                    requests.exceptions.RequestException) as e:
                print(f"[API] Attempt {attempt + 1} failed: {type(e).__name__}: {str(e)}")
                
                if attempt < max_retries - 1:
                    print(f"[API] Retrying in {retry_delay} seconds...")
                    import time as time_mod
                    time_mod.sleep(retry_delay)
                    retry_delay *= 1.5  # Экспоненциальная задержка
                else:
                    # Последняя попытка не удалась
                    raise Exception(f"All {max_retries} attempts failed. Last error: {str(e)}")
            except Exception as e:
                # Другие ошибки (HTTP статус коды и т.д.) не повторяем
                print(f"[API] Non-retryable error: {type(e).__name__}: {str(e)}")
                raise

        gen_ms = int((time.perf_counter() - t1) * 1000)
        filename = f"generated_{datetime.utcnow().strftime('%Y%m%d_%H%M%S_%f')}.jpg"
        out_path = os.path.join(images_dir, filename)

        # Уменьшаем итоговое изображение перед записью (уменьшает вес и ускоряет доставку)
        # size: 'sm' (512), 'md' (768), 'lg' (1024, по умолчанию), либо число пикселей по большей стороне
        requested_size = (payload.get("size") or "lg").strip()
        # jpeg_quality: число 40..90 или пресеты: low/med/high
        rq = payload.get("jpeg_quality") or payload.get("q") or payload.get("quality") or "high"
        if isinstance(rq, str) and rq.isdigit():
            jpeg_quality = max(40, min(90, int(rq)))
        elif isinstance(rq, (int, float)):
            jpeg_quality = max(40, min(90, int(rq)))
        else:
            preset = str(rq).lower().strip()
            jpeg_quality = 65 if preset == "low" else 78 if preset in ("med", "medium") else 85
        if isinstance(requested_size, str) and requested_size.isdigit():
            max_dim = max(256, min(2048, int(requested_size)))
        else:
            size_map = {"sm": 512, "md": 768, "lg": 1024}
            max_dim = size_map.get(str(requested_size).lower(), 768)

        resize_ms = 0
        final_w = final_h = None
        # В fast-режиме пропускаем локальный ресайз/пережатие для экономии времени
        if not fast_mode:
            try:
                from PIL import Image  # type: ignore
                import io as _io
                t_resize = time.perf_counter()
                with Image.open(_io.BytesIO(image_bytes)) as img:
                    img = img.convert("RGB")
                    w, h = img.size
                    scale = min(1.0, float(max_dim) / float(max(w, h)))
                    if scale < 1.0:
                        new_w = max(1, int(w * scale))
                        new_h = max(1, int(h * scale))
                        img = img.resize((new_w, new_h), Image.LANCZOS)
                        final_w, final_h = new_w, new_h
                    else:
                        final_w, final_h = w, h
                    buf = _io.BytesIO()
                    img.save(buf, format="JPEG", quality=jpeg_quality, optimize=True, progressive=True)
                    image_bytes = buf.getvalue()
                resize_ms = int((time.perf_counter() - t_resize) * 1000)
            except Exception:
                pass

        # Всегда сохраняем изображение на диск для истории
        try:
            with open(out_path, "wb") as f:
                f.write(image_bytes)
            write_ms = int((time.perf_counter() - (t1 + gen_ms/1000.0)) * 1000)
            print(f"[SAVE] Image saved to: {out_path}")
            
            # Сохраняем промпт в .txt файл (тот который отправлен в Stability AI)
            if not fast_mode:
                try:
                    with open(os.path.join(images_dir, filename + ".txt"), "w", encoding="utf-8") as tf:
                        tf.write(stability_prompt)
                    print(f"[SAVE] Prompt saved to: {filename}.txt")
                except Exception as e:
                    print(f"[SAVE] Failed to save prompt: {e}")
                    
        except Exception as e:
            print(f"[SAVE] Failed to save image: {e}")
            write_ms = 0

        # Кэшируем только для JSON ответов
        if not return_binary:
            _cache_put(cache_key, out_path)

        if return_binary:
            media_type = "image/jpeg"
            headers = {}
            if str(payload.get("debug", "")).lower() in ("1", "true", "yes"):
                headers["X-Timing-Enhance"] = str(enhance_ms)
                headers["X-Timing-Generate"] = str(gen_ms)
                headers["X-Timing-Resize"] = str(resize_ms)
                headers["X-Timing-Write"] = str(write_ms)
            
            # Логируем время генерации
            end_time = time.time()
            generation_time = end_time - start_time
            print(f"[TIMING] Generation completed in {generation_time:.2f} seconds")
            
            return Response(content=image_bytes, media_type=media_type, headers=headers)
        else:
            if str(payload.get("debug", "")).lower() in ("1", "true", "yes"):
                return JSONResponse({
                    "image_url": f"/images/{filename}",
                    "prompt_used": combined_prompt,
                    "model_used": used_model,
                    "size": used_size,
                    "quality": used_quality,
                    "timing_ms": {"enhance": enhance_ms, "generate": gen_ms, "resize": resize_ms, "write": write_ms},
                    "final_resolution": [final_w, final_h] if (final_w and final_h) else None
                })
            
            # Логируем время генерации
            end_time = time.time()
            generation_time = end_time - start_time
            print(f"[TIMING] Generation completed in {generation_time:.2f} seconds")
            
            return JSONResponse({"image_url": f"/images/{filename}"})
    except Exception as e:
            # Логируем время до ошибки
            end_time = time.time()
            generation_time = end_time - start_time
            print(f"[TIMING] Generation failed after {generation_time:.2f} seconds: {str(e)}")
            
            # Более понятные сообщения об ошибках для пользователя
            message = str(e)
            
            # Проблемы с авторизацией
            if "must be verified" in message or "Verify Organization" in message:
                raise HTTPException(status_code=403, detail="API ключ требует верификации организации")
            
            # Проблемы с подключением
            if "Connection" in message or "Remote end closed" in message:
                raise HTTPException(status_code=503, detail="Временные проблемы с соединением. Попробуйте еще раз через несколько секунд")
            
            # Таймауты
            if "timeout" in message.lower() or "timed out" in message.lower():
                raise HTTPException(status_code=504, detail="Превышено время ожидания ответа от сервера генерации изображений")
            
            # Проблемы с лимитами
            if "rate limit" in message.lower() or "quota" in message.lower():
                raise HTTPException(status_code=429, detail="Превышен лимит запросов. Попробуйте позже")
            
            # Все остальные ошибки
            raise HTTPException(status_code=502, detail=f"Ошибка генерации изображения: {message}")


# ────────────────────────────────────
# WebSocket: шлёт статичный кадр из test.jpg по кругу (без алгоритмов)
# ────────────────────────────────────
@app.websocket("/session/{sid}/stream")
async def stream(sid: str, ws: WebSocket):
    if sid not in sessions:
        await ws.close(code=1008)
        return

    await ws.accept()
    base = os.path.dirname(__file__)
    test_img_path = os.path.join(base, "test.jpg")

    async def consumer():
        try:
            while True:
                # Принимаем любые сообщения от клиента, но не обрабатываем
                _ = await ws.receive()  # json/bytes/close — игнорируем
        except WebSocketDisconnect:
            return

    async def producer():
        try:
            while True:
                if os.path.isfile(test_img_path):
                    with open(test_img_path, "rb") as f:
                        await ws.send_bytes(f.read())
                await asyncio.sleep(1.0)
        except WebSocketDisconnect:
            return

    await asyncio.gather(consumer(), producer())


# ────────────────────────────────────
# LLM-усиление пользовательского промта (OpenAI)
# ────────────────────────────────────
async def _enhance_prompt_llm(user_prompt: str, base_prompt: str = "") -> str:
    """
    Делает текст пользовательского промта более ярким, ясным и выразительным, не меняя смысла.
    Возвращает исходный текст, если SDK недоступен или произошла ошибка.
    """
    if not user_prompt:
        return user_prompt
    if not _openai_available:
        return user_prompt

    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        return user_prompt

    # Модель можно переопределить через переменную окружения
    model_name = os.getenv("PROMPT_ENHANCER_MODEL", "gpt-4o-mini")

    system_ru = (
        "Ты — эксперт по визуальному сторителлингу и профессиональный редактор промтов. "
        "Перепиши пользовательское описание для генерации изображения так, чтобы оно звучало ярко, образно и конкретно. "
        "Сохрани исходный смысл, убери двусмысленность, избегай канцелярита, сделай формулировки живыми и точными. "
        "Пиши кратко (до ~120 слов), без списков и без технических метаданных камеры. "
        "Если дан стилистический якорь, деликатно интегрируй его атмосферу, но не замещай основное содержание."
    )
    system_en = (
        "You are a world-class visual prompt editor. "
        "Rewrite the user's description to be vivid, precise, and eloquent while preserving the original intent. "
        "Keep it concise (~120 words), avoid lists and camera-technical jargon. "
        "If a style anchor is provided, weave its mood subtly without overriding the main content."
    )

    # Определим язык ответа по наличию кириллицы
    target_is_ru = any("а" <= ch.lower() <= "я" for ch in user_prompt)
    system_msg = system_ru if target_is_ru else system_en

    user_msg = (
        ("Описание пользователя: " if target_is_ru else "User description: ") + user_prompt.strip()
    )
    if base_prompt:
        user_msg += "\n\n" + ("Стилистический якорь: " if target_is_ru else "Style anchor: ") + base_prompt.strip()

    try:
        if _use_v1_client:
            client = OpenAI()
            resp = client.chat.completions.create(
                model=model_name,
                temperature=0.7,
                max_tokens=500,
                messages=[
                    {"role": "system", "content": system_msg},
                    {"role": "user", "content": user_msg},
                ],
            )
            enhanced = (resp.choices[0].message.content or "").strip()
        else:
            openai_legacy.api_key = api_key  # type: ignore[attr-defined]
            resp = openai_legacy.ChatCompletion.create(  # type: ignore[attr-defined]
                model=model_name,
                temperature=0.7,
                max_tokens=500,
                messages=[
                    {"role": "system", "content": system_msg},
                    {"role": "user", "content": user_msg},
                ],
            )
            enhanced = (resp["choices"][0]["message"]["content"] or "").strip()

        # Простая защита от неожиданных ответов
        if not enhanced or len(enhanced) < 12:
            return user_prompt
        return enhanced
    except Exception:
        return user_prompt


# Необязательный вспомогательный REST-ендпоинт для отладки усиления промта
@app.post("/enhance_prompt")
async def enhance_prompt_api(payload: Dict = Body(..., embed=False)):
    user_prompt = (payload.get("prompt") or "").strip()
    base_prompt = (payload.get("base_prompt") or "").strip()
    if not user_prompt:
        raise HTTPException(status_code=400, detail="prompt is required")
    enhanced = await _enhance_prompt_llm(user_prompt=user_prompt, base_prompt=base_prompt)
    return {"enhanced_prompt": enhanced}

# Используем простые эндпоинты вместо StaticFiles для лучшей совместимости

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
