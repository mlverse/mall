import pytest
import mall
import polars as pl
import shutil
import os

if os._exists("_test_cache"): shutil.rmtree("_test_cache", ignore_errors=True)


def test_classify():
    df = pl.DataFrame(dict(x=["one", "two", "three"]))
    df.llm.use("test", "echo", _cache="_test_cache")
    x = df.llm.classify("x", ["one", "two"])
    assert pull(x, "classify") == ["one", "two", None]


def test_classify_dict():
    df = pl.DataFrame(dict(x=[1, 2, 3]))
    df.llm.use("test", "echo", _cache="_test_cache")
    x = df.llm.classify("x", {"one": 1, "two": 2})
    assert pull(x, "classify") == [1, 2, None]


def pull(df, col):
    out = []
    for i in df.select(col).to_dicts():
        out.append(i.get(col))
    return out
