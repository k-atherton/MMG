This repository aims to replicate the functionality of PICRUSt for fungi by using the JGI's Mycocosm of available gene annotations.

To use this pipeline, you must have a Joint Genome Institute account. If you do not have one, please make one here: https://contacts.jgi.doe.gov/registration/new?_gl=1*103eu34*_ga*NTA1MTgxMjkuMTcwNTM1NTY1MA..*_ga_YBLMHYR3C2*MTcwNTUyNTg3OC4zLjAuMTcwNTUyNTg3OC4wLjAuMA..

# Workflow
## STEP 0: Download the NCBI ITS sequence database and the Mycocosm list of available fungal genomes
**Filename: 0\_ncbi\_mycocosm\_match.sh**
* Required inputs: none
* Required modules: R, required libraries: dplyr, data.table. Biostrings, & tidyverse
* Outputs:
  * fungi.ITS.fna : the NCBI fungi ITS database
  * mycocosm_database.csv : the list of available fungal genomes on Mycocosm
  * its_df.csv : the NCBI fungal ITS database as a csv
  * nrr_acc_its.txt : a list of NCBI NR accession numbers that match taxa in Mycocosm
  * its_acc_taxids.txt : the NCBI tax IDs that match the accession numbers in nrr_acc_its.txt
  * mycocosm_its_merge.csv : the mycocosm database merged with NCBI accession numbers, tax IDs, and ITS sequences
 
Use this file to download the most recent version of the NCBI ITS sequence database and the list of fungal genomes available on Mycocosm and match the NCBI data to the Mycocosm data. This step may take a couple hours. Skip this step if you already have the mycocosm_its_merge.csv. 

Run this file with the command **qsub 0_\ncbi\_mycocosm\_match.sh**.

## STEP 1: Request the genome annotation files from Mycocosm
**Filename: 1\_request\_mycocosm\_annotations.sh**
* Required inputs:
 * path to file with a list of fungal taxa in dataset (see below for formatting requirements)
 * JGI username
 * JGI password.
* Required modules: R, required library: readr
* Outputs:
 * mycocosm_download_scc_command.sh : a file with commands to request the genome annotation files for the taxa in your dataset from Mycocosm. This file is run immediately after being produced.
 * a link to Mycocosm : output when mycocosm_download_scc_command.sh is run, links to the data download. If you have many taxa and/or if your files are stored on tapes by Mycocosm, the link may say "Your request is being processed." You will receive an email from Mycocosm when your data is ready to download. This may take a few hours.

Use this file to request the genome annotation files from Mycocosm. Currently, this requests the GO annotations from only the published fungal genomes on Mycocosm where there is a species or genus=-level match with taxa in your dataset. The file with fungal taxa in your dataset must be a csv with column names "species" and "genus". The "species" column must contain the full genus and species name with an underscore between them, the first letter of the genus must be capitalized and the species must be lowercase (e.g. *Amanita_muscaria*). The "genus" column must only contain the genus name with the first letter capitalized (e.g. *Amanita*).

Run this file with the command **qsub 1\_request\_mycocosm\_annotations.sh <path/to/taxa/file> <username> <password>**. 
