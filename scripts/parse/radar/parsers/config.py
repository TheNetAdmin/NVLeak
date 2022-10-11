import re
from pathlib import Path

from radar.parsers.parser import parser
from radar.utils import _parse_kv_list


class config_parser(parser):
    def __init__(self, task_path: Path):
        self.task_path = task_path
        self.stdout_log = None

    def parse(self):
        with open(self.task_path / "stdout.log") as f:
            self.stdout_log = f.read()

        self._parse_git_config()
        self._parse_result_status()
        self._parse_profiler_config()
        self._parse_task_config()
        self._parse_machine_config()
        self._parse_runtime_config()

    def _parse_git_config(self):
        git = dict()
        git["id"] = re.findall(
            r"(?:\#\#\# Commit ID: )([a-z0-9]+)", self.stdout_log
        )[0]
        commit_status = re.findall(
            r"(?:\#\#\# Commit Status: )([a-z0-9]+)", self.stdout_log
        )
        git["status"] = commit_status[0] if len(commit_status) > 0 else "clean"

        self.data["git"] = git

    def _parse_result_status(self):
        self.data["status"] = "not-finished"
        if (self.task_path / "dmesg_after.txt").exists:
            self.data["status"] = "finished"

    def _parse_profiler_config(self):
        profiler = dict()
        profiler["type"] = "none"
        if (self.task_path / "emon.dat").exists():
            profiler["type"] = "emon"
            profiler["file"] = "emon.dat"
            profiler["cpuid"] = "auto"
            profiler["pmmid"] = "auto"
            profiler["imcid"] = "auto"
            profiler["events"] = ["Sample", "Clocks"]
            events = re.findall(
                r"(?:Profiler Events:.*\n.*\n.*\n)"
                r"([\[\]\-\s\:\.\w\n]*)"
                r"(?:\[.*?\]\s;)",
                self.stdout_log,
            )
            events = re.findall(r"(?:\[.*\]\s)([\w\.\_]+)(?:\n)", events[0])
            profiler["events"] += events
        elif (self.task_path / "AEPWatch.csv").exists():
            profiler["type"] = "aepwatch"
            profiler["file"] = "AEPWatch.csv"

        self.data["profiler"] = profiler

    def _parse_task_config(self):
        # `_id' (task_id) is also used in MongoDB
        _id = re.findall(
            r"(?:\[.*?\][\s#]*TaskID:\s)([\w\-]+)", self.stdout_log
        )[0]
        self.data["_id"] = _id
        self.data["batch_id"] = self.task_path.resolve().parent.name.lower()

        # task configs
        task = dict()
        cfg_str = re.findall(r"task=[\w\,\=\_\-]+", self.stdout_log)
        assert len(cfg_str) == 1
        for cfg in cfg_str[0].split(","):
            k, v = cfg.split("=")
            k, v = k.strip(), v.strip()
            try:
                v = int(v)
            except ValueError:
                pass
            task[k] = v

        # retrive task name from LENS help message in stdout log
        name = re.findall(
            r"(?:\[.*?\]\s*)(?:"
            + str(task["task"])
            + r": )([\w\s]+)(?:\s[\[\()])",
            self.stdout_log,
        )
        if len(name) == 1:
            task["name"] = name[0]
        elif len(name) == 0:
            if task["task"] == 11:
                task["name"] = "Wear Leveling Test"
            elif task["task"] == 12:
                task["name"] = "Pointer Chasing Strided Test"
            else:
                raise Exception(f"Unknown task {task['task']}")
        else:
            raise Exception(f"Multiple task name matched {task['task']}")

        # For task 13, parse covert info: send_data, total_data_bits
        if task["task"] == 13:
            covert_info = re.findall(
                r"send_data=.*total_data_bits.*", self.stdout_log
            )
            if len(covert_info) != 0:
                covert_info = _parse_kv_list(covert_info[0])
                task["covert"] = covert_info
            else:
                # Multiple send_data output format
                covert_info = re.findall(
                    r"send_data_buffer=.*total_data_bits.*", self.stdout_log
                )
                covert_info = _parse_kv_list(covert_info[0])
                task["covert"] = covert_info
                sender_stdout_log = re.findall(r".*\{1\}.*", self.stdout_log)
                sender_stdout_log = "\n".join(sender_stdout_log)
                covert_info = re.findall(
                    r"(?:Send data:\n)(((?:\[[\w\-:\s]+\]\s*\[[\s\.\d]+\]\s*\{\d+\})\s*\[\d+\]\:\s*[\dxa-f]+\n*)+)",
                    sender_stdout_log,
                )[0][0]
                send_data = []
                for sd in covert_info.split("\n"):
                    if sd.strip() == "":
                        continue
                    d = re.findall(r"(?:\s*\[\d+\]:\s*)(\w*)", sd)[0]
                    send_data.append(d)
                task["covert"]["send_data"] = send_data

        self.data["task"] = task

    def _parse_machine_config(self):
        machine = dict()
        machine["mtrr"] = list()
        if "MTRR" in self.stdout_log:
            for reg in re.findall(
                r"(?:\[.*?\]\s*)"
                r"(reg\d\d)(?:\:\sbase=\s*)([\da-fx]+)"
                r"(?:.*?,\ssize=\s*)([\d\w]+)"
                r"(?:,\scount=\s*)(\d+)"
                r"(?:\:\s)([\w\-]+)",
                self.stdout_log,
            ):
                r = dict()
                r["reg"] = reg[0]
                r["base"] = reg[1]
                r["size"] = reg[2]
                r["count"] = reg[3]
                r["type"] = reg[4]
                machine["mtrr"].append(r)
        machine["optane"] = dict()
        machine["optane"]["interleaved"] = (
            "AppDirectNotInterleaved" not in self.stdout_log
        )

        self.data["machine"] = machine

    def _parse_runtime_config(self):
        self.data["runtime"] = None
        if not (self.task_path / "dmesg_after.txt").exists():
            return

        with open(self.task_path / "dmesg_after.txt", "r") as f:
            dmesg = f.read()

        # parse runtime info only for pointer-chasing tests
        if "Working set" not in dmesg:
            return

        runtime = dict()

        working_set = re.findall(r"(?:\[.*?\]\s\{\d+\})(Working set.*)", dmesg)
        if self.data["task"]["task"] not in [13, 15]:
            if len(working_set) != 1:
                raise Exception(
                    f"Multiple working sets detected, this is unexpected. Task config = {self.data}"
                )
        working_set = working_set[0]
        for cfg in working_set.split(","):
            cfg = cfg.strip()
            if cfg.startswith("Working set begin"):
                runtime["working_set_beg"] = cfg.split(" ")[3]
                runtime["working_set_end"] = cfg.split(" ")[5]
            else:
                sep = ":" if ":" in cfg else "="
                k, v = cfg.split(sep)
                k, v = k.strip(), v.strip()
                try:
                    v = int(v)
                except ValueError:
                    pass
                runtime[k] = v
        runtime["chasing"] = dict()

        def _parse(pattern) -> str:
            res = re.findall(pattern, dmesg)
            if len(res) == 1:
                return res[0]
            else:
                return None

        runtime["chasing"]["csize"] = _parse(
            r"(?:\[.*?\]\s\{\d+\})(?:csize\s)(\d+)"
        )
        runtime["chasing"]["cindex"] = _parse(
            r"(?:\[.*?\]\s\{\d+\})(?:cindex\s)([\da-fA-F]+)"
        )
        runtime["chasing"]["buf_addr"] = _parse(
            r"(?:\[.*?\]\s\{\d+\})(?:buf_addr\s)([\da-fA-F]+)"
        )

        self.data["runtime"] = runtime


class config_parser_cross_vm_covert(config_parser):
    def __init__(self, task_path: Path):
        self.task_path = task_path
        self.stdout_log = None

    def parse(self):
        is_vanilla = False
        stdout_file = self.task_path / "sender.log"
        if not stdout_file.exists():
            stdout_file = self.task_path / "stdout.log"
            is_vanilla = True

        with open(stdout_file) as f:
            self.stdout_log = f.read()

        self._parse_task_config(is_vanilla)
        self._parse_profiler_config()

    def _parse_task_config(self, is_vanilla):
        self.data["_id"] = self.task_path.resolve().name
        self.data["batch_id"] = self.task_path.resolve().parent.name.lower()

        # task configs
        task = dict()
        if is_vanilla:
            task["task"] = "vm-ptr-chasing"
            task["name"] = "VM Pointer Chasing Test"
        else:
            task["task"] = "cross-vm-covert"
            task["name"] = "Cross-VM Covert Channel Test"
        cfg_str = re.findall(r"role_type=[\ \w\,\=\_\-]+", self.stdout_log)
        assert len(cfg_str) == 1
        for cfg in cfg_str[0].split(","):
            cfg = cfg.strip()
            if "=" not in cfg:
                continue
            k, v = cfg.split("=")
            k, v = k.strip(), v.strip()
            try:
                v = int(v)
            except ValueError:
                pass
            task[k] = v

        if not is_vanilla:
            # Covert info
            task["covert"] = dict()
            task["covert"]["total_data_bits"] = task["total_data_bits"]
            del task["total_data_bits"]
            del task["role_type"]
            page_offset_str = re.findall(
                r"receiver_channel_page_offset\=\d+", self.stdout_log
            )
            print(page_offset_str)
            if len(page_offset_str) > 0:
                page_offset = int(page_offset_str[0].split("=")[1].strip())
            else:
                assert False
                page_offset = 0
            task["covert"]["receiver_channel_page_offset"] = page_offset
            # TODO: Cross-VM covert may not print full send_data, need update
            try:
                send_data_raw = re.findall(
                    r"(?:Send data:\n)((\s*\[\d+\]\:\s*[\dxa-f]+\n*)+)",
                    self.stdout_log,
                )[0][0]
                send_data = []
                for sd in send_data_raw.split("\n"):
                    if sd.strip() == "":
                        continue
                    d = re.findall(r"(?:\s*\[\d+\]:\s*)(\w*)", sd)[0]
                    send_data.append(d)
                task["covert"]["send_data"] = send_data
            except Exception:
                first_data = re.findall(
                    r"(?:Read\sdata\s\[)(\w+)(?:\]\sfrom.*)", self.stdout_log
                )
                if len(first_data) > 0:
                    first_data = first_data[0]
                    if task["covert"]["total_data_bits"] > 64:
                        task["covert"]["send_data_full_recorded"] = False
                        task["covert"]["send_data"] = [first_data]
                    else:
                        task["covert"]["send_data"] = first_data

        self.data["task"] = task
