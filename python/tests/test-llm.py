import pytest
import mall
import polars as pl
import shutil
import os
import ollama

def test_ollama(monkeypatch):
    def mock_chat(model, messages, options):
        return dict(message = dict(content = "test"))
    monkeypatch.setattr(ollama, "chat", mock_chat)
    df = pl.DataFrame(dict(x="x"))
    df.llm.use("ollama", "llama3.2", _cache="")
    x = df.llm.summarize("x")
    assert (
        x["summary"][0] == "test"
    )

