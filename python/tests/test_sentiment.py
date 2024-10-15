import pytest
import mall
import polars as pl
import pyarrow

import shutil
import os

if os._exists("_test_cache"):
    shutil.rmtree("_test_cache", ignore_errors=True)


def test_sentiment_simple():
    data = mall.MallData
    reviews = data.reviews
    reviews.llm.use("test", "echo", _cache="_test_cache")
    x = reviews.llm.sentiment("review")
    assert (
        x.select("sentiment").to_pandas().to_string()
        == "  sentiment\n0      None\n1      None\n2      None"
    )


def sim_sentiment():
    df = pl.DataFrame(dict(x=["positive", "negative", "neutral", "not-real"]))
    df.llm.use("test", "echo", _cache="_test_cache")
    return df


def test_sentiment_valid():
    x = sim_sentiment()
    x = x.llm.sentiment("x")
    assert (
        x.select("sentiment").to_pandas().to_string()
        == "  sentiment\n0  positive\n1  negative\n2   neutral\n3      None"
    )


def test_sentiment_valid2():
    x = sim_sentiment()
    x = x.llm.sentiment("x", ["positive", "negative"])
    assert (
        x.select("sentiment").to_pandas().to_string()
        == "  sentiment\n0  positive\n1  negative\n2      None\n3      None"
    )


def test_sentiment_prompt():
    df = pl.DataFrame(dict(x="x"))
    df.llm.use("test", "content", _cache="_test_cache")
    x = df.llm.sentiment("x")
    assert (
        x["sentiment"][0]
        == "You are a helpful sentiment engine. Return only one of the following answers: positive, negative, neutral . No capitalization. No explanations.  The answer is based on the following text:\n{}"
    )
