# mall

## Intro

Run multiple LLM predictions against a data frame. The predictions are
processed row-wise over a specified column. It works using a
pre-determined one-shot prompt, along with the current row’s content.

## Install

To install from Github, use:

``` python
pip install "mall @ git+https://git@github.com/edgararuiz/mall.git@python#subdirectory=python"
```

## Examples

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

## Sentiment


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

## Summarize

``` python
reviews.llm.summarize("review", 5)
```

<small>shape: (3, 2)</small>

| review                           | summary                          |
|----------------------------------|----------------------------------|
| str                              | str                              |
| "This has been the best TV I've… | "it's a great tv"                |
| "I regret buying this laptop. I… | "laptop not worth the money"     |
| "Not sure how to feel about my … | "feeling uncertain about new pu… |

## Translate (as in ‘English to French’)

``` python
reviews.llm.translate("review", "spanish")
```

<small>shape: (3, 2)</small>

| review                           | translation                      |
|----------------------------------|----------------------------------|
| str                              | str                              |
| "This has been the best TV I've… | "Esta ha sido la mejor TV que h… |
| "I regret buying this laptop. I… | "Lo lamento comprar este portát… |
| "Not sure how to feel about my … | "No estoy seguro de cómo sentir… |

## Classify

``` python
reviews.llm.classify("review", ["computer", "appliance"])
```

<small>shape: (3, 2)</small>

| review                           | classify    |
|----------------------------------|-------------|
| str                              | str         |
| "This has been the best TV I've… | "appliance" |
| "I regret buying this laptop. I… | "appliance" |
| "Not sure how to feel about my … | "appliance" |

## LLM session setup

``` python
reviews.llm.use(options = dict(seed = 100))
```

    {'backend': 'ollama', 'model': 'llama3.2', 'options': {'seed': 100}}
