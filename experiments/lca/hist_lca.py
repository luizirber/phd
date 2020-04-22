#! /usr/bin/env python
import os
from pprint import pprint
import sys

import numpy as np
import pandas as pd
import sourmash


def main(db, output=None):
    index = sourmash.lca.lca_utils.LCA_Database()
    index.load(sys.argv[1])
    sizes = pd.Series({i: len(v) for (i, v) in index.hashval_to_idx.items()})

    if output is None:
        base = os.path.basename(db)
        output = f"{base}.csv"
    sizes.to_csv(output)


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("db")

    args = parser.parse_args()
    main(**vars(args))
