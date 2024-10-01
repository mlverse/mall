

# mall

``` python
import mall 
import polars as tp

df = tp.DataFrame(
    data=["I am happy", "I am sad"],
    schema=[("txt", tp.String)],
)

df.llm.sentiment("txt")
```

<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (2, 2)</small>

| txt          | sentiment  |
|--------------|------------|
| str          | str        |
| "I am happy" | "positive" |
| "I am sad"   | "negative" |

</div>
