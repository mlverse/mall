
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `mall`

<!-- badges: start -->
<!-- badges: end -->
<!-- toc: start -->

- [Intro](#intro)
  - [Databricks integration](#databricks-integration)
- [Motivation](#motivation)
- [Examples](#examples)
  - [Sentiment](#sentiment)
  - [Summarize](#summarize)
  - [Classify](#classify)
  - [Extract](#extract-)
  - [Translate](#translate)
  - [Custom prompt](#custom-prompt)
  - [Init](#init)
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

## Examples

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
#> ■■■■■■■■■■■ 33% | ETA: 4s ■■■■■■■■■■■■■■■■■■■■■ 67% | ETA: 1s
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
#> ! There were 1 predictions with invalid output, they were coerced to NA
#> # A tibble: 1 × 2
#>   review                                   .sentiment
#>   <chr>                                    <chr>     
#> 1 I regret buying this laptop. It is too … negative
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
#>   review                                   .summary                          
#>   <chr>                                    <chr>                             
#> 1 This has been the best TV I've ever use… best tv experience overall good   
#> 2 I regret buying this laptop. It is too … slow laptop with annoying keyboard
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
#> 1 This has been the best TV I've ever use… great tv with good quality           
#> 2 I regret buying this laptop. It is too … laptop is too slow noisy             
#> 3 Not sure how to feel about my new washi… new washing machine causes uncertain…
```

### Classify

Use the LLM to categorize the text into one of the options you provide:

``` r
reviews |>
  llm_classify(review, c("appliance", "computer"))
#> # A tibble: 3 × 2
#>   review                                   .classify
#>   <chr>                                    <chr>    
#> 1 This has been the best TV I've ever use… appliance
#> 2 I regret buying this laptop. It is too … computer 
#> 3 Not sure how to feel about my new washi… appliance
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
#>   review                                   product        
#>   <chr>                                    <chr>          
#> 1 This has been the best TV I've ever use… tv             
#> 2 I regret buying this laptop. It is too … laptop         
#> 3 Not sure how to feel about my new washi… washing machine
```

### Translate

As the title implies, this function will translate the text into a
specified language. What is really nice, it is that you don’t need to
specify the language of the source text. Only the target language needs
to be defined. The translation accuracy will depend on the LLM

``` r
reviews |>
  llm_translate(review, "spanish")
#> ■■■■■■■■■■■ 33% | ETA: 3s ■■■■■■■■■■■■■■■■■■■■■ 67% | ETA: 2s
#> # A tibble: 3 × 2
#>   review                                   .translation                         
#>   <chr>                                    <chr>                                
#> 1 This has been the best TV I've ever use… Este ha sido el mejor televisor que …
#> 2 I regret buying this laptop. It is too … Me arrepiento de haber comprado esta…
#> 3 Not sure how to feel about my new washi… No estoy seguro de cómo sentirme ace…
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
#>   review                                   .pred
#>   <chr>                                    <chr>
#> 1 This has been the best TV I've ever use… Yes  
#> 2 I regret buying this laptop. It is too … No   
#> 3 Not sure how to feel about my new washi… No
```

### Init

Invoking an `llm_` function will automatically initialize a model
selection if you don’t have one selected yet. If there is only one
option, it will pre-select it for you. If there are more than one
available models, then `mall` will present you as menu selection so you
can select which model you wish to use.

Calling `mall_init()` directly will let you specify the model and backend
to use. You can also setup additional arguments that will be passed down
to the function that actually runs the prediction. In the case of
Ollama, that function is
[`generate()`](https://hauselin.github.io/ollama-r/reference/generate.html).

``` r
mall_init("ollama", "llama3.1", seed = 100, temperature = 0.2)
#> Provider: ollama
#> Model: llama3.1
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
#> Rows: 100
#> Columns: 2
#> $ review    <chr> "i got this as both a book and an audio file. i had waited t…
#> $ sentiment <fct> 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 1, 1, 1, 1, 2, 1, …
```

As per the docs, `sentiment` is a factor indicating the sentiment of the
review: negative (1) or positive (2)

``` r
length(strsplit(paste(book_reviews, collapse = " "), " ")[[1]])
#> [1] 20571
```

Just to get an idea of how much data we’re processing, I’m using a very,
very simple word count. So we’re analyzing a bit over 20 thousand words.

``` r
library(tictoc)

tic()
reviews_llm <- book_reviews |>
  llm_sentiment(
    x = review,
    options = c("positive", "negative"),
    pred_name = "predicted"
  )
#>  ■                                  1% |  ETA:  3m ■■                                 2% |  ETA:  2m ■■                                 3% |  ETA:  5m ■■                                 4% |  ETA:  4m ■■■                                5% |  ETA:  3m ■■■                                6% |  ETA:  3m ■■■                                7% |  ETA:  3m ■■■                                8% |  ETA:  3m ■■■■                               9% |  ETA:  3m ■■■■                              10% |  ETA:  3m ■■■■                              11% |  ETA:  3m ■■■■■                             12% |  ETA:  3m ■■■■■                             13% |  ETA:  2m ■■■■■                             14% |  ETA:  2m ■■■■■                             15% |  ETA:  2m ■■■■■■                            16% |  ETA:  2m ■■■■■■                            17% |  ETA:  2m ■■■■■■                            18% |  ETA:  2m ■■■■■■■                           19% |  ETA:  2m ■■■■■■■                           20% |  ETA:  2m ■■■■■■■                           21% |  ETA:  2m ■■■■■■■■                          22% |  ETA:  2m ■■■■■■■■                          23% |  ETA:  2m ■■■■■■■■                          24% |  ETA:  2m ■■■■■■■■■                         25% |  ETA:  2m ■■■■■■■■■                         26% |  ETA:  2m ■■■■■■■■■                         27% |  ETA:  2m ■■■■■■■■■                         28% |  ETA:  2m ■■■■■■■■■■                        29% |  ETA:  2m ■■■■■■■■■■                        30% |  ETA:  2m ■■■■■■■■■■                        31% |  ETA:  2m ■■■■■■■■■■■                       32% |  ETA:  2m ■■■■■■■■■■■                       33% |  ETA:  2m ■■■■■■■■■■■                       34% |  ETA:  1m ■■■■■■■■■■■                       35% |  ETA:  1m ■■■■■■■■■■■■                      36% |  ETA:  1m ■■■■■■■■■■■■                      37% |  ETA:  1m ■■■■■■■■■■■■                      38% |  ETA:  1m ■■■■■■■■■■■■■                     39% |  ETA:  1m ■■■■■■■■■■■■■                     40% |  ETA:  1m ■■■■■■■■■■■■■                     41% |  ETA:  1m ■■■■■■■■■■■■■■                    42% |  ETA:  1m ■■■■■■■■■■■■■■                    43% |  ETA:  1m ■■■■■■■■■■■■■■                    44% |  ETA:  1m ■■■■■■■■■■■■■■■                   45% |  ETA:  1m ■■■■■■■■■■■■■■■                   46% |  ETA:  1m ■■■■■■■■■■■■■■■                   47% |  ETA:  1m ■■■■■■■■■■■■■■■                   48% |  ETA:  1m ■■■■■■■■■■■■■■■■                  49% |  ETA:  1m ■■■■■■■■■■■■■■■■                  50% |  ETA:  1m ■■■■■■■■■■■■■■■■                  51% |  ETA:  1m ■■■■■■■■■■■■■■■■■                 52% |  ETA:  1m ■■■■■■■■■■■■■■■■■                 53% |  ETA:  1m ■■■■■■■■■■■■■■■■■                 54% |  ETA:  1m ■■■■■■■■■■■■■■■■■                 55% |  ETA:  1m ■■■■■■■■■■■■■■■■■■                56% |  ETA:  1m ■■■■■■■■■■■■■■■■■■                57% |  ETA:  1m ■■■■■■■■■■■■■■■■■■                58% |  ETA:  1m ■■■■■■■■■■■■■■■■■■■               59% |  ETA:  1m ■■■■■■■■■■■■■■■■■■■               60% |  ETA:  1m ■■■■■■■■■■■■■■■■■■■               61% |  ETA:  1m ■■■■■■■■■■■■■■■■■■■■              62% |  ETA:  1m ■■■■■■■■■■■■■■■■■■■■              63% |  ETA:  1m ■■■■■■■■■■■■■■■■■■■■              64% |  ETA:  1m ■■■■■■■■■■■■■■■■■■■■■             65% |  ETA:  1m ■■■■■■■■■■■■■■■■■■■■■             66% |  ETA: 48s ■■■■■■■■■■■■■■■■■■■■■             67% |  ETA: 47s ■■■■■■■■■■■■■■■■■■■■■             68% |  ETA: 45s ■■■■■■■■■■■■■■■■■■■■■■            69% |  ETA: 43s ■■■■■■■■■■■■■■■■■■■■■■            70% |  ETA: 42s ■■■■■■■■■■■■■■■■■■■■■■            71% |  ETA: 40s ■■■■■■■■■■■■■■■■■■■■■■■           72% |  ETA: 39s ■■■■■■■■■■■■■■■■■■■■■■■           73% |  ETA: 37s ■■■■■■■■■■■■■■■■■■■■■■■           74% |  ETA: 35s ■■■■■■■■■■■■■■■■■■■■■■■           75% |  ETA: 34s ■■■■■■■■■■■■■■■■■■■■■■■■          76% |  ETA: 33s ■■■■■■■■■■■■■■■■■■■■■■■■          77% |  ETA: 32s ■■■■■■■■■■■■■■■■■■■■■■■■          78% |  ETA: 30s ■■■■■■■■■■■■■■■■■■■■■■■■■         79% |  ETA: 29s ■■■■■■■■■■■■■■■■■■■■■■■■■         80% |  ETA: 28s ■■■■■■■■■■■■■■■■■■■■■■■■■         81% |  ETA: 26s ■■■■■■■■■■■■■■■■■■■■■■■■■■        82% |  ETA: 25s ■■■■■■■■■■■■■■■■■■■■■■■■■■        83% |  ETA: 23s ■■■■■■■■■■■■■■■■■■■■■■■■■■        84% |  ETA: 22s ■■■■■■■■■■■■■■■■■■■■■■■■■■■       85% |  ETA: 20s ■■■■■■■■■■■■■■■■■■■■■■■■■■■       86% |  ETA: 20s ■■■■■■■■■■■■■■■■■■■■■■■■■■■       87% |  ETA: 18s ■■■■■■■■■■■■■■■■■■■■■■■■■■■       88% |  ETA: 17s ■■■■■■■■■■■■■■■■■■■■■■■■■■■■      89% |  ETA: 15s ■■■■■■■■■■■■■■■■■■■■■■■■■■■■      90% |  ETA: 14s ■■■■■■■■■■■■■■■■■■■■■■■■■■■■      91% |  ETA: 12s ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■     92% |  ETA: 11s ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■     93% |  ETA: 10s ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■     94% |  ETA:  8s ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■     95% |  ETA:  7s ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■    96% |  ETA:  5s ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■    97% |  ETA:  5s ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■    98% |  ETA:  3s ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■   99% |  ETA:  2s                                                   ! There were 1 predictions with invalid output, they were coerced to NA
```

``` r
toc()
#> 167.909 sec elapsed
```

As far as **time**, on my Apple M3 machine, it took about 3 minutes to
process, 100 rows, containing 20 thousand words. Setting `temp` to 0.2
in `mall_init()`, made the model run a bit faster.

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
#>    review                                                    sentiment predicted
#>    <chr>                                                     <fct>     <chr>    
#>  1 "i got this as both a book and an audio file. i had wait… 1         negative 
#>  2 "this book places too much emphasis on spending money in… 1         negative 
#>  3 "remember the hollywood blacklist? the hollywood ten? i'… 2         negative 
#>  4 "while i appreciate what tipler was attempting to accomp… 1         negative 
#>  5 "the others in the series were great, and i really looke… 1         negative 
#>  6 "a few good things, but she's lost her edge and i find i… 1         negative 
#>  7 "words cannot describe how ripped off and disappointed i… 1         negative 
#>  8 "1. the persective of most writers is shaped by their ow… 1         negative 
#>  9 "i have been a huge fan of michael crichton for about 25… 1         negative 
#> 10 "i saw dr. polk on c-span a month or two ago. he was add… 2         positive 
#> # ℹ 90 more rows
```

I used `yardstick` to see how well the model performed. Of course, the
accuracy will not be of the “truth”, but rather the package’s results
recorded in `sentiment`.

``` r
library(forcats)

reviews_llm |>
  mutate(fct_pred = as.factor(ifelse(predicted == "positive", 2, 1))) |>
  yardstick::accuracy(sentiment, fct_pred)
#> # A tibble: 1 × 3
#>   .metric  .estimator .estimate
#>   <chr>    <chr>          <dbl>
#> 1 accuracy binary         0.939
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
#> [1] "This is the best day!"
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
#> # Source:   SQL [3 x 2]
#> # Database: Spark SQL 3.1.1[token@Spark SQL/hive_metastore]
#>   review                                                              .sentiment
#>   <chr>                                                               <chr>     
#> 1 This has been the best TV Ive ever used. Great screen, and sound.   positive  
#> 2 I regret buying this laptop. It is too slow and the keyboard is to… negative  
#> 3 Not sure how to feel about my new washing machine. Great color, bu… mixed
```

There are some differences in the arguments, and output of the LLM’s.
Notice that instead of “neutral”, the prediction is “mixed”. The AI
Sentiment function does not allow to change the possible options.

Next, we will try `llm_summarize()`. The `max_words` argument maps to
the same argument in the AI Summarize function:

``` r
tbl_reviews |>
  llm_summarize(review, max_words = 5)
#> # Source:   SQL [3 x 2]
#> # Database: Spark SQL 3.1.1[token@Spark SQL/hive_metastore]
#>   review                                                                .summary
#>   <chr>                                                                 <chr>   
#> 1 This has been the best TV Ive ever used. Great screen, and sound.     Superio…
#> 2 I regret buying this laptop. It is too slow and the keyboard is too … Slow, n…
#> 3 Not sure how to feel about my new washing machine. Great color, but … Initial…
```
