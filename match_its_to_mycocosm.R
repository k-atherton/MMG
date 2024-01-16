

nr_taxid_mapping = read_tsv("/projectnb/talbot-lab-data/Katies_data/picrust_for_fungi_package/its_acc_taxids.txt",
                            col_names = c("NCBI_NR_accession","NCBI_TaxID"))


# Read in Mycocosm-published list (downloaded manually from site)
mycocosm_in <- read_csv("/projectnb2/talbot-lab-data/zrwerbin/soil_genome_db/fungal_genomes/mycocosm_unfiltered_list.txt",
                        col_names = c("row", "organism_name", "portal", "NCBI_TaxID", "assembly length", "gene_count", "is_public", "is_published", "is_superseded","superseded by", "publications", "pubmed_id","doi_id"), skip = 1)

# Mycocosm reformat
mycocosm_in$organism_name = gsub('\\"',"",mycocosm_in$organism_name)
mycocosm_in$strain = gsub(' v1.0| v2.0',"",mycocosm_in$organism_name)
mycocosm_in$species =  word(mycocosm_in$strain, 1, 2)
mycocosm_in$genus = word(mycocosm_in$species, 1, 1)

mycocosm_its_merge = merge(mycocosm_in, nr_taxid_mapping, all.x=T)

table(is.na(mycocosm_its_merge$NCBI_NR_accession))
