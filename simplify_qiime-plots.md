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
		function cleangenus (){
		  level=6;
		  outfolder=taxonomy_genus
		  mkdir -p ${outfolder}
		  gawk -v lev="${level}" 'BEGIN{FS="\t"; OFS="\t"}\
		  {if(NR==1){print $0} else \
		  {split($2,tax,";"); res=tax[lev]; \
      gsub("D_.__", "", res); split(res,gen," "); \
      gsub(/[ \t]+$/,"",gen[1]); \
		  print $1,gen[1],$3}}' $1 > "${outfolder}/${1%.tsv}.tsv"
		}

		function cleanspecies (){
		  level=7;
		  outfolder=taxonomy_species
		  mkdir -p ${outfolder}
		  gawk -v lev="${level}" 'BEGIN{FS="\t"; OFS="\t"}\
		  {if(NR==1){print $0} else \
		  {split($2,tax,";"); \
		  res=tax[lev]; split(res,spe," "); \
		  col2=spe[1]" "spe[2]; \
		  gsub(/[ \t]+$/,"",col2); \
		  print $1,col2,$3}}' $1 > "${outfolder}/${1%.tsv}.tsv"
		}
    ```

* convert the new folder and contained modified **.tsv** file back to a **qza** artefact

```
# for genus
qiime tools import \
  --type FeatureData[Taxonomy] \
  --input-path taxonomy_genus \
  --output-path taxonomy_genus.qza

# for species
qiime tools import \
  --type FeatureData[Taxonomy] \
  -input-path taxonomy_species \
  --output-path taxonomy_species.qza
```

* optionally filter out 'unclassified/unassigned' rows in the **table.qza** if you do not want them in the barplot

```
# choose either genus or species file below!
qiime taxa filter-table \
  --i-table table.qza \
  --i-taxonomy taxonomy_<genus|species>.qza \
  --p-exclude Unassigned \
  --o-filtered-table <genus|species>-table-no-unassigned.qza
```

* produce the **qzv** input for the viewer (requires $SAMPLE_METADATA defined before)

```
# choose either qza from above(
qiime taxa barplot \
  --i-table <table.qza|table-no-unassigned.qza> \
  --i-taxonomy taxonomy_<genus|species>.qza \
  --m-metadata-file $SAMPLE_METADATA \
  --o-visualization <genus|species>-taxa-bar-plots.qzv
```

## Problem !

The simplification worked as shown below

```
head taxonomy_export/taxonomy.tsv taxonomy_genus/taxonomy.tsv taxonomy_species/taxonomy.tsv 
==> taxonomy_export/taxonomy.tsv <==
Feature ID	Taxon	Consensus
00020107f579a17c6029b07351bf5744479bd7c8	D_0__Bacteria;D_1__Firmicutes;D_2__Bacilli;D_3__Bacillales;D_4__Bacillaceae;D_5__Bacillus;D_6__Bacillus subtilis	1.0
0003ba2cd3d636339b5bbf188964c6be168b2cf4	D_0__Bacteria;D_1__Firmicutes;D_2__Bacilli;D_3__Bacillales;D_4__Bacillaceae;D_5__Bacillus;D_6__Streptococcus pneumoniae	1.0
00044aa9825d55df21182e70982a97c1c9968184	D_0__Bacteria;D_1__Firmicutes;D_2__Bacilli;D_3__Bacillales;D_4__Bacillaceae;D_5__Bacillus;D_6__Bacillus subtilis	1.0
00052864db9eb0e8e141c725007d9daf9a8be86d	D_0__Bacteria;D_1__Proteobacteria;D_2__Gammaproteobacteria;D_3__Pseudomonadales;D_4__Pseudomonadaceae;D_5__Pseudomonas;D_6__metagenome	1.0
0009f868d18c2d64177c453b36b5b3fbcd2bbff2	D_0__Bacteria;D_1__Firmicutes;D_2__Bacilli;D_3__Bacillales;D_4__Staphylococcaceae;D_5__Staphylococcus;D_6__Staphylococcus aureus DAR3919	1.0
000a914ffaaeefe4cc5c5ba7d5fc0d8c2069acbf	D_0__Bacteria;D_1__Firmicutes;D_2__Bacilli;D_3__Lactobacillales;D_4__Lactobacillaceae;D_5__Lactobacillus;D_6__Lactobacillus fermentum	1.0
000b7d774410671c26231e4b674fc1b4a2f80e6c	D_0__Bacteria;D_1__Firmicutes;D_2__Bacilli;D_3__Bacillales;D_4__Bacillaceae;D_5__Bacillus;D_6__Bacillus subtilis	1.0
0012ee985d6dd440a583ea2e93ae082a00ddcb7f	D_0__Bacteria;D_1__Firmicutes;D_2__Bacilli;D_3__Bacillales;D_4__Listeriaceae;D_5__Listeria;D_6__Listeria monocytogenes	1.0
00138ad4bbf960cdcb83de0eb76429344015b90d	D_0__Bacteria;D_1__Firmicutes;D_2__Bacilli;D_3__Lactobacillales;D_4__Enterococcaceae;D_5__Enterococcus;D_6__uncultured bacterium	1.0

==> taxonomy_genus/taxonomy.tsv <==
Feature ID	Taxon	Consensus
00020107f579a17c6029b07351bf5744479bd7c8	Bacillus	1.0
0003ba2cd3d636339b5bbf188964c6be168b2cf4	Bacillus	1.0
00044aa9825d55df21182e70982a97c1c9968184	Bacillus	1.0
00052864db9eb0e8e141c725007d9daf9a8be86d	Pseudomonas	1.0
0009f868d18c2d64177c453b36b5b3fbcd2bbff2	Staphylococcus	1.0
000a914ffaaeefe4cc5c5ba7d5fc0d8c2069acbf	Lactobacillus	1.0
000b7d774410671c26231e4b674fc1b4a2f80e6c	Bacillus	1.0
0012ee985d6dd440a583ea2e93ae082a00ddcb7f	Listeria	1.0
00138ad4bbf960cdcb83de0eb76429344015b90d	Enterococcus	1.0

==> taxonomy_species/taxonomy.tsv <==
Feature ID	Taxon	Consensus
00020107f579a17c6029b07351bf5744479bd7c8	D_6__Bacillus subtilis	1.0
0003ba2cd3d636339b5bbf188964c6be168b2cf4	D_6__Streptococcus pneumoniae	1.0
00044aa9825d55df21182e70982a97c1c9968184	D_6__Bacillus subtilis	1.0
00052864db9eb0e8e141c725007d9daf9a8be86d	D_6__metagenome	1.0
0009f868d18c2d64177c453b36b5b3fbcd2bbff2	D_6__Staphylococcus aureus	1.0
000a914ffaaeefe4cc5c5ba7d5fc0d8c2069acbf	D_6__Lactobacillus fermentum	1.0
000b7d774410671c26231e4b674fc1b4a2f80e6c	D_6__Bacillus subtilis	1.0
0012ee985d6dd440a583ea2e93ae082a00ddcb7f	D_6__Listeria monocytogenes	1.0
00138ad4bbf960cdcb83de0eb76429344015b90d	D_6__uncultured bacterium	1.0
```

In the scase of species, I left the leading 'D_6__' but the error below remains when also removing this prefix

I ran the command below both with the original table.qza, the table-no-unassigned.qza OR the new <genus|species>-table-no-unassigned.qza without change in the error.

It seems that the simplified taxonomy_species.qza data is not structurally correct anymore to generate the plot

```
qiime taxa barplot --i-table table-no-unassigned.qza --i-taxonomy taxonomy_species.qza --m-metadata-file $SAMPLE_METADATA --o-visualization species-taxa-bar-plots.qzv
Plugin error from taxa:

  'float' object has no attribute 'split'

Debug info has been saved to /tmp/qiime2-q2cli-err-ufm_ty_p.log
(MetONTIIME_env) u0002316@gbw-s-pacbio01:/data2/analyses/MetONTIIME_4smpl_silva$ cat /tmp/qiime2-q2cli-err-ufm_ty_p.log
Traceback (most recent call last):
  File "/opt/biotools/miniconda3/envs/MetONTIIME_env/lib/python3.6/site-packages/q2cli/commands.py", line 327, in __call__
    results = action(**arguments)
  File "</opt/biotools/miniconda3/envs/MetONTIIME_env/lib/python3.6/site-packages/decorator.py:decorator-gen-144>", line 2, in barplot
  File "/opt/biotools/miniconda3/envs/MetONTIIME_env/lib/python3.6/site-packages/qiime2/sdk/action.py", line 240, in bound_callable
    output_types, provenance)
  File "/opt/biotools/miniconda3/envs/MetONTIIME_env/lib/python3.6/site-packages/qiime2/sdk/action.py", line 445, in _callable_executor_
    ret_val = self._callable(output_dir=temp_dir, **view_args)
  File "/opt/biotools/miniconda3/envs/MetONTIIME_env/lib/python3.6/site-packages/q2_taxa/_visualizer.py", line 34, in barplot
    collapsed_tables = _extract_to_level(taxonomy, table)
  File "/opt/biotools/miniconda3/envs/MetONTIIME_env/lib/python3.6/site-packages/q2_taxa/_util.py", line 37, in _extract_to_level
    max_obs_lvl = _get_max_level(taxonomy)
  File "/opt/biotools/miniconda3/envs/MetONTIIME_env/lib/python3.6/site-packages/q2_taxa/_util.py", line 11, in _get_max_level
    return taxonomy.apply(lambda x: len(x.split(';'))).max()
  File "/opt/biotools/miniconda3/envs/MetONTIIME_env/lib/python3.6/site-packages/pandas/core/series.py", line 3591, in apply
    mapped = lib.map_infer(values, f, convert=convert_dtype)
  File "pandas/_libs/lib.pyx", line 2217, in pandas._libs.lib.map_infer
  File "/opt/biotools/miniconda3/envs/MetONTIIME_env/lib/python3.6/site-packages/q2_taxa/_util.py", line 11, in <lambda>
    return taxonomy.apply(lambda x: len(x.split(';'))).max()
AttributeError: 'float' object has no attribute 'split'
```

* upload the created **taxa-bar-plots.qzv** to the viewer

## examples
