
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mall

<!-- badges: start -->

[![Codecov test
coverage](https://codecov.io/gh/edgararuiz/mall/branch/main/graph/badge.svg)](https://app.codecov.io/gh/edgararuiz/mall?branch=main)
[![R-CMD-check](https://github.com/edgararuiz/mall/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/edgararuiz/mall/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

<!-- toc: start -->

- [Motivation](#motivation)
- [LLM functions](#llm-functions)
  - [Sentiment](#sentiment)
  - [Summarize](#summarize)
  - [Classify](#classify)
  - [Extract](#extract)
  - [Translate](#translate)
  - [Custom prompt](#custom-prompt)
- [Initialize session](#initialize-session)
- [Key considerations](#key-considerations)
- [Performance](#performance)
- [Vector functions](#vector-functions)
- [Databricks](#databricks)

<!-- toc: end -->

## Intro

Run multiple LLM predictions against a table. The predictions run
row-wise over a specified column. It works using a pre-determined
one-shot prompt, along with the current row’s content. The prompt that
is use will depend of the type of analysis needed. Currently, the
included prompts perform the following:

- Sentiment analysis
- Summarize the text
- Extract one, or several, specific pieces information from the text

This package is inspired by the SQL AI functions now offered by vendors
such as
[Databricks](https://docs.databricks.com/en/large-language-models/ai-functions.html)
and Snowflake. For local data, `mall` uses [Ollama](https://ollama.com/)
to call an LLM.

### Databricks integration

If you pass a table connected to **Databricks** via `odbc`, `mall` will
automatically use Databricks’ LLM instead of Ollama. It will call the
corresponding SQL AI function.

## Motivation

We want to new find ways to help data scientists use LLMs in their daily
work. Unlike the familiar interfaces, such as chatting and code
completion, this interface runs your text data directly against the LLM.
The LLM’s flexibility, allows for it to adapt to the subject of your
data, and provide surprisingly accurate predictions. This saves the data
scientist the need to write and tune an NLP model.

## LLM functions

We will start with a very small table with product reviews:

``` r
library(dplyr)

reviews <- tribble(
  ~review,
  "This has been the best TV I've ever used. Great screen, and sound.",
  "I regret buying this laptop. It is too slow and the keyboard is too noisy",
  "Not sure how to feel about my new washing machine. Great color, but hard to figure"
)
```

### Sentiment

Primarily, `mall` provides verb-like functions that expect a `tbl` as
their first argument. This allows us to use them in piped operations.

For the first example, we’ll asses the sentiment of each review. In
order to do this we will call `llm_sentiment()`:

``` r
library(mall)

reviews |>
  llm_sentiment(review)
```

The function let’s us modify the options to choose from:

``` r
reviews |>
  llm_sentiment(review, options = c("positive", "negative"))
```

As mentioned before, by being pipe friendly, the results from the LLM
prediction can be used in further transformations:

``` r
reviews |>
  llm_sentiment(review, options = c("positive", "negative")) |>
  filter(.sentiment == "negative")
```

### Summarize

There may be a need to reduce the number of words in a given text.
Usually, to make it easier to capture its intent. To do this, use
`llm_summarize()`. This function has an argument to control the maximum
number of words to output (`max_words`):

``` r
reviews |>
  llm_summarize(review, max_words = 5)
```

To control the name of the prediction field, you can change `pred_name`
argument. This works with the other `llm_` functions as well.

``` r
reviews |>
  llm_summarize(review, max_words = 5, pred_name = "review_summary")
```

### Classify

Use the LLM to categorize the text into one of the options you provide:

``` r
reviews |>
  llm_classify(review, c("appliance", "computer"))
```

### Extract

One of the most interesting operations. Using natural language, we can
tell the LLM to return a specific part of the text. In the following
example, we request that the LLM return the product being referred to.
We do this by simply saying “product”. The LLM understands what we
*mean* by that word, and looks for that in the text.

``` r
reviews |>
  llm_extract(review, "product")
```

### Translate

As the title implies, this function will translate the text into a
specified language. What is really nice, it is that you don’t need to
specify the language of the source text. Only the target language needs
to be defined. The translation accuracy will depend on the LLM

``` r
reviews |>
  llm_translate(review, "spanish")
```

### Custom prompt

It is possible to pass your own prompt to the LLM, and have `mall` run
it against each text entry. Use `llm_custom()` to access this
functionality:

``` r
my_prompt <- paste(
  "Answer a question.",
  "Return only the answer, no explanation",
  "Acceptable answers are 'yes', 'no'",
  "Answer this about the following text, is this a happy customer?:"
)

reviews |>
  llm_custom(review, my_prompt)
```

## Initialize session

Invoking an `llm_` function will automatically initialize a model
selection if you don’t have one selected yet. If there is only one
option, it will pre-select it for you. If there are more than one
available models, then `mall` will present you as menu selection so you
can select which model you wish to use.

Calling `llm_use()` directly will let you specify the model and backend
to use. You can also setup additional arguments that will be passed down
to the function that actually runs the prediction. In the case of
Ollama, that function is
[`generate()`](https://hauselin.github.io/ollama-r/reference/generate.html).

``` r
llm_use("ollama", "llama3.1", seed = 100, temperature = 0.2)
```

## Key considerations

The main consideration is **cost**. Either, time cost, or money cost.

If using this method with an LLM locally available, the cost will be a
long running time. Unless using a very specialized LLM, a given LLM is a
general model. It was fitted using a vast amount of data. So determining
a response for each row, takes longer than if using a manually created
NLP model. The default model used in Ollama is Llama 3.1, which was
fitted using 8B parameters.

If using an external LLM service, the consideration will need to be for
the billing costs of using such service. Keep in mind that you will be
sending a lot of data to be evaluated.

Another consideration is the novelty of this approach. Early tests are
providing encouraging results. But you, as an user, will still need to
keep in mind that the predictions will not be infallible, so always
check the output. At this time, I think the best use for this method, is
for a quick analysis.

## Performance

We will briefly cover this methods performance from two perspectives:

- How long the analysis takes to run locally

- How well it predicts

To do so, we will use the `data_bookReviews` data set, provided by the
`classmap` package. For this exercise, only the first 100, of the total
1,000, are going to be part of this analysis.

``` r
library(classmap)

data(data_bookReviews)

book_reviews <- data_bookReviews |>
  head(100) |>
  as_tibble()

glimpse(book_reviews)
```

As per the docs, `sentiment` is a factor indicating the sentiment of the
review: negative (1) or positive (2)

``` r
length(strsplit(paste(book_reviews, collapse = " "), " ")[[1]])
```

Just to get an idea of how much data we’re processing, I’m using a very,
very simple word count. So we’re analyzing a bit over 20 thousand words.

``` r
library(tictoc)

tic()
reviews_llm <- book_reviews |>
  llm_sentiment(
    col = review,
    options = c("positive", "negative"),
    pred_name = "predicted"
  )
toc()
```

As far as **time**, on my Apple M3 machine, it took about 3 minutes to
process, 100 rows, containing 20 thousand words. Setting `temp` to 0.2
in `llm_use()`, made the model run a bit faster.

The package uses `purrr` to send each prompt individually to the LLM.
But, I did try a few different ways to speed up the process,
unsuccessfully:

- Used `furrr` to send multiple requests at a time. This did not work
  because either the LLM or Ollama processed all my requests serially.
  So there was no improvement.

- I also tried sending more than one row’s text at a time. This cause
  instability in the number of results. For example sending 5 at a time,
  sometimes returned 7 or 8. Even sending 2 was not stable.

This is what the new table looks like:

``` r
reviews_llm
```

I used `yardstick` to see how well the model performed. Of course, the
accuracy will not be of the “truth”, but rather the package’s results
recorded in `sentiment`.

``` r
library(forcats)

reviews_llm |>
  mutate(fct_pred = as.factor(ifelse(predicted == "positive", 2, 1))) |>
  yardstick::accuracy(sentiment, fct_pred)
```

## Vector functions

`mall` includes functions that expect a vector, instead of a table, to
run the predictions. This should make it easier to test things, such as
custom prompts or results of specific text. Each `llm_` function has a
corresponding `llm_vec_` function:

``` r
llm_vec_sentiment("I am happy")
```

``` r
llm_vec_translate("Este es el mejor dia!", "english")
```

## Databricks

This brief example shows how seamless it is to use the same `llm_`
functions, but against a remote connection:

``` r
library(DBI)

con <- dbConnect(
  odbc::databricks(),
  HTTPPath = Sys.getenv("DATABRICKS_PATH")
)

tbl_reviews <- copy_to(con, reviews)
```

As mentioned above, using `llm_sentiment()` in Databricks will call that
vendor’s SQL AI function directly:

``` r
tbl_reviews |>
  llm_sentiment(review)
```

There are some differences in the arguments, and output of the LLM’s.
Notice that instead of “neutral”, the prediction is “mixed”. The AI
Sentiment function does not allow to change the possible options.

Next, we will try `llm_summarize()`. The `max_words` argument maps to
the same argument in the AI Summarize function:

``` r
tbl_reviews |>
  llm_summarize(review, max_words = 5)
```
