#!/bin/bash -l

# Combine output and error files into a single file
#$ -j y

# Specify the output file name
#$ -o NCBI_Myco.qlog

# Keep track of information related to the current job
echo "=========================================================="
echo "Start date : $(date)"
echo "Job name : $JOB_NAME"
echo "Job ID : $SGE_TASK_ID"
echo "=========================================================="

# Move to Data Directory
cwd=$(pwd)
functionDir=${cwd}/download_scripts
dataDir=${cwd}/data

if [ ! -d "$dataDir" ]; then
  mkdir data
  echo "Creating data directory."
fi

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

echo "MAKING BLAST DATABASE OF MYCOCOSM ITS SEQUENCES"
cd $dataDir
module load blast+
makeblastdb -in mycocosm_its.fasta -dbtype nucl
echo "=========================================================="
echo "DONE."
