# read data
blast <- read.table("blast_nn.txt")

# name columns
colnames(blast) <- c("ASV_ID", "portal_id", "perc_id", "alignment_length", "mismatches",
                        "gap_opens", "q_start", "q_end", "s_start", "s_end", "eval", "bit_score")

#format portal names
blast$portal_id <- gsub("-.*", "", blast$portal_id)

# take unique ASVs with genome matches
asvs <- unique(blast$ASV_ID)

# keep best match for each ASV
keep <- c()
for(i in 1:length(asvs)){
  asv <- asvs[i]
  data <- blast[which(blast$ASV_ID == asv),]
  best_match <- max(data$perc_id)
  best <- rownames(data)[which(data$perc_id == best_match)]
  keep <- c(keep, best)
}
blast <- blast[keep,]

write.csv(blast, "blast_portal_matches.csv")
