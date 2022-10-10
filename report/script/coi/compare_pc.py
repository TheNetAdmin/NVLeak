import click
from fuzzywuzzy import fuzz
from prettytable import PrettyTable

@click.command()
@click.argument('hotcrp')
@click.argument('coi')
def compare_pc(hotcrp, coi):
    conf_pc = []
    with open(hotcrp, 'r') as f:
        for l in f:
            conf_pc.append(l.strip())
    coi_pc = []
    with open(coi, 'r') as f:
        for l in f:
            l = l.split(' (')[0]
            coi_pc.append(l.strip())

    match = []
    for p in coi_pc:
        max_ratio = 0
        match_pc = ''
        for c in conf_pc:
            r = fuzz.ratio(p.lower(), c.lower())
            if r > max_ratio:
                max_ratio = r
                match_pc = c
        match.append({
            'conf_pc': match_pc,
            'coi': p,
            'ratio': max_ratio
        })

    match.sort(key = lambda x: x['ratio'], reverse=True)
    tab = PrettyTable()
    tab.field_names = ['No.', 'conf_pc', 'coi', 'ratio']
    id = 1
    for m in match:
        tab.add_row([id, m['conf_pc'], m['coi'], m['ratio']])
        id += 1

    print(tab)

if __name__ == "__main__":
    compare_pc()
