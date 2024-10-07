import polars as pl
from mall.prompt import sentiment, summarize, translate, classify, extract, custom
from mall.llm import llm_call


@pl.api.register_dataframe_namespace("llm")
class MallFrame:
    """Extension to Polars that add ability to use
    an LLM to run batch predictions over a data frame
    """

    def __init__(self, df: pl.DataFrame) -> None:
        self._df = df
        self._use = dict(
            backend = "ollama",
            model = "llama3.2", 
            _cache = "_mall_cache"
        ) 

    def use(self, backend="", model="", _cache = "_mall_cache", **kwargs):
        if backend != "":
            self._use.update(dict(backend = backend))
        if model != "":
            self._use.update(dict(model = model))
        self._use.update(dict(_cache = _cache))
        self._use.update(dict(kwargs))
        return self._use

    def sentiment(
        self,
        col,
        options=["positive", "negative", "neutral"],
        additional="",
        pred_name="sentiment",
    ) -> list[pl.DataFrame]:
        df = map_call(
            df=self._df,
            col=col,
            msg=sentiment(options, additional=additional),
            pred_name=pred_name,
            use=self._use,
            valid_resps=options,
        )
        return df

    def summarize(
        self,
        col,
        max_words=10,
        additional="",
        pred_name="summary",
    ) -> list[pl.DataFrame]:
        df = map_call(
            df=self._df,
            col=col,
            msg=summarize(max_words, additional=additional),
            pred_name=pred_name,
            use=self._use,
        )
        return df

    def translate(
        self,
        col,
        language="",
        additional="",
        pred_name="translation",
    ) -> list[pl.DataFrame]:
        """Translate text into another language.

        Parameters
        ------
        col: str
            The name of the text field to process

        language: str
            The target language to translate to. For example 'French'.

        pred_name: str
            A character vector with the name of the new column where the
            prediction will be placed

        additional: str
            Inserts this text into the prompt sent to the LLM
        """
        df = map_call(
            df=self._df,
            col=col,
            msg=translate(language, additional=additional),
            pred_name=pred_name,
            use=self._use,
        )
        return df

    def classify(
        self,
        col,
        labels="",
        additional="",
        pred_name="classify",
    ) -> list[pl.DataFrame]:
        df = map_call(
            df=self._df,
            col=col,
            msg=classify(labels, additional=additional),
            pred_name=pred_name,
            use=self._use,
            valid_resps=labels,
        )
        return df

    def extract(
        self,
        col,
        labels="",
        additional="",
        pred_name="extract",
    ) -> list[pl.DataFrame]:
        df = map_call(
            df=self._df,
            col=col,
            msg=extract(labels, additional=additional),
            pred_name=pred_name,
            use=self._use,
            valid_resps=labels,
        )
        return df

    def custom(
        self,
        col,
        prompt="",
        valid_resps="",
        pred_name="custom",
    ) -> list[pl.DataFrame]:
        df = map_call(
            df=self._df,
            col=col,
            msg=custom(prompt),
            pred_name=pred_name,
            use=self._use,
            valid_resps=valid_resps,
        )
        return df


def map_call(df, col, msg, pred_name, use, valid_resps=""):
    df = df.with_columns(
        pl.col(col)
        .map_elements(
            lambda x: llm_call(x, msg, use, False, valid_resps),
            return_dtype=pl.String,
        )
        .alias(pred_name)
    )
    return df
