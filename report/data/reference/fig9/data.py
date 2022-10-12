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
@click.argument("task_id")
def pull_data(task_id):
    all_res = []
    all_tasks = [task_id]  # In the format like "20221011032039"
    db = make_mongodb("data:experiment_result")
    for task in all_tasks:
        print(f'Querying: {task}')
        task_res = db.client.find(
            {"batch_id": task},
            {
                # "task": 1,
                # "batch_id": 1,
                "result.summary.metric.median.recv_data.lat_sl": 1,
                "result.summary.bit_rate": 1,
                # "result.threads.1.iter_summary": 1,
                # "result.threads.2.iter_summary": 1,
                # "repeat_cnt": "$task.repeat",
            },
        )
        task_res = [t for t in task_res]
        print(f'Found {len(task_res)} records')
        all_res += task_res
    print(f'Dumping to file')
    with open('data.json', 'w') as f:
        json.dump(all_res, f, indent=4)
    print(f'Dumping finished')


if __name__ == "__main__":
    pull_data()
