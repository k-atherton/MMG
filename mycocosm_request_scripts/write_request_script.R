args <- commandArgs(trailingOnly = TRUE)

mycocosm_data <- args[1] #Mycocosm w/ ITS database, variable name mycocosm
fungi <- args[2] #Path to file with list of fungal taxa in dataset, variable name fungalTax
cwd <- args[3] #Path to Script Directory, variable name scriptDir
username <- args[4] #Mycocosm email address
password <- args[5] #Mycocosm password
annotation <- args[6] #Type of annotation, options: GO, KEGG, InterPro, KOG, Signalp

print(username)
print(password)

### DOWNLOAD MYCOCOSM DATA #####################
mycocosm <- read.delim(mycocosm_data, sep = ",")
mycocosm$species <- gsub(pattern=' ', replacement='_', mycocosm$species)
mycocosm <- mycocosm[which(mycocosm$is_published == "Y"),]

### DATA ######################################
data <- readr::read_csv(fungi)
data_w_mycocosm <- data[which(data$Species %in% mycocosm$species),]
data_w_mycocosm_genus <- data[which(data$Genus %in% mycocosm$genus),]
if("Species" %in% colnames(data)){
  data_w_mycocosm_genus <- data_w_mycocosm_genus[-which(data_w_mycocosm_genus$Species %in% data_w_mycocosm$Species),]
}

mycocosm_w_data <- mycocosm[which(mycocosm$genus %in% data_w_mycocosm_genus$Genus),]
mycocosm_w_species <- mycocosm[which(mycocosm$species %in% data_w_mycocosm$Species),]

to_download <- c(mycocosm_w_data$portal, mycocosm_w_species$portal)
to_download <- unique(to_download)
portals <- paste(to_download, collapse = ",")
login <- paste0("curl -k 'https://signon.jgi.doe.gov/signon/create' --data-urlencode 'login=",username,"' --data-urlencode 'password=",password,"' -c cookies > /dev/null\n")

if(annotation == "GO"){
  lines <-paste0("curl -k 'https://genome-downloads.jgi.doe.gov/portal/ext-api/downloads/bulk/request' -b cookies --data-urlencode 'portals=",paste(portals, collapse = ","),"' --data-urlencode 'fileTypes=Annotation' --data-urlencode 'filePattern=.*_GO\\.tab\\.gz' --data-urlencode 'sendMail=true'")
  sink(paste0(cwd,"/mycocosm_download_scc_command.sh"))
  cat(login)
  cat(lines)
  sink()
} else if(annotation == "KEGG"){
  lines <-paste0("curl -k 'https://genome-downloads.jgi.doe.gov/portal/ext-api/downloads/bulk/request' -b cookies --data-urlencode 'portals=",paste(portals, collapse = ","),"' --data-urlencode 'fileTypes=Annotation' --data-urlencode 'filePattern=.*_KEGG\\.tab\\.gz' --data-urlencode 'sendMail=true'")
  sink(paste0(cwd,"/mycocosm_download_scc_command.sh"))
  cat(login)
  cat(lines)
  sink()
} else if(annotation == "InterPro"){
  lines <-paste0("curl -k 'https://genome-downloads.jgi.doe.gov/portal/ext-api/downloads/bulk/request' -b cookies --data-urlencode 'portals=",paste(portals, collapse = ","),"' --data-urlencode 'fileTypes=Annotation' --data-urlencode 'filePattern=.*_IPR\\.tab\\.gz' --data-urlencode 'sendMail=true'")
  sink(paste0(cwd,"/mycocosm_download_scc_command.sh"))
  cat(login)
  cat(lines)
  sink()
} else if(annotation == "KOG"){
  lines <-paste0("curl -k 'https://genome-downloads.jgi.doe.gov/portal/ext-api/downloads/bulk/request' -b cookies --data-urlencode 'portals=",paste(portals, collapse = ","),"' --data-urlencode 'fileTypes=Annotation' --data-urlencode 'filePattern=.*_KOG\\.tab\\.gz' --data-urlencode 'sendMail=true'")
  sink(paste0(cwd,"/mycocosm_download_scc_command.sh"))
  cat(login)
  cat(lines)
  sink()
} else if(annotation == "Signalp"){
  lines <-paste0("curl -k 'https://genome-downloads.jgi.doe.gov/portal/ext-api/downloads/bulk/request' -b cookies --data-urlencode 'portals=",paste(portals, collapse = ","),"' --data-urlencode 'fileTypes=Annotation' --data-urlencode 'filePattern=.*_SigP\\.tab\\.gz' --data-urlencode 'sendMail=true'")
  sink(paste0(cwd,"/mycocosm_download_scc_command.sh"))
  cat(login)
  cat(lines)
  sink()
} else{
  print("Error: unrecognized annotation type. Options are GO, KEGG, InterPro, KOG, or Signalp.")
}