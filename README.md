
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `mall`

<!-- badges: start -->
<!-- badges: end -->

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

## Examples

We will start with a very small table with product reviews:

``` r
library(dplyr)

reviews  <- tribble(
  ~ review,
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
#> Ollama local server running
#> ■■■■■■■■■■■ 33% | ETA: 12s ■■■■■■■■■■■■■■■■■■■■■ 67% | ETA: 3s
#> # A tibble: 3 × 2
#>   review                                   .sentiment
#>   <chr>                                    <chr>     
#> 1 This has been the best TV I've ever use… positive  
#> 2 I regret buying this laptop. It is too … negative  
#> 3 Not sure how to feel about my new washi… neutral
```

The function let’s us modify the options to choose from:

``` r
reviews |>
  llm_sentiment(review, options = c("positive", "negative"))
#> # A tibble: 3 × 2
#>   review                                   .sentiment
#>   <chr>                                    <chr>     
#> 1 This has been the best TV I've ever use… positive  
#> 2 I regret buying this laptop. It is too … negative  
#> 3 Not sure how to feel about my new washi… negative
```

As mentioned before, by being pipe friendly, the results from the LLM
prediction can be used in further transformations:

``` r
reviews |>
  llm_sentiment(review, options = c("positive", "negative")) |> 
  filter(.sentiment == "negative")
#> # A tibble: 1 × 2
#>   review                                   .sentiment
#>   <chr>                                    <chr>     
#> 1 I regret buying this laptop. It is too … negative
```

## Summarize

There may be a need to reduce the number of words in a given text.
Usually, to make it easier to capture its intent. To do this, use
`llm_summarize()`. This function has an argument to control the maximum
number of words to output (`max_words`):

``` r
reviews |> 
  llm_summarize(review, max_words = 5) 
#> # A tibble: 3 × 2
#>   review                                   .summary                       
#>   <chr>                                    <chr>                          
#> 1 This has been the best TV I've ever use… good tv with great features    
#> 2 I regret buying this laptop. It is too … laptop is too slow noisy       
#> 3 Not sure how to feel about my new washi… mixed feelings about the washer
```

To control the name of the prediction field, you can change `pred_name`
argument. This works with the other `llm_` functions as well.

``` r
reviews |> 
  llm_summarize(review, max_words = 5, pred_name = "review_summary") 
#> # A tibble: 3 × 2
#>   review                                   review_summary                       
#>   <chr>                                    <chr>                                
#> 1 This has been the best TV I've ever use… very good tv experience overall.     
#> 2 I regret buying this laptop. It is too … laptop is too slow noisy             
#> 3 Not sure how to feel about my new washi… new washing machine purchase mixed e…
```

## Extract

One of the most interesting operations. Using natural language, we can
tell the LLM to return a specific part of the text. In the following
example, we request that the LLM return the product being referred to.
We do this by simply saying “product”. The LLM understands what we
*mean* by that word, and looks for that in the text.

``` r
reviews |>
  llm_extract(review, "product")
#> # A tibble: 3 × 2
#>   review                                   .pred          
#>   <chr>                                    <chr>          
#> 1 This has been the best TV I've ever use… tv             
#> 2 I regret buying this laptop. It is too … laptop         
#> 3 Not sure how to feel about my new washi… washing machine
```
