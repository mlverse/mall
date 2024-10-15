import pytest
import mall
import polars as pl
import pyarrow

import shutil
import os

if os._exists("_test_cache"):
    shutil.rmtree("_test_cache", ignore_errors=True)


def sim_verify():
    df = pl.DataFrame(dict(x=[1,1,0,2]))
    df.llm.use("test", "echo", _cache="_test_cache")
    return df


def test_verify():
    x = sim_verify()
    x = x.llm.verify("x", "this is my question")
    assert (
        x.select("verify").to_pandas().to_string()
        == '   verify\n0     1.0\n1     1.0\n2     0.0\n3     NaN'
    )

def test_verify_yn():
    df = pl.DataFrame(dict(x=["y", "n", "y", "x"]))
    df.llm.use("test", "echo", _cache="_test_cache")    
    x = df.llm.verify("x", "this is my question", ["y", "n"])
    assert (
        x.select("verify").to_pandas().to_string()
        == '  verify\n0      y\n1      n\n2      y\n3   None'
    )

