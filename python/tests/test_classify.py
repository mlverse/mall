import pytest
import mall
import polars as pl
import pyarrow
import shutil
import os

if os._exists("_test_cache"):
    shutil.rmtree("_test_cache", ignore_errors=True)


def test_classify():
    df = pl.DataFrame(dict(x=["one", "two", "three"]))
    df.llm.use("test", "echo", _cache="_test_cache")
    x = df.llm.classify("x", ["one", "two"])
    assert (
        x.select("classify").to_pandas().to_string()
        == "  classify\n0      one\n1      two\n2     None"
    )


def test_classify_dict():
    df = pl.DataFrame(dict(x=[1, 2, 3]))
    df.llm.use("test", "echo", _cache="_test_cache")
    x = df.llm.classify("x", {"one": 1, "two": 2})
    assert (
        x.select("classify").to_pandas().to_string()
        == "   classify\n0       1.0\n1       2.0\n2       NaN"
    )
