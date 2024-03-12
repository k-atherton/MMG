library(plyr)
library(dplyr)
library(vegan)

###### functions to get gene counts ############################################
call_in_files <- function(file){
  gene.table <- read.delim(file, sep = "\t", header = TRUE)
  return(print(file))
}

get_genes <- function(file, a_type){
  if(a_type == "GO"){
    gene.table <- read.delim(file,sep="\t",header=TRUE)
    gene.table$numHits <- 1
    data <- aggregate(numHits~goAcc, gene.table, sum)
    data <- data[order(data$goAcc),]
    rownames(data) <- data[,1]
    data <- data.frame(goAcc=data[,1])
    return(data)
  } else if(a_type == "KEGG"){
    gene.table <- read.delim(file,sep="\t",header=TRUE)
    gene.table$numHits <- 1
    data <- aggregate(numHits~ecNum, gene.table, sum)
    data <- data[order(data$ecNum),]
    rownames(data) <- data[,1]
    data <- data.frame(ecNum=data[,1])
    return(data)
  } else if(a_type == "InterPro"){
    gene.table <- read.delim(file,sep="\t",header=TRUE)
    gene.table$numHits <- 1
    data <- aggregate(numHits~iprId, gene.table, sum)
    data <- data[order(data$iprId),]
    rownames(data) <- data[,1]
    data <- data.frame(iprId=data[,1])
    return(data)
  } else if(a_type == "KOG"){
    gene.table <- read.delim(file,sep="\t",header=TRUE)
    gene.table$numHits <- 1
    data <- aggregate(numHits~kogid, gene.table, sum)
    data <- data[order(data$kogid),]
    rownames(data) <- data[,1]
    data <- data.frame(kogid=data[,1])
    return(data)
  } else if(a_type == "SignalP"){
    gene.table <- read.delim(file,sep="\t",header=TRUE, skip = 1)
    gene.table$numHits <- 1
    data <- aggregate(numHits~proteinid, gene.table, sum)
    data <- data[order(data$proteinid),]
    rownames(data) <- data[,1]
    data <- data.frame(proteinid=data[,1])
    return(data)
  } else{
    print("Error: unrecognized annotation type. See documentation for accepted annotationt types.")
  }
}

get_gene_count <- function(file,gene_names,a_type){
  if(a_type == "GO"){
    gene.table <- read.delim(paste0(path,"/",file),sep="\t",header=TRUE)
    gene.table$numHits <- 1
    data <- aggregate(as.numeric(gene.table$numHits), by = list(gene.table$goAcc), FUN = "sum")
    rownames(data) <- data[,1]
    spp_name_file <- strsplit(x=file,
                              split = "_")[[1]]
    index <- which((spp_name_file == "GeneCatalog") | (spp_name_file == "filtered") | (spp_name_file == paste0(a_type,".tab.gz")) | (spp_name_file == "FilteredModels1"))
    if(index[1] > 2){
      spp_name <- paste(spp_name_file[1:(index[1] - 1)], collapse = "_")
    } else{
      spp_name <- spp_name_file[1]
    }
    colnames(data)[1] <- "gene_id"
    colnames(data)[2] <-paste0(spp_name)
    data <- dplyr::left_join(gene_names,data,by = "gene_id")
    return(data) 
  } else if(a_type == "KEGG"){
    gene.table <- read.delim(paste0(path,"/",file),sep="\t",header=TRUE)
    gene.table$numHits <- 1
    data <- aggregate(as.numeric(gene.table$numHits), by = list(gene.table$ecNum), FUN = "sum")
    rownames(data) <- data[,1]
    spp_name_file <- strsplit(x=file,
                              split = "_")[[1]]
    index <- which((spp_name_file == "GeneCatalog") | (spp_name_file == "filtered") | (spp_name_file == paste0(a_type,".tab.gz")) | (spp_name_file == "FilteredModels1"))
    if(index[1] > 2){
      spp_name <- paste(spp_name_file[1:(index[1] - 1)], collapse = "_")
    } else{
      spp_name <- spp_name_file[1]
    }
    colnames(data)[1] <- "gene_id"
    colnames(data)[2] <-paste0(spp_name)
    data <- dplyr::left_join(gene_names,data,by = "gene_id")
    return(data)
  } else if(a_type == "IPR"){
    gene.table <- read.delim(paste0(path,"/",file),sep="\t",header=TRUE)
    gene.table$numHits <- 1
    data <- aggregate(as.numeric(gene.table$numHits), by = list(gene.table$iprId), FUN = "sum")
    rownames(data) <- data[,1]
    spp_name_file <- strsplit(x=file,
                              split = "_")[[1]]
    index <- which((spp_name_file == "GeneCatalog") | (spp_name_file == "filtered") | (spp_name_file == paste0(a_type,".tab.gz")) | (spp_name_file == "FilteredModels1"))
    if(index[1] > 2){
      spp_name <- paste(spp_name_file[1:(index[1] - 1)], collapse = "_")
    } else{
      spp_name <- spp_name_file[1]
    }
    colnames(data)[1] <- "gene_id"
    colnames(data)[2] <-paste0(spp_name)
    data <- dplyr::left_join(gene_names,data,by = "gene_id")
    return(data)
  } else if(a_type == "KOG"){
    gene.table <- read.delim(paste0(path,"/",file),sep="\t",header=TRUE)
    gene.table$numHits <- 1
    data <- aggregate(as.numeric(gene.table$numHits), by = list(gene.table$kogid), FUN = "sum")
    rownames(data) <- data[,1]
    spp_name_file <- strsplit(x=file,
                              split = "_")[[1]]
    index <- which((spp_name_file == "GeneCatalog") | (spp_name_file == "filtered") | (spp_name_file == paste0(a_type,".tab.gz")) | (spp_name_file == "FilteredModels1"))
    if(index[1] > 2){
      spp_name <- paste(spp_name_file[1:(index[1] - 1)], collapse = "_")
    } else{
      spp_name <- spp_name_file[1]
    }
    colnames(data)[1] <- "gene_id"
    colnames(data)[2] <-paste0(spp_name)
    data <- dplyr::left_join(gene_names,data,by = "gene_id")
    return(data)
  } else if(a_type == "Sigp"){
    gene.table <- read.delim(paste0(path,"/",file),sep="\t",header=TRUE, skip=1)
    gene.table$numHits <- 1
    data <- aggregate(as.numeric(gene.table$numHits), by = list(gene.table$proteinid), FUN = "sum")
    rownames(data) <- data[,1]
    spp_name_file <- strsplit(x=file,
                              split = "_")[[1]]
    index <- which((spp_name_file == "GeneCatalog") | (spp_name_file == "filtered") | (spp_name_file == paste0(a_type,".tab.gz")) | (spp_name_file == "FilteredModels1"))
    if(index[1] > 2){
      spp_name <- paste(spp_name_file[1:(index[1] - 1)], collapse = "_")
    } else{
      spp_name <- spp_name_file[1]
    }
    colnames(data)[1] <- "gene_id"
    colnames(data)[2] <-paste0(spp_name)
    data <- dplyr::left_join(gene_names,data,by = "gene_id")
    return(data)
  } else{
    print("Error: unrecognized annotation type. See documentation for accepted annotationt types.")
  }
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
  gene_list <- lapply(filenames, get_gene_id)
  gene_names <- plyr::ldply(gene_list, data.frame)
  gene_count_list <- lapply(file_list, gene_count, gene_names = gene_names)
  gene_count_dat <- Reduce(combine_second_column, gene_count_list)
  gene_count_dat[is.na(gene_count_dat)] <- 0
  gene_count_dat <- dplyr::distinct(gene_count_dat)
  rownames(gene_count_dat) <- gene_count_dat$gene_id
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

average_taxa <- function(data_t, taxa, colname){
  data_average <- as.data.frame(matrix(ncol = (ncol(data_t) - 2), 
                                       nrow = length(taxa)))
  colnames(data_average) <- colnames(data_t)[1:(ncol(data_t)-2)]
  rownames(data_average) <- taxa
  
  index <- which(colnames(data_t) == colname)
  
  for(i in 1:nrow(data_average)){
    genus <- rownames(data_average)[i]
    rows <- data_t[which(data_t[,index] == genus), c(1:(ncol(data_t)-2))]
    average <- colSums(rows)/nrow(rows)
    data_average[i,] <- average
  }
  
  return(data_average)
}
