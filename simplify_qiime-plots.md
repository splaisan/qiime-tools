# AT WORK

## context
By default Qiime2 produces boxplot labels covering the full taxonomy length (up to 7 levels in my case). These levels print ugly when data is submitted to the very neat **[Qiime2view](https://view.qiime2.org/)**

Two simple pilelines are shown below to produce 1-level data and create a more readable plot from it
The method can be devided as follows (thanks to the post by **[Nicholas_Bokulich](https://forum.qiime2.org/t/command-or-tool-to-shorten-the-very-long-labels-in-viewer-from-taxa-bar-plots-qzv/12023/3))**

## method

* export the current **taxonomy.qza** to a **.tsv** file using qiime export

```
qiime tools export --input-path taxonomy.qza --output-path taxonomy_export
```

* adapt the **.tsv** file to simplify the taxon column to your needs, (genus and species shown here)
  - two custom bash functions have been created to operate on genus or species level

    ```
    function cleantaxonomy (){
      glev=6
      slev=7
      outfolder=taxonomy_genus_species
      mkdir -p ${outfolder}
      gawk -v glev="${glev}" -v slev="${slev}" 'BEGIN{FS="\t"; OFS="\t"}\
      {if(NR==1){print $0} else \
      {split($2,tax,";"); \
      genus=tax[glev]; gsub("D_.__", "", genus); split(genus,gena," "); \
      gen=gena[1]; gsub(/[ \t]+$/,"",gen); \
      species=tax[slev]; gsub("D_.__", "", species); split(species,spea," "); \
      spe=spea[1]" "spea[2]; gsub(/[ \t]+$/,"",spe); \
      print $1,gen";"spe,$3}}' $1 > "${outfolder}/${1%.tsv}.tsv"
    }
        
    # run with
    cleantaxonomy taxonomy.tsv
    ```

* convert the new folder and contained modified **.tsv** file back to a **qza** artefact

```
# reimport
qiime tools import \
  --type FeatureData[Taxonomy] \
  --input-path taxonomy_genus_species \
  --output-path taxonomy_cleaned.qza
```

* produce the **qzv** input for the viewer (requires $SAMPLE_METADATA defined before)

```
# choose either qza from (cleaned-table-no-unassigned.qza)
qiime taxa barplot \
  --i-table table.qza \
  --i-taxonomy taxonomy_cleaned.qza \
  --m-metadata-file $SAMPLE_METADATA \
  --o-visualization cleaned-taxa-bar-plots.qzv
```

* optionally filter out 'unclassified/unassigned' rows in the **table.qza** if you do not want them in the barplot

```
qiime taxa filter-table \
  --i-table table.qza \
  --i-taxonomy taxonomy.qza \
  --p-exclude Unassigned \
  --o-filtered-table table-no-unassigned.qza
```

* produce the **qzv** input for the viewer (requires $SAMPLE_METADATA defined before)

```
# choose either qza from (cleaned-table-no-unassigned.qza)
qiime taxa barplot \
  --i-table table-no-unassigned.qza \
  --i-taxonomy taxonomy_cleaned.qza \
  --m-metadata-file $SAMPLE_METADATA \
  --o-visualization cleaned-no-unassigned-taxa-bar-plots.qzv
```
* upload the created **taxa-bar-plots.qzv** to the viewer

## examples

The first plot shows the very long labels obtained at species level with the MetONTIIME data

![original genus plot](pictures/silva_original_genus_taxa_plot.png)

![original species plot](pictures/silva_original_species_taxa_plot.png)

After cleaning the taxonomy labels, the genus and species levels are shown below

For the total data (including unassigned reads)

![cleaned genus plot](pictures/silva_cleaned_genus_taxa_plot.png)

![cleaned species plot](pictures/silva_cleaned_species_taxa_plot.png)

For the assigned data
