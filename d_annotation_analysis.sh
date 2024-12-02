#!/bin/bash -l

# Combine output and error files into a single file
#$ -j y

# Specify the output file name
#$ -o calculate_genes_per_sample.qlog

# Keep track of information related to the current job
echo "=========================================================="
echo "Start date : $(date)"
echo "Job name : $JOB_NAME"
echo "Job ID : $SGE_TASK_ID"
echo "=========================================================="

# Move to directory with R analysis script
cwd=$(pwd)
scriptDir=${cwd}/annotation_analysis

# Set path to your file where your ASV table with taxonomy is stored (must be a csv)
data=$1

# Set annotation type
annotation=$2

# Run R script
echo "Running Normalize Gene Counts Script"
module load R
Rscript ${scriptDir}/normalize_gene_counts.R ${annotation}
echo "Running Get Gene Counts for Data Script"
Rscript ${scriptDir}/get_gene_counts_for_data.R ${data} 
echo "Done."
