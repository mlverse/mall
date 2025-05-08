import pytest
import mall
import polars as pl
import shutil
import os


def test_summarize_prompt():
    df = pl.DataFrame(dict(x="x"))
    df.llm.use("test", "content", _cache="_test_cache")
    x = df.llm.summarize("x")
    assert (
        x["summary"][0]
        == "You are a helpful summarization engine. Your answer will contain no no capitalization and no explanations. Return no more than 10 words.   The answer is the summary of the following text:\n{}"
    )
    shutil.rmtree("_test_cache", ignore_errors=True)


def test_summarize_max():
    df = pl.DataFrame(dict(x="x"))
    df.llm.use("test", "content", _cache="_test_cache")
    x = df.llm.summarize("x", max_words=5)
    assert (
        x["summary"][0]
        == "You are a helpful summarization engine. Your answer will contain no no capitalization and no explanations. Return no more than 5 words.   The answer is the summary of the following text:\n{}"
    )
    shutil.rmtree("_test_cache", ignore_errors=True)
