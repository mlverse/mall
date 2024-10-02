import polars as pl
import ollama
from mall.prompt import sentiment


def build_msg(x, msg):
    out = []
    for msgs in msg:
        out.append({"role": msgs["role"], "content": msgs["content"].format(x)})
    return out


def llm_call(x, msg):
    out = ollama.chat(model="llama3.2", messages=build_msg(x, msg))
    out = out["message"]["content"]
    return out


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
                lambda x: llm_call(x, msg),
                return_dtype=pl.String,
            )
            .alias(pred_name)
        )
        return df
