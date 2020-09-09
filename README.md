# The PhD repo

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/luizirber/phd/master)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4012667.svg)](https://doi.org/10.5281/zenodo.4012667)

## Qualifying Exam

Exam happened in 2019-04-17.

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
- smol (scaled minhash)

Regenerating results (after running the [setup](#Setup) steps):
```bash
conda activate thesis
cd experiments/smol_gather && snakemake --use-conda
```

### Scaled MinHash sizes

[experiments/sizes](https://github.com/luizirber/phd/tree/master/experiments/sizes)
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/luizirber/phd/master?urlpath=lab%2Ftree%2Fexperiments%2Fsizes%2Fnotebooks%2Fanalysis.ipynb)

Scaled MinHash sizes (number of hashes) analysis across domains in Genbank.

### Inverted index and shared hashes

[experiments/lca](https://github.com/luizirber/phd/tree/master/experiments/lca)
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/luizirber/phd/master?urlpath=lab%2Ftree%2Fexperiments%2Flca%2Fnotebooks%2Fanalysis.ipynb)

Analyzing unique and shared hashes in an inverted index.

## Setup

All processing and analysis scripts were performed using the conda environment specified in `environment.yml`.
To build and activate this environment run:

```bash
conda env create --force --file environment.yml

conda activate thesis
```
