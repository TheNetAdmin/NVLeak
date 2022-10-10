import click
from bs4 import BeautifulSoup


@click.command()
@click.argument('in_file')
@click.argument('out_file')
def extract_pc(in_file, out_file):
    content = open(in_file, 'r').read()
    soup = BeautifulSoup(content, 'html.parser')
    pc = soup.findAll('span', {'class': 'pcconf-editselector'})
    p = [ r.next_sibling for r in pc ]
    with open(out_file, 'w') as f:
        for r in p:
            f.write(f'{r}\n')


if __name__ == "__main__":
    extract_pc()
