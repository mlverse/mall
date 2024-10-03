def process_labels(x, if_list="", if_dict=""):
    if isinstance(x, list):
        out = ""
        for i in x:
            out += " " + i
        out = out.strip()
        out = out.replace(" ", ", ")
        out = if_list.replace("{values}", out)


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
