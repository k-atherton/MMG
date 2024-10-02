#!/bin/bash -l

# Send an email when the job finishes or if it is aborted (by default no email is sent).
#$ -m a

# Combine output and error files into a single file
#$ -j y

# Specify the output file name
#$ -o blast_nn.qlog

# Request more cores and memory
#$ -pe omp 8 

# Keep track of information related to the current job
echo "=========================================================="
echo "Start date : $(date)"
echo "Job name : $JOB_NAME"
echo "Job ID : $SGE_TASK_ID"
echo "=========================================================="

# Set path to where the query fasta file is
query=$1

# Set sequence similarity threshold
perc=$2

cwd=$(pwd)
module load blast+
blastn -query ${query} \
          -db mycocosm_its_db \
          -out ${cwd}/blast_nn_all.txt \
          -outfmt 7 \
          -qcov_hsp_perc ${perc}

grep "^[^#]" blast_nn_all.txt >> blast_nn.txt

rm -rf blast_nn_all.txt
