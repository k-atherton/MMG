#!/bin/bash -l

# Set SCC project
#$ -P talbot-lab-data

# Send an email when the job finishes or if it is aborted (by default no email is sent).
#$ -m a

# Give job a name
#$ -N blast_une_nn

# Combine output and error files into a single file
#$ -j y

# Specify the output file name
#$ -o blast_une_nn.qlog

# Request more cores and memory
#$ -pe omp 8 

# Keep track of information related to the current job
echo "=========================================================="
echo "Start date : $(date)"
echo "Job name : $JOB_NAME"
echo "Job ID : $SGE_TASK_ID"
echo "=========================================================="
cwd=$(pwd)
module load blast+
blastn -query /projectnb/talbot-lab-data/ctatsumi/Analysis/UNE-DNA/ITS/seqs.fasta \
          -db mycocosm_its_db \
          -out ${cwd}/blast_nn_50_all.txt \
          -outfmt 7 \
          -qcov_hsp_perc 50