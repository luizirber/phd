#! /usr/bin/env python

from glob import glob
from pprint import pprint
import multiprocessing
import sys

import khmer
import pandas as pd
import sourmash


def analyze_file(filename):
    """Run over the given file and count base pairs and sequences."""
    bps = 0
    seqs = 0
    input_iter = khmer.ReadParser(filename)
    unique = {}
    for k in (21, 31, 51):
        unique[k] = khmer.HLLCounter(ksize=k)
    for record in input_iter:
        bps += len(record.sequence)
        seqs += 1
#        for hll in unique.values():
#            hll.consume_string(record.sequence)
    for hll in unique.values():
        hll.consume_seqfile(filename)
    return bps, seqs, unique


def process_sig(sigfile):
    counters = {}

    original = sigfile[5:-4]
    ident = sigfile.split("/")[3]
    bps, seqs, unique = analyze_file(original)
    counters["id"] = ident
    counters["bp"] = bps
    for k in unique:
        counters[f"unique_{k}"] = len(unique[k])

    sigs = sourmash.load_signatures(sigfile)
    for sig in sigs:
        mh = sig.minhash
        k = mh.ksize
        counters[k] = len(mh)

    return counters


def main(domain, output=None, basedir=None):
    counters = {}
    for k in (21, 31, 51):
        counters[k] = list()
        counters[f"unique_{k}"] = list()
    counters["id"] = list()
    counters["bp"] = list()

    sigfiles = glob(f"{basedir}/{domain}/**/*.sig")
    with multiprocessing.Pool(processes=multiprocessing.cpu_count()) as pool:
        for result in pool.imap_unordered(process_sig, sigfiles):
            for key in counters:
                counters[key].append(result[key])

    df = pd.DataFrame(counters).set_index("id")
    if output is None:
        output = f"{domain}.csv"
    df.to_csv(output)


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("domain")
    parser.add_argument(
        "-d", "--dir", help="base directory", default="sigs/genbank", dest="basedir"
    )

    args = parser.parse_args()
    main(**vars(args))
