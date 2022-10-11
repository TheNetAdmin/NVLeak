import contextlib
import json
import logging
import os
from pathlib import Path

from numpyencoder import NumpyEncoder
from pymongo import MongoClient


@contextlib.contextmanager
def chdir(path):
    """Go to working directory and return to previous on exit."""
    prev_cwd = Path.cwd()
    os.chdir(Path(path))
    try:
        yield
    finally:
        os.chdir(prev_cwd)


@contextlib.contextmanager
def chmkdir(path):
    """Go to working directory and return to previous on exit."""
    prev_cwd = Path.cwd()
    Path(path).mkdir(parents=True, exist_ok=True)
    os.chdir(path)
    try:
        yield
    finally:
        os.chdir(prev_cwd)


def _parse_kv_list(kvl, sep=", ", kv_sep="="):
    res = dict()
    for kv in kvl.split(sep):
        k, v = _parse_kv(kv, kv_sep)
        res[k] = v
    return res


def _parse_kv(kv, sep="="):
    k, v = kv.split(sep)
    k, v = k.strip(), v.strip()
    try:
        v = int(v)
    except ValueError:
        pass
    return k, v


def save_json(data, f):
    json.dump(
        data,
        f,
        indent=4,
        ensure_ascii=False,
        cls=NumpyEncoder,
        sort_keys=True,
    )


def make_mongodb(dbcol: str):
    db, col = dbcol.split(":")
    return mongodb(db, col)


class mongodb:
    def __init__(self, database, collection):
        self.logger = logging.getLogger("mongo")
        # NOTE: fill with your MongoDB username, password and url
        #       if you are using Docker/mighty-pc.yaml to create MongoDB Docker
        #       you can find and set the default username and password in that file
        self.username = os.getenv("MONGODB_USERNAME")
        self.password = os.getenv("MONGODB_PASSWORD")
        self.url = "127.0.0.1:28082"
        self.database = database
        self.collection = collection
        self.server = MongoClient(
            f"mongodb://{self.username}:{self.password}@{self.url}",
            serverSelectionTimeoutMS=2000,
        )
        self.server.server_info()
        self.client = self.server[database][collection]


def setup_logger(filename):
    log_format = logging.Formatter(
        "[%(asctime)s][%(filename)s:%(lineno)4s - %(funcName)10s()][%(levelname)s] %(message)s"
    )
    # Console output
    handler = logging.StreamHandler()
    handler.setLevel(logging.INFO)
    handler.setFormatter(log_format)
    logging.getLogger().addHandler(handler)
    # File output
    handler = logging.FileHandler(f"{filename}")
    handler.setLevel(logging.DEBUG)
    handler.setFormatter(log_format)
    logging.getLogger().addHandler(handler)


def try_cast(val, to_type):
    try:
        return to_type(val)
    except (ValueError, TypeError):
        return val
