import ollama


def build_msg(x, msg):
    out = []
    for msgs in msg:
        out.append({"role": msgs["role"], "content": msgs["content"].format(x)})
    return out


def llm_call(x, msg, use):
    if use.get("backend"):
        resp = ollama.chat(
            model=use.get("model"),
            messages=build_msg(x, msg),
            options=use.get("options"),
        )
        out = resp["message"]["content"]
    return out
