# Create QIIME2 v138 nr99 classifier for SSU (16S) region V3-4
# work files are stored in tax/workdir 
# final classifiers are stored in the tax folder 

# https://forum.qiime2.org/t/processing-filtering-and-evaluating-the-silva-database
# -and-other-reference-sequence-data-with-rescript/15494

conda activate qiime2-2020.8
# install RESCRIPt within Qiime2
# conda activate qiime2-2020.8
# conda install -c conda-forge -c bioconda -c qiime2 -c defaults xmltodict
# install rescript from git
# pip install git+https://github.com/bokulich-lab/RESCRIPt.git

# CPU resources
nthr=8

# V3-4 primers: (443bps)
#   314F: CCTACGGGNGGCWGCAG 
#   805R: GACTACHVGGGTATCTAATCC

fname="314f"
fseq="CCTACGGGNGGCWGCAG"
rname="805r"
rseq="GACTACHVGGGTATCTAATCC"

export basedir=$PWD
mkdir -p ${basedir}/tax/workdir && cd ${basedir}/tax/workdir

########################################################## end user edits###########

# get silva 99 r138
qiime rescript get-silva-data \
    --p-version '138' \
    --p-target 'SSURef_NR99' \
    --p-include-species-labels \
    --o-silva-sequences silva-138-ssu-nr99-seqs.qza \
    --o-silva-taxonomy silva-138-ssu-nr99-tax.qza

# “Culling” low-quality sequences with cull-seqs
qiime rescript cull-seqs \
    --i-sequences silva-138-ssu-nr99-seqs.qza \
    --o-clean-sequences silva-138-ssu-nr99-seqs-cleaned.qza \
    --p-n-jobs ${nthr} \
    
# Filtering sequences by length and taxonomy
qiime rescript filter-seqs-length-by-taxon \
    --i-sequences silva-138-ssu-nr99-seqs-cleaned.qza \
    --i-taxonomy silva-138-ssu-nr99-tax.qza \
    --p-labels Archaea Bacteria Eukaryota \
    --p-min-lens 900 1200 1400 \
    --o-filtered-seqs silva-138-ssu-nr99-seqs-filt.qza \
    --o-discarded-seqs silva-138-ssu-nr99-seqs-discard.qza

# Dereplicating in uniq mode
qiime rescript dereplicate \
    --i-sequences silva-138-ssu-nr99-seqs-filt.qza  \
    --i-taxa silva-138-ssu-nr99-tax.qza \
    --p-rank-handles 'silva' \
    --p-mode 'uniq' \
    --o-dereplicated-sequences silva-138-ssu-nr99-seqs-derep-uniq.qza \
    --o-dereplicated-taxa silva-138-ssu-nr99-tax-derep-uniq.qza \
    --p-threads ${nthr}
    
# create classifier (takes time!)
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads  silva-138-ssu-nr99-seqs-derep-uniq.qza \
  --i-reference-taxonomy silva-138-ssu-nr99-tax-derep-uniq.qza \
  --o-classifier ${basedir}/tax/silva-138-ssu-nr99-classifier.qza


###########################################
# Make amplicon-region specific classifier 
###########################################

qiime feature-classifier extract-reads \
    --i-sequences ${basedir}/tax/silva-138-ssu-nr99-seqs-derep-uniq.qza \
    --p-f-primer ${fseq} \
    --p-r-primer ${rseq} \
    --p-n-jobs ${nthr} \
    --p-read-orientation 'forward' \
    --o-reads silva-138-ssu-nr99-seqs-${fname}-${rname}.qza

# Dereplicating extracted region in uniq mode 
qiime rescript dereplicate \
    --i-sequences silva-138-ssu-nr99-seqs-${fname}-${rname}.qza \
    --i-taxa silva-138-ssu-nr99-tax-derep-uniq.qza \
    --p-rank-handles 'silva' \
    --p-mode 'uniq' \
    --o-dereplicated-sequences silva-138-ssu-nr99-seqs-${fname}-${rname}-uniq.qza \
    --o-dereplicated-taxa  silva-138-ssu-nr99-tax-${fname}-${rname}-derep-uniq.qza \
    --p-threads ${nthr}

# create amplicon-region specific classifier (takes time!)
qiime feature-classifier fit-classifier-naive-bayes \
    --i-reference-reads silva-138-ssu-nr99-seqs-${fname}-${rname}-uniq.qza \
    --i-reference-taxonomy silva-138-ssu-nr99-tax-${fname}-${rname}-derep-uniq.qza \
    --o-classifier ${basedir}/tax/silva-138-ssu-nr99-${fname}-${rname}-classifier.qza
