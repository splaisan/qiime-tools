# Context
By default Qiime2 produces boxplot labels covering the full taxonomy length (up to 7 levels in my case). These levels print ugly when data is submitted to the very neat **[Qiime2view](https://view.qiime2.org/)**

Two simple pilelines are shown below to produce 1-level data and create a more readable plot from it
The method can be devided as follows (thanks to the post by **[Nicholas_Bokulich](https://forum.qiime2.org/t/command-or-tool-to-shorten-the-very-long-labels-in-viewer-from-taxa-bar-plots-qzv/12023/3))**

* export the current **taxonomy.qza** using qiime export

```
qiime tools export --input-path taxonomy.qza --output-path taxonomy_export
```

* adapt the tsv file to simplify the taxon column to your needs, (genus and species shown here)
  - two custom bash functions have been created to operate on genus or species level

    ```
    cleangenus () 
    { 
    
      level=6;
      outfolder=taxonomy_species
      mkdir -p ${outfolder}
      gawk -v lev="${level}" 'BEGIN{FS="\t"; OFS="\t"}\
      {if(NR==1){print $0} else \
      {split($2,tax,";"); res=tax[lev]; gsub("D_.__", "", res); split(res,gen," "); \
      print $1,gen[1],$3}}' $1 > "${outfolder}/${1%.tsv}.tsv"
    
    }
    
    cleanspecies () 
    { 
      level=7;
      outfolder=taxonomy_genus
      mkdir -p ${outfolder}
      gawk -v lev="${level}" 'BEGIN{FS="\t"; OFS="\t"}\
      {if(NR==1){print $0} else \
      {split($2,tax,";"); res=tax[lev]; gsub("D_.__", "", res); split(res,spe," "); \
      print $1,spe[1]" "spe[2],$3}}' $1 > "${outfolder}/${1%.tsv}.tsv"
    }
    ```

* convert the folder and contained modified tsv file back as a **qza** artefact

```
# for genus
qiime tools import --type FeatureData[Taxonomy] --input-path taxonomy_genus --output-path taxonomy_genus.qza

# for species
qiime tools import --type FeatureData[Taxonomy] --input-path taxonomy_species --output-path taxonomy_species.qza
```

* optionally filter unclassified rows

```
# choose either genus or species file below!
qiime taxa filter-table \
  --i-table table.qza \
  --i-taxonomy taxonomy_<genus|species>.qza \
  --p-exclude Unassigned \
  --o-filtered-table table-no-unassigned.qza
```

* produce the viewer **qzv**

```
# choose either qza from above(
qiime qiime taxa barplot \
  --i-table <table.qza|table-no-unassigned.qza> \
  --i-taxonomy taxonomy.qza \
  --m-metadata-file $SAMPLE_METADATA \
  --o-visualization taxa-bar-plots.qzv
```

* upload **taxa-bar-plots.qzv** to the viewer
