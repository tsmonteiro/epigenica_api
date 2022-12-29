# BiocManager::install(c("minfi","ChAMPdata","Illumina450ProbeVariants.db","sva","IlluminaHumanMethylation450kmanifest","limma","RPMM","DNAcopy","preprocessCore","impute","marray","wateRmelon","goseq","plyr","GenomicRanges","RefFreeEWAS","qvalue","isva","doParallel","bumphunter","quadprog","shiny","shinythemes","plotly","RColorBrewer","DMRcate","dendextend","IlluminaHumanMethylationEPICmanifest","FEM","matrixStats","missMethyl","combinat"))
# install.packages("googledrive")
# NOTES
# Sample sheet must be named sample_sheet.csv
# Headers in the sample_sheet are not supported
library('googledrive')
library(dplyr)
source('./funcs/champ_import_epi.R')
source('./funcs/champ_filter_epi.R')
source('./funcs/readIDAT_epi.R')
source('./funcs/impute_epi.R')

# library('ChAMP')
 #Rscript ChAMP_Process_GDrive.R 'Epigenica/Dados/Test'
# /home/thiago/Epigenica/Dados/Samples/Test
args = commandArgs(trailingOnly=TRUE)

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

# csv_gfile <- drive_get( 'Epigenica/Dados/Test/sample_sheet.csv'  )
# 
# csv_file <- tempfile()
# csv_dfile <- drive_download(csv_gfile, path = csv_file)
# csv <- read.csv(file=csv_dfile$local_path)
# 
# greenFiles <- drive_find( "Grn.idat" )
# redFiles <- drive_find( "Grn.idat" )
# baseGrn <- paste(pd$Slide,pd$Array,"Grn.idat",sep="_")
# inc <- unlist(lapply(greenFiles$name, function(x){
#   x %in% baseGrn
# }  ))
# 
# baseRed <- paste(pd$Slide,pd$Array,"Grn.idat",sep="_")
# inc <- unlist(lapply(greenFiles$name, function(x){
#   x %in% baseGrn
# }  ))
# 
# greenFiles <- greenFiles %>% filter( inc )
# redFiles <- greenFiles %>% filter( inc )
# # GrnPath <- unlist(sapply(paste(pd$Slide,pd$Array,"Grn.idat",sep="_"), function(x) grep(x,list.files(directory,recursive=T,full.names=TRUE), value = TRUE)))
# 
# idat_tmp <- tempfile()
# 
# data(AnnoEPIC)
# 
# save(Anno, file='/home/thiago/Epigenica/workspace/projects/epigenica_clock/AnnoEPIC.Rda')
# 
# G.idats <- lapply(greenFiles$id, function(x){ 
#   message("  Loading:",x,"")
#   xd <- drive_download(x, path = idat_tmp, overwrite = TRUE)
#   readIDAT_epi(xd$local_path)
# })
# 
# data(AnnoEPIC)
# for( i in range(1, length(pd$Slide))){
#   if( i == 1 ) {
#     GrnGPath <- drive_find(paste(pd$Slide[i],pd$Array[i],"Grn.idat",sep="_"))    
#   }else{
#     GrnGPath <- rbind(GrnGPath, drive_find(paste(pd$Slide[i],pd$Array[i],"Grn.idat",sep="_")) )
#   }
# }
# 
#  


# # save(myImport, file=paste0(testDir, '/proc_files/myImport.Rda'))
# 
# myImport <- champ.import(directory,arraytype=arraytype)
# 
# myLoad <- champ.filter(beta=myImport$beta,
#                        M=NULL,
#                        pd=myImport$pd,
#                        intensity=myImport$intensity,
#                        Meth=NULL,
#                        UnMeth=NULL,
#                        detP=myImport$detP,
#                        beadcount=myImport$beadcount,
#                        autoimpute=TRUE,
#                        filterDetP=TRUE,
#                        ProbeCutoff=0,
#                        SampleCutoff=0.1,
#                        detPcut=0.01,
#                        filterBeads=TRUE,
#                        beadCutoff=0.05,
#                        filterNoCG=TRUE,
#                        filterSNPs=TRUE,
#                        population=NULL,
#                        filterMultiHit=TRUE,
#                        filterXY=TRUE,
#                        arraytype="EPIC")
# 
# 
# # myLoad <- champ.load(testDir, autoimpute=TRUE,
# # arraytype="EPIC")
# 
# champ.QC( beta =  myLoad$beta, pheno = myLoad$pd$COVID,
#           resultsDir = '/home/thiago/Epigenica/Dados/Samples/COVID/CHAMP_QC', dendrogram = T)
# 
# 
# myNorm <- champ.norm(arraytype = "EPIC", 
#                      resultsDir = '/home/thiago/Epigenica/Dados/Samples/COVID/CHAMP_Normalization')
# champ.SVD(beta=data.frame(myNorm), pd=myLoad$pd,
#           resultsDir = '/home/thiago/Epigenica/Dados/Samples/COVID/CHAMP_SVD/')
# 
# 
# myRefbase <- champ.refbase(arraytype = "EPIC")
