from pymongo import MongoClient
import logging
import click
import json
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


@click.command()
@click.argument("signal_id")
def pull_data(signal_id):
    id = signal_id # in the format of '20211105233247-efc477a-AEP2'
    db = make_mongodb("data:experiment_result")
    print(f'Querying: {id}')
    task_res = db.client.find(
        {"_id": id},
        {
            "task": 1,
            "batch_id": 1,
            "result.summary": 1,
            "result.threads.1.iter_summary": 1,
            "result.threads.2.iter_summary": 1,
            "repeat_cnt": "$task.repeat",
        },
    )
    res = task_res[0]
    res['result']['threads']['1']['iter_summary'] = res['result']['threads']['1']['iter_summary'][32:32+128]
    res['result']['threads']['2']['iter_summary'] = res['result']['threads']['2']['iter_summary'][32:32+128]
    print(len(res['result']['threads']['1']['iter_summary']))
    print(len(res['result']['threads']['2']['iter_summary']))
    del res['result']['summary']

    print(f'Dumping to file')
    with open('signal.json', 'w') as f:
        json.dump(res, f, indent=4)
    print(f'Dumping finished')


if __name__ == "__main__":
    pull_data()
