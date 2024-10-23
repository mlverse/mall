import polars as pl

from mall.prompt import (
    sentiment,
    summarize,
    translate,
    classify,
    extract,
    custom,
    verify,
)
from mall.llm import map_call


@pl.api.register_dataframe_namespace("llm")
class MallFrame:
    """Extension to Polars that add ability to use
    an LLM to run batch predictions over a data frame

    We will start by loading the needed libraries, and
    set up the data frame that will be used in the
    examples:

    ```{python}
    #| output: false
    import mall
    import polars as pl
    pl.Config(fmt_str_lengths=100)
    pl.Config.set_tbl_hide_dataframe_shape(True)
    pl.Config.set_tbl_hide_column_data_types(True)
    data = mall.MallData
    reviews = data.reviews
    reviews.llm.use(options = dict(seed = 100))
    ```
    """

    def __init__(self, df: pl.DataFrame) -> None:
        self._df = df
        self._use = dict(backend="ollama", model="llama3.2", _cache="_mall_cache")

    def use(self, backend="", model="", _cache="_mall_cache", **kwargs):
        """Define the model, backend, and other options to use to
        interact with the LLM.

        Parameters
        ------
        backend : str
            The name of the backend to use. At the beginning of the session
            it defaults to "ollama". If passing `""`, it will remain unchanged
        model : str
            The name of the model tha the backend should use. At the beginning
            of the session it defaults to "llama3.2". If passing `""`, it will
            remain unchanged
        _cache : str
            The path of where to save the cached results. Passing `""` disables
            the cache
        **kwargs
            Arguments to pass to the downstream Python call. In this case, the
            `chat` function in `ollama`

        Examples
        ------

        ```{python}
        # Additional arguments will be passed 'as-is' to the
        # downstream R function in this example, to ollama::chat()
        reviews.llm.use("ollama", "llama3.2", options = dict(seed = 100, temperature = 0.1))
        ```

        ```{python}
        # During the Python session, you can change any argument
        # individually and it will retain all of previous
        # arguments used
        reviews.llm.use(options = dict(temperature = 0.3))
        ```

        ```{python}
        # Use _cache to modify the target folder for caching
        reviews.llm.use(_cache = "_my_cache")
        ```

        ```{python}
        # Leave _cache empty to turn off this functionality
        reviews.llm.use(_cache = "")
        ```
        """
        if backend != "":
            self._use.update(dict(backend=backend))
        if model != "":
            self._use.update(dict(model=model))
        self._use.update(dict(_cache=_cache))
        self._use.update(dict(kwargs))
        return self._use

    def sentiment(
        self,
        col,
        options=["positive", "negative", "neutral"],
        additional="",
        pred_name="sentiment",
    ) -> list[pl.DataFrame]:
        """Use an LLM to run a sentiment analysis

        Parameters
        ------
        col : str
            The name of the text field to process

        options : list or dict
            A list of the sentiment options to use, or a named DICT
            object

        pred_name : str
            A character vector with the name of the new column where the
            prediction will be placed

        additional : str
            Inserts this text into the prompt sent to the LLM


        Examples
        ------

        ```{python}
        reviews.llm.sentiment("review")
        ```

        ```{python}
        # Use 'pred_name' to customize the new column's name
        reviews.llm.sentiment("review", pred_name="review_sentiment")
        ```

        ```{python}
        # Pass custom sentiment options
        reviews.llm.sentiment("review", ["positive", "negative"])
        ```

        ```{python}
        # Use a DICT object to specify values to return per sentiment
        reviews.llm.sentiment("review", {"positive" : 1, "negative" : 0})
        ```

        """
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
        """Summarize the text down to a specific number of words.

        Parameters
        ------
        col : str
            The name of the text field to process

        max_words : int
            Maximum number of words to use for the summary

        pred_name : str
            A character vector with the name of the new column where the
            prediction will be placed

        additional : str
            Inserts this text into the prompt sent to the LLM

        Examples
        ------

        ```{python}
        # Use max_words to set the maximum number of words to use for the summary
        reviews.llm.summarize("review", max_words = 5)
        ```

        ```{python}
        # Use 'pred_name' to customize the new column's name
        reviews.llm.summarize("review", 5, pred_name = "review_summary")
        ```
        """
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
        col : str
            The name of the text field to process

        language : str
            The target language to translate to. For example 'French'.

        pred_name : str
            A character vector with the name of the new column where the
            prediction will be placed

        additional : str
            Inserts this text into the prompt sent to the LLM


        Examples
        ------

        ```{python}
        reviews.llm.translate("review", "spanish")
        ```

        ```{python}
        reviews.llm.translate("review", "french")
        ```

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
        """Classify text into specific categories.

        Parameters
        ------
        col : str
            The name of the text field to process

        labels : list
            A list or a DICT object that defines the categories to
            classify the text as. It will return one of the provided
            labels.

        pred_name : str
            A character vector with the name of the new column where the
            prediction will be placed

        additional : str
            Inserts this text into the prompt sent to the LLM

        Examples
        ------

        ```{python}
        reviews.llm.classify("review", ["appliance", "computer"])
        ```

        ```{python}
        # Use 'pred_name' to customize the new column's name
        reviews.llm.classify("review", ["appliance", "computer"], pred_name="prod_type")
        ```

        ```{python}
        #Pass a DICT to set custom values for each classification
        reviews.llm.classify("review", {"appliance" : "1", "computer" : "2"})
        ```
        """
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
        expand_cols=False,
        additional="",
        pred_name="extract",
    ) -> list[pl.DataFrame]:
        """Pull a specific label from the text.

        Parameters
        ------
        col : str
            The name of the text field to process

        labels : list
            A list or a DICT object that defines tells the LLM what
            to look for and return

        pred_name : str
            A character vector with the name of the new column where the
            prediction will be placed

        additional : str
            Inserts this text into the prompt sent to the LLM

        Examples
        ------

        ```{python}
        # Use 'labels' to let the function know what to extract
        reviews.llm.extract("review", labels = "product")
        ```

        ```{python}
        # Use 'pred_name' to customize the new column's name
        reviews.llm.extract("review", "product", pred_name = "prod")
        ```

        ```{python}
        # Pass a vector to request multiple things, the results will be pipe delimeted
        # in a single column
        reviews.llm.extract("review", ["product", "feelings"])
        ```

        ```{python}
        # Set 'expand_cols' to True to split multiple lables
        # into individual columns
        reviews.llm.extract(
            col="review",
            labels=["product", "feelings"],
            expand_cols=True
            )
        ```

        ```{python}
        # Set custom names to the resulting columns
        reviews.llm.extract(
            col="review",
            labels={"prod": "product", "feels": "feelings"},
            expand_cols=True
            )
        ```

        """

        lab_names = labels
        lab_vals = labels
        if isinstance(labels, dict):
            lab_names = []
            lab_vals = []
            for label in labels:
                lab_names.append(label)
                lab_vals.append(labels[label])
        df = map_call(
            df=self._df,
            col=col,
            msg=extract(lab_vals, additional=additional),
            pred_name=pred_name,
            use=self._use,
        )
        if expand_cols:
            df = df.with_columns(
                pl.col("extract")
                .str.split_exact(n=len(labels) - 1, by="|")
                .struct.rename_fields(lab_names)
            ).unnest("extract")

        return df

    def custom(
        self,
        col,
        prompt="",
        valid_resps="",
        pred_name="custom",
    ) -> list[pl.DataFrame]:
        """Provide the full prompt that the LLM will process.

        Parameters
        ------
        col : str
            The name of the text field to process

        prompt : str
            The prompt to send to the LLM along with the `col`

        pred_name : str
            A character vector with the name of the new column where the
            prediction will be placed


        Examples
        ------

        ```{python}
        my_prompt = (
            "Answer a question."
            "Return only the answer, no explanation"
            "Acceptable answers are 'yes', 'no'"
            "Answer this about the following text, is this a happy customer?:"
        )

        reviews.llm.custom("review", prompt = my_prompt)
        ```
        """
        df = map_call(
            df=self._df,
            col=col,
            msg=custom(prompt),
            pred_name=pred_name,
            use=self._use,
            valid_resps=valid_resps,
        )
        return df

    def verify(
        self,
        col,
        what="",
        yes_no=[1, 0],
        additional="",
        pred_name="verify",
    ) -> list[pl.DataFrame]:
        """Check to see if something is true about the text.

        Parameters
        ------
        col : str
            The name of the text field to process

        what : str
            The statement or question that needs to be verified against the
            provided text

        yes_no : list
            A positional list of size 2, which contains the values to return
            if true and false. The first position will be used as the 'true'
            value, and the second as the 'false' value

        pred_name : str
            A character vector with the name of the new column where the
            prediction will be placed

        additional : str
            Inserts this text into the prompt sent to the LLM

        Examples
        ------

        ```{python}
        reviews.llm.verify("review", "is the customer happy")
        ```

        ```{python}
        # Use 'yes_no' to modify the 'true' and 'false' values to return
        reviews.llm.verify("review", "is the customer happy", ["y", "n"])
        ```
        """
        df = map_call(
            df=self._df,
            col=col,
            msg=verify(what, additional=additional),
            pred_name=pred_name,
            use=self._use,
            valid_resps=yes_no,
            convert=dict(yes=yes_no[0], no=yes_no[1]),
        )
        return df
