import polars as pl
import ollama
from mall.prompt import sentiment


def build_msg(x, msg):
    out = []
    for msgs in msg:
        out.append({"role": msgs["role"], "content": msgs["content"].format(x)})
    return out


def llm_call(x, msg, backend, model):
    if backend == "ollama":
        resp = ollama.chat(model=model, messages=build_msg(x, msg))
        out = resp["message"]["content"]
    return out


@pl.api.register_dataframe_namespace("llm")
class MallFrame:
    def __init__(self, df: pl.DataFrame) -> None:
        self._df = df
        self._use = {"backend": "ollama", "model": "llama3.2"}

    def use(self, backend="", model="", **kwars):
        print(self._use)
        return self._df

    def sentiment(
        self,
        col,
        additional="",
        options="positive, negative",
        pred_name="sentiment",
    ) -> list[pl.DataFrame]:
        msg = sentiment(options, additional=additional)
        backend = self._use["backend"]
        model = self._use["model"]
        self._df = self._df.with_columns(
            pl.col(col)
            .map_elements(
                lambda x: llm_call(x, msg, backend, model),
                return_dtype=pl.String,
            )
            .alias(pred_name)
        )
        return self._df
