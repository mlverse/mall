import polars as pl
import ollama
import json
import hashlib
import os


def map_call(df, col, msg, pred_name, use, valid_resps="", convert=None):
    if valid_resps == "":
        valid_resps = []
    valid_resps = valid_output(valid_resps)
    ints = 0
    for resp in valid_resps:
        ints = ints + isinstance(resp, int)

    pl_type = pl.String
    data_type = str

    if len(valid_resps) == ints & ints != 0:
        pl_type = pl.Int8
        data_type = int

    df = df.with_columns(
        pl.col(col)
        .map_elements(
            lambda x: llm_call(
                x=x,
                msg=msg,
                use=use,
                preview=False,
                valid_resps=valid_resps,
                convert=convert,
                data_type=data_type,
            ),
            return_dtype=pl_type,
        )
        .alias(pred_name)
    )
    return df


def llm_call(x, msg, use, preview=False, valid_resps="", convert=None, data_type=None):

    backend = use.get("backend")
    model=use.get("model")
    call = dict(
        backend=backend,
        model=model,
        messages=build_msg(x, msg),
        options=use.get("options"),
    )

    if preview: print(call)

    cache = ""
    if use.get("_cache") != "":

        hash_call = build_hash(call)
        cache = cache_check(hash_call, use)

    if cache == "":
        if backend == "ollama":
            resp = ollama.chat(
                model=use.get("model"),
                messages=build_msg(x, msg),
                options=use.get("options"),
            )
            out = resp["message"]["content"]
        if backend == "test":
            if model=="echo":
                out = x
            if model=="content":
                out = msg[0]["content"]
                return(out)
    else:
        out = cache

    if use.get("_cache") != "":
        if cache == "":
            cache_record(hash_call, use, call, out)

    if isinstance(convert, dict):
        for label in convert:
            if out == label:
                out = convert.get(label)

    if data_type == int:
        out = data_type(out)

    if out not in valid_resps and len(valid_resps) > 0:
        out = None

    return out


def valid_output(x):
    out = []
    if isinstance(x, list):
        out = x
    if isinstance(x, dict):
        for i in x:
            out.append(x.get(i))
    return out


def build_msg(x, msg):
    out = []
    for msgs in msg:
        out.append({"role": msgs["role"], "content": msgs["content"].format(x)})
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
