import pytest
import mall
import polars as pl
import pyarrow


def test_extract_list():
    df = pl.DataFrame(dict(x="x"))
    df.llm.use("test", "content")
    x = df.llm.extract("x", ["a", "b"])
    assert (
        x["extract"][0]
        == "You are a helpful text extraction engine. Extract the a, b being referred to on the text. I expect 2 items exactly. No capitalization. No explanations.  Return the response exclusively in a pipe separated list, and no headers.    The answer is based on the following text:\n{}"
    )


def test_extract_dict():
    df = pl.DataFrame(dict(x="x"))
    df.llm.use("test", "content")
    x = df.llm.extract("x", dict(a="one", b="two"))
    assert (
        x["extract"][0]
        == "You are a helpful text extraction engine. Extract the one, two being referred to on the text. I expect 2 items exactly. No capitalization. No explanations.  Return the response exclusively in a pipe separated list, and no headers.    The answer is based on the following text:\n{}"
    )


def test_extract_one():
    df = pl.DataFrame(dict(x="x"))
    df.llm.use("test", "content")
    x = df.llm.extract("x", labels="a")
    assert (
        x["extract"][0]
        == "You are a helpful text extraction engine. Extract the a being referred to on the text. I expect 1 item exactly. No capitalization. No explanations.     The answer is based on the following text:\n{}"
    )
