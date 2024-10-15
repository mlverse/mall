import pytest
import mall
import polars
import pyarrow


def test_use_init():
    data = mall.MallData
    reviews = data.reviews
    reviews.llm.use("test")
    x = reviews.llm.sentiment("review")
    assert (
        x.select("sentiment").to_pandas().to_string()
        == "  sentiment\n0      None\n1      None\n2      None"
    )
