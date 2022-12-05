#!/bin/bash -login

cat << "EOF"
   _________    ___    ____        ____  ____ 
  / ____/   |  /   |  / __ \      / __ )/ __ \
 / / __/ /| | / /| | / /_/ /_____/ __  / /_/ /
/ /_/ / ___ |/ ___ |/ ____/_____/ /_/ / ____/ 
\____/_/  |_/_/  |_/_/         /_____/_/      
                                              
EOF

echo -e "
GAAP-BP v. 1.0 - Genome Assembly and Annotation Pipeline for Bacteria Pacbio

MIT LICENSE - Copyright © 2022 Gian M.N. Benucci, Ph.D.
email: benucci[at]msu[dot]edu

`date`

This pipeline is based upon work supported by the Great Lakes Bioenergy Research Center,
U.S. Department of Energy, Office of Science, Office of Biological and Environmental 
Research under award DE-SC0018409\n"

source ./config.yaml
cd $project_dir/rawdata/

echo -e "\n========== Comparing md5sum codes... ==========\n"
md5=$project_dir/rawdata/md5.txt

if [[ -f "$md5" ]]; then
		echo -e "\nAn md5 file exist. Now checking for matching codes.\n"
		md5sum md5* --check > tested_md5.results
		cat tested_md5.results
		resmd5=$(cat tested_md5.results | cut -f2 -d" " | uniq)

		if [[ "$resmd5" == "OK" ]]; then
				echo -e "\n Good news! Files are identical. \n"
		else
				echo -e "\n Oh oh! You're in trouble. Files are different! \n"
				echo -e "\nSomething went wrong during files'download. Try again, please.\n"
				exit
		fi
else
	echo "No md5 file found. You should look for it and start over!"
	exit
fi

cd $project_dir/code/

echo -e "\n Submitting jobs to cue, one after another...\n"

echo -e "\n========== Prefiltering ==========\n" 
if [[ "$RAWFILES" == "fastq" ]]; then
	jid1=`sbatch 00.1_decompressfiles.sb | cut -d " " -f 4`
	echo "$jid1: Decompressing fastq files."  
elif [[ "$RAWFILES" == "bam" ]]; then
	jid1=`sbatch 00.2_generateHiFi-pbcss.sb | cut -d " " -f 4`
	echo "$jid1: Generate ccs (i.e. Pacbio HiFi) reads."  
fi

jid2=`sbatch --dependency=afterok:$jid1 01_rawquality-fastqc.sb | cut -d" " -f 4`
echo "$jid2: Check raw reads quality with fastqc."

jid3=`sbatch --dependency=afterok:$jid1 02_rawquality-nanostats.sb | cut -d" " -f 4`
echo "$jid3: Check raw reads quality with nanostats."

echo -e "\n========== Assembly, assembly evaluation, preliminary check for plasmid ==========\n" 
jid4=`sbatch --dependency=afterok:$jid1 03_assembly-flye.sb | cut -d" " -f 4`
echo "$jid4: Assembly using flye."

jid5=`sbatch --dependency=afterok:$jid4 04_polish-minimap2-racon-pilon.sb | cut -d" " -f 4`
echo "$jid5: Assembly polishing using racon and pilon."

jid6=`sbatch --dependency=afterok:$jid5 05_fixstart-circlator.sb | cut -d" " -f 4`
echo "$jid6: Circularize the genome and fixstart with the circlator pipeline."

jid7=`sbatch --dependency=afterok:$jid6 06_assemblyquality-quast.sb | cut -d" " -f 4`
echo "$jid7: Assembly quality and comparisons with quast"

jid8=`sbatch --dependency=afterok:$jid6 07_assemblyeval-minimap2-qualimap.sb | cut -d" " -f 4`
echo "$jid8: Assembly evaluation using Qualimap."

jid9=`sbatch --dependency=afterok:$jid6:$jid8 08_assemblyvisual-blast-blobtl.sb | cut -d" " -f 4`
echo "$jid9: Assembly visualization and quality check using BLAST and blobtools."

jid10=`sbatch --dependency=afterok:$jid6 09_plasmidcheck-platon.sb | cut -d" " -f 4`
echo "$jid10: Checking for plasmids using Platon."

jid11=`sbatch --dependency=afterok:$jid6 10_plasmidcheck-mash.sb | cut -d" " -f 4`
echo "$jid11: Checking for plasmids using Mash."

echo -e "\n========== Contigs classification ==========\n" 

jid12=`sbatch --dependency=afterok:$jid6 11_completeness-checkm-gtdbtk.sb | cut -d" " -f 4`
echo "$jid12: Assembly completeness and contamination using checkM and GTDB-tk."

jid13=`sbatch --dependency=afterok:$jid6 12_taxclassabund-kraken2-braken.sb | cut -d" " -f 4`
echo "$jid13: Assembly taxonomic classification and abundance with Kraken2 and Bracken."

jid14=`sbatch --dependency=afterok:$jid6 13_extractRNAgenes-barrnap-metaxa.sb | cut -d" " -f 4`
echo "$jid14: Extract rRNA marker genes using barrnap and metaxa."

echo -e "\n========== Gene annotation ==========\n" 
# Gene predicions, completeness, and orthologs searches
jid15=`sbatch --dependency=afterok:$jid6 14_geneprediction-busco.sb | cut -d" " -f 4`
echo "$jid15: Gene prediciton and completeness with BUSCO single-copy orthologs."

# depends on gtdbtk classification
jid16=`sbatch --dependency=afterok:$jid12 15_geneannotation-prokka.sb | cut -d" " -f 4`
echo "$jid16: Gene functional annotation with Prokka."

jid17=`sbatch --dependency=afterok:$jid12:$jid16 16_proteinAnnotation_eggnog.sb | cut -d" " -f 4`
echo "$jid17: Additional annootation using the bakta pipeline."

jid18=`sbatch --dependency=afterok:$jid6 17_ARgenes-abricate.sb | cut -d" " -f 4`
echo "$jid18: Identifying Antimicrobial resistence genes with abricate."

echo -e "\n========== Exporting and zipping reports and results ==========\n" 
jid19=`sbatch --dependency=afterok:$jid2:$jid3:$jid7:$jid8:$jid13:$jid15:$jid16 18_combinereports-multiqc.sb | cut -d" " -f 4`
echo "$jid19: Generating multi-report with multiQC."

jid20=`sbatch --dependency=afterok:$jid4:$jid6:$jid16 19_assemblygraph-bandage.sb | cut -d" " -f 4`
echo "$jid20: plotting genome network - differnet versions."

# Optional annotation with Bakta https://github.com/oschwengers/bakta
jid21=`sbatch --dependency=afterok:$jid12 15.2_optAnnotation-bakta.sb | cut -d" " -f 4`
echo "$jid21: Additional annootation using the bakta pipeline."

if [[ "$BAKTA" == "yes" ]]; then
	jid22=`sbatch --dependency=afterok:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid12:$jid13:$jid14:$jid15:$jid16:$jid17:$jid18:$jid19:$jid20:$jid21 20_exportReports-bash.sb | cut -d" " -f 4`
	echo "$jid22: Copy and zip all reports for further use."
else 
	jid22=`sbatch --dependency=afterok:$jid1:$jid2:$jid3:$jid4:$jid5:$jid6:$jid7:$jid8:$jid9:$jid10:$jid12:$jid13:$jid14:$jid15:$jid16:$jid17:$jid18:$jid19:$jid20 20_exportReports-bash.sb | cut -d" " -f 4`
	echo "$jid22: Copy and zip all reports for further use."
fi

echo -e "\n========== Listing submitted jobs ==========\n" 
echo -e "\n `sq` \n"

echo -e "\n========== 'This is the end, my friend'. You should be all done! ==========\n" 
