This repository aims to replicate the functionality of PICRUSt for fungi by using the JGI's Mycocosm of available gene annotations.

To use this pipeline, you must have a Joint Genome Institute account. If you do not have one, please make one [here](https://contacts.jgi.doe.gov/registration/new?_gl=1*103eu34*_ga*NTA1MTgxMjkuMTcwNTM1NTY1MA..*_ga_YBLMHYR3C2*MTcwNTUyNTg3OC4zLjAuMTcwNTUyNTg3OC4wLjAuMA.).

# Workflow: Name Matching Method
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
 
Use this script to download the most recent version of the NCBI ITS sequence database and the list of fungal genomes available on Mycocosm and match the NCBI data to the Mycocosm data. This step may take a couple hours. Skip this step if you already have the mycocosm_its_merge.csv. 

Run this script with the command <code>sh 0_ncbi\_mycocosm\_match.sh</code>

If running on a computing cluster, include commands <code>-P \<project-name\> -N \<job-name></code> and run with command <code>qsub</code>.

## STEP 1: Request the genome annotation files from Mycocosm
**Filename: 1\_request\_mycocosm\_annotations.sh**
* Required inputs:
  * path to file with a list of fungal taxa in dataset (see below for formatting requirements)
  * JGI username
  * JGI password.
  * annotation type (options: GO, KEGG, InterPro, KOG, Signalp)
* Required modules: R, required library: readr
* Outputs:
  * mycocosm_download_scc_command.sh : a file with commands to request the genome annotation files for the taxa in your dataset from Mycocosm. This file is run immediately after being produced.
  * a link to Mycocosm : output when mycocosm_download_scc_command.sh is run, links to the data download. If you have many taxa and/or if your files are stored on tapes by Mycocosm, the link may say "Your request is being processed." You will receive an email from Mycocosm when your data is ready to download. This may take a few hours. If you receive an "Invalid User ID" error when opening this link, log into Mycocosm and open it again.

Use this script to request the genome annotation files from Mycocosm. Currently, this requests the annotations from only the published fungal genomes on Mycocosm where there is a species or genus=-level match with taxa in your dataset. The file with fungal taxa in your dataset must be a csv with column names "species" and "genus". The "species" column must contain the full genus and species name with an underscore between them, the first letter of the genus must be capitalized and the species must be lowercase (e.g. *Amanita_muscaria*). The "genus" column must only contain the genus name with the first letter capitalized (e.g. *Amanita*).

Run this script with the command <code>sh 1\_request\_mycocosm\_annotations.sh \<MycoCosm username\> \<MycoCosm password\> \<annotation type\> N <path/to/taxa_file></code>

If running on a computing cluster, include commands <code>-P \<project-name\> -N \<job-name></code> and run with command <code>qsub</code>.

## STEP 2: Move the annotations to one folder
**Filename: 2\_move\_annotation\_files.sh**
* Required inputs:
  * path to directory with Mycocosm annotation files
  * annotation type (options: GO, KEGG, InterPro, KOG, Signalp)
* Required modules: none
* Outputs:
  * moves all files from the folder Mycocosm gives you into one singular folder.
 
Use this script to move the files from Mycocosm into one folder within this directory. When you receive the Mycocosm data download, it gives you each file in a number of subdirectories. To make things easier for downstream usage of these files, input the path to the folder that contains the folders named after the Mycocosm portal names for each genome.

Run this script with the command <code>sh 2\_move\_annotation\_files.sh <path/to/annotations_directory> \<annotation type\></code>

## STEP 3: Calculate gene counts per sample
**Filename: 3\_annotation\_analysis.sh**
* Required inputs:
  * path to OTU/ASV table with taxonomy (must be a csv)
  * annotation type
* Required modules: R, required library: dplyr
* Outputs:
  * annotations\_count\_table.csv : a table of the raw counts of gene numbers for each genome pulled from Mycocosm.
  * annotations\_count\_table\_norm.csv : a table of the counts of gene numbers for each genome pulled from Mycocosm normalized to genome size (count per 10,000 genes).
  * average\_bySpecies.csv : a table of normalized gene numbers averaged for each species pulled from Mycocosm.
  * average\_byGenus.csv : a table of normalized gene numbers averaged for each genus pulled from Mycocosm.
  * gene\_count\_per\_sample.csv : a table of the normalized gene numbers for each sample in your dataset.
 
Use this script to create the final table of normalized gene counts per sample in your dataset. The script adjusts your raw ITS sequence count number by ITS copy number based on the dataset provided in Data S1 of [Bradford et al. 2023](https://www.sciencedirect.com/science/article/pii/S2589004223013949?via%3Dihub). This csv is now useful for downstream analysis to understand how functional gene abundances, rather than fungal functional group abundances, shift with the variables tested by your dataset. 


# Workflow: BLAST Method
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
 
Use this script to download the most recent version of the NCBI ITS sequence database and the list of fungal genomes available on Mycocosm and match the NCBI data to the Mycocosm data. This step may take a couple hours. Skip this step if you already have the mycocosm_its_merge.csv. 

Run this script with the command <code>sh 0_ncbi\_mycocosm\_match.sh</code>

If running on a computing cluster, include commands <code>-P \<project-name\> -N \<job-name></code> and run with command <code>qsub</code>.

**Filename: blast.sh**
* Required inputs: 
   * Path to fasta file of query sequences (i.e. the representative ITS sequences for your ASVs)
* Required modules: blast+ and R
* Outputs:
  * blast_nn.txt : the list of all matches from the MycoCosm fungal ITS database to your ITS sequences
  * blast_portal_matches.csv : the list of best matches from MycoCosm fungal ITS database to your ITS sequences
 
Use this script to blast your ITS sequences to the MycoCosm database. This step may take a couple hours. Skip this step if you already have the blast_portal_matches.csv. 

Run this script with the command <code>sh blast.sh <path/to/query/sequences> <percent similarity threshold> </code>

If running on a computing cluster, include commands <code>-P \<project-name\> -N \<job-name></code> and run with command <code>qsub</code>.

## STEP 1: Request the genome annotation files from Mycocosm
**Filename: 1\_request\_mycocosm\_annotations.sh**
* Required inputs:
  * path to file with a list of fungal taxa in dataset (see below for formatting requirements)
  * JGI username
  * JGI password.
  * annotation type (options: GO, KEGG, InterPro, KOG, Signalp)
* Required modules: R, required library: readr
* Outputs:
  * mycocosm_download_scc_command.sh : a file with commands to request the genome annotation files for the taxa in your dataset from Mycocosm. This file is run immediately after being produced.
  * a link to Mycocosm : output when mycocosm_download_scc_command.sh is run, links to the data download. If you have many taxa and/or if your files are stored on tapes by Mycocosm, the link may say "Your request is being processed." You will receive an email from Mycocosm when your data is ready to download. This may take a few hours. If you receive an "Invalid User ID" error when opening this link, log into Mycocosm and open it again.

Use this script to request the genome annotation files from Mycocosm. Currently, this requests the annotations from only the published fungal genomes on Mycocosm that were matched with BLAST to sequences in your dataset.

Run this script with the command <code>sh 1\_request\_mycocosm\_annotations.sh \<MycoCosm username\> \<MycoCosm password\> \<annotation type\> Y</code>

If running on a computing cluster, include commands <code>-P \<project-name\> -N \<job-name></code> and run with command <code>qsub</code>.

## STEP 2: Move the annotations to one folder
**Filename: 2\_move\_annotation\_files.sh**
* Required inputs:
  * path to directory with Mycocosm annotation files
  * annotation type (options: GO, KEGG, InterPro, KOG, Signalp)
* Required modules: none
* Outputs:
  * moves all files from the folder Mycocosm gives you into one singular folder.
 
Use this script to move the files from Mycocosm into one folder within this directory. When you receive the Mycocosm data download, it gives you each file in a number of subdirectories. To make things easier for downstream usage of these files, input the path to the folder that contains the folders named after the Mycocosm portal names for each genome.

Run this script with the command <code>sh 2\_move\_annotation\_files.sh <path/to/annotations_directory> \<annotation type\></code>

## STEP 3: Calculate gene counts per sample
**Filename: 3\_annotation\_analysis.sh**
* Required inputs:
  * path to OTU/ASV table with taxonomy (must be a csv)
  * annotation type
* Required modules: R, required library: dplyr
* Outputs:
  * annotations\_count\_table.csv : a table of the raw counts of gene numbers for each genome pulled from Mycocosm.
  * annotations\_count\_table\_norm.csv : a table of the counts of gene numbers for each genome pulled from Mycocosm normalized to genome size (count per 10,000 genes).
  * average\_bySpecies.csv : a table of normalized gene numbers averaged for each species pulled from Mycocosm.
  * average\_byGenus.csv : a table of normalized gene numbers averaged for each genus pulled from Mycocosm.
  * gene\_count\_per\_sample.csv : a table of the normalized gene numbers for each sample in your dataset.
 
Use this script to create the final table of normalized gene counts per sample in your dataset. The script adjusts your raw ITS sequence count number by ITS copy number based on the dataset provided in Data S1 of [Bradford et al. 2023](https://www.sciencedirect.com/science/article/pii/S2589004223013949?via%3Dihub). This csv is now useful for downstream analysis to understand how functional gene abundances, rather than fungal functional group abundances, shift with the variables tested by your dataset. 

Run this script with the command <code>sh 3\_annotation\_analysis.sh <path/to/OTU_table.csv> \<annotation type\></code>

If running on a computing cluster, include commands <code>-P \<project-name\> -N \<job-name></code> and run with command <code>qsub</code>.
