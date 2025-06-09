import pytest
import mall
import polars as pl
import shutil
import os


def test_custom_prompt():
    df = pl.DataFrame(dict(x="x"))
    df.llm.use("test", "content", _cache="_test_cache")
    x = df.llm.custom("x", "hello")
    assert x["custom"][0] == "hello: \n{}"
    shutil.rmtree("_test_cache", ignore_errors=True)

def test_custom_vec():
    from mall import LLMVec
    llm = LLMVec("test", "echo")
    x = llm.custom(["a"], "hello")
    assert x == ['a']
