import binascii
import json
import os
import re
import struct
from datetime import datetime
from pathlib import Path

import editdistance
import pandas as pd
from radar.parsers.parser import parser
from radar.utils import _parse_kv, _parse_kv_list, try_cast


def make_result_parser(task_path: Path, result_path: Path):
    with open(result_path / "config.json", "r") as f:
        config = json.load(f)
    task_id = config["task"]["task"]
    task_id = try_cast(task_id, int)
    match task_id:
        case 7:
            return task_7_result_parser(task_path, result_path)
        case 11:
            return task_11_result_parser(task_path, result_path)
        case 12:
            return task_12_result_parser(task_path, result_path)
        case 13:
            return task_13_result_parser(task_path, result_path)
        case "cross-vm-covert":
            return task_cross_vm_covert_result_parser(task_path, result_path)
        case "vm-ptr-chasing":
            return task_12_result_parser(task_path, result_path)
        case _:
            raise Exception(f"Unknow task: {task_id}")


class result_parser(parser):
    def __init__(self, task_path: Path, result_path: Path):
        self.task_path = task_path
        self.result_path = result_path
        with open(result_path / "config.json", "r") as f:
            self.config = json.load(f)


class task_11_result_parser(result_parser):
    """Wear leveling test result parser"""

    def parse(self):
        if self.config['task']['op'] in [6, 7]:
            self.data = self._parse_warmup_repeated()
            return

        res = self._parse_binary()
        res = pd.DataFrame(res)
        self.data["cycle_90_00_percentile"] = res.cycle.quantile(
            q=0.9,
        )
        self.data["cycle_99_00_percentile"] = res.cycle.quantile(
            q=0.99, interpolation="nearest"
        )
        self.data["cycle_99_90_percentile"] = res.cycle.quantile(
            q=0.999, interpolation="nearest"
        )
        self.data["cycle_99_99_percentile"] = res.cycle.quantile(
            q=0.9999, interpolation="nearest"
        )
        self.data["cycle_max"] = res.cycle.max()
        self.data["cycle_mean"] = res.cycle.mean()
        self.data["cycle_min"] = res.cycle.min()
        self.data["cycle_sum"] = res.cycle.sum()
        self.data["count_over_mean"] = res.cycle.agg(
            lambda x: (x > x.mean())
        ).sum()
        self.data["count_over_1000"] = res.cycle.agg(lambda x: (x > 1000)).sum()
        self.data["count_over_3000"] = res.cycle.agg(lambda x: (x > 3000)).sum()
        self.data["count_over_10000"] = res.cycle.agg(
            lambda x: (x > 10000)
        ).sum()
        self.data["count_over_30000"] = res.cycle.agg(
            lambda x: (x > 30000)
        ).sum()

    def _parse_binary(self):
        result = []
        result_file = list(self.task_path.glob("dump-*"))[0]
        fsize = os.stat(result_file).st_size
        fin = open(result_file, "rb")

        if self.config["task"]["op"] in [0, 1, 3]:
            # Vanilla
            for iter in range(fsize // 8):
                cycle = struct.unpack("q", fin.read(8))[0]
                if cycle < 0:
                    cycle = -cycle
                result.append({"iter": iter, "cycle": int(cycle)})
        elif self.config["task"]["op"] in [2]:
            # Two points
            for iter in range((fsize // 8) // 2):
                cycle_first = struct.unpack("Q", fin.read(8))[0]
                cycle_second = struct.unpack("Q", fin.read(8))[0]
                i = iter * 2
                result.append({"iter": i, "cycle": int(cycle_first)})
                result.append({"iter": i + 1, "cycle": int(cycle_second)})
        elif self.config["task"]["op"] in [4, 5]:
            # Delay by size
            for iter in range((fsize // 8) // 2):
                start = int(struct.unpack("L", fin.read(8))[0])
                end = int(struct.unpack("L", fin.read(8))[0])
                diff = end - start
                if diff < 0:
                    diff = start - end
                result.append(
                    {"iter": iter, "start": start, "end": end, "cycle": diff}
                )
                if diff < 0:
                    raise Exception(f"Number overflow!")

        return result

    def _parse_warmup_repeated(self):
        results = []
        with open(self.task_path / 'dmesg_after.txt', 'r') as f:
            dmesg_after = f.read()
        lines = [l for l in dmesg_after.split('\n') if 'overwrite warmup' in l]
        for line in lines:
            result = {}
            line = line.strip().split(':')[1]
            for k, v in re.findall(r'([\w\s]+)(?:\[)(\w+)(?:\])(?:,\s*)', line):
                k = k.strip().replace(' ', '_')
                v = try_cast(v, int)
                result[k] = v
            result['access_size'] = self.config['task']['access_size']
            results.append(result)
        return results

class task_7_result_parser(result_parser):
    """Pointer chasing vanilla test result parser"""

    def parse(self):
        with open(self.task_path / "stdout.log", "r") as f:
            stdout_log = f.read()

        res = re.findall(
            r"(?:pointer-chasing-[a-z\-\d]+\].*)region_size.*", stdout_log
        )
        assert len(res) == 1

        def reg_key(key, val="(\d+)", post=r"[,.]"):
            return r"(?:\s*" + key + "\s*)" + val + "(?:\s*" + post + "\s*)"

        pattern = "".join(
            [
                reg_key("region_size"),
                reg_key("block_size"),
                reg_key("count"),
                reg_key("total", post=r"[ns,]+"),
                reg_key("average", post=r"[ns,]+"),
                reg_key("cycle", val=r"(\d+)(?:[\s\-]+)(\d+)(?:[\s\-]+)(\d+)"),
                reg_key("fence_strategy", val=r"([a-zA-Z]+)"),
                reg_key("fence_freq", val=r"([a-zA-Z]+)"),
            ]
        )
        res = re.findall(pattern, res[0])[0]

        self.data["region_size"] = try_cast(res[0], int)
        self.data["block_size"] = try_cast(res[1], int)
        self.data["count"] = try_cast(res[2], int)
        self.data["total"] = try_cast(res[3], int)
        self.data["average"] = try_cast(res[4], int)
        self.data["cycle_st_beg"] = try_cast(res[5], int)
        self.data["cycle_st_end"] = try_cast(res[6], int)
        self.data["cycle_ld_end"] = try_cast(res[7], int)
        self.data["fence_strategy"] = res[8]
        self.data["fence_freq"] = res[9]


class task_12_result_parser(result_parser):
    """Pointer chasing strided test result parser"""

    def parse(self):
        with open(self.task_path / "stdout.log", "r") as f:
            stdout_log = f.read()

        res = re.findall(
            r"pointer-chasing-[a-z\-\d]+\].*region_size.*", stdout_log
        )
        res += re.findall(r", lat_.*?=\d+", stdout_log)
        assert len(res) > 0
        if len(res) > 1:
            rd = [r for r in res if "region_size" in r or "lat_" in r]
            res = [" ".join(rd)]
        res = re.findall(r"[\w\_]+\s*=\s*[\w:]+", res[0])
        for r in res:
            k, v = _parse_kv(r, "=")
            if k.startswith("lat_"):
                if "per_repeat" not in self.data:
                    self.data["per_repeat"] = dict()
                self.data["per_repeat"][k] = v
            else:
                self.data[k] = v
        c = self.data["cycle"].split(":")
        self.data["cycle_st_beg"] = int(c[0])
        self.data["cycle_st_end"] = int(c[1])
        self.data["cycle_ld_end"] = int(c[2])


class task_13_result_parser(result_parser):
    """Buffer covert chasnnel test result parser"""

    def parse(self):
        with open(self.task_path / "stdout.log", "r") as f:
            stdout_log = f.read()

        self.already_warn_block_size_bug = False
        self.result_has_ns_latency = True

        self.data["threads"] = dict()
        self.data["threads"][1] = self._parse_thread(1, stdout_log)
        self.data["threads"][2] = self._parse_thread(2, stdout_log)
        self.data["summary"] = self._summarize_covert()

    def _parse_thread(self, thread_id, stdout_log, separate_logs=False):
        tdata = dict()
        tdata["id"] = thread_id

        if separate_logs:
            thread_log = stdout_log.split("\n")
        else:
            thread_log = re.findall(
                r"(?:\{" + str(thread_id) + r"\})(.*)", stdout_log
            )

        # Parse role, receiver or sender
        for log_msg in thread_log:
            if log_msg.startswith("Recv bit"):
                tdata["role"] = "receiver"
                break
            if log_msg.startswith("Send bit"):
                tdata["role"] = "sender"
                break
        if "role" not in tdata:
            print("DEBUG: thread log:")
            print(thread_log)
            raise Exception(
                f"Unknown covert channel role, neither receiver nor sender, "
                f"SeparateLogs={separate_logs}"
            )

        def is_end_line(s):
            return s.startswith(
                "TASK_BUFFER_COVERT_CHANNEL_END"
            ) or s.startswith("SUMMARY:")

        iter_index = []
        for i, s in enumerate(thread_log):
            if s.startswith("Waiting to"):
                iter_index.append(i)
            elif is_end_line(s):
                end_index = i
                break

        # If the above is not successful, i.e., we do not have 'Waiting to' in
        # the output, try another approach
        if len(iter_index) <= 1:
            for i, s in enumerate(thread_log):
                if s.startswith("Recv bit_id") or s.startswith("Send bit_data"):
                    iter_index.append(i)
                elif is_end_line(s):
                    end_index = i
                    break

        assert len(iter_index) > 1

        tdata["iter_results"] = []
        tdata["iter_summary"] = []
        for i in range(len(iter_index)):
            # log range beg <= index < end
            beg = iter_index[i]
            end = iter_index[i + 1] if i < len(iter_index) - 1 else end_index
            res, summary = self._parse_iter_results(thread_log[beg:end])

            res["iter"] = i
            summary["iter"] = i
            tdata["iter_results"].append(res)
            tdata["iter_summary"].append(summary)

        return tdata

    def _parse_iter_results(self, iter_log):
        idata = dict()

        # 1st pass: parse configs
        for log_msg in iter_log:
            if log_msg.startswith("Send bit_data="):
                msg = re.sub(r"Send\s*", "", log_msg)
                idata.update(_parse_kv_list(msg))
            elif log_msg.startswith("buf_addr"):
                idata["buf_addr"] = log_msg.split(" ")[1]
            elif re.match(r"\[pointer-chasing.*region_size.*", log_msg):
                msg = re.sub(r"\[pointer-chasing-\d+\]\s*", "", log_msg)
                idata.update(_parse_kv_list(msg))

        c = idata["cycle"].split(":")
        idata["cycle_st_beg"] = int(c[0])
        idata["cycle_st_end"] = int(c[1])
        idata["cycle_ld_end"] = int(c[2])
        if self.result_has_ns_latency:
            idata["total_ns"] = int(idata["total"].split(" ")[0])
            idata["average_ns"] = int(idata["average"].split(" ")[0])
        else:
            cycle_total = idata["cycle_ld_end"] - idata["cycle_st_beg"]
            # Assume 2.2GHz -> 2.2 cycle per ns
            total_ns = cycle_total / 2.2
            average_ns = total_ns / int(self.config["task"]["count"])
            idata["total_ns"] = total_ns
            idata["average_ns"] = average_ns

        # Fix 'block_size' bug prior to 17e64ac63, i.e. prior to Aug 19, 2021
        task_date = self.config["_id"].split("-")[0]
        task_date = datetime.strptime(task_date, "%Y%m%d%H%M%S")
        if task_date < datetime(2021, 8, 19):
            if idata["block_size"] != 64:
                if not self.already_warn_block_size_bug:
                    print(
                        f"WARNING: block_size is not 64, it is {idata['block_size']}"
                        f"         hard-setting it to 64, this is an output bug"
                        f"         before Aug 19, 2021 (17e64ac63)"
                    )
                    self.already_warn_block_size_bug = True
                idata["block_size"] = 64

        # 2nd pass: parse latencies
        idata["lat_st"] = [-1 for _ in range(idata["repeat"])]  # store
        idata["lat_ld"] = [-1 for _ in range(idata["repeat"])]  # load
        for log_msg in iter_log:
            if re.match(r",\s*lat_", log_msg):
                pattern = r"(?:,\s*)(lat_\w+)(?:_)(\d+)(?:=)(\d+)"
                if re.match(r",\s*lat_[a-z]+_it\d", log_msg):
                    # TODO: parse all sub-iterations, not just it0
                    pattern = r"(?:,\s*)(lat_[a-z]+)(?:_it0_)(\d+)(?:=)(\d+)"
                res = re.findall(pattern, log_msg)
                if len(res) > 0:
                    res = res[0]
                    idata[res[0]][int(res[1])] = int(res[2])

        for t in ["lat_st", "lat_ld"]:
            for i, d in enumerate(idata[t]):
                if d == -1:
                    raise Exception(
                        f"Latency data is missing: bit_id={idata['bit_id']}, {t}_{i}=-1"
                    )
        idata["lat_sl"] = []  # store + load
        for i in range(idata["repeat"]):
            idata["lat_sl"].append(idata["lat_st"][i] + idata["lat_ld"][i])

        # Summarize results
        isummary = dict()
        for t in ["lat_st", "lat_ld", "lat_sl"]:
            lat = pd.DataFrame(idata[t])
            isummary[t] = dict()
            isummary[t]["mean"] = float(lat.mean())
            isummary[t]["min"] = float(lat.min())
            isummary[t]["max"] = float(lat.max())
            isummary[t]["sum"] = float(lat.sum())
            isummary[t]["median"] = float(lat.median())
            for p in [10, 25, 50, 75, 90]:
                isummary[t][f"p{p}"] = float(
                    lat.quantile(q=p / 100, interpolation="nearest")
                )
            isummary[t]["mean_p25_p75"] = float(
                lat[
                    lat[0].between(
                        isummary[t]["p25"], isummary[t]["p75"], inclusive=True
                    )
                ].mean()
            )
        isummary["covert"] = dict()
        isummary["covert"]["bw_bps"] = 1 / idata["average_ns"] * 1e9

        return idata, isummary

    def _summarize_covert(self):
        summary = dict()
        summary["send_data"] = self.config["task"]["covert"]["send_data"]
        summary["total_data_bits"] = self.config["task"]["covert"][
            "total_data_bits"
        ]

        categorize_iters = 8

        # TODO: to support data bits other than 64, remember to also modify
        #       _receiver_*() functions which have hard-coded 64 bit processing
        #       code
        single_64bit_data = True
        if summary["total_data_bits"] > 64:
            single_64bit_data = False
        # assert summary["total_data_bits"] == 64
        assert categorize_iters < summary["total_data_bits"]
        assert self.data["threads"][2]["role"] == "receiver"

        # threshold_data = summary["send_data"][0]
        # threshold = self._receiver_threshold(threshold_data, categorize_iters)
        # recv_data = []
        # for i, send_data in enumerate(summary["send_data"]):
        #     rd = self._receiver_data(send_data, threshold, i * 64, 64)
        #     recv_data.append(rd)
        # summary["recv_data_all_iter"] = recv_data
        # recv_data = self._aggregate_receiver_data(recv_data)
        # print(recv_data)
        # summary["recv_data"] = recv_data

        summary["metric"] = dict()

        def _assign_metric_result(metric, rd, rds, thr, eed):
            nonlocal summary
            summary["metric"][metric] = dict()
            summary["metric"][metric]["recv_data_all_iter"] = rd
            summary["metric"][metric]["recv_data"] = rds
            summary["metric"][metric]["latency_threshold"] = thr
            summary["metric"][metric]["error_edit_distance"] = eed

        metric = "mean"
        rd, rds, thr, eed = self._aggregate_data(
            summary, categorize_iters, metric
        )
        # For backward compatibility
        summary["recv_data_all_iter"] = rd
        summary["recv_data"] = rds
        summary["latency_threshold"] = thr
        summary["error_edit_distance"] = eed
        # Mean metric
        _assign_metric_result(metric, rd, rds, thr, eed)

        for metric in [
            "sum",
            "median",
            "max",
            "min",
            "p10",
            "p25",
            "p50",
            "p75",
            "p90",
            "mean_p25_p75",
        ]:
            if (
                metric
                not in self.data["threads"][2]["iter_summary"][0][
                    "lat_ld"
                ].keys()
            ):
                print(f"Skipping metric {metric}")
                continue
            rd, rds, thr, eed = self._aggregate_data(
                summary, categorize_iters, metric
            )
            _assign_metric_result(metric, rd, rds, thr, eed)

        bit_rate = self._parse_bit_rate()

        summary["categorize_iters"] = categorize_iters
        summary["bit_rate"] = bit_rate

        return summary

    def _error_edit_distance(self, send_data, recv_data: list):
        def _list_to_bin(l: list):
            res = ""
            for e in l:
                res = e.replace("0x", "") + res
            res = binascii.unhexlify(res)
            res = int.from_bytes(res, "big")
            return bin(res)

        src = _list_to_bin(send_data)
        src_bits = len(src) - 2

        res = dict()
        for lat_type in ["lat_ld", "lat_sl", "lat_st"]:
            rd = [d[lat_type]["data"] for d in recv_data]
            tgt = _list_to_bin(rd)
            distance = editdistance.eval(src, tgt)
            res[lat_type] = {
                "error": distance,
                "error_rate": distance / src_bits,
            }
        return res

    def _aggregate_data(self, summary, categorize_iters, metric):
        threshold_data = summary["send_data"][0]
        threshold = self._receiver_threshold(
            threshold_data, categorize_iters, metric=metric
        )
        recv_data = []
        for i, send_data in enumerate(summary["send_data"]):
            rd = self._receiver_data(
                send_data, threshold, i * 64, 64, metric=metric
            )
            recv_data.append(rd)
        recv_data_summary = self._aggregate_receiver_data(recv_data)
        error_edit_distance = self._error_edit_distance(
            summary["send_data"], recv_data
        )
        # print(recv_data_summary)
        return recv_data, recv_data_summary, threshold, error_edit_distance

    def _aggregate_receiver_data(self, recv_data: list):
        cols = ["lat_ld", "lat_sl", "lat_st"]
        df = pd.DataFrame(recv_data)
        agg_data = {}
        for c in cols:
            agg_data[c] = pd.DataFrame(df[c].tolist()).mean().to_dict()
        return agg_data

    def _edit_distance_summary(self) -> dict:
        """
        Calculate error rate based on edit distance
        """

    def _receiver_threshold(
        self, send_data: str, categorize_iters=8, metric="mean"
    ) -> dict:
        """
        Use the first _categorize_iters_ iterations to calculate the latency
        threshold for bit 0 and bit 1 latencies
        """
        threshold = {
            "lat_ld": 0,
            "lat_sl": 0,
            "lat_st": 0,
        }

        assert send_data.startswith("0x")
        send_data = int(send_data, 16)  # convert string to int
        send_data = format(send_data, "064b")  # convert to 64 length bit string
        send_data = send_data[::-1]  # reverse the bit string
        categ_data = send_data[0:categorize_iters]  # bits for categorization

        # categorization bits should have same amount of 0 bits and 1 bits
        assert categ_data.count("0") == categ_data.count("1")

        for i in range(categorize_iters):
            threshold["lat_ld"] += self.data["threads"][2]["iter_summary"][i][
                "lat_ld"
            ][metric]
            threshold["lat_sl"] += self.data["threads"][2]["iter_summary"][i][
                "lat_sl"
            ][metric]
            threshold["lat_st"] += self.data["threads"][2]["iter_summary"][i][
                "lat_st"
            ][metric]

        threshold["lat_ld"] /= categorize_iters
        threshold["lat_sl"] /= categorize_iters
        threshold["lat_st"] /= categorize_iters

        assert threshold["lat_ld"] != 0
        assert threshold["lat_sl"] != 0
        # When op=1, we only have load latency, no store latency
        if "op" in self.config["task"]:
            if self.config["task"]["op"] != 1:
                assert threshold["lat_st"] != 0
        return threshold

    def _receiver_data(
        self, send_data, threshold, iter_beg=0, iter_size=64, metric="mean"
    ) -> dict:
        all_data = dict()
        send_data = format(int(send_data, 16), "064b")
        for typ in ["lat_ld", "lat_sl", "lat_st"]:
            all_data[typ] = dict()
            recv_data = ""  # bit string
            for iter in self.data["threads"][2]["iter_summary"][
                iter_beg : iter_beg + iter_size
            ]:
                if iter[typ][metric] > threshold[typ]:
                    bit = "0"  # high latency is for channel 0 where both sender and receiver work on
                else:
                    bit = "1"
                recv_data += bit
            recv_data = recv_data[::-1]  # reverse bit string
            assert len(recv_data) == len(send_data)  # sanity check
            error = 0
            for i in range(len(recv_data)):
                if recv_data[i] != send_data[i]:
                    error += 1
            all_data[typ]["error"] = error
            all_data[typ]["error_rate"] = error / len(recv_data)
            all_data[typ]["data"] = f"0x{int(recv_data, 2):016x}"
        return all_data

    def _parse_bit_rate(self) -> dict:
        bit_rate = dict()
        for _, thread in self.data["threads"].items():
            thread_bit_rate = 0
            thread_total_ns = 0
            for iter in thread["iter_results"]:
                thread_total_ns += iter["total_ns"]
                thread_bit_rate += 1
            thread_bit_rate = thread_bit_rate / thread_total_ns * 1e9
            bit_rate[thread["role"]] = thread_bit_rate
        return bit_rate


class task_cross_vm_covert_result_parser(task_13_result_parser):
    """Cross-VM covert chasnnel test result parser"""

    def parse(self):
        #     if (self.task_path / "sender.log").exists():
        #         self._parse_covert()
        #     else:
        #         self._parse_vanilla()

        # def _parse_covert(self):
        with open(self.task_path / "sender.log", "r") as f:
            sender_log = f.read()
        with open(self.task_path / "receiver.log", "r") as f:
            receiver_log = f.read()

        self.already_warn_block_size_bug = False
        self.result_has_ns_latency = False

        self.data["threads"] = dict()
        self.data["threads"][1] = self._parse_thread(
            1, sender_log, separate_logs=True
        )
        self.data["threads"][2] = self._parse_thread(
            2, receiver_log, separate_logs=True
        )
        self.data["summary"] = self._summarize_covert()

    # def _parse_vanilla(self):
    #     with open(self.task_path / "stdout.log", "r") as f:
    #         stdout_log = f.read()
    #     self.already_warn_block_size_bug = False
    #     self.result_has_ns_latency = False

    #     self.data["threads"] = dict()
    #     self.data["threads"][1] = self._parse_thread(
    #         1, stdout_log, separate_logs=True
    #     )

    #     self.data["summary"] = self._summarize_vanilla()
