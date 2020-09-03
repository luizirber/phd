rule download_sra_dataset:
  output:
     "outputs/01_RAW_FASTQ/{sra_id}.fastq.gz",
  conda: "env/sra.yml"
  shell: '''
    fastq-dump --gzip \
               --skip-technical  \
               --readids \
               --read-filter pass \
               --dumpbase \
               --split-spot \
               --clip \
               -Z \
               {wildcards.sra_id} > {output}
  '''

rule download_TOBG:
  output: "outputs/01_FASTA/TOBG.fa.gz"
  shell: """
    wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/002/731/465/GCA_002731465.1_ASM273146v1/GCA_002731465.1_ASM273146v1_genomic.fna.gz \
           -O outputs/01_FASTA/TOBG.fa.gz
  """


###########
# Anvi'o
###########

rule prepare_contigs:
  output:
    mag="outputs/01_FASTA/TOBG.fa",
    fasta_txt="inputs/TOBG_merged.txt"
  input:
    config="inputs/CONTIGS-CONFIG.json",
  conda: "env/anvio.yml"
  shell: """
    anvi-run-workflow -w contigs \
                      -c {input.config} \
                      --additional-params \
                      --until anvi_script_reformat_fasta_prefix_only
    cat 01_FASTA/*/*-contigs-prefix-formatted-only.fa > {output.mag}
    rm -rf 01_FASTA/
    echo -e "name\tpath" > {output.fasta_txt}
    echo -e "TOBG_NP_110\t{output.mag}" >> {output.fasta_txt}
  """

rule download_collection_script:
  output: "scripts/gen-collection-for-merged-fasta.py"
  shell: """
    wget https://gist.githubusercontent.com/ShaiberAlon/23fc13ed56e02854bee42773672832a5/raw/3322cf23effe3325b9f8d97615f0b5af212b2fc2/gen-collection-for-merged-fasta.py -O {output}
  """

rule prepare_mags_collection:
  output:
    collection = "inputs/collections.txt",
    mag_collection = "inputs/mags_collection.txt",
    reformatted = temp("inputs/TOBG_reformatted.txt"),
  input: "inputs/TOBG_merged.txt"
  conda: "env/anvio.yml"
  shell: """
    ls outputs/01_FASTA/*.fa | \
          awk 'BEGIN{{FS="/"; print "name\tpath"}}
                    {{print $2 "\t" $0}}' > {output.reformatted}
    python scripts/gen-collection-for-merged-fasta.py -f {output.reformatted} \
                                              -o {output.mag_collection}
    echo -e "name\tcollection_name\tcollection_file\tcontigs_mode" > {output.collection}
    echo -e "TOBG_NP_110\tORIGINAL_MAGS\t{output.mag_collection}\t1" >> {output.collection}
  """

rule setup_scg_databases:
  conda: "env/anvio.yml"
  shell: "anvi-setup-scg-databases"

rule prepare_samples:
  output: "inputs/samples.txt"
  input:
    paired_end=expand("outputs/01_RAW_FASTQ/paired/{sra_id}_pass_{i}.fastq.gz",
           sra_id=("SRR1509798", "SRR1509792", "SRR1509799",
                   "ERR3256923", "SRR1509793", "SRR1509794"),
           i=(1, 2)),
#    single=expand("outputs/01_RAW_FASTQ/single/{sra_id}_pass.fastq.gz",
#           sra_id=("SRR070081", "SRR070083", "SRR070084", #"SRR304680",
#                   "SRR5868539", "SRR5868540"))
  run:
    with open(output[0], 'w') as out:
      out.write("sample\tr1\tr2\n")
      for r1, r2 in zip(input.paired_end[:-1:2], input.paired_end[1::2]):
        sample = r1.split("/")[-1].split("_")[0]
        out.write(f"{sample}\t{r1}\t{r2}\n")

rule download_centrifuge:
  output:
    targz = temp("inputs/centrifuge/p_compressed_2018_4_15.tar.gz")
  shell: """
    wget https://genome-idx.s3.amazonaws.com/centrifuge/p_compressed_2018_4_15.tar.gz \
         -O {output.targz}
    tar -zxvf {output.targz} && rm -rf {output.targz}
  """

rule anvio:
  input: 
    config="inputs/TOBG.json",
    fasta_txt="inputs/TOBG_merged.txt",
    samples="inputs/samples.txt",
    collections="inputs/collections.txt"
  conda: "env/anvio.yml"
  threads: 6
  shell: """
		anvi-run-workflow \
        -w metagenomics \
				-c {input.config}
  """
