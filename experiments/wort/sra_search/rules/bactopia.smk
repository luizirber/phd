###########
# Bactopia
###########

rule split_fastq:
  output:
    r1 = "outputs/minimap/split/SRR5868539_r1.fastq",
    r2 = "outputs/minimap/split/SRR5868539_r2.fastq",
  input: "outputs/minimap/SRR5868539.mapped.fastq",
  shell: """
  """

rule bactopia:
  output: 
    "outputs/{sra_id}/{sra_id}-genome-size.txt",
    gzipped=temp("outputs/temp/{sra_id}.mapped.fastq.gz"),
  input: "outputs/minimap/{sra_id}.mapped.fastq",
  conda: "env/bactopia.yml"
  params:
    outdir=lambda w, input, output: Path(output[0]).parent.parent
  shell: """
    #bactopia datasets outputs/datasets
    gzip -c {input} > {output.gzipped}
		bactopia --SE {output.gzipped} \
						 --sample {wildcards.sra_id} \
						 --datasets outputs/datasets/ \
						 --coverage 10 \
						 --genome_size 1240000 \
						 --cpus 2 \
						 --outdir {params.outdir}
  """

rule bactopia_paired:
  output: 
    directory("outputs/SRR1509798/"),
    r1=temp("outputs/temp/SRR1509798_r1.fq.gz"),
    r2=temp("outputs/temp/SRR1509798_r2.fq.gz"),
    single=temp("outputs/temp/SRR1509798_s.fq.gz"),
  input: "outputs/minimap/SRR1509798.bam",
  conda: "env/bactopia.yml"
  shell: """
    #bactopia datasets outputs/datasets
    samtools fastq -1 {output.r1} -2 {output.r2} -0 /dev/null -s {output.single} -n {input}

		bactopia --R1 {output.r2} \
             --R2 {output.single} \
						 --sample SRR1509798 \
						 --datasets outputs/datasets/ \
						 --coverage 10 \
						 --genome_size 1240000 \
						 --cpus 2 \
						 --outdir {output[0]}
  """
