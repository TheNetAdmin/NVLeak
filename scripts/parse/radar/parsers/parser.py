from pathlib import Path
import json

from radar.utils import save_json

class parser:
    data = dict()

    def parse(self):
        pass

    def save(self, out_file: Path):
        with open(out_file, "w") as f:
            save_json(self.data, f)
