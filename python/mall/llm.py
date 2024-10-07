import ollama


def build_msg(x, msg):
    out = []
    for msgs in msg:
        out.append({"role": msgs["role"], "content": msgs["content"].format(x)})
    return out


def llm_call(x, msg, use, preview=True, valid_resps=""):
    resp = ollama.chat(
        model=use.get("model"),
        messages=build_msg(x, msg),
        options=use.get("options"),
    )
    out = resp["message"]["content"]
    if isinstance(valid_resps, list):
        if out not in valid_resps:
            out = None
    return out


# print(
#     dict(
#         model=use.get("model"),
#         messages=build_msg(x, msg),
#         options=use.get("options"),
#     )
# )
