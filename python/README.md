

<img src="https://mlverse.github.io/mall/site/images/favicon/apple-touch-icon-180x180.png" style="float:right"/>

<!-- badges: start -->

[![PyPi](https://img.shields.io/pypi/v/mlverse-mall.png)](https://pypi.org/project/mlverse-mall/)
[![Python
tests](https://github.com/mlverse/mall/actions/workflows/python-tests.yaml/badge.svg)](https://github.com/mlverse/mall/actions/workflows/python-tests.yaml)
\| [![Package
coverage](https://codecov.io/gh/mlverse/mall/branch/main/graph/badge.svg)](https://app.codecov.io/gh/mlverse/mall?branch=main)

<!-- badges: end -->

Use Large Language Models (LLM) to run Natural Language Processing (NLP)
operations against your data. It takes advantage of the LLMs general
language training in order to get the predictions, thus removing the
need to train a new traditional NLP model. `mall` is available for R and
Python.

It works by running multiple LLM predictions against your data. The
predictions are processed row-wise over a specified column. The package
includes prompts to perform the following specific NLP operations:

- Sentiment analysis
- Text summarizing
- Classify text
- Extract one, or several, specific pieces information from the text
- Translate text
- Verify that something is true about the text (binary)

For other NLP operations, `mall` offers the ability for you to write
your own prompt.

`mall` lets you **use local and external LLMs such as
[OpenAI](https://openai.com/), [Gemini](https://gemini.google.com/) and
[Anthropic](https://www.anthropic.com/)**. It uses
[`chatlas`](https://posit-dev.github.io/chatlas/) package to integrate
to perform the integration. It is a library extension to
[Polars](https://pola.rs/). To interact with Ollama, it uses the
official [Python library](https://github.com/ollama/ollama-python).

## Get started

Install `mall`:

- From PyPi:

  ``` python
  pip install mlverse-mall
  ```

- Install `mall` from Github

  ``` python
  pip install "mall @ git+https://git@github.com/mlverse/mall.git#subdirectory=python"
  ```

## LLM functions

We will start with loading a very small data set contained in `mall`. It
has 3 product reviews that we will use as the source of our examples.

``` python
import mall 
reviews = mall.MallData.reviews
reviews 
```

| review |
|----|
| "This has been the best TV I've ever used. Great screen, and sound." |
| "I regret buying this laptop. It is too slow and the keyboard is too noisy" |
| "Not sure how to feel about my new washing machine. Great color, but hard to figure" |

Because `mall` is loaded, the `reviews` Polars data frame contain a
class named `llm`. This is the class that enables access to all of the
NLP functions.

### Setup

The connection to the LLM is created via a `Chat` object from `chatlas`.
For this article, an Ollama chat connection is created:

``` python
from chatlas import ChatOllama
chat = ChatOllama(model = "llama3.2", seed = 100)
```

Now, `reviews` is “told” to use the `chat` object by calling
`.llm.use()`. In this case, the `_cache` path is set in order to re-run
render this article faster as edits are made to the prose:

``` python
reviews.llm.use(chat, _cache = "_readme_cache")
```

    {'backend': 'chatlas',
     'chat': <Chat Ollama/llama3.2 turns=0 tokens=0/0>,
     '_cache': '_readme_cache'}

<p>

### Sentiment

Automatically returns “positive”, “negative”, or “neutral” based on the
text.

``` python
reviews.llm.sentiment("review")
```

| review | sentiment |
|----|----|
| "This has been the best TV I've ever used. Great screen, and sound." | "positive" |
| "I regret buying this laptop. It is too slow and the keyboard is too noisy" | "negative" |
| "Not sure how to feel about my new washing machine. Great color, but hard to figure" | "neutral" |

### Summarize

There may be a need to reduce the number of words in a given text.
Typically to make it easier to understand its intent. The function has
an argument to control the maximum number of words to output
(`max_words`):

``` python
reviews.llm.summarize("review", 5)
```

| review | summary |
|----|----|
| "This has been the best TV I've ever used. Great screen, and sound." | "exceptional tv for its price" |
| "I regret buying this laptop. It is too slow and the keyboard is too noisy" | "not a good laptop purchase" |
| "Not sure how to feel about my new washing machine. Great color, but hard to figure" | "some assembly required included" |

### Classify

Use the LLM to categorize the text into one of the options you provide:

``` python
reviews.llm.classify("review", ["computer", "appliance"])
```

| review | classify |
|----|----|
| "This has been the best TV I've ever used. Great screen, and sound." | "appliance" |
| "I regret buying this laptop. It is too slow and the keyboard is too noisy" | "computer" |
| "Not sure how to feel about my new washing machine. Great color, but hard to figure" | "appliance" |

### Extract

One of the most interesting use cases Using natural language, we can
tell the LLM to return a specific part of the text. In the following
example, we request that the LLM return the product being referred to.
We do this by simply saying “product”. The LLM understands what we
*mean* by that word, and looks for that in the text.

``` python
reviews.llm.extract("review", "product")
```

| review | extract |
|----|----|
| "This has been the best TV I've ever used. Great screen, and sound." | "tv" |
| "I regret buying this laptop. It is too slow and the keyboard is too noisy" | "laptop" |
| "Not sure how to feel about my new washing machine. Great color, but hard to figure" | "washing machine" |

### Classify

Use the LLM to categorize the text into one of the options you provide:

``` python
reviews.llm.classify("review", ["computer", "appliance"])
```

| review | classify |
|----|----|
| "This has been the best TV I've ever used. Great screen, and sound." | "appliance" |
| "I regret buying this laptop. It is too slow and the keyboard is too noisy" | "computer" |
| "Not sure how to feel about my new washing machine. Great color, but hard to figure" | "appliance" |

### Verify

This functions allows you to check and see if a statement is true, based
on the provided text. By default, it will return a 1 for “yes”, and 0
for “no”. This can be customized.

``` python
reviews.llm.verify("review", "is the customer happy with the purchase")
```

| review | verify |
|----|----|
| "This has been the best TV I've ever used. Great screen, and sound." | 1 |
| "I regret buying this laptop. It is too slow and the keyboard is too noisy" | 0 |
| "Not sure how to feel about my new washing machine. Great color, but hard to figure" | 0 |

### Translate

As the title implies, this function will translate the text into a
specified language. What is really nice, it is that you don’t need to
specify the language of the source text. Only the target language needs
to be defined. The translation accuracy will depend on the LLM

``` python
reviews.llm.translate("review", "spanish")
```

| review | translation |
|----|----|
| "This has been the best TV I've ever used. Great screen, and sound." | "Este ha sido la mejor televisión que he utilizado. Una pantalla excelente y buena calidad de sonido." |
| "I regret buying this laptop. It is too slow and the keyboard is too noisy" | "Me arrepiento de haber comprado este portátil. Es demasiado lento y la tecla tiene un ruido excesivo… |
| "Not sure how to feel about my new washing machine. Great color, but hard to figure" | "No estoy seguro de cómo sentirme sobre mi nueva lavadora. Una buena cromática, pero difícil de compr… |

### Custom prompt

It is possible to pass your own prompt to the LLM, and have `mall` run
it against each text entry:

``` python
my_prompt = (
    "Answer a question."
    "Return only the answer, no explanation."
    "Only 'yes' and 'no' are the acceptable answers."
    "If unsure about the answer, return 'no'."
    "Answer this about the following text: 'is this a happy customer?':"
)

reviews.llm.custom("review", prompt = my_prompt)
```

| review | custom |
|----|----|
| "This has been the best TV I've ever used. Great screen, and sound." | "yes" |
| "I regret buying this laptop. It is too slow and the keyboard is too noisy" | "no" |
| "Not sure how to feel about my new washing machine. Great color, but hard to figure" | "no" |

## Results caching

By default `mall` caches the requests and corresponding results from a
given LLM run. Each response is saved as individual JSON files. By
default, the folder name is `_mall_cache`. The folder name can be
customized, if needed. Also, the caching can be turned off by setting
the argument to empty (`""`).

``` python
reviews.llm.use(_cache = "my_cache")
```

To turn off:

``` python
reviews.llm.use(_cache = "")
```

## Vectors

`mall` also includes a class to work with character vectors. This is a
separate module from that of the Polars extension, but offers the same
functionality. To start, import the `LLMVec` class from `mall`, and then
assign it to a new variable. The function call works just like
`<df>.llm.use()`, this is where the cache can be specified.

``` python
from mall import LLMVec
llm_ollama = LLMVec(chat, _cache="_readme_cache")
```

To use, call the same NLP functions used data frames. For example
sentiment:

``` python
llm_ollama.sentiment(["I am happy", "I am sad"])
```

    ['positive', 'negative']

The functions will also return a character vector. As mentioned before,
all of the same functions are accessible via this class:

- Classify
- Custom
- Extract
- Sentiment
- Summarize
- Translate
- Verify

## Key considerations

The main consideration is **cost**. Either, time cost, or money cost.

If using this method with an LLM locally available, the cost will be a
long running time. Unless using a very specialized LLM, a given LLM is a
general model. It was fitted using a vast amount of data. So determining
a response for each row, takes longer than if using a manually created
NLP model. The default model used in Ollama is [Llama
3.2](https://ollama.com/library/llama3.2), which was fitted using 3B
parameters.

If using an external LLM service, the consideration will need to be for
the billing costs of using such service. Keep in mind that you will be
sending a lot of data to be evaluated.

Another consideration is the novelty of this approach. Early tests are
providing encouraging results. But you, as an user, will still need to
keep in mind that the predictions will not be infallible, so always
check the output. At this time, I think the best use for this method, is
for a quick analysis.
