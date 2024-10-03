

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
def markdown(x):
    return x.to_pandas().to_markdown()
```

``` python
markdown(reviews.llm.sentiment("review"))
```

    "|    | review                                                                             | sentiment   |\n|---:|:-----------------------------------------------------------------------------------|:------------|\n|  0 | This has been the best TV I've ever used. Great screen, and sound.                 | positive    |\n|  1 | I regret buying this laptop. It is too slow and the keyboard is too noisy          | negative    |\n|  2 | Not sure how to feel about my new washing machine. Great color, but hard to figure | neutral     |"
