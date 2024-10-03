---
toc-title: Table of contents
---

# mall

``` python
pip install "mall @ git+https://git@github.com/edgararuiz/mall.git@python#subdirectory=python"
```

:::: {.cell execution_count="1"}
``` {.python .cell-code}
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

reviews.llm.sentiment("review")
```

::: {.cell-output .cell-output-display execution_count="3"}
<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (3, 2)</small>

  review                                 sentiment
  -------------------------------------- --------------
  str                                    str
  \"This has been the best TV I\'ve...   \"positive\"
  \"I regret buying this laptop. I...    \"negative\"
  \"Not sure how to feel about my ...    \"neutral\"

</div>
:::
::::
