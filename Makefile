all:
	snakemake -j 1 --use-conda --scheduler greedy

deps:
	snakemake -j 1 --use-conda --scheduler greedy install_deps
