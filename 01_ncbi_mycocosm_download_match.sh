#!/bin/bash -l

# Set SCC project
#$ -P talbot-lab-data

# Send an email when the job finishes or if it is aborted (by default no email is sent).
#$ -m a

# Give job a name
#$ -N NCBI_data

# Combine output and error files into a single file
#$ -j y

# Specify the output file name
#$ -o NCBI_data.qlog

# Use SGE_TASK_ID env variable to select appropriate input file from bash array
# Bash array index starts from 0, so need to subtract one from SGE_TASK_ID value

# Keep track of information related to the current job
echo "=========================================================="
echo "Start date : $(date)"
echo "Job name : $JOB_NAME"
echo "Job ID : $SGE_TASK_ID"
echo "=========================================================="

# Move to Data Directory
cwd=$(pwd)
functionDir=/projectnb/talbot-lab-data/Katies_data/picrust_for_fungi_package/functions
dataDir=/projectnb/talbot-lab-data/Katies_data/picrust_for_fungi_package/data
cd $dataDir

# Download NCBI fungi ITS database
echo "DOWNLOADING NCBI FUNGI ITS DATABASE"
wget https://ftp.ncbi.nlm.nih.gov/refseq/TargetedLoci/Fungi/fungi.ITS.fna.gz
echo "UNZIPPING NCBI FUNGI ITS DATABASE"
gunzip fungi.ITS.fna.gz
its=${dataDir}/fungi.ITS.fna
echo "=========================================================="

# Download Mycocosm database
# Need dplyr R library
cd $functionDir
echo "DOWNLOADING MYCOCOSM DATABASE"
module load R
Rscript 1_get_mycocosm_database.R ${dataDir}
# Mycocosm database location
mycocosm=${dataDir}/mycocosm_database.csv
echo "=========================================================="

# Pull the ITS refseq from the database with R script
# Need data.table, Biostrings, and tidyverse R libraries
echo "PULLING ITS REFSEQ FROM NCBI DATABASE"
Rscript 2_get_refseq_its.R ${its} ${mycocosm} ${dataDir}
echo "=========================================================="

# Download the NCBI Tax IDs from the nucleotide accessions for the NCBI ITS sequences
# Saves to a list
# Then, the taxIDs can be cross-references with the ones in Mycocosm

# This doesn't go through the whole ITS database; only the ones with GENUS in common with Mycocosm

echo "DOWNLOADING TAX IDS FROM NCBI ITS SEQUENCES"
cd $dataDir
  cat nr_acc_its.txt | while read ACC || [[ -n $ACC ]];
do
echo -n -e "$ACC\t"
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=${ACC}&rettype=fasta&retmode=xml" |\
grep TSeq_taxid |\
cut -d '>' -f 2 |\
cut -d '<' -f 1 |\
tr -d "\n"
echo
done > its_acc_taxids.txt

itsacc=${dataDir}/its_acc_taxids.txt
echo "=========================================================="

echo "MATCHING ITS SEQUENCES TO MYCOCOSM TAXA"
# Match ITS to Mycocosm
# Need tidyverse R library
cd $functionDir
Rscript 3_match_its_to_mycocosm.R ${itsacc} ${mycocosm} ${dataDir}
echo "=========================================================="
echo "DONE."