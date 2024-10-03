

# mall

``` python
pip install "mall @ git+https://git@github.com/edgararuiz/mall.git@python#subdirectory=python"
```

``` python
import mall 
import polars as pl

reviews = pl.DataFrame(
    data=[
        "This has been the best TV I've ever used. Great screen, and sound.", 
        "I regret buying this laptop. It is too slow and the keyboard is too noisy",
        "Not sure how to feel about my new washing machine. Great color, but hard to figure"
        ],
    schema=[("review", pl.String)],
)
```

``` python
reviews.llm.sentiment("review")
```

<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (3, 2)</small>

| review                           | sentiment  |
|----------------------------------|------------|
| str                              | str        |
| "This has been the best TV I've… | "positive" |
| "I regret buying this laptop. I… | "negative" |
| "Not sure how to feel about my … | "negative" |

</div>

``` python
reviews.llm.summarize("review", 5)
```

<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (3, 3)</small>

| review | sentiment | summary |
|----|----|----|
| str | str | str |
| "This has been the best TV I've… | "positive" | "best tv experience ever" |
| "I regret buying this laptop. I… | "negative" | "laptop purchase was a mistake" |
| "Not sure how to feel about my … | "negative" | "neutral about the washing mach… |

</div>
