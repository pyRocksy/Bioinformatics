## RNA-seq Pipeline
This script automates a basic RNA-seq pipeline for processing Illumina reads from sequencing runs, including quality control, alignment, and differential expression analysis. The pipeline assumes that the input files are either paired-end or single-end reads in gzipped FASTQ format, and that the reference genome and annotation file are available in the appropriate directories.

### Dependencies
The following tools and software packages are required to run this pipeline:
  
  - FastQC: https://www.bioinformatics.babraham.ac.uk/projects/fastqc/
  - Trimmomatic: http://www.usadellab.org/cms/?page=trimmomatic
  - HISAT2: https://daehwankimlab.github.io/hisat2/download/
  - SAMtools: http://www.htslib.org/download/
  - featureCounts: http://subread.sourceforge.net/
  - DESeq2: https://bioconductor.org/packages/release/bioc/html/DESeq2.html
  - R: https://www.r-project.org/
  - Python: https://www.python.org/
  - GNU Bash: https://www.gnu.org/software/bash/

### Usage
1. Set the following variables in the script:
  
  - FASTQ_DIR: the path to the directory containing the input fastq files
  - GENOME_DIR: the path to the directory containing the reference genome files
  - ANNOTATION_FILE: the path to the GTF annotation file
  - OUTPUT_DIR: the path to the directory where output files will be saved

2. Run the script in a Linux terminal using bash:
  
  - `chmod +x rna_seq_pipeline.sh`
  - `bash RNAseq_pipeline.sh`

### Pipeline Steps
  
  - Check that each sample has exactly two input fastq files with the correct naming convention.
  - Check whether input fastq files are single-end or paired-end.
  - Perform quality control and preprocessing using fastqc and trimmomatic.
  - Perform alignment using hisat2.
  - Convert the resulting SAM file to BAM format and sort it using samtools.
  - Count features using featureCounts.
  - Perform differential expression analysis using DESeq2 in R.
  - Validate the output using validate.py.

### Outputs
The pipeline generates the following output files for each sample:
  
  - fastqc_results/: a directory containing the output from fastqc
  - *_aligned_reads.bam: the sorted BAM file containing aligned reads
  - *_counts.txt: the feature counts for each gene
  - *_validated_results.txt: the validated differential expression results

All output files are saved to the specified OUTPUT_DIR, with the sample name included in the file name.
