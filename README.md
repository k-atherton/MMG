This repository aims to replicate the functionality of PICRUSt for fungi by using the JGI's Mycocosm of available gene annotations.

To use this pipeline, you must have a Joint Genome Institute account. If you do not have one, please make one here: https://contacts.jgi.doe.gov/registration/new?_gl=1*103eu34*_ga*NTA1MTgxMjkuMTcwNTM1NTY1MA..*_ga_YBLMHYR3C2*MTcwNTUyNTg3OC4zLjAuMTcwNTUyNTg3OC4wLjAuMA..

# Workflow
## Download the NCBI ITS sequence database and the Mycocosm list of available fungal genomes
**Filename: 0\_ncbi\_mycocosm\_match.sh**
* Required input files: none
* Required modules: R, requires libraries: dplyr, data.table. Biostrings, & tidyverse
* Outputs:
  * fungi.ITS.fna : the NCBI fungi ITS database
  * mycocosm_database.csv : the list of available fungal genomes on Mycocosm
  * its_df.csv : the NCBI fungal ITS database as a csv
  * nrr_acc_its.txt : a list of NCBI NR accession numbers that match taxa in Mycocosm
  * its_acc_taxids.txt : the NCBI tax IDs that match the accession numbers in nrr_acc_its.txt
  * mycocosm_its_merge.csv : the mycocosm database merged with NCBI accession numbers, tax IDs, and ITS sequences
 
Use this file to download the most recent version of the NCBI ITS sequence database and the list of fungal genomes available on Mycocosm and match the NCBI data to the Mycocosm data. This step may take a couple hours. Skip this step if you already have the mycocosm_its_merge.csv. 

Run this file with the command **qsub 0_\ncbi\_mycocosm\_match.sh**.
