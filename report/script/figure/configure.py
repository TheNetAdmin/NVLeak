import subprocess
import pandas
import click
import csv
import sys

import warnings

warnings.simplefilter(action="ignore", category=Warning)


class makefile(object):
    def __init__(self, filename):
        self.content = ""
        self.filename = filename
        self.comment(f"This Makefile is generated by {sys.argv[0]}")
        self.comment(
            f"Do not modify this file manually, modify the config file instead"
        )
        self.newline()
        self.variable(".DEFAULT_GOAL", "all_tikz_pdf")
        self.newline()
        self.variable("make_flag", "--no-print-directory -j8")
        self.newline()
        self.variable("RSCRIPT", "Rscript --no-save --no-restore")
        self.newline()

    def newline(self):
        self.content += "\n"

    def rule(self, target, deps: list, cmds, phony=False):
        if isinstance(cmds, str):
            cmd = f"{cmds}"
        else:
            cmd = "\n\t".join(cmds) + "\n"

        if phony:
            l = len(target) + 2 - len(".PHONY:")
            if l >= 0 and len(deps) != 0:
                space = " " * l
            else:
                space = " "
            self.content += f"\n.PHONY:{space}{target}"

        dep = ""
        if isinstance(deps, str):
            dep = deps + "\n"
        else:
            if len(deps) == 0:
                dep = "\n"
            else:
                pre_space = " " * (len(target) + 2)
                max_len = max([len(s) for s in deps])
                for i, v in enumerate(deps):
                    dep += "" if i == 0 else pre_space
                    dep += v
                    dep += (
                        " " * (max_len - len(v) + 1) + "\\\n"
                        if i != len(deps) - 1
                        else "\n"
                    )

        self.content += f"\n{target}: {dep}"
        if len(cmd) != 0:
            self.content += f"\t{cmd}\n"

    def comment(self, content):
        if isinstance(content, str):
            text = f"{content}"
        else:
            text = "\n# ".join(content)
        self.content += f"\n# {text}"

    def variable(self, vname, vvalue):
        self.content += f"\n{vname}:={vvalue}"

    def save(self):
        with open(self.filename, "w") as file:
            file.write(self.content)


class texfile(object):
    def __init__(self, filename):
        self.content = ""
        self.filename = filename
        self.cmd("documentclass", "../config/paper")
        self.cmd("title", "All TIKZ Figures")
        self.newline()
        self.cmd("begin", "document")
        self.newline()
        # self.cmd('author', '')
        # self.cmd('date', '')
        # self.cmd_noarg('maketitle')
        # self.cmd('thispagestyle', 'empty')
        self.newline()

    def newline(self):
        self.content += "\n"

    def cmd(self, cmd, arg):
        self.content += f"\\{cmd}" + "{" + f"{arg}" + "}\n"

    def cmd_noarg(self, cmd):
        self.content += f"\\{cmd}\n"

    def insert_tikz(self, figname):
        self.newline()
        self.cmd("begin", "figure*")
        self.cmd_noarg("centering")
        self.cmd("input", figname)
        self.cmd("caption", figname)
        self.cmd("end", "figure*")
        self.newline()

    def save(self):
        self.newline()
        self.cmd("end", "document")
        with open(self.filename, "w") as file:
            file.write(self.content)


def read_config(cfg_filename):
    configs = []
    data_path = "../data"
    code_path = "src"
    dest_path = "plot"
    with open(cfg_filename, "r") as file:
        cfg_data = pandas.read_csv(
            file, sep=r"\s+,", keep_default_na=False, comment="#"
        )
        for _, cfg in cfg_data.iterrows():
            if not cfg["code"].endswith(".R"):
                print(f'Unsupported source code type: {cfg["code"]}')
                exit(1)
            if "target" not in cfg.keys() or cfg["target"] == "":
                cfg["dest"] = f'{dest_path}/{cfg["code"].rstrip(".R")}'
            else:
                cfg["dest"] = f'{dest_path}/{cfg["target"]}'
            cfg["data"] = f'{data_path}/{cfg["data"]}'
            cfg["code"] = f'{code_path}/{cfg["code"]}'
            configs.append(cfg)
    return configs


def get_all_pdf():
    script = "script/figure/ls_figures/ls_figures.sh"
    res = subprocess.run(["bash", script, "figure"], stdout=subprocess.PIPE)
    pdfs = res.stdout.decode("utf-8").split("\n")
    pdfs = [f for f in pdfs if f != ""]
    return pdfs


@click.group()
def cli():
    pass


@cli.command()
@click.argument("cfg_filename")
@click.argument("tex_filename")
def gen_texfile(cfg_filename, tex_filename):
    configs = read_config(cfg_filename)
    tex = texfile(tex_filename)
    for cfg in configs:
        if "tikz" in cfg["type"].split(":"):
            tex.insert_tikz(f'{cfg["dest"]}.tikz')
    tex.save()


@cli.command()
@click.argument("cfg_filename")
@click.argument("make_filename")
def gen_makefile(cfg_filename, make_filename):
    configs = read_config(cfg_filename)

    make = makefile(make_filename)
    all_targets = dict()
    all_targets["pdf"] = []
    all_targets["png"] = []
    all_targets["tikz"] = []
    all_targets["tikz_pdf"] = []
    all_targets["tikz_svg"] = []
    for cfg in configs:
        for t in cfg["type"].split(":"):
            rules = ['@echo -e "GEN \\t $@"']
            if t in ["tikz", "pdf", "png"]:
                target = f'{cfg["dest"]}.{t}'
                depend = [cfg["data"], cfg["code"]]
                arg = cfg["arg"]
                rules.append(
                    "@${RSCRIPT} $(word 2,$^) --data $< --out $@ --type "
                    + f"{t}"
                    + f" {arg}"
                )
                if cfg["post_process"] != "":
                    ptype, pscript = cfg["post_process"].split(":")
                    if ptype != t:
                        continue
                    rules.append(
                        f"@bash ../script/figure/post_process/{ptype}/{pscript} $@"
                    )
            elif t in ["tikz_pdf"]:
                target = f'{cfg["dest"]}.tikz.pdf'
                depend = f'{cfg["dest"]}.tikz'
                rules.append("@bash ../script/figure/tikz_to_pdf/tikz_to_pdf.sh $<")
            elif t in ["tikz_svg"]:
                target = f'{cfg["dest"]}.tikz.svg'
                depend = f'{cfg["dest"]}.tikz.pdf'
                rules.append("@bash ../script/figure/pdf_to_svg/pdf_to_svg.sh $<")
            all_targets[t].append(target)
            make.rule(f"{target}", depend, rules)

    # svg files from pdf figures like LucidChart
    all_targets["pdf_svg"] = []
    for pdf in get_all_pdf():
        target = pdf.replace("pdf", "svg")
        depend = pdf
        all_targets["pdf_svg"].append(target)
        rules = [
            f'@echo -e "GEN \\t $@"',
            f"@bash ../script/figure/pdf_to_svg/pdf_to_svg.sh $<",
        ]
        make.rule(f"{target}", [depend], rules)

    make.rule(
        "all",
        [
            "all_tikz",
            "all_pdf",
            "all_png",
            "all_tikz_pdf",
            "all_tikz_svg",
            "all_pdf_svg",
        ],
        "",
        phony=True,
    )

    make.rule("all_pdf", all_targets["pdf"], "", phony=True)
    make.rule("all_png", all_targets["png"], "", phony=True)
    make.rule("all_tikz", all_targets["tikz"], "", phony=True)
    make.rule("all_tikz_pdf", all_targets["tikz_pdf"], "", phony=True)
    make.rule("all_tikz_svg", all_targets["tikz_svg"], "", phony=True)
    make.rule("all_pdf_svg", all_targets["pdf_svg"], "", phony=True)

    make.rule("config", "", ["ln -s ../config $@"])
    make.rule("figure", "", ["ln -s . $@"])
    make.rule("tikz_to_pdf", ["out/plots.pdf"], "", phony=True)
    make.rule(
        "out/plots.pdf",
        ["plots.tex", "config", "figure"] + all_targets["tikz"],
        ["@latexmk -pdf -outdir=out -quiet plots.tex"],
    )

    # make.rule('zip_all_figures', '', [
    #           f'zip out/figure.zip *.pdf *.svg'], phony=True)

    make.rule(
        "clean",
        [
            "clean_tikz",
            "clean_tikz_pdf",
            "clean_tikz_svg",
            "clean_pdf",
            "clean_png",
            "clean_symlinks",
        ],
        "",
        phony=True,
    )
    make.rule(
        "clean_tikz",
        "",
        [f'rm -f {" ".join(all_targets["tikz"])}', "rm -f *_ras1.png"],
        phony=True,
    )
    make.rule(
        "clean_tikz_pdf", "", [f'rm -f {" ".join(all_targets["tikz_pdf"])}'], phony=True
    )
    make.rule(
        "clean_tikz_svg", "", [f'rm -f {" ".join(all_targets["tikz_svg"])}'], phony=True
    )
    make.rule("clean_pdf", "", f'rm -f {" ".join(all_targets["pdf"])}', phony=True)
    make.rule("clean_png", "", f'rm -f {" ".join(all_targets["png"])}', phony=True)
    make.rule(
        "clean_symlinks", "", f'rm -f {" ".join(["config", "figure"])}', phony=True
    )

    make.save()

    # generate .gitignore for all pdf targets
    with open("figure/.gitignore", "w") as f:
        # f.write('\n'.join(all_targets['pdf']))
        f.write('\n')
        f.write('\n'.join(all_targets['tikz']))
        f.write("\n")
        f.write("\n".join(all_targets["tikz_svg"]))
        f.write("\n")
        f.write("\n".join(all_targets["pdf_svg"]))


if __name__ == "__main__":
    cli()
