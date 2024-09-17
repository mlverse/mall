# Sentiment translates expected Spark SQL

    Code
      llm_sentiment(df_spark, x)
    Output
      <SQL>
      SELECT `df`.*, ai_analyze_sentiment(`x`) AS `.sentiment`
      FROM `df`

