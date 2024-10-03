
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mall

<img src="man/figures/favicon/apple-touch-icon-180x180.png" style="float:right" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/edgararuiz/mall/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/edgararuiz/mall/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/edgararuiz/mall/branch/main/graph/badge.svg)](https://app.codecov.io/gh/edgararuiz/mall?branch=main)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

## Intro

Run multiple LLM predictions against a data frame. The predictions are
processed row-wise over a specified column. It works using a
pre-determined one-shot prompt, along with the current row’s content.
The prompt that is use will depend of the type of analysis needed.
Currently, the included prompts perform the following:

- [Sentiment analysis](#sentiment)
- [Text summarizing](#summarize)
- [Classify text](#classify)
- [Extract one, or several](#extract), specific pieces information from
  the text
- [Translate text](#translate)
- [Custom prompt](#custom-prompt)

This package is inspired by the SQL AI functions now offered by vendors
such as
[Databricks](https://docs.databricks.com/en/large-language-models/ai-functions.html)
and Snowflake. `mall` uses [Ollama](https://ollama.com/) to interact
with LLMs installed locally. That interaction takes place via the
[`ollamar`](https://hauselin.github.io/ollama-r/) package.

## Motivation

We want to new find ways to help data scientists use LLMs in their daily
work. Unlike the familiar interfaces, such as chatting and code
completion, this interface runs your text data directly against the LLM.
The LLM’s flexibility, allows for it to adapt to the subject of your
data, and provide surprisingly accurate predictions. This saves the data
scientist the need to write and tune an NLP model.

## Get started

- Install `mall` from Github

  ``` r
  pak::pak("edgararuiz/mall")
  ```

### With local LLMs

- Install Ollama in your machine. The `ollamar` package’s website
  provides this [Installation
  guide](https://hauselin.github.io/ollama-r/#installation)

- Download an LLM model. For example, I have been developing this
  package using Llama 3.2 to test. To get that model you can run:

  ``` r
  ollamar::pull("llama3.2")
  ```

### With Databricks

If you pass a table connected to **Databricks** via `odbc`, `mall` will
automatically use Databricks’ LLM instead of Ollama. *You won’t need
Ollama installed if you are using Databricks only.*

`mall` will call the appropriate SQL AI function. For more information
see our [Databricks
article.](https://edgararuiz.github.io/mall/articles/databricks.html)

## LLM functions

### Sentiment

Primarily, `mall` provides verb-like functions that expect a `tbl` as
their first argument. This allows us to use them in piped operations.

We will start with loading a very small data set contained in `mall`. It
has 3 product reviews that we will use as the source of our examples.

``` r
library(mall)

data("reviews")

reviews
#> # A tibble: 3 × 1
#>   review                                                                        
#>   <chr>                                                                         
#> 1 This has been the best TV I've ever used. Great screen, and sound.            
#> 2 I regret buying this laptop. It is too slow and the keyboard is too noisy     
#> 3 Not sure how to feel about my new washing machine. Great color, but hard to f…
```

For the first example, we’ll asses the sentiment of each review. In
order to do this we will call `llm_sentiment()`:

``` r
reviews |>
  llm_sentiment(review)
#> # A tibble: 3 × 2
#>   review                                                              .sentiment
#>   <chr>                                                               <chr>     
#> 1 This has been the best TV I've ever used. Great screen, and sound.  positive  
#> 2 I regret buying this laptop. It is too slow and the keyboard is to… negative  
#> 3 Not sure how to feel about my new washing machine. Great color, bu… neutral
```

The function let’s us modify the options to choose from:

``` r
reviews |>
  llm_sentiment(review, options = c("positive", "negative"))
#> # A tibble: 3 × 2
#>   review                                                              .sentiment
#>   <chr>                                                               <chr>     
#> 1 This has been the best TV I've ever used. Great screen, and sound.  positive  
#> 2 I regret buying this laptop. It is too slow and the keyboard is to… negative  
#> 3 Not sure how to feel about my new washing machine. Great color, bu… negative
```

As mentioned before, by being pipe friendly, the results from the LLM
prediction can be used in further transformations:

``` r
reviews |>
  llm_sentiment(review, options = c("positive", "negative")) |>
  filter(.sentiment == "negative")
#> # A tibble: 2 × 2
#>   review                                                              .sentiment
#>   <chr>                                                               <chr>     
#> 1 I regret buying this laptop. It is too slow and the keyboard is to… negative  
#> 2 Not sure how to feel about my new washing machine. Great color, bu… negative
```

### Summarize

There may be a need to reduce the number of words in a given text.
Usually, to make it easier to capture its intent. To do this, use
`llm_summarize()`. This function has an argument to control the maximum
number of words to output (`max_words`):

``` r
reviews |>
  llm_summarize(review, max_words = 5)
#> # A tibble: 3 × 2
#>   review                                        .summary                      
#>   <chr>                                         <chr>                         
#> 1 This has been the best TV I've ever used. Gr… it's a great tv               
#> 2 I regret buying this laptop. It is too slow … laptop purchase was a mistake 
#> 3 Not sure how to feel about my new washing ma… having mixed feelings about it
```

To control the name of the prediction field, you can change `pred_name`
argument. This works with the other `llm_` functions as well.

``` r
reviews |>
  llm_summarize(review, max_words = 5, pred_name = "review_summary")
#> # A tibble: 3 × 2
#>   review                                        review_summary                
#>   <chr>                                         <chr>                         
#> 1 This has been the best TV I've ever used. Gr… it's a great tv               
#> 2 I regret buying this laptop. It is too slow … laptop purchase was a mistake 
#> 3 Not sure how to feel about my new washing ma… having mixed feelings about it
```

### Classify

Use the LLM to categorize the text into one of the options you provide:

``` r
reviews |>
  llm_classify(review, c("appliance", "computer"))
#> # A tibble: 3 × 2
#>   review                                        .classify
#>   <chr>                                         <chr>    
#> 1 This has been the best TV I've ever used. Gr… computer 
#> 2 I regret buying this laptop. It is too slow … computer 
#> 3 Not sure how to feel about my new washing ma… appliance
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
#> # A tibble: 3 × 2
#>   review                                        .extract       
#>   <chr>                                         <chr>          
#> 1 This has been the best TV I've ever used. Gr… tv             
#> 2 I regret buying this laptop. It is too slow … laptop         
#> 3 Not sure how to feel about my new washing ma… washing machine
```

### Translate

As the title implies, this function will translate the text into a
specified language. What is really nice, it is that you don’t need to
specify the language of the source text. Only the target language needs
to be defined. The translation accuracy will depend on the LLM

``` r
reviews |>
  llm_translate(review, "spanish")
#> # A tibble: 3 × 2
#>   review                                        .translation                    
#>   <chr>                                         <chr>                           
#> 1 This has been the best TV I've ever used. Gr… Esta ha sido la mejor televisió…
#> 2 I regret buying this laptop. It is too slow … Me arrepiento de comprar este p…
#> 3 Not sure how to feel about my new washing ma… No estoy seguro de cómo me sien…
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
#> # A tibble: 3 × 2
#>   review                                                                   .pred
#>   <chr>                                                                    <chr>
#> 1 This has been the best TV I've ever used. Great screen, and sound.       Yes  
#> 2 I regret buying this laptop. It is too slow and the keyboard is too noi… No   
#> 3 Not sure how to feel about my new washing machine. Great color, but har… No
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
[`chat()`](https://hauselin.github.io/ollama-r/reference/chat.html).

``` r
llm_use("ollama", "llama3.2", seed = 100, temperature = 0)
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

data_bookReviews |>
  glimpse()
#> Rows: 1,000
#> Columns: 2
#> $ review    <chr> "i got this as both a book and an audio file. i had waited t…
#> $ sentiment <fct> 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 1, 1, 1, 1, 2, 1, …
```

As per the docs, `sentiment` is a factor indicating the sentiment of the
review: negative (1) or positive (2)

``` r
length(strsplit(paste(head(data_bookReviews$review, 100), collapse = " "), " ")[[1]])
#> [1] 20470
```

Just to get an idea of how much data we’re processing, I’m using a very,
very simple word count. So we’re analyzing a bit over 20 thousand words.

``` r
reviews_llm <- data_bookReviews |>
  head(100) |> 
  llm_sentiment(
    col = review,
    options = c("positive" ~ 2, "negative" ~ 1),
    pred_name = "predicted"
  )
#> ! There were 2 predictions with invalid output, they were coerced to NA
```

As far as **time**, on my Apple M3 machine, it took about 1.5 minutes to
process, 100 rows, containing 20 thousand words. Setting `temp` to 0 in
`llm_use()`, made the model run faster.

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
#> # A tibble: 100 × 3
#>    review                                        sentiment             predicted
#>    <chr>                                         <fct>                     <dbl>
#>  1 "i got this as both a book and an audio file… 1                             1
#>  2 "this book places too much emphasis on spend… 1                             1
#>  3 "remember the hollywood blacklist? the holly… 2                             2
#>  4 "while i appreciate what tipler was attempti… 1                             1
#>  5 "the others in the series were great, and i … 1                             1
#>  6 "a few good things, but she's lost her edge … 1                             1
#>  7 "words cannot describe how ripped off and di… 1                             1
#>  8 "1. the persective of most writers is shaped… 1                            NA
#>  9 "i have been a huge fan of michael crichton … 1                             1
#> 10 "i saw dr. polk on c-span a month or two ago… 2                             2
#> # ℹ 90 more rows
```

I used `yardstick` to see how well the model performed. Of course, the
accuracy will not be of the “truth”, but rather the package’s results
recorded in `sentiment`.

``` r
library(forcats)

reviews_llm |>
  mutate(predicted = as.factor(predicted)) |>
  yardstick::accuracy(sentiment, predicted)
#> # A tibble: 1 × 3
#>   .metric  .estimator .estimate
#>   <chr>    <chr>          <dbl>
#> 1 accuracy binary         0.980
```

## Vector functions

`mall` includes functions that expect a vector, instead of a table, to
run the predictions. This should make it easier to test things, such as
custom prompts or results of specific text. Each `llm_` function has a
corresponding `llm_vec_` function:

``` r
llm_vec_sentiment("I am happy")
#> [1] "positive"
```

``` r
llm_vec_translate("Este es el mejor dia!", "english")
#> [1] "It's the best day!"
```