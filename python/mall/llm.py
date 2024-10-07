import ollama
import json
import hashlib
import os


def build_msg(x, msg):
    out = []
    for msgs in msg:
        out.append({"role": msgs["role"], "content": msgs["content"].format(x)})
    return out


def llm_call(x, msg, use, preview=False, valid_resps=""):

    call = dict(
        model=use.get("model"),
        messages=build_msg(x, msg),
        options=use.get("options"),
    )

    if preview:
        print(call)

    cache = ""
    if use.get("_cache") != "":
        hash_call = build_hash(call)
        cache = cache_check(hash_call, use)

    if cache == "":
        resp = ollama.chat(
            model=use.get("model"),
            messages=build_msg(x, msg),
            options=use.get("options"),
        )
        out = resp["message"]["content"]
    else:
        out = cache

    if use.get("_cache") != "":
        if cache == "":
            cache_record(hash_call, use, call, out)

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


def cache_check(hash_call, use):
    file_path = cache_path(hash_call, use)
    if os.path.isfile(file_path):
        file_connection = open(file_path)
        file_read = file_connection.read()
        file_parse = json.loads(file_read)
        out = file_parse.get("response")
    else:
        out = ""
    return out


def cache_record(hash_call, use, call, response):
    file_path = cache_path(hash_call, use)
    file_folder = os.path.dirname(file_path)
    if not os.path.isdir(file_folder):
        os.makedirs(file_folder)
    contents = dict(request=call, response=response)
    json_contents = json.dumps(contents)
    with open(file_path, "w") as file:
        file.write(json_contents)


def cache_path(hash_call, use):
    sub_folder = hash_call[0:2]
    file_path = use.get("_cache") + "/" + sub_folder + "/" + hash_call + ".json"
    return file_path
