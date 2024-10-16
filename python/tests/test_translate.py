import pytest
import mall
import polars as pl
import shutil
import os

if os._exists("_test_cache"): shutil.rmtree("_test_cache", ignore_errors=True)


def test_translate_prompt():
    df = pl.DataFrame(dict(x="x"))
    df.llm.use("test", "content", _cache="_test_cache")
    x = df.llm.translate("x", language="spanish")
    assert (
        x["translation"][0]
        == "You are a helpful translation engine. You will return only the translation text, no explanations. The target language to translate to is: spanish.   The answer is the translation of the following text:\n{}"
    )
