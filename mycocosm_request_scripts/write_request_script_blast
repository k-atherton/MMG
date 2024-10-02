args <- commandArgs(trailingOnly = TRUE)

fungi <- args[1] #Path to file with list of Mycocosm Portal IDs
cwd <- args[2] #Path to Script Directory, variable name scriptDir
username <- args[3] #Mycocosm email address
password <- args[4] #Mycocosm password
annotation <- args[5] #Type of annotation, options: GO, KEGG, InterPro, KOG, Signalp

print(username)
print(password)

### DATA ######################################
data <- readr::read_csv(fungi)

to_download <- data$portal
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
