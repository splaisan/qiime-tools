# prepare rrnaDB data for MetONTIIME
# source activate MetONTIIME_env
# usage: Rscript rrn2ncbi.R operons.100.fa species_annotation operons.100_gb_names.fa
# script provided by Simone Maestri (https://github.com/MaestSi) 
# 2019-10-16

suppressMessages(library("Biostrings"))
args = commandArgs(trailingOnly=TRUE)
db_file_name <- args[1]
annotation_file_name <- args[2]
output_file_name <- args[3]

db <- readDNAStringSet(db_file_name, "fasta")
orig_names <- names(db)
annotation_file <- read.table(file = annotation_file_name, sep = "\t", stringsAsFactors = FALSE)
new_names <- c()

for (i in 1:length(orig_names)) {
  new_names[i] <- annotation_file[which(orig_names[i] == annotation_file[, 2]), 3]
}

new_db <- db
names(new_db) <- new_names

writeXStringSet(x = new_db, filepath = output_file_name, format = "fasta", width = 20000)
