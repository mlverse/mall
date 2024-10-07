import ollama
import json
import hashlib


def build_msg(x, msg):
    out = []
    for msgs in msg:
        out.append({"role": msgs["role"], "content": msgs["content"].format(x)})
    return out


def llm_call(x, msg, use, preview=True, valid_resps=""):

    call = dict(
        model=use.get("model"),
        messages=build_msg(x, msg),
        options=use.get("options"),
    )

    if preview:
        print(call)

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


def build_hash(x):
    if isinstance(x, dict):
        x = json.dumps(x)
    x_sha = hashlib.sha1(x.encode("utf-8"))
    x_digest = x_sha.hexdigest()
    return x_digest
