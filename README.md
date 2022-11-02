# **GAAP-BP**

*GAAP-BP v. 1.0* - **G**enome **A**ssembly and **A**nnotation **P**ipeline for **B**acteria **P**acbio<br>
<br>

MIT LICENSE - Copyright © 2022 Gian M.N. Benucci, Ph.D.<br>
email: *benucci[at]msu[dot]edu*<br>
Gisa-BP v.1, October 2022<br>

*This pipeline is based upon work supported by the Great Lakes Bioenergy Research Center,
U.S. Department of Energy, Office of Science, Office of Biological and Environmental 
Research under award DE-SC0018409*

### **Installation**

To use Gisa-PB just clone the directory 
```
git clone git@github.com:Gian77/GAAP-BP.git
```
You will then need to 
* Copy your raw reads file in the rawdata directory together with a md5sum file.
* Install all the necessary tools through `conda` (please see the complete list of tools reported below).
* Download the databases (please see below and the `config.yaml` file), and include the full paths into the config file.
* Select all the **User options** (please see below).

Then you should be good to go and run Gisa-PB by just 
`sh Gisa-PB-v1.sh`

### **Let's explore the settings in the `config.yaml` file**

#### **Directories**
The main project's directory is: `project_dir="/mnt/home/benucci/genome-pipe-bac-pb`. Of course, you will need to adjust the path to your HPCC user name. 

> **_IMPORTANT NOTEs_**<br> 
* This pipeline was born for running on the `HPCC` at Michigan State University on the `dev-amd20` (which as 128 cpus per node). If you want to run this piepline in any other systems it will require (possibly substantial) modification of the main, as well as, the accessory scripts.
* The individual scripts in the `code` direcotry include the buy-in node priority `#SBATCH -A shade-cole-bonito`. If you do not have access to those priority nodes please remove that line in the individual scripts.
* You can change the name of the project directory. However, you will not be able to change the other direcotiry names (i.e. `outputs` and `slurms`) becasue they are part of the workflow, unless you want to modify the individual scripts.
* Please check the config file for options. A few script are additional and are can be avoided to save time.

#### **Default to the `rawdata` directory**
When the config is sourced it defaults to the `rawdata` project directory
```
cd $project_dir/rawdata/
```

#### **Databases**
Find a place in your lab space (or in your home directory) where to put all the needed databases.
Correct the directory hierarchy according to your HPCC account name.
```
NCBI_nt="/mnt/research/ShadeLab/Benucci/databases/ncbi_nt1121"
kraken2_db="/mnt/research/ShadeLab/Benucci/databases/kraken2_db/"
minikraken2_db="/mnt/research/ShadeLab/Benucci/databases/minikraken2_db/"
dmnd_bac="/mnt/research/ShadeLab/Benucci/databases/emapperdb/eggdb_bacteria.dmnd"
platon_db="/mnt/research/ShadeLab/Benucci/databases/platon_db/db/"
mash_plsdb="/mnt/research/ShadeLab/Benucci/databases/plasmid_db/plsdb.msh"
mash_plsdb_meta="/mnt/research/ShadeLab/Benucci/databases/plasmid_db/plsdb.tsv"
busco_db="/mnt/research/ShadeLab/Benucci/databases/busco_db1121/bacteria_odb10"
```
#### **PATHs**
```
export GTDBTK_DATA_PATH=/mnt/research/ShadeLab/Benucci/databases/gtdb_tk/release207_v2
export EGGNOG_DATA_DIR=/mnt/research/ShadeLab/Benucci/databases/emapperdb/
export GUNC_DB=/mnt/research/ShadeLab/Benucci/databases/gunc_db/gunc_db_progenomes2.1.dmnd
```

### **User options**
If not *numeric* (i.e. float) then `yes` or `no`.

```
MASH=yes
BAKTA=no
EGGNOG=yes
CHROMOSOMES=5
```

### **Software needed to fully run Gisa-PB on HPCC**

Please install via conda (or use the binaries in the HPPC) of all these software below. 
* ##### [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
* ##### [NanoStat](https://github.com/wdecoster/nanostat)
* ##### [Flye](https://github.com/fenderglass/Flye)
* ##### [Minimap2](https://github.com/lh3/minimap2)
* ##### [Racon](https://github.com/isovic/racon)
* ##### [Pilon](https://github.com/broadinstitute/pilon/wiki)
* ##### [Circlator](https://sanger-pathogens.github.io/circlator/)
* ##### [quast](http://bioinf.spbau.ru/quast)
* ##### [qualimap](https://github.com/EagleGenomics-cookbooks/QualiMap)
* ##### [BLAST](https://blast.ncbi.nlm.nih.gov/Blast.cgi?PAGE_TYPE=BlastDocs)
* ##### [BlobTools](https://github.com/DRL/blobtools)
* ##### [Platon](https://github.com/oschwengers/platon)
* ##### [Mash](https://github.com/marbl/Mash)
* ##### [Kraken 2](https://ccb.jhu.edu/software/kraken2/)
* ##### [Bracken](https://github.com/jenniferlu717/Bracken)
* ##### [CheckM](https://ecogenomics.github.io/CheckM/)
* ##### [GTDB-Tk](https://github.com/Ecogenomics/GTDBTk)
* ##### [Barrnap](https://github.com/tseemann/barrnap)
* ##### [Metaxa2](https://microbiology.se/software/metaxa2/)
* ##### [eggNOG](https://github.com/eggnogdb)
* ##### [Prokka](https://github.com/tseemann/prokka)
* ##### [Bakta](https://github.com/oschwengers/bakta)
* ##### [BUSCO](https://busco.ezlab.org/)
* ##### [ABRicate](https://github.com/tseemann/abricate)
* ##### [MultiQC](https://github.com/ewels/MultiQC)
* ##### [Bandage](https://github.com/rrwick/Bandage)

