# The PhD repo

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/luizirber/phd/master)

## Qualifying Exam

Exam happened in 2019-04-19.

- [Proposal]
- [Presentation]

[Proposal]: proposal/Proposal.pdf
[Presentation]: qe/presentation/QE_no_extras.pdf

## Dissertation

Uses [aggiedown] and [GitHub Actions] for CI. Tagged versions are available in
the [Releases] page.

[aggiedown]: https://github.com/ryanpeek/aggiedown/
[GitHub Actions]: https://github.com/luizirber/phd/actions
[Releases]: https://github.com/luizirber/phd/releases

## Experiments

### smol gather

[experiments/smol_gather](https://github.com/luizirber/phd/tree/master/experiments/smol_gather)
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/luizirber/phd/master?urlpath=lab%2Ftree%2Fexperiments%2Fsmol_gather%2Fnotebooks%2Fanalysis.ipynb)

Comparison of containment approaches using MinHash:

- CMash (containment minhash)
- mash screen
- sourmash (scaled minhash)

Regenerating results (after running the [setup](#Setup) steps):
```bash
conda activate thesis
cd experiments/smol_gather && snakemake --use-conda
```

## Setup

All processing and analysis scripts were performed using the conda environment specified in `environment.yml`.
To build and activate this environment run:

```bash
conda env create --force --file environment.yml

conda activate thesis
```
