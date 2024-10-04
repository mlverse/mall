

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

<small>shape: (3, 2)</small>

| review                           | sentiment  |
|----------------------------------|------------|
| str                              | str        |
| "This has been the best TV I've… | "positive" |
| "I regret buying this laptop. I… | "negative" |
| "Not sure how to feel about my … | "neutral"  |

``` python
reviews.llm.summarize("review", 5)
```

<small>shape: (3, 3)</small>

| review | sentiment | summary |
|----|----|----|
| str | str | str |
| "This has been the best TV I've… | "positive" | "very happy with this tv" |
| "I regret buying this laptop. I… | "negative" | "laptop not meeting expectation… |
| "Not sure how to feel about my … | "neutral" | "unsure about my new washer" |

``` python
reviews.llm.use(options = dict(seed = 100))
```

    {'backend': 'ollama', 'model': 'llama3.2', 'options': {'seed': 100}}

``` python
reviews.llm.summarize("review", 5)
```

<small>shape: (3, 3)</small>

| review | sentiment | summary |
|----|----|----|
| str | str | str |
| "This has been the best TV I've… | "positive" | "it's a great tv" |
| "I regret buying this laptop. I… | "negative" | "laptop not worth the money" |
| "Not sure how to feel about my … | "neutral" | "feeling uncertain about new pu… |

``` python
reviews.llm.summarize("review", 5)
```

<small>shape: (3, 3)</small>

| review | sentiment | summary |
|----|----|----|
| str | str | str |
| "This has been the best TV I've… | "positive" | "it's a great tv" |
| "I regret buying this laptop. I… | "negative" | "laptop not worth the money" |
| "Not sure how to feel about my … | "neutral" | "feeling uncertain about new pu… |
