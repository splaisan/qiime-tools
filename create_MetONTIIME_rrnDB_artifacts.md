## context

MetONTIIME comes as a method meant to replicate the ONT epi2me cloud solution for metagenomics 16S analysis. 
The softwafre used is different from the ONT pipeline but tries to perform similar steps and use similar reference data.

Using **[epi2me 16S](https://nanoporetech.com/nanopore-sequencing-data-analysis)** with gDNA sequencing data from the *[ZymoBIOMICS™ Microbial Community Standard](https://files.zymoresearch.com/protocols/_d6300_zymobiomics_microbial_community_standard.pdf)* detailed on our **[InSilico_PCR](https://github.com/Nucleomics-VIB/InSilico_PCR)** page. The results obtained with different in-silico amplicons showed that some of the expected genus were not detected in that data (reported by others too).
We then analyzed the read dta with MetONTIIME using the 'official' NCBI reference database () and with another popular public references (Silva).
The results obtained with Silva were very encourageing as they included the genuses missed with the NCBI reference and therefore 
