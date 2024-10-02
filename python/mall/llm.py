import polars as pl
import ollama


@pl.api.register_dataframe_namespace("llm")
class MallFrame:
    def __init__(self, df: pl.DataFrame) -> None:
        self._df = df

    def sentiment(self, col, pred_name="sentiment") -> list[pl.DataFrame]:
        prompt = (
            "You are a helpful sentiment engine. Return only one of the following"
            + " answers: positive, negative, neutral. No capitalization. No explanations. "
            + "The answer is based on the following text:\n"
        )
        df = self._df.with_columns(
            pl.col(col)
            .map_elements(
                lambda x: ollama.chat(
                    model="llama3.2",
                    messages=[
                        {
                            "role": "user",
                            "content": prompt + x,
                            
                        }
                    ],
                )["message"]["content"],
                return_dtype=pl.String,
            )
            .alias(pred_name)
        )
        return df
