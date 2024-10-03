

# mall

``` python
pip install "mall @ git+https://git@github.com/edgararuiz/mall.git@python#subdirectory=python"
```

``` python
import mall 
import polars as tp

df = tp.DataFrame(
    data=["I am happy", "I am sad"],
    schema=[("txt", tp.String)],
)

df.llm.sentiment("txt")
```


| txt          | sentiment  |
|--------------|------------|
| str          | str        |
| "I am happy" | "positive" |
| "I am sad"   | "negative" |


