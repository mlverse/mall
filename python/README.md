

<img src="https://mlverse.github.io/mall/site/images/favicon/apple-touch-icon-180x180.png" style="float:right" />

<!-- badges: start -->

[![Python
tests](https://github.com/mlverse/mall/actions/workflows/python-tests.yaml/badge.svg)](https://github.com/mlverse/mall/actions/workflows/python-tests.yaml)
[![Code
coverage](https://codecov.io/gh/mlverse/mall/branch/main/graph/badge.svg)](https://app.codecov.io/gh/mlverse/mall?branch=main)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

Run multiple LLM predictions against a data frame. The predictions are
processed row-wise over a specified column. It works using a
pre-determined one-shot prompt, along with the current row’s content.
`mall` has been implemented for both R and Python. The prompt that is
use will depend of the type of analysis needed.

Currently, the included prompts perform the following:

- [Sentiment analysis](#sentiment)
- [Text summarizing](#summarize)
- [Classify text](#classify)
- [Extract one, or several](#extract), specific pieces information from
  the text
- [Translate text](#translate)
- [Verify that something it true](#verify) about the text (binary)
- [Custom prompt](#custom-prompt)

This package is inspired by the SQL AI functions now offered by vendors
such as
[Databricks](https://docs.databricks.com/en/large-language-models/ai-functions.html)
and Snowflake. `mall` uses [Ollama](https://ollama.com/) to interact
with LLMs installed locally.

For **Python**, `mall` is a library extension to
[Polars](https://pola.rs/). To interact with Ollama, it uses the
official [Python library](https://github.com/ollama/ollama-python).

``` python
reviews.llm.sentiment("review")
```

## Motivation

We want to new find ways to help data scientists use LLMs in their daily
work. Unlike the familiar interfaces, such as chatting and code
completion, this interface runs your text data directly against the LLM.

The LLM’s flexibility, allows for it to adapt to the subject of your
data, and provide surprisingly accurate predictions. This saves the data
scientist the need to write and tune an NLP model.

In recent times, the capabilities of LLMs that can run locally in your
computer have increased dramatically. This means that these sort of
analysis can run in your machine with good accuracy. Additionally, it
makes it possible to take advantage of LLM’s at your institution, since
the data will not leave the corporate network.

## Get started

- Install `mall` from Github

``` python
pip install "mall @ git+https://git@github.com/mlverse/mall.git#subdirectory=python"
```

- [Download Ollama from the official
  website](https://ollama.com/download)

- Install and start Ollama in your computer

- Install the official Ollama library

  ``` python
  pip install ollama
  ```

- Download an LLM model. For example, I have been developing this
  package using Llama 3.2 to test. To get that model you can run:

  ``` python
  import ollama
  ollama.pull('llama3.2')
  ```

## LLM functions

We will start with loading a very small data set contained in `mall`. It
has 3 product reviews that we will use as the source of our examples.

``` python
import mall 
data = mall.MallData
reviews = data.reviews

reviews 
```

| review |
|----|
| "This has been the best TV I've ever used. Great screen, and sound." |
| "I regret buying this laptop. It is too slow and the keyboard is too noisy" |
| "Not sure how to feel about my new washing machine. Great color, but hard to figure" |

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
| "This has been the best TV I've ever used. Great screen, and sound." | "great tv with good features" |
| "I regret buying this laptop. It is too slow and the keyboard is too noisy" | "laptop purchase was a mistake" |
| "Not sure how to feel about my new washing machine. Great color, but hard to figure" | "feeling uncertain about new purchase" |

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
| "This has been the best TV I've ever used. Great screen, and sound." | "Esta ha sido la mejor televisión que he utilizado hasta ahora. Gran pantalla y sonido." |
| "I regret buying this laptop. It is too slow and the keyboard is too noisy" | "Me arrepiento de comprar este portátil. Es demasiado lento y la tecla es demasiado ruidosa." |
| "Not sure how to feel about my new washing machine. Great color, but hard to figure" | "No estoy seguro de cómo sentirme con mi nueva lavadora. Un color maravilloso, pero muy difícil de en… |

### Custom prompt

It is possible to pass your own prompt to the LLM, and have `mall` run
it against each text entry:

``` python
my_prompt = (
    "Answer a question."
    "Return only the answer, no explanation"
    "Acceptable answers are 'yes', 'no'"
    "Answer this about the following text, is this a happy customer?:"
)

reviews.llm.custom("review", prompt = my_prompt)
```

| review | custom |
|----|----|
| "This has been the best TV I've ever used. Great screen, and sound." | "Yes" |
| "I regret buying this laptop. It is too slow and the keyboard is too noisy" | "No" |
| "Not sure how to feel about my new washing machine. Great color, but hard to figure" | "No" |

## Model selection and settings

You can set the model and its options to use when calling the LLM. In
this case, we refer to options as model specific things that can be set,
such as seed or temperature.

The model and options to be used will be defined at the Polars data
frame object level. If not passed, the default model will be
**llama3.2**.

``` python
reviews.llm.use("ollama", "llama3.2", options = dict(seed = 100))
```

#### Results caching

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
