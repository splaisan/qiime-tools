Inspired from [https://forum.qiime2.org/t/nanopore-reads-analysis-using-qiime2/11364/2](https://forum.qiime2.org/t/nanopore-reads-analysis-using-qiime2/11364/2)

*REQUIREMENTS:* software as explained in the **[MetONTIIME tutorial and scripts](https://github.com/MaestSi/MetONTIIME)**

### get the SQILVA raw data from the server

```
wget https://www.arb-silva.de/fileadmin/silva_databases/qiime/Silva_132_release.zip
unzip Silva_132_release.zip
```

A folder was created which contains a full structure with imput files for **qiime import** commands

### create a single gene SILVA.132 database

Choose target database (16S or 18S) and a specificity in the code below. Comment/uncomment as required for your needs.

```
input="16S_only"
type="_16S"

# input="18S_only"
# type="_18S"

#identity=90
#identity=94
#identity=97
identity=99

qiime tools import \
    --type FeatureData[Sequence] \
    --input-path SILVA_132_QIIME_release/rep_set/rep_set_${input}/${identity}/silva_132_${identity}${type}.fna \
    --output-path silva_132_${identity}${type}_sequence.qza

qiime tools import \
    --type FeatureData[Taxonomy] \
    --input-path  SILVA_132_QIIME_release/taxonomy/${input}/${identity}/taxonomy_7_levels.txt \
    --input-format HeaderlessTSVTaxonomyFormat \
    --output-path silva_132_${identity}${type}_taxonomy.qza
```

### create a full operon SILVA.132 database

The artifacts will cover the full operon **16S-ITS-23S**

```
input="all"
type=""

qiime tools import \
    --type FeatureData[Sequence] \
    --input-path SILVA_132_QIIME_release/rep_set/rep_set_${input}/${identity}/silva132_${identity}${type}.fna \
    --output-path silva_132_${identity}${type}_sequence.qza

qiime tools import \
    --type FeatureData[Taxonomy] \
    --input-path  SILVA_132_QIIME_release/taxonomy/taxonomy_${input}/${identity}/taxonomy_7_levels.txt \
    --input-format HeaderlessTSVTaxonomyFormat \
    --output-path silva_132_${identity}${type}_taxonomy.qza
```
