from chatlas import ChatOpenAI
from chatlas import Chat
import pytest
import mall
import polars


def test_use_init():
    data = mall.MallData
    reviews = data.reviews
    x = reviews.llm.use()
    x == dict(backend="ollama", model="llama3.2", _cache="_mall_cache")


def test_use_mod1():
    data = mall.MallData
    reviews = data.reviews
    x = reviews.llm.use(options=dict(seed=100))
    x == dict(
        backend="ollama", model="llama3.2", _cache="_mall_cache", options=dict(seed=100)
    )


def test_use_mod2():
    data = mall.MallData
    reviews = data.reviews
    x = reviews.llm.use(options=dict(seed=99))
    x == dict(
        backend="ollama", model="llama3.2", _cache="_mall_cache", options=dict(seed=99)
    )


def test_use_chatlas(monkeypatch):
    monkeypatch.setenv("OPENAI_API_KEY", "TEST")
    data = mall.MallData
    reviews = data.reviews
    chat = ChatOpenAI()
    x = reviews.llm.use(chat)
    assert isinstance(x.get("chat"), Chat)
