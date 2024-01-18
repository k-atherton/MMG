source("annotation_analysis/functions.R")

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
  index <- which((spp_name_file == "GeneCatalog") | (spp_name_file == "filtered") | (spp_name_file == "GO.tab.gz") | (spp_name_file == "FilteredModels1"))
  if(index[1] > 2){
    spp_name <- paste(spp_name_file[1:(index[1] - 1)], collapse = "_")
  } else{
    spp_name <- spp_name_file[1]
  }
  portal_names <- c(portal_names, spp_name)
}

n_occur <- data.frame(table(portal_names))
duplicates <- n_occur[n_occur$Freq > 1,]

if(nrow(duplicates) > 0){
  filenames_duplicates <- c()
  for(i in 1:length(file_list)){
    spp_name_file <- strsplit(x=file_list[i],
                              split = "_")[[1]]
    index <- which((spp_name_file == "GeneCatalog") | (spp_name_file == "filtered") | (spp_name_file == "GO.tab.gz") | (spp_name_file == "FilteredModels1"))
    if(index[1] > 2){
      spp_name <- paste(spp_name_file[1:(index[1] - 1)], collapse = "_")
    } else{
      spp_name <- spp_name_file[1]
    }
    if(spp_name %in% duplicates$portal_names){
      filenames_duplicates <- c(filenames_duplicates, file_list[i])
    }
  }
  
  filenames_duplicates <- as.data.frame(filenames_duplicates)
  filenames_duplicates$portal <- NA
  
  for(i in 1:length(filenames_duplicates$filenames_duplicates)){
    spp_name_file <- strsplit(x=filenames_duplicates$filenames_duplicates[i],
                              split = "_")[[1]]
    index <- which((spp_name_file == "GeneCatalog") | (spp_name_file == "filtered") | (spp_name_file == "GO.tab.gz") | (spp_name_file == "FilteredModels1"))
    if(index[1] > 2){
      spp_name <- paste(spp_name_file[1:(index[1] - 1)], collapse = "_")
    } else{
      spp_name <- spp_name_file[1]
    }
    filenames_duplicates$portal[i] <-spp_name
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
    file_remove <- c(file_remove, 
                     filenames_duplicates$filenames_duplicates[which((filenames_duplicates$date != date_keep) & (filenames_duplicates$portal == portal))])
  }
  if(length(file_remove) > 0){
    files_remove <- which(file_list %in% file_remove)
    filenames <- filenames[-files_remove]
    file_list <- file_list[-files_remove] 
  }
}

### MAKE A LIST OF GENE NAMES #################################################
gene_list <- lapply(filenames, get_GOacc)
gene_names <- plyr::ldply(gene_list, data.frame)
gene_names <- distinct(gene_names)

### GET GENE COUNTS ###########################################################
gene_count_list <- lapply(file_list, get_gene_count, gene_names = gene_names)

### COLLATE DATA ##############################################################
gene_count_data <- Reduce(combine_second_column, gene_count_list)
gene_count_data[is.na(gene_count_data)] <- 0

### SAVE COUNTS CSV ###########################################################
write.csv(gene_count_data, file = "data/GO_annotations_count_table.csv", row.names = FALSE)

### NORMALIZE COUNTS TO GENOME SIZE (PER 10,000 GENES) ########################
rownames(gene_count_data) <- gene_count_data$goAcc
gene_count_data <- gene_count_data[,-1]
gene_count_norm <- normalize_genome_count(gene_count_data)
write.csv(gene_count_norm, file = "data/GO_annotations_count_table_norm.csv")

### IMPORT MYCOCOSM DATABASE ##################################################
mycocosm <- read.csv("data/mycocosm_its_merge.csv")
mycocosm$species <- gsub(" ", "_", mycocosm$species)

### ASSIGN GENUS AND SPECIES TO GENOMES #######################################
gene_count_t <- as.data.frame(t(gene_count_data))
gene_count_t$Genus <- NA
gene_count_t$Species <- NA

for(i in 1:nrow(gene_count_t)){
  portal <- rownames(gene_count_t)[i]
  gene_count_t$Genus[i] <- mycocosm$genus[which(mycocosm$portal == portal)]
  gene_count_t$Species[i] <- mycocosm$species[which(mycocosm$portal == portal)]
}

