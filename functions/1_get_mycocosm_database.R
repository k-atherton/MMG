args <- commandArgs(trailingOnly = TRUE)

data_path <- args[1] #Path to Data Directory, variable name dataDir

library(dplyr)
myco_in <- read.csv("https://mycocosm.jgi.doe.gov/ext-api/mycocosm/catalog/download-group?flt=&seq=all&pub=all&grp=fungi&srt=released&ord=desc", check.names = F, col.names = c("row", "Name", "portal", "NCBI_TaxID", "assembly length", "gene_count", "is_public", "is_published", "is_superseded","superseded by", "publications", "pubmed_id","doi_id"), skip = 1) %>% arrange(NCBI_TaxID)
myco_in$Name = gsub('\\"',"",myco_in$Name)
myco_in$filename = paste0(myco_in$portal, "_AssemblyScaffolds_Repeatmasked.fasta.gz")

write.csv(myco_in, paste0(data_path,"/mycocosm_database.csv"))