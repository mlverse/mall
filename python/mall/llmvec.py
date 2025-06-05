from mall.prompt import (
    sentiment,
    summarize,
    translate,
    classify,
    extract,
    custom,
    verify,
)

from mall.llm import llm_use, llm_loop


class LlmVec:
    """Class that adds ability to use an LLM to run batch predictions

    ```{python}
    from chatlas import ChatOllama
    from mall import LlmVec

    chat = ChatOllama(model = "llama3.2")
    
    llm = LlmVec(chat)    
    ```
    """
    def __init__(self, backend="", model="", _cache="_mall_cache", **kwargs):
        self._use = llm_use(backend=backend, model=model, _cache=_cache, **kwargs)

    def sentiment(
        self, x, options=["positive", "negative", "neutral"], additional=""
    ) -> list:
        """Use an LLM to run a sentiment analysis

        Parameters
        ------
        x : list
            A list of texts

        options : list or dict
            A list of the sentiment options to use, or a named DICT
            object

        additional : str
            Inserts this text into the prompt sent to the LLM

        Examples
        ------

        llm.sentiment(['I am happy', 'I am sad'])
       
        """    
        return llm_loop(
            x=x,
            msg=sentiment(options, additional=additional),
            use=self._use,
            valid_resps=options,
        )

    def summarize(self, x, max_words=10, additional="") -> list:
        """Summarize the text down to a specific number of words.

        Parameters
        ------
        x : list
            A list of texts

        max_words : int
            Maximum number of words to use for the summary

        additional : str
            Inserts this text into the prompt sent to the LLM

        Examples
        ------

        llm.summarize('This has been the best TV I've ever used. Great screen, and sound.', max_words = 5)
        """        
        return llm_loop(
            x=x,
            msg=summarize(max_words, additional=additional),
            use=self._use,
        )

    def translate(self, x, language="", additional="") -> list:
        return llm_loop(
            x=x,
            msg=translate(language, additional=additional),
            use=self._use,
        )

    def classify(self, x, labels="", additional="") -> list:
        return llm_loop(
            x=x,
            msg=classify(labels, additional=additional),
            use=self._use,
            valid_resps=labels,
        )

    def extract(self, x, labels="", additional="") -> list:
        return llm_loop(x=x, msg=extract(labels, additional=additional), use=self._use)

    def custom(self, x, prompt="", valid_resps="") -> list:
        return llm_loop(x=x, msg=custom(prompt), use=self._use, valid_resps=labels)

    def verify(self, x, what="", yes_no=[1, 0], additional="") -> list:
        return llm_loop(
            x=x,
            msg=verify(what, additional=additional),
            use=self._use,
            valid_resps=yes_no,
            convert=dict(yes=yes_no[0], no=yes_no[1]),
        )
