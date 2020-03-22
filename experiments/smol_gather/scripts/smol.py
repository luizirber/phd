#! /usr/bin/env python
import argparse
import copy
import json
import sys


__complementTranslation = {"A": "T", "C": "G", "G": "C", "T": "A", "N": "N"}


def complement(s):
    """
    Return complement of 's'.
    """
    c = "".join(__complementTranslation[n] for n in s)
    return c


def reverse(s):
    """
    Return reverse of 's'.
    """
    r = "".join(reversed(s))
    return r


def kmers(seq, k):
    for start in range(len(seq) - k + 1):
        kmer = seq[start : start + k].upper()
        if any(c not in "ACGT" for c in kmer):
            continue
        yield kmer


class ScaledMinHash:
    def __init__(self, *, k=21, scaled=1000, name=None, filename=None):
        self.hashes = set()
        self.max_hash = int((2 ** 64) / scaled)
        self.k = k
        self.name = name
        self.filename = filename

    def add(self, h):
        if h <= self.max_hash:
            self.hashes.add(h)

    def containment(self, other):
        assert self.max_hash == other.max_hash
        assert self.k == other.k
        return len(self.hashes.intersection(other.hashes)) / len(self.hashes)

    def subtract(self, other):
        self.hashes -= other.hashes

    def save(self, f):
        json.dump(self, f)

    @staticmethod
    def load(f):
        data = json.load(f)
        mh = ScaledMinHash(
            k=data["k"], scaled=1, name=data["name"], filename=data["filename"]
        )
        mh.max_hash = data["max_hash"]
        mh.hashes = set(data["hashes"])
        return mh

    def __len__(self):
        return len(self.hashes)

    def __repr__(self):
        scaled = int((2 ** 64) / self.max_hash)
        name = self.name[:15]
        if len(self.name) > 15:
            name = name + "..."
        return f'ScaledMinHash(k={self.k}, scaled={scaled}, name="{name}", filename="{self.filename:<.15}"'


def compute(filename, *, k=21, scaled=1000, output=None, **kwargs):
    import mmh3
    import screed

    max_hash = (2 ** 64) / scaled

    # compute the actual hashes to insert by breaking down the sequence
    # into k-mers and applying MurmurHash to each one; here, the only
    # interesting thing that is done by add() is to keep only the
    # hashes smaller than max_hash.

    mh = ScaledMinHash(k=k, scaled=scaled, filename=filename)
    name = None
    with screed.open(filename) as f:
        for record in f:
            if name is None:
                name = record.name

            for fwd_kmer in kmers(record.sequence, k):
                rev_kmer = reverse(complement(fwd_kmer))
                if fwd_kmer < rev_kmer:
                    kmer = fwd_kmer
                else:
                    kmer = rev_kmer

                h = mmh3.hash64(kmer, seed=42)[0]

                # convert to unsigned int if negative
                if h < 0:
                    h += 2 ** 64

                mh.add(h)

    mh.name = name
    if output is None:
        output = f"{filename}.sig"

    with open(output, "wb") as f:
        mh.save(f)


def find_best_contained(query, collection, threshold):
    best_containment = threshold
    best_match = None

    for sig in collection:
        containment = sig.containment(query)
        if containment > best_containment:
            best_containment = containment
            best_match = sig

    return best_match


def summarize_matches(matches, output):
    for match in matches:
        filename = match[0].filename
        containment, f_match = match[1:]
        output.write(f'"{filename}",{containment},{f_match}\n')


def gather(
    query, signatures, *, k=21, scaled=1000, output=None, threshold=0.1, **kwargs
):
    collection = []
    for sig in signatures:
        with open(sig, "rb") as f:
            collection.append(ScaledMinHash.load(f))

    with open(query, "rb") as f:
        original_query = ScaledMinHash.load(f)

    query = copy.deepcopy(original_query)

    matches = []
    while 1:
        best = find_best_contained(query, collection, threshold)
        if best is None:
            break

        containment = best.containment(original_query)
        f_match = best.containment(query)
        matches.append((best, containment, f_match))
        query.subtract(best)

    summarize_matches(matches, output)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-k", type=int, default=21)
    parser.add_argument("--scaled", type=int, default=1000)
    subp = parser.add_subparsers()

    compute_cmd = subp.add_parser("compute")
    compute_cmd.add_argument("filename")
    compute_cmd.add_argument(
        "-o", "--output", type=argparse.FileType("w"), default=sys.stdout
    )
    compute_cmd.set_defaults(func=compute)

    gather_cmd = subp.add_parser("gather")
    gather_cmd.add_argument("-t", "--threshold", type=float, default=0.1)
    gather_cmd.add_argument(
        "-o", "--output", type=argparse.FileType("w"), default=sys.stdout
    )
    gather_cmd.add_argument("query", help="query signature")
    gather_cmd.add_argument("signatures", nargs="+", help="signatures to search")
    gather_cmd.set_defaults(func=gather)

    args = parser.parse_args()
    args.func(**vars(args))
