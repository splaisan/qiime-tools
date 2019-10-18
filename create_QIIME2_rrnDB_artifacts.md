## context

MetONTIIME comes as a method meant to replicate the ONT epi2me cloud solution for metagenomics 16S analysis. 
The softwafre used is different from the ONT pipeline but tries to perform similar steps and use similar reference data.

Using **[epi2me 16S](https://nanoporetech.com/nanopore-sequencing-data-analysis)** with gDNA sequencing data from the *[ZymoBIOMICS™ Microbial Community Standard](https://files.zymoresearch.com/protocols/_d6300_zymobiomics_microbial_community_standard.pdf)* detailed on our **[InSilico_PCR](https://github.com/Nucleomics-VIB/InSilico_PCR)** page. The results obtained with different in-silico amplicons showed that some of the expected genus were not detected in that data (reported by others too).
We then analyzed the read dta with **[MetONTIIME](https://github.com/MaestSi/MetONTIIME)** using the 'official' NCBI reference database **[BioProject 33175](https://www.ncbi.nlm.nih.gov/nuccore?term=33175%5BBioProject%5D)** and with another popular public references **[SILVA](https://www.arb-silva.de/fileadmin/silva_databases/qiime/Silva_132_release.zip)** (see *[create_QIIME2_SILVA_artifacts](create_QIIME2_SILVA_artifacts.md)* for the preparation of the Silva qiime artifacts).

The MetONTIIME results obtaioned with **[BioProject 33175** were close to the ONT epi2me results and missing a few bacterial strains.
The results obtained with **Silva** were by contrast very encourageing as they included the E Coli genus missed with the NCBI reference and therefore seem closer to the real community content as reported by the vendor.

![original genus plot](pictures/Zymo_compositions_Fig1.png)

A third database, **rrn** was created in order to analyse long rRNA amplicons encompassing bother 16S and 23S together with the ITS region as described in recent papers by *[Cusco et al, 2019](https://doi.org/10.12688/f1000research.16817.2)*.

We detail here the procedure to create Qiime2 artifacts for the rrn database for use in MetONTIIME or QIIME2.

## create qiime artifacts for the rrnDB database 

The **rrnDB** public database was derived from the NCBI RefSeq collection ([Stoddard et al, 2015](https://dx.doi.org/10.1093%2Fnar%2Fgku1201)) and contains genomic regions corresponding to the full 16S_ITS_18S locus from a large number of bacteria. We obtained this data and corresponding accession numbers from the **[github repository](https://github.com/alfbenpa/rrn_db)**.

The procedure includes the following steps

* get public data from the **rrn** repository

* reformat the rrn data and create Qiime compatible data

* get GB data to build a taxonomy mapping of the sequences

* convert the reformatted data in Qiime format

### get public data from the **rrn** repository

### get GB data to build a taxonomy mapping of the sequences

```
wget https://github.com/alfbenpa/rrn_db/blob/master/operon.100.fa.tar.gz
tar -xzvf operon.100.fa.tar.gz

wget https://github.com/alfbenpa/rrn_db/blob/master/species_annotation

# rename fasta headers with rrn2ncbi.R
Rscript rrn2ncbi.R operons.100.fa species_annotation operons.100_gb_names.fa
```

### reformat the rrn data and create Qiime compatible data

The **rrn2ncbi.R** script (provided by *[Simone Maestri](https://github.com/MaestSi)*) was used to rename the fasta sequences based on the accompanying annotation file

```
# prepare rrnaDB data for MetONTIIME
# source activate MetONTIIME_env
# Rscript rrn2ncbi.R operons.100.fa species_annotation operons.100_gb_names.fa
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
```

### get GB data to build a taxonomy mapping of the sequences

Direct classification of the **rrnDB** with the classical genbank *nucl_gb.accession2taxid* as detailerd in the *[MetONTIIME tutorial[(https://github.com/MaestSi/MetONTIIME)* leads to **8012** missing accessions. The same analysis using the second dump file *nucl_wgs.accession2taxid* missed **3755** accessions. This motivated merging both files to recover more taxons.

The 2 Genbank dumps *nucl_gb.accession2taxid* and *nucl_wgs.accession2taxid* were therefore merged to a non-redundant file that covers most of the **rrnDB** accessions. Only **283** accessions from the rrnDB out of **11484** were still missed with the merged reference set. We did not try to rescue the remaining GBacc which probbaly correspond to removed or renamed records.

```
# get raw data from NCBI
wget ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/accession2taxid/nucl_gb.accession2taxid.gz
gunzip nucl_gb.accession2taxid.gz 

wget ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/accession2taxid/nucl_wgs.accession2taxid.gz
gunzip nucl_wgs.accession2taxid.gz 

# merge to a unique dataset
cat nucl_gb.accession2taxid nucl_wgs.accession2taxid | sort | uniq > nucl_merged.accession2taxid
```

### convert the reformatted data in Qiime format

The fasta, ncbi-dump, and merged accession table were fed to **[entrez_qiime](https://github.com/bakerccm/entrez_qiime)** to produce a taxonomy used by **Qiime2** to create * the final **rnDB_operons_sequence.qza** and **rrnDB_operons_taxonomy.qza** artifacts.

```
# use to create annotation taxonomy as detailed in MetONTIIME/Import_database.sh
python2.7 ./entrez_qiime/entrez_qiime.py \
 -i operons.100_gb_names.fa \
 -n ./taxonomy/taxdump \
 -a ./taxonomy/nucl_merged.accession2taxid

# create Qiime2 artefacts for MetONTIIME
qiime tools import \
  --type FeatureData[Sequence] \
  --input-path rrnDB/operons.100_gb_names.fa\
  --output-path rrnDB_operons_sequence.qza

qiime tools import \
  --type FeatureData[Taxonomy] \
  --input-path  rrnDB/operons.100_merged_accession_taxonomy.txt \
  --input-format HeaderlessTSVTaxonomyFormat \
  --output-path rrnDB_operons_taxonomy.qza
```
