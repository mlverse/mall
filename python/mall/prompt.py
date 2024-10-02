def process_labels(x, if_characters="", if_list=""):
    return if_characters.format(x)


def sentiment(options, additional=""):
    new_options = process_labels(
        options,
        "Return only one of the following answers: {}",
        "- If the text is {f_lhs(x)}, return {f_rhs(x)}",
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
