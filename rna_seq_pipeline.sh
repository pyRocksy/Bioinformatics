#!/bin/bash

# Set variables
FASTQ_DIR=/path/to/fastq/files
GENOME_DIR=/path/to/genome/files
ANNOTATION_FILE=/path/to/annotation/file.gtf
OUTPUT_DIR=/path/to/output/directory

# Check that each sample has exactly two input fastq files with the correct naming convention
for file in ${FASTQ_DIR}/*.fastq.gz; do
    sample=$(basename ${file%_*} | sed 's/_1$//')
    if [[ ! -f "${FASTQ_DIR}/${sample}_1.fastq.gz" ]] || [[ ! -f "${FASTQ_DIR}/${sample}_2.fastq.gz" ]]; then
        echo "Error: Sample ${sample} does not have two input fastq files with the correct naming convention"
        exit 1
    fi
done

# Check whether input fastq files are single-end or paired-end
if ls ${FASTQ_DIR}/*_1.fastq.gz >/dev/null 2>&1; then
    echo "Input files are paired-end"
    # Quality control and preprocessing
    fastqc ${FASTQ_DIR}/*_1.fastq.gz ${FASTQ_DIR}/*_2.fastq.gz -o ${OUTPUT_DIR}/fastqc_results
    trimmomatic PE ${FASTQ_DIR}/*_1.fastq.gz ${FASTQ_DIR}/*_2.fastq.gz \
        ${OUTPUT_DIR}/output_1_paired.fq.gz ${OUTPUT_DIR}/output_1_unpaired.fq.gz \
        ${OUTPUT_DIR}/output_2_paired.fq.gz ${OUTPUT_DIR}/output_2_unpaired.fq.gz \
        ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
    # Alignment and quantification
    hisat2 -x ${GENOME_DIR}/genome_index -1 ${OUTPUT_DIR}/output_1_paired.fq.gz -2 ${OUTPUT_DIR}/output_2_paired.fq.gz -S ${OUTPUT_DIR}/aligned_reads.sam
else
    echo "Input files are single-end"
    # Quality control and preprocessing
    fastqc ${FASTQ_DIR}/*.fastq.gz -o ${OUTPUT_DIR}/fastqc_results
    trimmomatic SE ${FASTQ_DIR}/*.fastq.gz ${OUTPUT_DIR}/output_trimmed.fastq.gz \
        ILLUMINACLIP:TruSeq3-SE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
    # Alignment and quantification
    hisat2 -x ${GENOME_DIR}/genome_index -U ${OUTPUT_DIR}/output_trimmed.fastq.gz -S ${OUTPUT_DIR}/aligned_reads.sam
fi

# Convert SAM to BAM, sort and index BAM files
sample=$(basename ${file%_*} | sed 's/_1$//')
samtools view -Sb ${OUTPUT_DIR}/aligned_reads.sam > ${OUTPUT_DIR}/${sample}_aligned_reads.bam
samtools sort ${OUTPUT_DIR}/${sample}_aligned_reads.bam -o ${OUTPUT_DIR}/${sample}_sorted_aligned_reads.bam
samtools index ${OUTPUT_DIR}/${sample}_sorted_aligned_reads.bam

# Count features and perform differential expression analysis
featureCounts -a ${ANNOTATION_FILE} -o ${OUTPUT_DIR}/${sample}_counts.txt ${OUTPUT_DIR}/${sample}_sorted_aligned_reads.bam
Rscript DESeq2.R ${OUTPUT_DIR}/${sample}_counts.txt

# Validate output
python validate.py ${OUTPUT_DIR}/${sample}_validated_results.txt
