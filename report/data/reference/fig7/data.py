from importlib.metadata import requires
from pymongo import MongoClient
import logging
import click
import json
import pandas as pd
import os


def make_mongodb(dbcol: str):
    db, col = dbcol.split(":")
    return mongodb(db, col)


class mongodb:
    def __init__(self, database, collection):
        self.logger = logging.getLogger("mongo")
        # NOTE: fill with your MongoDB username, password and url
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


@click.group()
def data():
    pass


@data.command()
@click.argument("task_id")
def pull(task_id):
    all_res = []
    all_tasks = [task_id]  # In the format like "tasks-04-27-2022-110-0-nv-4"
    db = make_mongodb("data:experiment_result")
    for task in all_tasks:
        print(f"Querying: {task}")
        task_res = db.client.find(
            {"batch_id": task},
            {
                "task": 1,
                "batch_id": 1,
                "result": 1,
                "repeat_cnt": "$task.repeat",
            },
        )
        task_res = [t for t in task_res]
        print(f"Found {len(task_res)} records")
        all_res += task_res
    print(f"Dumping to file")
    with open("data_raw.json", "w") as f:
        json.dump(all_res, f, indent=4)
    print(f"Dumping finished")


@data.command()
def parse():
    df_raw = pd.read_json("data_raw.json")
    df = []
    for _, row in df_raw.iterrows():
        df += row["result"]
    # jdf = json.loads(df)
    with open("data.json", "w") as f:
        json.dump(df, f, indent=4)


if __name__ == "__main__":
    data()
