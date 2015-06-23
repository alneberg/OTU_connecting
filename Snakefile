__author__ = "Inodb, Alneberg"
__license__ = "MIT"


configfile: "config.json"

import os
import glob


# Add all reads to the bowtie2_rules
config["bowtie2_rules"]["samples"] = {os.path.basename(p).replace("_R1.cut.sync.fasta", ""): [os.path.basename(p).replace("_R1.cut.sync.fasta", "")] for p in glob.glob("{0}/*_R1.cut.sync.fasta".format( config["reads_dir"]))}
config["bowtie2_rules"]["units"] = {os.path.basename(p).replace("_R1.cut.sync.fasta", ""): [p, p.replace("R1", "R2")] for p in glob.glob("{0}/*_R1.cut.sync.fasta".format( config["reads_dir"] )) }

# Add the assembly to bowtie2_rules
config["bowtie2_rules"]["references"] = config["OTU_connecting_rules"]["otus"]

# add newbler merged assemblies to concoct assemblies
config["OTU_connecting_rules"]["otus"] = {k:v for k,v in config["bowtie2_rules"]["references"].items()}

#SM_WORKFLOW_LOC="https://raw.githubusercontent.com/alneberg/snakemake-workflows/a2a6cab285adad51f1997a03638cdf53b07b529b/"
SM_WORKFLOW_LOC="/proj/b2014214/repos/snakemake-workflows/"
#SM_WORKFLOW_LOC="https://raw.githubusercontent.com/inodb/snakemake-workflows/fe913ac3a40387dbe26558ac35c8a807236e466a/"
#SM_WORKFLOW_LOC = "/glob/inod/github/snakemake-workflows/"
include: SM_WORKFLOW_LOC + "bio/ngs/rules/OTU_connecting/OTU_connecting.rules"

localrules: track_changes

# Reads are fasta
ruleorder: bam_sort > OTU_filtering_threshold
ruleorder: remove_mark_duplicates > OTU_filtering_threshold 

# Filter first to reduce file size

rule all:
    input: 
        expand("OTU_connecting/{otus}/filtered_nm{threshold}/otu_mapping.tsv",
            otus=config["OTU_connecting_rules"]["otus"],    
            threshold=config["OTU_connecting_rules"]["threshold"])
