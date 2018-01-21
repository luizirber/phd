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
   Leaves are still datasets,
   with internal nodes representing the union of all hashes present in the MinHashes below it.
   The preliminary implementation already support searching and insertion of new datasets,
   but insertion is naive (add to the next available space).
   I propose to implement insertion based on maximizing shared hashes under an internal node,
   since this allows faster pruning in the search space when querying.

     While the SBT still adheres to presence filtering like Bloofi
     (using Bloom Filters for internal nodes)
     there are other useful data structures that can be used instead and allow a wider range of operations.
     Multiset representations allow keeping track of the hashes abundances,
     so using a Count-Min Sketch or a Counting Quotient Filter to represent internal nodes allow other useful queries in the tree.
     But there is an additional consideration in this case:
     how to calculate the union of these data structures.
     Usually the union of two multisets is defined as the sum of abundances of each multiset for a specific element,
     but in the hierachical index this leads to not-so-useful queries
     (the root node would have an abundance count of how many times a hash happened in all datasets).
     We can use other definitions of the union to create more useful queries:

       Similarity: with Bloom Filters;
       Abundance: using max Count-Min Sketch;
       Occurrence: Using "Counting" CMS / CQF

     Since these new definitions for the union maintain the hashes untouched,
     this means that an optimal tree structure can be shared among all trees,
     independent of what kind of internal node is used.
     This leads to the result that a bare tree
     (containing only the leaves and the a representation of the tree structure,
     but not the content of the internal nodes)
     is enough to build all the other variations of the index.
     In network-restricted environments
     (where it is cheaper to rerun the creation of internal nodes data instead of transferring it)
     this can also lead to more efficient use of resources without loosing generality.
     Also,
     if no additional insertions to the index are expected,
     this can also serve as the backbone for more efficient representations
     (in a sense this is what the SSBT is to a SBT).

3. **Decentralized indices for genomic data.**
   The structure of a MinHash Bloom Tree can be thought of as a persistent data structure:
   each leaf in the tree never change,
   and for each insertion $O(log n)$ internal nodes
   (the internal nodes between the leaf and the root)
   need to be updated.
   Since all the other internal nodes (and the leaves) will still be the same as the tree before the update,
   this view of the MHBT as a persistent data structure makes it a very good fit for storing it in a Merkle Tree.

     I'll explore two different decentralized data storage systems
     (`IPFS` and `Dat`) as ways of storing and interacting with MHBT indices.
       - Popular indices benefit from increase bandwidth for downloading data
       - Derived indices still benefit from nodes shared with the original index

     On top the data storage aspects,
     another important point is how researchers can interact with these indices
     (both querying and updating it)
     in a way that a central authority is not essential
     (but operations are optimized if it is).
     This is important in the context of long term sustainability of the system,
     ~~since I hope to graduate one day and I can't promise I will maintain the system~~
     something often overlooked in bioinformatics systems.
<!--
       - CRDT for updating
       - Submission/query system (soursigs)
-->

   Because these systems are content-aware,
   modifying a signature (the JSON file containing the MinHash + metadata)
   leads to different addresses on the network,
   which is suboptimal for data sharing.
   I also plan to explore how to use other systems to link back and provide additional metadata
   (for example: taxonomy records)
   using IPLD
   (Interplanetary Linked Data,
   a format similar to JSON-LD but focusing on IPFS)
   and also Hypothesis,
   a web annotation tool.
