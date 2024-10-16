import pytest
import mall
import polars as pl
import shutil
import os

if os._exists("_test_cache"): shutil.rmtree("_test_cache", ignore_errors=True)


def test_sentiment_simple():
    data = mall.MallData
    reviews = data.reviews
    reviews.llm.use("test", "echo", _cache="_test_cache")
    x = reviews.llm.sentiment("review")
    assert pull(x, "sentiment") == [None, None, None]


def sim_sentiment():
    df = pl.DataFrame(dict(x=["positive", "negative", "neutral", "not-real"]))
    df.llm.use("test", "echo", _cache="_test_cache")
    return df


def test_sentiment_valid():
    x = sim_sentiment()
    x = x.llm.sentiment("x")
    assert pull(x, "sentiment") == ["positive", "negative", "neutral", None]


def test_sentiment_valid2():
    x = sim_sentiment()
    x = x.llm.sentiment("x", ["positive", "negative"])
    assert pull(x, "sentiment") == ["positive", "negative", None, None]


def test_sentiment_prompt():
    df = pl.DataFrame(dict(x="x"))
    df.llm.use("test", "content", _cache="_test_cache")
    x = df.llm.sentiment("x")
    assert (
        x["sentiment"][0]
        == "You are a helpful sentiment engine. Return only one of the following answers: positive, negative, neutral . No capitalization. No explanations.  The answer is based on the following text:\n{}"
    )


def pull(df, col):
    out = []
    for i in df.select(col).to_dicts():
        out.append(i.get(col))
    return out
