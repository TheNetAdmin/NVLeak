import json
import re
from pathlib import Path

import pandas as pd

from .parser import parser


def make_profiler_parser(task_path: Path, result_path: Path):
    with open(result_path / "config.json", "r") as f:
        config = json.load(f)
    profiler = config["profiler"]["type"].lower()
    if profiler == "none":
        return none_parser(task_path, result_path)
    elif profiler == "emon":
        return emon_parser(task_path, result_path)
    elif profiler == "aepwatch":
        return aepwatch_parser(task_path, result_path)
    else:
        raise Exception(f"Unknown profiler: {profiler}")


class profiler_parser(parser):
    def __init__(self, task_path: Path, result_path: Path):
        """
        Profiler parser::
            data["result"]: raw results
            data["parsed"]: parsed results
        """
        self.task_path = task_path
        with open(result_path / "config.json", "r") as f:
            self.config = json.load(f)
        if self.config['profiler']['type'] != 'none':
            if self.config["profiler"]["file"]:
                self.result_file = task_path / self.config["profiler"]["file"]

class none_parser(profiler_parser):
    """
    No profiler result, output an empty profiler result file
    """

    def parse(sefl):
        pass

class aepwatch_parser(profiler_parser):
    """
    AEPWatch profiler parser
    """

    def parse(self):
        df = pd.read_csv(self.result_file, sep=";", header=[4, 5, 6, 7])
        df.columns = [
            ".".join(
                [
                    n.replace(" ", "").replace("(", "_").replace(")", "")
                    for n in k
                    if "Unnamed" not in n
                ]
            )
            for k in df.columns
        ]
        del df['']
        self.data["result"] = df.to_dict()
        self.data["parsed"] = df.sum().to_frame().transpose().to_dict()


class emon_parser(profiler_parser):
    """
    EMon profiler parser
    """

    def parse(self):
        df = pd.read_csv(self.result_file, sep="\t", thousands=",")
        df = df.dropna(axis="columns", how="all")

        keys = list(df.columns)
        keys_str = "\n".join(keys)
        cpus = len(set(re.findall(r"(?:\[CPU)(\d+)(?:\])", keys_str)))
        pmms = len(set(re.findall(r"(?:PMM.*?\[UNIT)(\d+)(?:\])", keys_str)))
        imcs = len(set(re.findall(r"(?:IMC.*?\[UNIT)(\d+)(?:\])", keys_str)))

        cpu_events = []
        pmm_events = []
        imc_events = []
        for e in self.config["profiler"]["events"]:
            # Be careful about the order, e.g.:
            #   UNC_M2M_IMC_WRITES.TO_PMM should be an IMC event, although it
            #   has PMM in the name
            if e in ["Sample", "Clocks"]:
                continue
            elif "IMC" in e:
                imc_events.append(e)
            elif "PMM" in e or "DDRT" in e:
                pmm_events.append(e)
            else:
                cpu_events.append(e)

        cpu_id = self._detect_id(df, cpu_events, cpus, "CPU")
        pmm_id = self._detect_id(df, pmm_events, pmms, "UNIT")
        imc_id = self._detect_id(df, imc_events, imcs, "UNIT")

        self.data["result"] = df.to_dict()
        self.data["parsed"] = dict()
        self.data["parsed"]["cpu_id"] = cpu_id
        self.data["parsed"]["pmm_id"] = pmm_id
        self.data["parsed"]["imc_id"] = imc_id
        for e in self.config["profiler"]["events"]:
            if e in cpu_events:
                self.data["parsed"][e] = df[f"{e}[CPU{cpu_id}]"].sum()
            elif e in pmm_events:
                self.data["parsed"][e] = df[f"{e}[UNIT{pmm_id}]"].sum()
            elif e in imc_events:
                self.data["parsed"][e] = df[f"{e}[UNIT{imc_id}]"].sum()
            else:
                self.data["parsed"][e] = df[e].sum()

    def _detect_id(self, df, events, id_total, prefix):
        id = -1
        ev = ""
        curr_sum = -float("inf")
        for e in events:
            id_curr = -1
            for i in range(id_total):
                en = f"{e}[{prefix}{i}]"
                es = df[en].sum()
                if es > curr_sum:
                    id_curr = i

            if id != -1 and id != id_curr:
                raise Exception(
                    f"ID detection failed for {prefix}, "
                    f"prev id {id} ({ev}) != {id_curr} ({e})"
                )
            else:
                id = id_curr
                ev = e
        return id
