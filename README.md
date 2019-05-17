# WXS_SNV
Snakemake pipeline to call SNV in hybridization capture data adapted for multiple samples of a same tumor.
(+WIP on CNV calling)

Made following 
https://gatkforums.broadinstitute.org/gatk/discussion/11136/how-to-call-somatic-mutations-using-gatk4-mutect2
and 
https://software.broadinstitute.org/gatk/best-practices/workflow?id=11146

# Conda envs for non singularity rules
Two conda envs: "root", for bwa and samtools, etc and "plot" for R rules. List of packages found in local

**TODO** add use-conda in Snakefiles, right now `source activate plot` is needed only before calling the coverage_plot
rule in align_recalibrate and root is ok for everything else (note that it has more packages than those needed for this project, **TODO** list).

# Singularity from GATK docker

To produce the GATK singularity image the recipe is in local/src, then
`singularity build gatk.img gatk.recipe` if you have root access.

Otherwise:
`singularity pull --name gatk.img docker://broadinstitute/gatk:4.1.0.0`
Right now Snakefiles load the image from `ROOT+"/gatk/gatk.img"`.

# Singularity for CNVkit

`singularity pull --name gatk.img docker://etal/cnvkit`
Right now Snakefiles load the image from `ROOT+"/cnvkit/cnvkit.img"`.
