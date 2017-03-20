# cis-eQTL analysis with DAP: a step-by-step guide

This page provides a step-by-by guide to analyze cis-eQTL data (from a single tissue) using the software package DAP, which enables highly effient Bayesian multi-SNP analysis. Among many important features, DAP allows to incorporate genomic annotations into the eQTL mapping.

Here we show a step-by-step guide to analyze a subset of [GEUVADIS](http://www.geuvadis.org/) data that contains genotype-expression data for 92 Toscani(TSI) samples. This data set contains expression data of 11,837 protein-coding and LincRNA genes measured in LCLs. The candidate SNPs for cis-eQTL mapping are those within the 100kb radius of the trasnscription start site (TSS) of each gene.      

The described analysis is performed in a single multi-core Linux box. The procedure utilizes the feature of multi-thread processing. It can also be adjusted to run in a cluster environment.  

## Step 1: software installation

The following binary executables are ***required*** by the analysis
  * [dap-g](https://github.com/xqwen/dap/tree/master/dap_greedy_src): the newest implementation of the DAP algorithm for multi-SNP fine-mapping
  * [torus](https://github.com/xqwen/dap/tree/master/torus_src): for prior specification

The following utility is recommended
  * [openmp-wrapper](https://github.com/xqwen/openmp_wrapper): for automatic multi-thread processing

Download and compile the source code from the above URLs and make the binary executables accessible to the analysis.



## Step 2: data preparation

After standard QC and pre-processing steps, the genotype-phenotype information of each gene should be organized into a single text file. The file format is explained in [here](https://github.com/xqwen/dap/wiki/Case-study:-multi-SNP-fine-mapping#genotype-phenotype-data-file-required).  The formatted genotype-phenotype data files for 11,837 genes in GEUVADIS TSI samples can be downloaded from [here](http://www-personal.umich.edu/~xwen/download/qtl_example/geuv.tsi.eqtl.sbams.tgz).


## Step 3: set up working directory

1. create a working directory ```workspace```, this directory is assumed to be the current working directory (cwd) from this point on.
2. create an empty directory ```workspace/sbams_data/``` and move the downloaded data file into this directory
3. unpack the data file: ```cd sbsams_data; tar zxf geuv.tsi.eqtl.sbams.tgz```. In the end, there should be 11,837 data files named as "***gene_name***.dat" unpacked in the ```sbams_data``` directory.


## Step 4: prior estimation

Before the multi-SNP mapping, we first set the prior for each candidate cis-SNP. In cis-eQTL mapping, it is well-known that candidate SNPs located closer to transcription start site (TSS) is more likely to be associated with the  expression level of the targe gene. We will utilize this information to quantify different priors for different SNPs according to their distance to TSS (DTSS). In particular, we treat the genomic feature DTSS as a categorical annotation and use the executable```torus``` for prior estimation. The statistical procedure is described in [Wen 2016](http://projecteuclid.org/euclid.aoas/1475069621).

### Step 4.1: obtain single-SNP association test statistics

If the eQTL data are already analyzed by either [```MatrixEQTL```]() or [```fastQTL```](), the output from either software can be fed into ```torus``` for prior estimation. Alternatively, single-SNP Bayes factor can be computed by ```dap-g``` using the following command
```
 dap-g -d gene_name.dat -scan > gene_name.bf
```
where ```gene_name.dat``` a single sbams format genotype-expression file.

For batch processing,
1. download ```batch_scan.pl``` from the [repo]() into the ````workspace``` directory
2. create directory ```workspace/scan_out```
3. run ```perl batch_scan.pl > batch_scan.cmd```
4. batch processing by ```openmp_wraper -d batch_scan.cmd -t 8``` where "-t 8" specifices that 8 parallel threads are requested.
5. upon completion, obtain the combine the data by ```cat scan_out/*.bf | gzip - > geuv.tsi.bf.gz``` 

The output ```guev.tsi.bf.gz``` should appear in ```workspace``` upon completion.


### Step 4.2 run ```torus```

To obtain the priors, issue the following command from ```workspace``` directory

```torus -d geuv.tsi.bf.gz -smap geuv.snp.map.gz -gmap geuv.gene.map.gz --load_bf -dump_prior priors```

In the end, 11,837 prior files should be output into the newly created directory ```workspace/priors```.




