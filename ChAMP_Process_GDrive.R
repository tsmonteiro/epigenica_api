# BiocManager::install(c("minfi","ChAMPdata","Illumina450ProbeVariants.db","sva","IlluminaHumanMethylation450kmanifest","limma","RPMM","DNAcopy","preprocessCore","impute","marray","wateRmelon","goseq","plyr","GenomicRanges","RefFreeEWAS","qvalue","isva","doParallel","bumphunter","quadprog","shiny","shinythemes","plotly","RColorBrewer","DMRcate","dendextend","IlluminaHumanMethylationEPICmanifest","FEM","matrixStats","missMethyl","combinat"))
# install.packages("googledrive")
# NOTES
# Sample sheet must be named sample_sheet.csv
# Headers in the sample_sheet are not supported
library('googledrive')
library('gargle')
library(dplyr)
source('./funcs/champ_import_epi.R')
source('./funcs/champ_filter_epi.R')
source('./funcs/readIDAT_epi.R')
source('./funcs/impute_epi.R')

# library('ChAMP')
 #Rscript ChAMP_Process_GDrive.R 'Epigenica/Dados/Test'
# /home/thiago/Epigenica/Dados/Samples/Test
args = commandArgs(trailingOnly=TRUE)
email = args[2]
tok = args[3]

#drive_auth(email=email, token=tok, cache=FALSE)
drive_deauth()

test_dir <- args[1]
myImport <- champ.import.epi(test_dir, arraytype="EPIC")

myLoad <- champ.filter.epi(beta=myImport$beta,
                       M=NULL,
                       pd=myImport$pd,
                       intensity=myImport$intensity,
                       Meth=NULL,
                       UnMeth=NULL,
                       detP=myImport$detP,
                       beadcount=myImport$beadcount,
                       autoimpute=TRUE,
                       filterDetP=TRUE,
                       ProbeCutoff=0,
                       SampleCutoff=0.1,
                       detPcut=0.01,
                       filterBeads=TRUE,
                       beadCutoff=0.05,
                       filterNoCG=TRUE,
                       filterSNPs=TRUE,
                       population=NULL,
                       filterMultiHit=TRUE,
                       filterXY=TRUE,
                       arraytype="EPIC")

local_file <- '/tmp/01_load_filtered.Rda'
save(myLoad, file = local_file)