source("annotation_analysis/functions.R")

args <- commandArgs(trailingOnly = TRUE)
annotation <- args[1] #annotation type (options: GO, KEGG, InterPro, KOG, Signalp)

if(annotation == "GO"){
  a_file <- "GO"
} else if(annotation == "KEGG"){
  a_file <- "KEGG"
} else if(annotation == "InterPro"){
  a_file <- "IPR"
} else if(annotation == "KOG"){
  a_file <- "KOG"
} else if(annotation == "Signalp"){
  a_file <- "Sigp"
} else {
  print("Error: unrecognized annotation type. Options: GO, KEGG, InterPro, KOG, Signalp")
}

### SET PATH TO WHERE ALL ANNOTATIONN FILES FOR A SINGLE TYPE OF ANNOTATION ARE LOCATED
path <- "mycocosm_annotations"

### GET FILE NAMES (WILL BE COLUMN NAMES IN FINAL FILE) #######################
filenames <- list.files(path, full.names=TRUE)
file_list <- list.files(path = path, pattern = "*.tab")

### CALL IN FILES #############################################################
lapply(filenames, call_in_files)

### REMOVE EMPTY FILES #######################################################
empty_files <- c()
for(i in 1:length(filenames)){
  gene.table <- read.delim(filenames[[i]],sep="\t",header=TRUE)
  if(nrow(gene.table) == 0){
    empty_files <- c(empty_files, i)
  }
}
if(length(empty_files) > 0){
  filenames <- filenames[-empty_files]
  file_list <- file_list[-empty_files] 
}
### REMOVE FILES THAT ARE DUPLICATES OF THE SAME GENOME #######################
portal_names <- c()
for(i in 1:length(file_list)){
  spp_name_file <- strsplit(x=file_list[i],
                            split = "_")[[1]]
  index <- which((spp_name_file == "GeneCatalog") | (spp_name_file == "filtered") | (spp_name_file == paste0(a_file,".tab.gz")) | (spp_name_file == "FilteredModels1"))
  if(index[1] > 2){
    spp_name <- paste(spp_name_file[1:(index[1] - 1)], collapse = "_")
  } else{
    spp_name <- spp_name_file[1]
  }
  portal_names <- c(portal_names, spp_name)
}
portal_names_no_nums <- portal_names
for(i in 1:length(portal_names_no_nums)){
  portal <- strsplit(x=portal_names_no_nums[i], split = "-")
  if(length(portal[[1]]) > 1){
    portal_names_no_nums[i] <- portal[[1]][!grepl("^[[:digit:]]+", portal[[1]])]
  }
}

n_occur <- data.frame(table(portal_names_no_nums))
duplicates <- n_occur[n_occur$Freq > 1,]

portals_duplicate <- c()

for(i in 1:nrow(duplicates)){
  portal <- as.character(duplicates$portal_names_no_nums[i])
  index <- which(portal == portal_names_no_nums)
  portals_duplicate <- c(portals_duplicate, portal_names[index])
}

if(nrow(duplicates) > 0){
  filenames_duplicates <- c()
  for(i in 1:length(file_list)){
    spp_name_file <- strsplit(x=file_list[i],
                              split = "_")[[1]]
    index <- which((spp_name_file == "GeneCatalog") | (spp_name_file == "filtered") | (spp_name_file == paste0(a_file,".tab.gz")) | (spp_name_file == "FilteredModels1"))
    if(index[1] > 2){
      spp_name <- paste(spp_name_file[1:(index[1] - 1)], collapse = "_")
    } else{
      spp_name <- spp_name_file[1]
    }
    if(spp_name %in% portals_duplicate){
      filenames_duplicates <- c(filenames_duplicates, file_list[i])
    }
  }
  
  filenames_duplicates <- as.data.frame(filenames_duplicates)
  filenames_duplicates$portal <- NA
  
  for(i in 1:length(filenames_duplicates$filenames_duplicates)){
    spp_name_file <- strsplit(x=filenames_duplicates$filenames_duplicates[i],
                              split = "_")[[1]]
    index <- which((spp_name_file == "GeneCatalog") | (spp_name_file == "filtered") | (spp_name_file == paste0(a_file,".tab.gz")) | (spp_name_file == "FilteredModels1"))
    if(index[1] > 2){
      spp_name <- paste(spp_name_file[1:(index[1] - 1)], collapse = "_")
    } else{
      spp_name <- spp_name_file[1]
    }
    filenames_duplicates$portal[i] <-spp_name
  }
  
  filenames_duplicates$other <- NA
  
  for(i in 1:length(filenames_duplicates$portal)){
    portal <- strsplit(x=filenames_duplicates$portal[i], split = "-")
    if(length(portal[[1]]) > 1){
      filenames_duplicates$portal[i] <- portal[[1]][!grepl("^[[:digit:]]+", portal[[1]])]
      filenames_duplicates$other[i] <- portal[[1]][grepl("^[[:digit:]]+", portal[[1]])]
    }
  }
  
  filenames_duplicates$date <- NA
  for(i in 1:length(filenames_duplicates$filenames_duplicates)){
    spp_name_file <- strsplit(x=filenames_duplicates$filenames_duplicates[i],
                              split = "_")[[1]]
    index <- length(spp_name_file) - 1
    spp_name <- spp_name_file[index]
    filenames_duplicates$date[i] <-spp_name
  }
  
  unique_duplicates <- unique(filenames_duplicates$portal)
  file_remove <- c()
  for(i in 1:length(unique_duplicates)){
    portal <- unique_duplicates[i]
    date_keep <- max(filenames_duplicates$date[which(filenames_duplicates$portal == portal)])
    delete <- filenames_duplicates$filenames_duplicates[which((filenames_duplicates$date != date_keep) & (filenames_duplicates$portal == portal))]
    if(length(delete) < 1){
      other_keep <- max(filenames_duplicates$other[which(filenames_duplicates$portal == portal)])
      delete <- filenames_duplicates$filenames_duplicates[which((filenames_duplicates$other != other_keep) & (filenames_duplicates$portal == portal))]
    }
    file_remove <- c(file_remove, delete)
  }                 
  if(length(file_remove) > 0){
    files_remove <- which(file_list %in% file_remove)
    filenames <- filenames[-files_remove]
    file_list <- file_list[-files_remove] 
  }
}

### MAKE A LIST OF GENE NAMES #################################################
gene_list <- lapply(filenames, get_genes, a_type=annotation)
gene_names <- plyr::ldply(gene_list, data.frame)
gene_names <- distinct(gene_names)
colnames(gene_names) <- "gene_id"

### GET GENE COUNTS ###########################################################
gene_count_list <- lapply(file_list, get_gene_count, gene_names = gene_names, a_type = a_file)

### COLLATE DATA ##############################################################
gene_count_data <- Reduce(combine_second_column, gene_count_list)
for(i in 1:ncol(gene_count_data)){
  portal <- strsplit(x=colnames(gene_count_data)[i], split = "-")
  if(length(portal[[1]]) > 1){
    colnames(gene_count_data)[i] <- portal[[1]][!grepl("^[[:digit:]]+", portal[[1]])]
  }
}
gene_count_data[is.na(gene_count_data)] <- 0

### SAVE COUNTS CSV ###########################################################
write.csv(gene_count_data, file = "data/annotations_count_table.csv", row.names = FALSE)

### NORMALIZE COUNTS TO GENOME SIZE (PER 10,000 GENES) ########################
rownames(gene_count_data) <- gene_count_data$gene_id
gene_count_data <- gene_count_data[,-1]
gene_count_norm <- normalize_genome_count(gene_count_data)
write.csv(gene_count_norm, file = "data/annotations_count_table_norm.csv")

### IMPORT MYCOCOSM DATABASE ##################################################
mycocosm <- read.csv("data/mycocosm_its_merge.csv")
mycocosm$species <- gsub(" ", "_", mycocosm$species)

### ASSIGN GENUS AND SPECIES TO GENOMES #######################################
gene_count_t <- as.data.frame(t(gene_count_norm))
gene_count_t$Genus <- NA
gene_count_t$Species <- NA

for(i in 1:nrow(gene_count_t)){
  portal <- rownames(gene_count_t)[i]
  gene_count_t$Genus[i] <- mycocosm$genus[which(mycocosm$portal == portal)]
  gene_count_t$Species[i] <- mycocosm$species[which(mycocosm$portal == portal)]
}

### AVERAGE GENE COUNTS FOR SPECIES ##########################################
species <- unique(gene_count_t$Species)
average_species_count <- average_taxa(gene_count_t, species, "Species")
write.csv(average_species_count, file = "data/annotation_average_bySpecies.csv")

### AVERAGE GENE COUNTS FOR GENERA ###########################################
genera <- unique(gene_count_t$Genus)
average_genus_count <- average_taxa(gene_count_t, genera, "Genus")
write.csv(average_genus_count, file = "data/annotation_average_byGenus.csv")
