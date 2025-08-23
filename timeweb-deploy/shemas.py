from pydantic import BaseModel, Field
from typing import Optional

# Request schemas
class SessionCreateIn(BaseModel):
    prompts: Optional[list[str]] = Field(default=None)
    promptType: Optional[int] = Field(default=None)  # добавлено поле типа промпта

class PromptIn(BaseModel):
    prompt: str

class UserDataIn(BaseModel):
    text: str
