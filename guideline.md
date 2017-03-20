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

The illustrated analysis also utilizes SNP and gene position information. The SNP position file can be downloaded from [here](http://www-personal.umich.edu/~xwen/download/qtl_example/geuv.snp.map.gz). The Gene position file can be downloaded from [here](http://www-personal.umich.edu/~xwen/download/qtl_example/geuv.gene.map.gz).

## Step 3: set up working directory

1. create a working directory ```workspace```, this directory is assumed to be the current working directory (cwd) from this point on.
2. create an empty directory ```workspace/sbams_data/``` and move the downloaded data file into this directory
3. unpack the data file: ```cd sbsams_data; tar zxf geuv.tsi.eqtl.sbams.tgz```. In the end, there should be 11,837 data files named as "***gene_name***.dat" unpacked in the ```sbams_data``` directory.


## Step 4: prior estimation

Before the multi-SNP mapping, we first set the prior for each candidate cis-SNP. In cis-eQTL mapping, it is well-known that candidate SNPs located closer to transcription start site (TSS) is more likely to be associated with the  expression level of the targe gene. We will utilize this information to quantify different priors for different SNPs according to their distance to TSS (DTSS). In particular, we treat the genomic feature DTSS as a categorical annotation and use the executable```torus``` for prior estimation. The statistical procedure is described in [Wen 2016](http://projecteuclid.org/euclid.aoas/1475069621).

### Step 4.1: obtain single-SNP association test statistics

If the eQTL data are already analyzed by either [```MatrixEQTL```](http://www.bios.unc.edu/research/genomic_software/Matrix_eQTL/) or [```fastQTL```](http://fastqtl.sourceforge.net/), the output from either software can be fed into ```torus``` for prior estimation.

Alternatively, single-SNP Bayes factor can be computed by ```dap-g``` using the following command
```
 dap-g -d gene_name.dat -scan > gene_name.bf
```
where ```gene_name.dat``` a single sbams format genotype-expression file.

For batch processing,

1. download ```batch_scan.pl``` from the [repo]() into the ```workspace``` directory
2. create directory ```workspace/scan_out```
3. run ```perl batch_scan.pl > batch_scan.cmd```
4. batch processing by ```openmp_wraper -d batch_scan.cmd -t 8``` where "-t 8" specifices that 8 parallel threads are requested.
5. upon completion, obtain the combine the data by ```cat scan_out/*.bf | gzip - > geuv.tsi.bf.gz``` 

The output ```guev.tsi.bf.gz``` should appear in ```workspace``` upon completion.


### Step 4.2: run ```torus```

To obtain the priors, issue the following command from ```workspace``` directory

```torus -d geuv.tsi.bf.gz -smap geuv.snp.map.gz -gmap geuv.gene.map.gz --load_bf -dump_prior priors```

In the end, 11,837 prior files should be output into the newly created directory ```workspace/priors```. It is important to emphasize here that prior should be estimated for ***all genes*** (instead of just a few selected ones) for the necessary statistical rigor. 

## Step 5: multi-SNP fine-mapping

With the prior and genotype-phenotype file ready, the multi-SNP cis-eQTL mapping can be achieved by the following command

``` dap-g -d gene_name.dat -p gene_name.prior -t 4 -ld_control 0.25 --no_size_limit > gene_name.fm.out```

The command line options are explained in below

  *  ```-d gene_name.dat```: specify the sbams format genotype-phenotype data
  *  ```-p gene_name.prior```: specify the prior file for the corresponding gene generated by ```torus```
  *  ```-t 4```: running ```dap-g``` with 4 parallel threads
  *  ```-ld_control 0.25```: lower r^2 threshold for ```dap-g``` to consider multiple SNPs (in LD) responsible to a single association signal. (if not specified, the thereshold is 0)
  *  ```--no_size_limit``` : do not restrict the number of SNPs within a single association signal cluster (the default value is set to be 25)


For batch processing,

1. download ```batch_dap.pl``` from the [repo]() into the ```workspace``` directory
2. create directory ```workspace/dap_out```
3. run ```perl batch_dap.pl > batch_dap.cmd```
4. batch processing by ```openmp_wraper -d batch_dap.cmd -t 4``` where "-t 4" specifices that 8 parallel threads are requested.
