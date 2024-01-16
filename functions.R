library(plyr)
library(dplyr)
library(vegan)

###### functions to get gene counts ############################################
call_in_files <- function(file){
  gene.table <- read.delim(file, sep = "\t", header = TRUE)
  return(print(file))
}

get_GOacc <- function(file){
  gene.table <- read.delim(file,sep="\t",header=TRUE)
  gene.table$numHits <- 1
  data <- aggregate(numHits~goAcc, gene.table, sum)
  data <- data[order(data$goAcc),]
  rownames(data) <- data[,1]
  data <- data.frame(goAcc=data[,1])
  return(data)
}

get_GOgid <- function(file){
  gene.table <- read.delim(file,sep="\t",header=TRUE)
  gene.table$numHits <- 1
  data <- aggregate(numHits~GOgid, gene.table, sum)
  data <- data[order(data$GOgid),]
  rownames(data) <- data[,1]
  data <- data.frame(GOgid=data[,1])
  return(data)
}

get_pfam_names <- function(file){
  gene.table <- read.delim(file,sep="\t",header=TRUE)
  gene.table <- data.frame(subset(gene.table, gene.table$domainDb %in% c("HMMPfam")))
  data <- aggregate(gene.table$numHits, by = list(gene.table$domainId), FUN = "sum")
  rownames(data) <- data[,1]
  data <- data.frame(domainId=data[,1])
  return(data)
}

get_gene_count <- function(file,gene_names){
  gene.table <- read.delim(paste0(path,file),sep="\t",header=TRUE)
  gene.table$numHits <- 1
  data <- aggregate(as.numeric(gene.table$numHits), by = list(gene.table$goAcc), FUN = "sum")
  rownames(data) <- data[,1]
  spp_name <- strsplit(x=file,
                       split = "_")[[1]][1]
  
  colnames(data)[1] <- "goAcc"
  colnames(data)[2] <-paste0(spp_name)
  data <- dplyr::left_join(gene_names,data,by = "goAcc")
  return(data)
}

combine_second_column<-function(x,y){
  y2 <- data.frame(y[,2])
  names(y2)[1] <- names(y)[2]
  cbind(x,y2)
}  

### functions to make files ####################################################
make_merged_dataframe <- function(path){
  filenames <- list.files(path, full.names=TRUE) 
  file_list <- list.files(path=path, pattern="*.tab")
  lapply(filenames, read_file_dat)
  gene_list <- lapply(filenames, get_GOacc)
  gene_names <- plyr::ldply(gene_list, data.frame)
  gene_count_list <- lapply(file_list, gene_count, gene_names = gene_names)
  gene_count_dat <- Reduce(combine_second_column, gene_count_list)
  gene_count_dat[is.na(gene_count_dat)] <- 0
  gene_count_dat <- dplyr::distinct(gene_count_dat)
  rownames(gene_count_dat) <- gene_count_dat$goAcc
  gene_count_dat <- gene_count_dat[,-1]
  
  return(gene_count_dat)
}

normalize_genome_count <- function(gene_count_dat){
  genome_size <- colSums(gene_count_dat)
  for(i in 1:ncol(gene_count_dat)){
    size <- genome_size[[i]]
    gene_count_dat[,i] <- gene_count_dat[,i]/size*10000
  }
  
  return(gene_count_dat)
}

average_genus <- function(gene_count_dat, genera){
  data_t <- as.data.frame(t(gene_count_dat))
  data_t$Genus <- genera
  
  data_average <- as.data.frame(matrix(ncol = (ncol(data_t) - 1), 
                                       nrow = length(unique(genera))))
  colnames(data_average) <- rownames(gene_count_dat)
  rownames(data_average) <- unique(genera)
  
  for(i in 1:nrow(data_average)){
    genus <- rownames(data_average)[i]
    rows <- data_t[which(data_t$Genus == genus), c(1:nrow(gene_count_dat))]
    average <- colSums(rows)/nrow(rows)
    data_average[i,] <- average
  }
  
  return(data_average)
}
