from click.core import batch
from radar.make.makefile import makefile
from radar.utils import chdir
from pathlib import Path
import re


def generate_makefile(
    batch_path: Path, parser_file: Path, cross_vm_covert=False
):
    with chdir(batch_path):
        m = makefile()
        # Common rules
        m.comment("Common rules")
        m.variable("PARSER", str(parser_file))
        m.rule(
            ".PRECIOUS",
            " ".join(
                [
                    "%/result/config.json",
                    "%/result/profiler.json",
                    "%/result/result.json",
                    "%/result/summary.json",
                ]
            ),
        )
        m.newline()
        config_arg = ""
        if cross_vm_covert:
            config_arg = " -c"
        m.rule(
            target="%/result/config.json",
            deps=[],
            cmds=[
                "python3 ${PARSER} backup -t $*",
                "mkdir -p $*/result",
                "python3 ${PARSER} config -t $* -r $*/result -o config.json"
                + config_arg,
            ],
        )
        m.rule(
            target="%/result/profiler.json",
            deps=["%/result/config.json"],
            cmds=[
                "python3 ${PARSER} profiler -t $* -r $*/result -o profiler.json"
            ],
        )
        m.rule(
            target="%/result/result.json",
            deps=["%/result/config.json"],
            cmds=["python3 ${PARSER} result -t $* -r $*/result -o result.json"],
        )
        m.rule(
            target="%/result/summary.json",
            deps=[
                "%/result/config.json",
                "%/result/profiler.json",
                "%/result/result.json",
            ],
            cmds=["python3 ${PARSER} summary -r $*/result -o summary.json"],
        )
        m.rule(
            target="%/result/update.log",
            deps=["%/result/summary.json"],
            cmds=[
                "python3 ${PARSER} update -r $*/result -s summary.json -o update.log"
            ],
        )

        m.rule(
            target="clean",
            deps=[],
            cmds=[
                "rm -f */result/config.json",
                "rm -f */result/profiler.json",
                "rm -f */result/result.json",
                "rm -f */result/summary.json",
            ],
            phony=True,
        )

        # All targets
        targets = []
        for f in Path(".").iterdir():
            if f.is_dir() and re.match(r"^\d{14}\-\w{7}\-[\w\-]*$", f.name):
                targets.append(f"{f.name}/result/summary.json")
        m.comment("All targets")
        m.rule(target="all", deps=targets, phony=True)

        m.comment("Update all results to MongoDB")
        m.rule(
            target="all_update",
            deps=[t.replace("summary.json", "update.log") for t in targets],
            phony=True,
        )

        m.save()
