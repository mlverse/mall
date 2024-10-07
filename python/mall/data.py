import polars as pl


class MallData:
    reviews = pl.DataFrame(
        data=[
            "This has been the best TV I've ever used. Great screen, and sound.",
            "I regret buying this laptop. It is too slow and the keyboard is too noisy",
            "Not sure how to feel about my new washing machine. Great color, but hard to figure",
        ],
        schema=[("review", pl.String)],
    )
