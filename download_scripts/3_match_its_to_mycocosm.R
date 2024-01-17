args <- commandArgs(trailingOnly = TRUE)

its_acc <- args[1] #ITS tax ids from NCBI ITS sequences, variable name itsacc
mycocosm <- args[2] #Mycocosm database, variable name mycocosm
data_path <- args[3] #Path to Data Directory, variable name dataDir

library(tidyverse)
nr_taxid_mapping = read_tsv(its_acc,
                            col_names = c("NCBI_NR_accession","NCBI_TaxID"))


# Read in Mycocosm-published list (downloaded manually from site)
mycocosm_in <- read_csv(mycocosm,
                        col_names = c("x", "row", "organism_name", "portal", "NCBI_TaxID", "assembly length", "gene_count", "is_public", "is_published", "is_superseded","superseded by", "publications", "pubmed_id","doi_id", "filename"), skip = 1)

# Mycocosm reformat
mycocosm_in$organism_name = gsub('\\"',"",mycocosm_in$organism_name)
mycocosm_in$strain = gsub(' v1.0| v2.0',"",mycocosm_in$organism_name)
mycocosm_in$species =  word(mycocosm_in$strain, 1, 2)
mycocosm_in$genus = word(mycocosm_in$species, 1, 1)

mycocosm_its_merge = merge(mycocosm_in, nr_taxid_mapping, all.x=T)

table(is.na(mycocosm_its_merge$NCBI_NR_accession))

its_df <- read_csv(paste0(data_path,"/its_df.csv"))
colnames(its_df)[1] <- colnames(mycocosm_its_merge[19])

its_df <- its_df[which(its_df$NCBI_NR_accession %in% nr_taxid_mapping$NCBI_NR_accession),]

mycocosm_its_merge = merge(mycocosm_its_merge, its_df, all.x=T)
mycocosm_its_merge = mycocosm_its_merge[which(mycocosm_its_merge$is_superseded == "N"),]

write.csv(mycocosm_its_merge, paste0(data_path,"/mycocosm_its_merge.csv"))