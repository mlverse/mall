from mall.prompt import (
    sentiment,
    summarize,
    translate,
    classify,
    extract,
    custom,
    verify,
)

from mall.llm import llm_use, llm_loop


class LlmVec:
    def __init__(self, backend="", model="", _cache="_mall_cache", **kwargs):
        self._use = llm_use(backend=backend, model=model, _cache=_cache, **kwargs)

    def sentiment(
        self, x, options=["positive", "negative", "neutral"], additional=""
    ) -> list:
        out = llm_loop(
            x=x,
            msg=sentiment(options, additional=additional),
            use=self._use,
            valid_resps=options,
        )
        return out
