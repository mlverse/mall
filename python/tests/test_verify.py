import pytest
import mall
import polars as pl
import shutil
import os

def test_verify():
    df = pl.DataFrame(dict(x=[1, 1, 0, 2]))
    df.llm.use("test", "echo", _cache="_test_cache")
    x = df.llm.verify("x", "this is my question")
    assert pull(x, "verify") == [1, 1, 0, None]
    shutil.rmtree("_test_cache", ignore_errors=True)

def test_verify_yn():
    df = pl.DataFrame(dict(x=["y", "n", "y", "x"]))
    df.llm.use("test", "echo", _cache="_test_cache")
    x = df.llm.verify("x", "this is my question", ["y", "n"])
    assert pull(x, "verify") == ["y", "n", "y", None]
    shutil.rmtree("_test_cache", ignore_errors=True)

def pull(df, col):
    out = []
    for i in df.select(col).to_dicts():
        out.append(i.get(col))
    return out
