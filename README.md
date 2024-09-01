
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `mall`

<!-- badges: start -->
<!-- badges: end -->

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
and Snowflake. For local data, `mall` uses Ollama to call an LLM.

If you pass a table connected to **Databricks** via ODBC, `mall` will
automatically use Databricks’ LLM instead of Ollama. It will call the
corresponding SQL AI function.

## Motivation

We want to help data scientists use LLMs in a new way. Typically, LLMs
have been used to ask coding questions (chat) or for code completion
(Copilot). This interface provides an easy way to analyze text data, and
without having to spend time writing an NLP model.

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

The main functions in `mall` are verb-like functions that expect a `tbl`
as their first argument. This allows us to use them in piped operations.

### Sentiment

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
#> 3 Not sure how to feel about my new washi… neutral
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

``` r
reviews |> 
  llm_summarize(review, max_words = 5) 
#> # A tibble: 3 × 2
#>   review                                   .summary                        
#>   <chr>                                    <chr>                           
#> 1 This has been the best TV I've ever use… very pleased with tv performance
#> 2 I regret buying this laptop. It is too … laptop purchase turned out bad  
#> 3 Not sure how to feel about my new washi… mixed emotions about new washer
```

``` r
reviews |> 
  llm_summarize(review, max_words = 5, pred_name = "review_summary") 
#> # A tibble: 3 × 2
#>   review                                   review_summary                       
#>   <chr>                                    <chr>                                
#> 1 This has been the best TV I've ever use… very good television experience repo…
#> 2 I regret buying this laptop. It is too … laptop is too slow, noisy            
#> 3 Not sure how to feel about my new washi… uncertain about new washer purchase
```

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
