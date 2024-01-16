source("/projectnb/talbot-lab-data/zrwerbin/soil_genome_db/helper_functions.r")
####

taxdir = "/projectnb/microbiome/zrwerbin/ncbi_taxdir"
ncbi_taxdump = data.table::fread("/projectnb/microbiome/zrwerbin/ncbi_taxdir/rankedlineage.dmp",
                                 col.names = c("tax_id","tax_name","species","genus","family",
                                               "order","class","phylum","kingdom","superkingdom","NA"), sep = "|")

# Read in Mycocosm-published list (downloaded manually from site)
myco_in <- read.csv("https://mycocosm.jgi.doe.gov/ext-api/mycocosm/catalog/download-group?flt=&seq=all&pub=all&grp=fungi&srt=released&ord=desc", check.names = F, col.names = c("row", "Name", "portal", "NCBI_TaxID", "assembly length", "gene_count", "is_public", "is_published", "is_superseded","superseded by", "publications", "pubmed_id","doi_id"), skip = 1) %>% arrange(NCBI_TaxID)
myco_in$Name = gsub('\\"',"",myco_in$Name)
myco_in$filename = paste0(myco_in$portal, "_AssemblyScaffolds_Repeatmasked.fasta.gz")

mycocosm_downloaded = read_in_genomes("/projectnb2/talbot-lab-data/zrwerbin/soil_genome_db/genomes/mycocosm_genomes",
                                      pattern = ".fasta.gz")


# download_df = read.csv("/projectnb2/talbot-lab-data/zrwerbin/soil_genome_db/mycocosm_genomes/download_links.csv",
# 											 row.names = NULL)
# download_df$filename = basename(download_df$Go.Download.Link)

mycocosm_downloaded$portal = myco_in[match(mycocosm_downloaded$filename, myco_in$filename),]$portal
mycocosm_downloaded$is_published = myco_in[match(mycocosm_downloaded$filename, myco_in$filename),]$is_published
mycocosm_downloaded$NCBI_TaxID = myco_in[match(mycocosm_downloaded$portal, myco_in$portal),]$NCBI_TaxID %>% as.numeric()
mycocosm_downloaded$Name = myco_in[match(mycocosm_downloaded$portal, myco_in$portal),]$Name

# Add NCBI taxonomy to NCBI eukaryotic genome file
nodes <- getnodes(taxdir = taxdir)
mycocosm_downloaded$rank = CHNOSZ::getrank(mycocosm_downloaded$NCBI_TaxID, taxdir, nodes = nodes)
ncbi_taxonomy = tax_id_to_ranked_lineage(mycocosm_downloaded$NCBI_TaxID, taxdir) %>% arrange(tax_id)
mycocosm_downloaded <- mycocosm_downloaded %>% arrange(NCBI_TaxID)

check_match = identical(ncbi_taxonomy$tax_id, mycocosm_downloaded$NCBI_TaxID)
cat("Taxonomy good to join with TaxIDs?",check_match)

ncbi_taxonomy = cbind.data.frame(mycocosm_downloaded, ncbi_taxonomy) %>%
  mutate(species = ifelse(rank == "species", tax_name, species)) %>%
  mutate(custom_taxonomy =
           paste0("k__", kingdom,
                  ";p__", phylum,
                  ";c__",class,
                  ";o__",order,
                  ";f__",family,
                  ";g__", genus,
                  ";s__", species))


# FILTER TO PUBLISHED ONLY
ready_genomes_myco = inner_join(mycocosm_downloaded,
                                ncbi_taxonomy,	#by = c("NCBI_TaxID" = "NCBI_TaxID"),
                                relationship = "many-to-many") %>%
  mutate(source = "Mycocosm") %>%
  select(ncbi_species_taxid = NCBI_TaxID,
         accession = Name,
         ncbi_organism_name = tax_name,
         species,
         fasta_file_path = filepath,
         ncbi_taxonomy=custom_taxonomy, source, is_published)


# Remove any taxon ID with multiple genomes - random
to_write_published = ready_genomes_myco %>%
  filter(is_published=="Y") #%>% distinct(ncbi_species_taxid, .keep_all = TRUE)
to_write = ready_genomes_myco #%>% distinct(ncbi_species_taxid, .keep_all = TRUE)

#ncbi_taxonomy

write_tsv(to_write_published,  "/projectnb/talbot-lab-data/Katies_data/picrust_for_fungi_package/mycocosm_published_struo.tsv")