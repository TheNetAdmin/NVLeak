import pandas as pd
import click

sets_to_diff = [
    16,
    32,
    48,
    64,
    80,
    96,
]

def parse_single(filename: str):
    print(f"Reading {filename}")
    df = pd.read_csv(filename)
    df = df[df['iter'] >= 10000]
    df = df[df['iter'] <  30000]
    df = df[df['over_median'] == 1]
    df = df[df['lat'] < 1000]
    res = []
    for set_idx in sets_to_diff:
        set_lat = df[df['set'] == set_idx]
        res.append({
            "total_over_median": len(set_lat),
            "med_lat": set_lat['lat'].median(),
            "mean_lat": set_lat['lat'].mean(),
        })
    return res

@click.command()
def parse():
    all_res = []
    for f in range(1, 5):
        res = parse_single(f"M{f}.csv")
        all_res.append(res)
    metrics = ["total_over_median"]
    for metric in metrics:
        print(metric)
        print(f"Set\tM1\tM2\tM3\tM4")
        for i, set_idx in enumerate(sets_to_diff):
            row = f"{set_idx}\t"
            for f in range(1, 5):
                # print(f'{i}, {set_idx}, {f}')
                row += str(int(all_res[f-1][i][metric])) + "\t"
            print(row)


if __name__ == "__main__":
    parse()
