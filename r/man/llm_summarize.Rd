% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/llm-summarize.R
\name{llm_summarize}
\alias{llm_summarize}
\alias{llm_vec_summarize}
\title{Summarize text}
\usage{
llm_summarize(
  .data,
  col,
  max_words = 10,
  pred_name = ".summary",
  additional_prompt = ""
)

llm_vec_summarize(x, max_words = 10, additional_prompt = "", preview = FALSE)
}
\arguments{
\item{.data}{A \code{data.frame} or \code{tbl} object that contains the text to be
analyzed}

\item{col}{The name of the field to analyze, supports \code{tidy-eval}}

\item{max_words}{The maximum number of words that the LLM should use in the
summary. Defaults to 10.}

\item{pred_name}{A character vector with the name of the new column where the
prediction will be placed}

\item{additional_prompt}{Inserts this text into the prompt sent to the LLM}

\item{x}{A vector that contains the text to be analyzed}

\item{preview}{It returns the R call that would have been used to run the
prediction. It only returns the first record in \code{x}. Defaults to \code{FALSE}
Applies to vector function only.}
}
\value{
\code{llm_summarize} returns a \code{data.frame} or \code{tbl} object.
\code{llm_vec_summarize} returns a vector that is the same length as \code{x}.
}
\description{
Use a Large Language Model (LLM) to summarize text
}
\examples{
\donttest{
library(mall)

data("reviews")

llm_use("ollama", "llama3.2", seed = 100, .silent = TRUE)

# Use max_words to set the maximum number of words to use for the summary
llm_summarize(reviews, review, max_words = 5)

# Use 'pred_name' to customize the new column's name
llm_summarize(reviews, review, 5, pred_name = "review_summary")

# For character vectors, instead of a data frame, use this function
llm_vec_summarize(
  "This has been the best TV I've ever used. Great screen, and sound.",
  max_words = 5
)

# To preview the first call that will be made to the downstream R function
llm_vec_summarize(
  "This has been the best TV I've ever used. Great screen, and sound.",
  max_words = 5,
  preview = TRUE
)
}
}
