#!/bin/bash -l

# Set SCC project
#$ -P talbot-lab-data

# Send an email when the job finishes or if it is aborted (by default no email is sent).
#$ -m a

# Give job a name
#$ -N write_myco_request

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

# Set path to your file where your list of fungal taxa in your dataset is stored
fungalTax=$1

# Set path to Myococosm/ITS dataset created in step 0
mycocosm=${cwd}/data/mycocosm_its_merge.csv

# Set Mycocosm Username and Password
username=$2
password=$3

# Run R script to write the request
echo "Running Request Script"
module load R
Rscript write_request_script.R ${mycocosm} ${fungalTax} ${scriptDir} ${username} ${password}
echo "=========================================================="

echo "Requesting data from Mycocosm"
# Execute the request
sh mycocosm_download_scc_command.sh
printf "\nCopy and paste the above link to view your download status.\n"
echo "=========================================================="
echo "Done."