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

echo "BLASTING FASTA TO MYCOCOSM ITS DATABASE"
# Set path to data directory
dataDir=${cwd}/data
cd ${dataDir}
module load blast+
blastn -query ${query} \
          -db mycocosm_its_db \
          -out ${cwd}/blast_nn_all.txt \
          -outfmt 7 \
          -qcov_hsp_perc ${perc}

grep "^[^#]" blast_nn_all.txt >> blast_nn.txt
rm -rf blast_nn_all.txt
echo "=========================================================="

echo "GETTING BEST BLAST MATCH PORTAL ID FOR ITS"
# Set path to script directory
scriptDir=${cwd}/download_scripts

module load R
Rscript 4_blast_to_portal.R ${dataDir}/blast_nn.txt ${dataDir}
echo "Done."

