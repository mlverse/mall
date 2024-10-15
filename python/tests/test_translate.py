import pytest
import mall
import polars as pl
import pyarrow


def test_translate_prompt():
    df = pl.DataFrame(dict(x="x"))
    df.llm.use("test", "content")
    x = df.llm.translate("x", language="spanish")
    assert (
        x["translation"][0]
        == "You are a helpful translation engine. You will return only the translation text, no explanations. The target language to translate to is: spanish.   The answer is the translation of the following text:\n{}"
    )
