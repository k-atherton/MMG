#!/bin/bash -l

# Combine output and error files into a single file
#$ -j y

# Specify the output file name
#$ -o write_myco_request.qlog

# Keep track of information related to the current job
echo "=========================================================="
echo "Start date : $(date)"
echo "Job name : $JOB_NAME"
echo "Job ID : $SGE_TASK_ID"
echo "=========================================================="

# Move to directory with written request script
cwd=$(pwd)
scriptDir=${cwd}/mycocosm_request_scripts
cd $scriptDir

# Set path to Myococosm/ITS dataset created in step 0
mycocosm=${cwd}/data/mycocosm_its_merge.csv

# Set Mycocosm Username and Password
username=$1
password=$2

# Set Annotation Type
annotation=$3

# Blast?
blast=$4

if [[ "${blast}" == "Y" ]]; then
   echo "USING BLAST METHOD"
   # Run R script to write the request
   echo "Running Request Script"
   module load R
   Rscript write_request_script_blast.R ${cwd}/data/blast_portal_matches.csv" ${scriptDir} ${username} ${password} ${annotation}
   echo "=========================================================="
   echo "Requesting data from Mycocosm"
   # Execute the request
   sh mycocosm_download_scc_command.sh
   printf "\nCopy and paste the above link to view your download status.\n"
   echo "=========================================================="
   echo "Done."
elif [[ "${blast}" == "N" ]]; then
   echo "USING NAME-MATCHING METHOD"
   # Set path to your file where your list of fungal taxa in your dataset or your portal IDs matched by BLAST is stored
   fungalTax=$5
   # Run R script to write the request
   echo "Running Request Script"
   module load R
   Rscript write_request_script_name_matching.R ${mycocosm} ${fungalTax} ${scriptDir} ${username} ${password} ${annotation}
   echo "=========================================================="
   echo "Requesting data from Mycocosm"
   # Execute the request
   sh mycocosm_download_scc_command.sh
   printf "\nCopy and paste the above link to view your download status.\n"
   echo "=========================================================="
   echo "Done."
else
   echo "Error: BLAST method setting not recognized. Please use 'Y' to use BLAST method and 'N' to use name-matching method."
fi
