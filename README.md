
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
#> ■■■■■■■■■■■ 33% | ETA: 3s
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
#> # A tibble: 2 × 2
#>   review                                   .sentiment
#>   <chr>                                    <chr>     
#> 1 I regret buying this laptop. It is too … negative  
#> 2 Not sure how to feel about my new washi… negative
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
#> 1 This has been the best TV I've ever use… best tv ever used                    
#> 2 I regret buying this laptop. It is too … disappointing purchase experience wi…
#> 3 Not sure how to feel about my new washi… mixed feelings about new washer
```

To control the name of the prediction field, you can change `pred_name`
argument. This works with the other `llm_` functions as well.

``` r
reviews |> 
  llm_summarize(review, max_words = 5, pred_name = "review_summary") 
#> # A tibble: 3 × 2
#>   review                                   review_summary                       
#>   <chr>                                    <chr>                                
#> 1 This has been the best TV I've ever use… very good tv experience reported.    
#> 2 I regret buying this laptop. It is too … disappointed with new laptop purchase
#> 3 Not sure how to feel about my new washi… new washing machine is average
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

## Key considerations

The main consideration is **cost**. Either, time cost, or money cost.

If using this method with an LLM locally available, the cost will be a
long running time. Unless using a very specialized LLM, a given LLM is a
general model. It was fitted using a vast amount of data. So determining
a response for each row, takes longerthat if using a manually created
NLP model. The default model used in Ollama is Llama 3.1, which was
fitted using 8B parameters.

If using an external LLM service, the consideration will need to be for
the billing costs of using such service. Keep in mind that you will be
sending a lot of data to be evaluated.

Another consideration is the novelty of this approach. Early tests are
providing encouraging results. But you, as an user, will still need to
keep in mind that the predictions will not be infalable, so always check
the output. At this time, I think the best use for this method, is for a
quick analysis.

## Performance

``` r
library(classmap)

data(data_bookReviews)

book_reviews <- data_bookReviews |> 
  head(10) |> 
  as_tibble()

glimpse(book_reviews)
#> Rows: 10
#> Columns: 2
#> $ review    <chr> "i got this as both a book and an audio file. i had waited t…
#> $ sentiment <fct> 1, 1, 2, 1, 1, 1, 1, 1, 1, 2
```

As per the docs, `sentiment` is a factor indicating the sentiment of the
review: negative (1) or positive (2)

``` r
length(strsplit(paste(book_reviews, collapse = " "), " ")[[1]])
#> [1] 2683
```

``` r
reviews_llm <- book_reviews |> 
  llm_sentiment(review, pred_name = "predicted")
#> ■■■■ 10% | ETA: 18s ■■■■■■■ 20% | ETA: 10s ■■■■■■■■■■ 30% | ETA: 22s
#> ■■■■■■■■■■■■■ 40% | ETA: 15s ■■■■■■■■■■■■■■■■ 50% | ETA: 10s
#> ■■■■■■■■■■■■■■■■■■■ 60% | ETA: 7s ■■■■■■■■■■■■■■■■■■■■■■ 70% | ETA: 6s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■ 80% | ETA: 4s ■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 90% | ETA:
#> 2s
```

``` r

reviews_llm
#> # A tibble: 10 × 3
#>    review                                                    sentiment predicted
#>    <chr>                                                     <fct>     <chr>    
#>  1 "i got this as both a book and an audio file. i had wait… 1         negative 
#>  2 "this book places too much emphasis on spending money in… 1         negative 
#>  3 "remember the hollywood blacklist? the hollywood ten? i'… 2         positive 
#>  4 "while i appreciate what tipler was attempting to accomp… 1         negative 
#>  5 "the others in the series were great, and i really looke… 1         negative 
#>  6 "a few good things, but she's lost her edge and i find i… 1         negative 
#>  7 "words cannot describe how ripped off and disappointed i… 1         negative 
#>  8 "1. the persective of most writers is shaped by their ow… 1         neutral  
#>  9 "i have been a huge fan of michael crichton for about 25… 1         negative 
#> 10 "i saw dr. polk on c-span a month or two ago. he was add… 2         positive
```

``` r
library(forcats)

reviews_llm |> 
  mutate(fct_pred = as.factor(ifelse(predicted == "positive", 2, 1))) |> 
  yardstick::accuracy(sentiment, fct_pred)
#> # A tibble: 1 × 3
#>   .metric  .estimator .estimate
#>   <chr>    <chr>          <dbl>
#> 1 accuracy binary             1
```
