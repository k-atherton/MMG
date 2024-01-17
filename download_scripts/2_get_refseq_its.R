args <- commandArgs(trailingOnly = TRUE)

fungi_its_fna <- args[1] #NCBI ITS database from NCBI, variable name its
mycocosm <- args[2] #Mycocosm database, variable name mycocosm
data_path <- args[3] #Path to Data Directory, variable name dataDir

library(data.table)
library(Biostrings)
library(tidyverse)

# Read in ITS loci downloaded from NCBI ftp site (above)
its_sequences_in <- readDNAStringSet(fungi_its_fna)
its_df <- data.frame(seq_name = names(its_sequences_in), sequence = paste(its_sequences_in)) %>%
  separate(seq_name, sep = "^\\S*\\K\\s+", into=c("ID","organism_name")) # separate at first space

write_csv(its_df[,c(1,3)], paste0(data_path, "/its_df.csv"))

# Read in Mycocosm-published list (downloaded manually from site)
mycocosm_in <- read_csv(mycocosm,
                        col_names = c("x","row", "organism_name", "portal", "NCBI_TaxID", "assembly length", "gene_count", "is_public", "is_published", "is_superseded","superseded by", "publications", "pubmed_id","doi_id", "filename"), skip = 1)


# Reformat names in both dataframes to match
# This assumes all species have exactly two words... not the best method

# ITS loci reformat - ideally we'd pull the taxid from each ncbi listing (using the NR accession)
its_df$strain = gsub(" ITS region; from TYPE material| ITS region; from reference material","",its_df$organism_name)
its_df$species = word(its_df$strain, 1, 2)
its_df$genus = word(its_df$species, 1, 1)
# Mycocosm reformat
mycocosm_in$organism_name = gsub('\\"',"",mycocosm_in$organism_name)
mycocosm_in$strain = gsub(' v1.0| v2.0',"",mycocosm_in$organism_name)
mycocosm_in$species =  word(mycocosm_in$strain, 1, 2)
mycocosm_in$genus = word(mycocosm_in$species, 1, 1)

# # Label genomes with ITS sequences
# mycocosm_in$have_species_its = ifelse(mycocosm_in$species %in% its_df$species, T, F)
# mycocosm_in$have_strain_its = ifelse(mycocosm_in$strain %in% its_df$strain, T, F)
# mycocosm_in$is_published_and_has_its = ifelse(mycocosm_in$have_species_its==T & mycocosm_in$is_published=="Y", T, F)
# mycocosm_in$is_published_and_has_strain_its = ifelse(mycocosm_in$have_strain_its==T & mycocosm_in$is_published=="Y", T, F)
#
# ##table(mycocosm_in$have_species_its)
# # 1411 mycocosm genomes are published
# ## table(mycocosm_in$is_published_and_has_its)
# # 937 mycocosm genomes have an ITS sequence at the species level
#
# # 518 mycocosm genomes have an ITS sequence at the species level AND are published
# ## table(mycocosm_in$is_published_and_has_strain_its)
# # 72 mycocosm genomes have an ITS sequence at the strain level AND are published
#
#
# # Subset to these 518
# myco_subset = mycocosm_in %>% filter(is_published_and_has_its)
# myco_subset$ITS_species = its_df[match(myco_subset$species, its_df$species),]$species
# myco_subset$ITS_strain = its_df[match(myco_subset$species, its_df$species),]$strain
# myco_subset$ITS_NR_accession = its_df[match(myco_subset$species, its_df$species),]$ID
# myco_subset$ITS_sequence = its_df[match(myco_subset$species, its_df$species),]$sequence
#
#
# # Subset to these 518
# myco_strain_subset = mycocosm_in %>% filter(have_strain_its)
# myco_strain_subset$ITS_species = its_df[match(myco_strain_subset$species, its_df$species),]$species
# myco_strain_subset$ITS_strain = its_df[match(myco_strain_subset$species, its_df$species),]$strain
# myco_strain_subset$ITS_NR_accession = its_df[match(myco_strain_subset$species, its_df$species),]$ID
# myco_strain_subset$ITS_sequence = its_df[match(myco_strain_subset$species, its_df$species),]$sequence
#
# write.csv(myco_subset, "/projectnb/talbot-lab-data/zrwerbin/soil_genome_db/mycocosm_matching/mycocosm_its.csv")
#
#
# unite_fasta = readDNAStringSet("/projectnb2/talbot-lab-data/zrwerbin/soil_genome_db/mycocosm_matching/86E80475EDB915AC7173E82787BC0B73463A7690C30A91D715CF9BA0D51059BD/sh_general_release_dynamic_25.07.2023.fasta")
#
# unite_df <- data.frame(seq_name = names(unite_fasta), sequence = paste(unite_fasta)) %>%
# 	separate(seq_name, sep = "\\|", into=c("organism_name","ID2","ID3","reps","Lineage")) # separate at breaks


its_genus_subset = its_df %>% filter(genus %in% mycocosm_in$genus)
nr_acc_its <- unique(its_genus_subset$ID) %>% unique() %>%  paste(sep="", collapse="\n")

writeLines(nr_acc_its, paste0(data_path,"/nr_acc_its.txt"))
