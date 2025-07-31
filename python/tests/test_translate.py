import pytest
import mall
import polars as pl
import shutil
import os


def test_translate_prompt():
    df = pl.DataFrame(dict(x="x"))
    df.llm.use("test", "content", _cache="_test_cache")
    x = df.llm.translate("x", language="spanish")
    assert (
        x["translation"][0]
        == "You are a helpful translation engine. You will return only the translation text, no explanations. The target language to translate to is: spanish. The answer is based on the following text:\n{}"
    )
    shutil.rmtree("_test_cache", ignore_errors=True)

def test_translate_vec():
    from mall import LLMVec
    llm = LLMVec("test", "echo")
    x = llm.translate(["a"], "spanish")
    assert x == ['a']
