import polars as pl
import ollama
from mall.prompt import sentiment


@pl.api.register_dataframe_namespace("llm")
class MallFrame:
    def __init__(self, df: pl.DataFrame) -> None:
        self._df = df

    def sentiment(
        self,
        col,
        additional="",
        options="positive, negative",
        pred_name="sentiment",
    ) -> list[pl.DataFrame]:
        msg = sentiment(options, additional=additional)
        df = self._df.with_columns(
            pl.col(col)            
            .map_elements(
                lambda x: ollama.chat(
                    model="llama3.2",
                    messages= msg.format(x),
                )["message"]["content"],
                return_dtype=pl.String,
            )
            .alias(pred_name)
        )
        return df
