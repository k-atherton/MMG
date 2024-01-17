### DOWNLOAD MYCOCOSM DATA #####################
mycocosm <- read.delim("/projectnb2/talbot-lab-data/Katies_data/picrust_for_fungi_package/data/mycocosm_database.csv", sep = ",")
mycocosm$species <- gsub(pattern=' ', replacement='_', mycocosm$species)
mycocosm <- mycocosm[which(mycocosm$is_published == "Y"),]

rm(list=setdiff(ls(), "mycocosm"))

### DATA ######################################
data <- readr::read_csv("/projectnb/talbot-lab-data/Katies_data/Street_Trees/dada2_output/ITS_NR1_trunc/ST_ITS_NR1_ASV_w_tax_20240115.csv")
data_w_mycocosm <- data[which(data$Species %in% mycocosm$species),]
data_w_mycocosm_genus <- data[which(data$Genus %in% mycocosm$genus),]
data_w_mycocosm_genus <- data_w_mycocosm_genus[-which(data_w_mycocosm_genus$Species %in% data_w_mycocosm$Species),]

mycocosm_w_data <- mycocosm[which(mycocosm$genus %in% data_w_mycocosm_genus$Genus),]
mycocosm_w_species <- mycocosm[which(mycocosm$species %in% data_w_mycocosm$Species),]

to_download <- c(mycocosm_w_data$portal, mycocosm_w_species$portal)
to_download <- unique(to_download)
portals <- paste(to_download, collapse = ",")
lines <-paste0("curl -k 'https://genome-downloads.jgi.doe.gov/portal/ext-api/downloads/bulk/request' -b cookies --data-urlencode 'portals=",paste(portals, collapse = ","),"' --data-urlencode 'fileTypes=Annotation' --data-urlencode 'filePattern=.*_GO\\.tab\\.gz' --data-urlencode 'sendMail=true'")

sink("/projectnb/talbot-lab-data/Katies_data/picrust_for_fungi_package/mycocosm_download_scc_command.sh")
cat("curl -k 'https://signon.jgi.doe.gov/signon/create' --data-urlencode 'login=katherto@bu.edu' --data-urlencode 'password=x6tsgfDJJ#vNP!q' -c cookies > /dev/null\n")
cat(lines)
sink()