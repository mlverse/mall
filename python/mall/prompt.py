def sentiment(options, additional="", use=[]):
    new_options = process_labels(
        options,
        "Return only one of the following answers: {values} ",
        "- If the text is {key}, return {value} ",
    )
    x = (
        "You are a helpful sentiment engine."
        f" {new_options}. "
        " No capitalization. No explanations."
        f" {additional}"
    )
    return prompt_complete(x, use)


def summarize(max_words, additional="", use=[]):
    x = (
        "You are a helpful summarization engine. "
        "Your answer will contain no capitalization and no explanations. "
        f"Return no more than {max_words} words. "
        f"{additional}"
    )
    return prompt_complete(x, use)


def translate(language, additional="", use=[]):
    x = (
        "You are a helpful translation engine. "
        "You will return only the translation text, no explanations. "
        f"The target language to translate to is: {language}. "
        f"{additional}"
    )
    return prompt_complete(x, use)


def classify(labels, additional="", use=[]):
    labels = process_labels(
        labels,
        "Determine if the text refers to one of the following:{values} ",
        "- If the text is {key}, return {value} ",
    )
    x = (
        "You are a helpful classification engine. "
        f"{labels}. "
        "No capitalization. No explanations. "
        f"{additional}"
    )
    return prompt_complete(x, use)


def extract(labels, additional="", use=[]):
    col_labels = ""
    if isinstance(labels, list):
        no_labels = len(labels)
        plural = "s"
        text_multi = (
            "Return the response exclusively in a pipe separated list, and no headers. "
        )
        for label in labels:
            col_labels += label + " "
        col_labels = col_labels.rstrip()
        col_labels = col_labels.replace(" ", ", ")
    else:
        no_labels = 1
        plural = ""
        text_multi = ""
        col_labels = labels

    x = (
        "You are a helpful text extraction engine. "
        f"Extract the {col_labels} being referred to in the text. "
        f"I expect {no_labels} item{plural} exactly. "
        "No capitalization. No explanations. "
        f"{text_multi}"
        f"{additional}"
    )
    return prompt_complete(x, use)


def verify(what, additional="", use=[]):
    x = (
        "You are a helpful text analysis engine."
        "Determine if this is true "
        f"'{what}'."
        "There are only two acceptable answers, 'yes' and 'no'. "
        "No capitalization. No explanations."
        f"{additional}"
    )
    return prompt_complete(x, use)


def custom(x, use):
    return prompt_complete(x, use)


def process_labels(x, if_list="", if_dict=""):
    if isinstance(x, list):
        out = ""
        for i in x:
            out += " " + i
        out = out.strip()
        out = out.replace(" ", ", ")
        out = if_list.replace("{values}", str(out))
    if isinstance(x, dict):
        out = ""
        for i in x:
            new = if_dict
            new = new.replace("{key}", i)
            new = new.replace("{value}", str(x.get(i)))
            out += " " + new
    return out


def prompt_complete(x, use):
    backend = use.get("backend")
    if backend == "chatlas":
        x = (
            x
            + "The answer will be based on each individual prompt."
            + " Treat each prompt as unique when deciding the answer."
        )
    else:
        x = x + "The answer is based on the following text:\n{}"
    return x
