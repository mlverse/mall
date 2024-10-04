def process_labels(x, if_list="", if_dict=""):
    if isinstance(x, list):
        out = ""
        for i in x:
            out += " " + i
        out = out.strip()
        out = out.replace(" ", ", ")
        out = if_list.replace("{values}", out)
    return out


def sentiment(options, additional=""):
    new_options = process_labels(
        options,
        "Return only one of the following answers: {values}",
        "- If the text is {key}, return {value}",
    )
    msg = [
        {
            "role": "user",
            "content": "You are a helpful sentiment engine. "
            + f"{new_options}. "
            + "No capitalization. No explanations. "
            + f"{additional} "
            + "The answer is based on the following text:\n{}",
        }
    ]
    return msg


def summarize(max_words, additional=""):
    msg = [
        {
            "role": "user",
            "content": "You are a helpful summarization engine."
            + "Your answer will contain no no capitalization and no explanations."
            + f"Return no more than "
            + str(max_words)
            + " words."
            + f"{additional}"
            + "The answer is the summary of the following text:\n{}",
        }
    ]
    return msg


def translate(language, additional=""):
    msg = [
        {
            "You are a helpful translation engine."
            + "You will return only the translation text, no explanations."
            + f"The target language to translate to is: {language}."
            + f"{additional}"
            + "The answer is the translation of the following text:\n{}"
        }
    ]
    return msg
