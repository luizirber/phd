---
title: 'Research Proposal: *Decentralized indexes for genomic data*'
subtitle: 'Research Proposal'
authors:
 - name: Luiz Irber
   orcid: 0000-0003-4371-9659
   affiliation: 1
affiliations:
 - name: University of California, Davis
   index: 1
date: 19 January 2018
bibliography: 'minhash'
biblio-style: 'abbrvnat'
...

# Introduction


## Background


### Problem Description

### Scaled MinHashes



MinHash [@broder_resemblance_1997],
Mash [@ondov_mash:_2016],
sourmash [@titus_brown_sourmash:_2016],

Frequency moments [@alon_space_1996]

HyperLogLog [@flajolet_hyperloglog:_2008]
HyperLogLog++ [@heule_hyperloglog_2013]
KmerStream [@melsted_kmerstream:_2014]
ntCard [@mohamadi_ntcard:_nodate]

HyperMinHash [@yu_hyperminhash:_2017]

### Hierarchical index structure

Linear searching of MinHashes is not practical well when hundreds of thousands of datasets are available.
One solution to this problem is to use an hierarchical index structure like Bloofi [@crainiceanu_bloofi:_2015],

Sequence Bloom Tree [@solomon_fast_2016],
Split Sequence Bloom Trees [@solomon_improved_2017]
AllSome Sequence Bloom Trees [@sun_allsome_2017]

BIGSI [@bradley_real-time_2017]
Mantis [@pandey_mantis:_2017]

### Decentralized querying

IPFS [@benet_ipfs_2014],
Persistent Data Structures [@driscoll_making_1989],
SRA closure [@noauthor_closure_2011],
A little centralization [@tsitsiklis_power_2011]

## Aims

1. **Using scaled MinHash for abundance distribution and cardinality estimation.**
   The scaled MinHash already allows comparing datasets with distinct genomic
   complexity,
   but it is still limited to similarity operations.
   I propose to extend it to support cardinality estimation using an approach
   derived from the HyperLogLog cardinality estimator,
   and also as an approximate abundance distribution estimator.
   The goal is to have one sketch supporting these three operations,
   even though other approaches
   (like the HLL for cardinality estimation or ntCard for abundance distribution)
   are more appropriate for a specific question.

     Both operation leverage the existing support for tracking abundances for each value in the MinHash,
	 and the scaled approach makes it easier to give better guarantees of the result because we know how 'full' the band is.


2. **Fast queries on many MinHashes using MinHash Bloom Trees**
   A MinHash Bloom Tree (MHBT) is similar to a Sequence Bloom Tree (SBT),
   but using a MinHash to represent a dataset instead of Bloom Filters containing the full $k$-mer spectrum.
   Datasets are still present only in the leaves,
   with internal nodes representing the union of all hashes presents in the MinHashes below it.

       Similarity: with Bloom Filters;
       Abundance: using max Count-Min Sketch;
       Occurrence: Using "Counting" CMS / CQF

3. **Decentralized indices for genomic data.**
   The structure of a Sequence Bloom Tree can be thought of as a persistent data structure,
   where adding nodes to a tree 

       - Encoding SBT in the Merkle-Dag
        - Persistent Data Structure
       - CRDT for updating
       - Linking with other datasets/metadata
        - Using IPLD (similar to JSON-LD)
          - Taxonomy
          - Metaseek
       - Submission/query system (soursigs)
