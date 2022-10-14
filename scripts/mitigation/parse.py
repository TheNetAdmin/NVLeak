from unittest import result
import click
import pathlib
import csv
import re


@click.command()
@click.argument("result_path")
def parse(result_path):
    result_path = pathlib.Path(result_path)
    results = []
    for task_path in result_path.iterdir():
        if not task_path.is_dir():
            continue
        results += parse_task(task_path)
    results = parse_norm_time(results)
    with open("performance.csv", "w") as f:
        writer = csv.DictWriter(f, fieldnames=results[0].keys())
        writer.writeheader()
        writer.writerows(results)


def parse_norm_time(results):
    parsed_results = []
    for result in results:
        if result["version"] == "original":
            result["norm_time"] = 1
        else:
            # Find original result
            for orig_result in results:
                if (
                    orig_result["version"] == "original"
                    and orig_result["benchmark"] == result["benchmark"]
                ):
                    result["norm_time"] = int(result["time"]) / int(orig_result["time"])
        parsed_results.append(result)
    return parsed_results


def open_results(task_path):
    with open(task_path / "benchmark_result.log", "r") as f:
        result = f.read()
    with open(task_path / "stdout.log", "r") as f:
        stdout = f.read()

    return result, stdout


def parse_radix_tree(task_path):
    result, stdout = open_results(task_path)
    data = []
    version = "mitigation" if "secure.sh" in stdout else "original"
    info = [
        (
            r"(?:\nAverage insert time: \(persistent radix tree\):\s)(\d+)",
            "radix tree insert",
            "rti",
        ),
        (
            r"(?:\nAverage access time \(persistent radix tree\):\s)(\d+)",
            "radix tree search",
            "rts",
        ),
        (
            r"(?:\n\[Key not present\] Average access time \(persistent radix tree\):\s)(\d+)",
            "radix tree search (key not present)",
            "rtsn",
        ),
    ]
    for pattern, name, abbr in info:
        try:
            time = re.findall(pattern, result)[0]
        except Exception as e:
            print(result)
            print(f"{pattern} -- {name} -- {abbr}")
            raise e
        data.append({"benchmark": name, "abbr": abbr, "version": version, "time": time})
    return data


def parse_hash_map(task_path):
    result, stdout = open_results(task_path)
    data = []
    version = "mitigation" if "secure.sh" in stdout else "original"
    info = [
        (
            r"(?:time=)(\d+)",
            "concurrent hash map insert",
            "chmi",
        ),
    ]
    for pattern, name, abbr in info:
        time = re.findall(pattern, result)[0]
        data.append({"benchmark": name, "abbr": abbr, "version": version, "time": time})
    return data


def parse_rel(task_path):
    result, stdout = open_results(task_path)
    data = []
    version = "mitigation" if "secure.sh" in stdout else "original"
    info = [
        (
            r"(?:Run time swap persistent ptr )(\d+)",
            "swap persistent ptr",
            "spp",
        ),
        (
            r"(?:Run time assignment persistent ptr )(\d+)",
            "assignment persistent ptr",
            "app",
        ),
        (
            r"(?:Run time swap self-relative ptr )(\d+)",
            "swap self-relative ptr",
            "ssrp",
        ),
        (
            r"(?:Run time assignment self-relative ptr )(\d+)",
            "assignment self-relative ptr",
            "asrp",
        ),
    ]
    for pattern, name, abbr in info:
        time = re.findall(pattern, result)[0]
        data.append({"benchmark": name, "abbr": abbr, "version": version, "time": time})
    return data


def parse_task(task_path):
    with open(task_path / "stdout.log", "r") as f:
        content = f.read()
    if "radix_tree" in content:
        return parse_radix_tree(task_path)
    elif "hash_map" in content:
        return parse_hash_map(task_path)
    elif "rel_ptr" in content:
        return parse_rel(task_path)
    else:
        raise Exception(f"Unknown task {task_path}")


if __name__ == "__main__":
    parse()
