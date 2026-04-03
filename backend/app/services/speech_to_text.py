from __future__ import annotations

import logging
from functools import lru_cache

from ..core.config import get_settings

try:
    from faster_whisper import WhisperModel
except Exception:  # pragma: no cover - dependency may be absent in some environments
    WhisperModel = None

settings = get_settings()
logger = logging.getLogger("uvicorn.error")


@lru_cache(maxsize=1)
def _load_model():
    if WhisperModel is None:
        raise RuntimeError("Speech-to-text dependency is missing. Install faster-whisper to enable voice prompts.")

    try:
        return WhisperModel(
            settings.STT_MODEL_SIZE,
            device="cpu",
            compute_type="int8",
        )
    except Exception as exc:
        logger.exception("Failed to load STT model: %s", exc)
        raise RuntimeError("Unable to initialize speech-to-text model") from exc


def transcribe_audio_file(file_path: str, language: str | None = None) -> str:
    model = _load_model()
    options = {
        "beam_size": 1,
        "vad_filter": True,
        "condition_on_previous_text": False,
        "temperature": 0.0,
    }
    if language:
        options["language"] = language

    try:
        segments, _ = model.transcribe(file_path, **options)
    except Exception as exc:
        logger.exception("STT transcription failed: %s", exc)
        raise RuntimeError("Failed to transcribe audio") from exc

    text = " ".join(segment.text.strip() for segment in segments if segment.text and segment.text.strip()).strip()
    if not text:
        raise ValueError("No speech detected. Please try again.")
    return text
