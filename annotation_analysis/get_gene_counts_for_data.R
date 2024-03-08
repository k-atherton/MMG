library(dplyr)

args <- commandArgs(trailingOnly = TRUE)
path <- args[1] #path to ASV table with taxonomy csv file, variable name data

### READ IN DATA AND AVERAGE GENE COUNTS #####################################
data <- read.csv(path)
species_count <- read.delim("data/GO_average_bySpecies.csv", sep = ",", row.names = 1)
genus_count <- read.delim("data/GO_average_byGenus.csv", sep = ",", row.names = 1)
its_copy <- read.csv("ITS_copy_Bradshaw2023.csv", row.names = 1)

### ONLY TAKE SPECIES AND GENERA THAT WE HAVE GENES FOR ######################
data_w_species <- data[which(data$species %in% row.names(species_count)),]
data_w_genus <- data[which(data$genus %in% row.names(genus_count)),]

### REMOVE SPECIES THAT WE HAVE MATCH FOR FROM GENUS COUNT ###################
if(nrow(data_w_species) > 0){
  data_w_genus <- data_w_genus[-as.numeric(rownames(data_w_species)),]
}

### ADJUST GENUS AND SPECIES DATAFRAMES FOR APPENDING ########################
data_w_genus$taxa <- data_w_genus$genus
data_w_species$taxa <- data_w_species$species

### APPEND DATAFRAMES ########################################################
data_w_genes <- rbind(data_w_genus, data_w_species) 
taxa <- data_w_genes$taxa
data_w_genes <- select_if(data_w_genes, is.numeric)
cols <- ncol(data_w_genes)
data_w_genes$taxa <- taxa

### AGGREGATE COUNTS FOR DUPLICATE TAXA ######################################
data_w_genes_unique <- aggregate(.~taxa, data_w_genes, sum)

### ADJUST COUNTS BY ITS COPY NUMBER #########################################
its_copy_exact <- its_copy[which(its_copy$taxa %in% data_w_genes_unique$taxa),]
taxa_genus <- sapply(strsplit(data_w_genes_unique$taxa,"_"), `[`, 1)
its_copy_genus <- its_copy[which(its_copy$taxa %in% taxa_genus),]

for(i in 1:nrow(data_w_genes_unique)){
  taxa <- data_w_genes_unique$taxa[i]
  genus <- strsplit(taxa, "_")[[1]][1]
  if(taxa %in% its_copy_exact$taxa){
    n <- its_copy$ITS.Copies[which(its_copy$taxa == taxa)]
    data_w_genes_unique[i,2:ncol(data_w_genes_unique)] <- data_w_genes_unique[i,2:ncol(data_w_genes_unique)]/n
  }
  else if(genus %in% its_copy_genus$taxa){
    n <- its_copy$ITS.Copies[which(its_copy$taxa == genus)]
    data_w_genes_unique[i,2:ncol(data_w_genes_unique)] <- data_w_genes_unique[i,2:ncol(data_w_genes_unique)]/n
  }
}

### APPEND GENUS AND SPECIES GENE COUNT DATAFRAMES ###########################
genus_w_data <- genus_count[which(row.names(genus_count) %in% data_w_genes_unique$taxa),]
species_w_data <- species_count[which(row.names(species_count) %in% data_w_genes_unique$taxa),]
genes_w_data <- rbind(species_w_data, genus_w_data) 
genes_w_data <- genes_w_data[ order(row.names(genes_w_data)), ]

### MAKE FINAL DATAFRAME #####################################################
gene_count_per_sample <- data.frame(matrix(NA, nrow = ncol(genes_w_data), ncol = (ncol(data_w_genes_unique)-1)))
rownames(gene_count_per_sample) <- colnames(genes_w_data)
colnames(gene_count_per_sample) <- colnames(data_w_genes_unique)[2:(ncol(data_w_genes_unique))]

for(i in 1:nrow(gene_count_per_sample)){ # gene
  gene <- row.names(gene_count_per_sample)[i]
  gene_count <- genes_w_data[,which(colnames(genes_w_data) == gene)]
  for(j in 1:ncol(gene_count_per_sample)){ # sample
    sample <- colnames(gene_count_per_sample)[j]
    taxa_count <- data_w_genes_unique[,which(colnames(data_w_genes_unique) == sample)]
    total <- gene_count * taxa_count
    gene_count_per_sample[i,j] <- sum(total)
  }
}

write.csv(gene_count_per_sample, "data/gene_count_per_sample.csv")
