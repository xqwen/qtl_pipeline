# cis-eQTL analysis with DAP: a step-by-step guide

This page provides a step-by-by guide to analyze cis-eQTL data (from a single tissue) using the software package DAP, which enables highly effient Bayesian multi-SNP analysis. Among many important features, DAP allows to incorporate genomic annotations into the eQTL mapping.

Here we show a step-by-step guide to analyze a subset of [GEUVADIS](http://www.geuvadis.org/) data that contains genotype-expression data for 92 Toscani samples. This data set contains expression data of 11,837 protein-coding and LincRNA genes measured in LCLs. The candidate SNPs for cis-eQTL mapping are those within the 100kb radius of the trasnscription start site (TSS) of each gene.      

The described analysis is performed in a single multi-core Linux box. The procedure utilizes the feature of multi-thread processing. It can also be adjusted to run in a cluster environment.  

## Step 1: software installation

The following binary executables are **required** by the analysis
  * [dap-g](https://github.com/xqwen/dap/tree/master/dap_greedy_src): the newest implementation of the DAP algorithm for multi-SNP fine-mapping
  * [torus](https://github.com/xqwen/dap/tree/master/torus_src): for prior specification

The following utility is recommended
  * [openmp-wrapper](https://github.com/xqwen/openmp_wrapper): for automatic multi-thread processing

Download and compile the source code from the above URLs and make the binary executables accessible to the analysis.



# Step 2: data preparation


