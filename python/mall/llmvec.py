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


class LLMVec:
    """Class that adds ability to use an LLM to run batch predictions

    ```{python}
    from chatlas import ChatOllama
    from mall import LLMVec

    chat = ChatOllama(model = "llama3.2")
    
    llm = LLMVec(chat)    
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

        ```{python}
        llm.sentiment(['I am happy', 'I am sad'])
        ```
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

        ```{python}
        llm.summarize(['This has been the best TV Ive ever used. Great screen, and sound.'], max_words = 5)
        ```
        """        
        return llm_loop(
            x=x,
            msg=summarize(max_words, additional=additional),
            use=self._use,
        )

    def translate(self, x, language="", additional="") -> list:
        """Translate text into another language.

        Parameters
        ------
        x : list
            A list of texts

        language : str
            The target language to translate to. For example 'French'.

        additional : str
            Inserts this text into the prompt sent to the LLM


        Examples
        ------

        ```{python}
        llm.translate(['This has been the best TV Ive ever used. Great screen, and sound.'], language = 'spanish')
        ```

        """        
        return llm_loop(
            x=x,
            msg=translate(language, additional=additional),
            use=self._use,
        )

    def classify(self, x, labels="", additional="") -> list:
        """Classify text into specific categories.

        Parameters
        ------
        x : list
            A list of texts

        labels : list
            A list or a DICT object that defines the categories to
            classify the text as. It will return one of the provided
            labels.

        additional : str
            Inserts this text into the prompt sent to the LLM

        Examples
        ------

        ```{python}
        llm.classify(['this is important!', 'there is no rush'], ['urgent', 'not urgent'])
        ```
        """        
        return llm_loop(
            x=x,
            msg=classify(labels, additional=additional),
            use=self._use,
            valid_resps=labels,
        )

    def extract(self, x, labels="", additional="") -> list:
        """Pull a specific label from the text.

        Parameters
        ------
        x : list
            A list of texts

        labels : list
            A list or a DICT object that defines tells the LLM what
            to look for and return

        additional : str
            Inserts this text into the prompt sent to the LLM

        Examples
        ------

        ```{python}
        llm.extract(['bob smith, 123 3rd street'], labels=['name', 'address'])
        ```
        """        
        return llm_loop(x=x, msg=extract(labels, additional=additional), use=self._use)

    def custom(self, x, prompt="", valid_resps="") -> list:
        """Provide the full prompt that the LLM will process.

        Parameters
        ------
        x : list
            A list of texts

        prompt : str
            The prompt to send to the LLM along with the `col`

        """        
        return llm_loop(x=x, msg=custom(prompt), use=self._use, valid_resps=labels)

    def verify(self, x, what="", yes_no=[1, 0], additional="") -> list:
        """Check to see if something is true about the text.

        Parameters
        ------
        x : list
            A list of texts

        what : str
            The statement or question that needs to be verified against the
            provided text

        yes_no : list
            A positional list of size 2, which contains the values to return
            if true and false. The first position will be used as the 'true'
            value, and the second as the 'false' value

        additional : str
            Inserts this text into the prompt sent to the LLM

        """        
        return llm_loop(
            x=x,
            msg=verify(what, additional=additional),
            use=self._use,
            valid_resps=yes_no,
            convert=dict(yes=yes_no[0], no=yes_no[1]),
        )
