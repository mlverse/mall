def process_labels(x, if_list="", if_dict=""):
    if isinstance(x, list):
        out = ""
        for i in x:
            out += " " + i
        out = out.strip()
        out = out.replace(" ", ", ")
        out = if_list.replace("{values}", out)
    if isinstance(x, dict):
        out = ""
        for i in x:
            new = if_dict
            new = new.replace("{key}", i)
            new = new.replace("{value}", x.get(i))
            out += " " + new
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
            "role": "user",
            "content": "You are a helpful translation engine."
            + "You will return only the translation text, no explanations."
            + f"The target language to translate to is: {language}."
            + f"{additional}"
            + "The answer is the translation of the following text:\n{}",
        }
    ]
    return msg


def classify(labels, additional=""):
    new_labels = process_labels(
        labels,
        "Determine if the text refers to one of the following:{values}",
        "- If the text is {key}, return {value}",
    )
    msg = [
        {
            "role": "user",
            "content": "You are a helpful classification engine. "
            + f"{new_labels}. "
            + "No capitalization. No explanations. "
            + f"{additional} "
            + "The answer is based on the following text:\n{}",
        }
    ]
    return msg


def extract(labels, additional=""):
    no_labels = len(labels)
    col_labels = ""
    for label in labels:
        col_labels += label + " "
    col_labels = col_labels.rstrip()
    col_labels = col_labels.replace(" ", ", ")
    if no_labels > 1:
        plural = "s"
        text_multi = (
            "Return the response in a simple list, pipe separated, and no headers. "
        )
    else:
        plural = ""
        text_multi = ""
    msg = [
        {
            "role": "user",
            "content": "You are a helpful text extraction engine."
            + f"Extract the {col_labels} being referred to on the text."
            + f"I expect {no_labels} item{plural} exactly."
            + "No capitalization. No explanations."
            + f"{text_multi}"
            + f"{additional}"
            + "The answer is based on the following text:\n{}",
        }
    ]
    return msg
