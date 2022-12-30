champ.import.epi <- function(directory = getwd(),
                         offset = 100,
                         arraytype="450K")
{
  message("[===========================]")
  message("[<<<< ChAMP.IMPORT START >>>>>]")
  message("-----------------------------")
  
  message("\n[ Section 1: Read PD Files Start ]")
  
  # csv_gfile <- drive_get( paste0(directory, '/sample_sheet.csv')  )
  # csv_file <- tempfile()
  # csv_gfile <- drive_download(csv_gfile, path = csv_file)
  files <- drive_ls(directory)
  fnames <- as.list(files[1])[[1]]
  fids  <- as.list(files[2])[[1]]
  
  for( i in seq(1, length(fnames))){
    f = fnames[i]
    if(f == 'sample_sheet.csv'){
      csv_gfile <- drive_get( fids[i]  )
      csv_file <- tempfile()
      csv_gfile <- drive_download(csv_gfile, path = csv_file, verbose = TRUE)
    }
  }
  
  csvfile <- csv_gfile$local_path #list.files(directory,recursive=TRUE,pattern="csv$",full.names=TRUE)

  message("  CSV Directory: ",csvfile)
  message("  Find CSV Success")
  
  message("  Reading CSV File")
  
  skipline <- 0#which(substr(readLines(csvfile),1,6) == "[Data]")
  if(length(skipline)==0)
    suppressWarnings(pd <- read.csv(csvfile,stringsAsFactor=FALSE,header=TRUE))
  else
    suppressWarnings(pd <- read.csv(csvfile,skip=skipline,stringsAsFactor=FALSE,header=TRUE))
  
  if("Sentrix_Position" %in% colnames(pd))
  {
    colnames(pd)[which(colnames(pd)=="Sentrix_Position")] <- "Array"
    message("  Replace Sentrix_Position into Array")
  } else 
  {
    message("  Your pd file contains NO Array(Sentrix_Position) information.")
  }
  
  if("Sentrix_ID" %in% colnames(pd))
  {
    colnames(pd)[which(colnames(pd)=="Sentrix_ID")] <- "Slide"
    message("  Replace Sentrix_ID into Slide")
  } else 
  {
    message("  Your pd file contains NO Slide(Sentrix_ID) information.")
  }
  
  sapply(c("Pool_ID", "Sample_Plate", "Sample_Well"),function(x) if(x %in% colnames(pd)) pd[,x] <- as.character(pd[,x]) else message("  There is NO ",x, " in your pd file."))
  
  # GrnPath <- unlist(sapply(paste(pd$Slide,pd$Array,"Grn.idat",sep="_"), function(x) grep(x,list.files(directory,recursive=T,full.names=TRUE), value = TRUE)))
  # RedPath <- unlist(sapply(paste(pd$Slide,pd$Array,"Red.idat",sep="_"), function(x) grep(x,list.files(directory,recursive=T,full.names=TRUE), value = TRUE)))
  # 
  # if(!identical(names(GrnPath),paste(pd$Slide,pd$Array,"Grn.idat",sep="_")))
  #   stop("  Error Match between pd file and Green Channel IDAT file.")
  # if(!identical(names(RedPath),paste(pd$Slide,pd$Array,"Red.idat",sep="_")))
  #   stop("  Error Match between pd file and Red Channel IDAT file.")
  allFiles = NULL
  
  files <-  drive_ls( directory )
  fnames <- unlist(as.list(files$name))
  fids <- unlist(as.list(files$id))
  
  for( i in seq(1, length(fnames))){
    if(fnames[i] != 'sample_sheet.csv'){
      channelFiles <- drive_ls(paste0('https://drive.google.com/drive/folders/', fids[i]))
      cnames <- unlist(as.list(channelFiles$name))
      cids <- unlist(as.list(channelFiles$id))
      
      for( j in seq(1, length(cnames))){
        if(is.null(allFiles)){
          allFiles <- tibble( "name"=cnames[j], "id"=cids[j] )
        }else{
          tmp <- tibble( "name"=cnames[j], "id"=cids[j] )
          allFiles <- rbind(allFiles, tmp  )
          
        }
      }
    }
  }
  
  greenFiles <- allFiles %>%
    filter(grepl("_Grn.idat", name))
  redFiles <- allFiles %>%
    filter(grepl("_Red.idat", name))
  
  # greenFiles <- drive_find( "Grn.idat" )
  # redFiles <- drive_find( "Red.idat" )
  # baseGrn <- paste(pd$Slide,pd$Array,"Grn.idat",sep="_")
  # inc <- unlist(lapply(greenFiles$name, function(x){
  #   x %in% baseGrn
  # }  ))
  # 
  # baseRed <- paste(pd$Slide,pd$Array,"Red.idat",sep="_")
  # inc <- unlist(lapply(greenFiles$name, function(x){
  #   x %in% baseGrn
  # }  ))
  # 
  # greenFiles <- greenFiles %>% filter( inc )
  # redFiles <- redFiles %>% filter( inc )
  # 
  # 
  
  message("[ Section 1: Read PD file Done ]")
  
  message("\n\n[ Section 2: Read IDAT files Start ]")
  
  count <- 1
  idat_tmp <- tempfile()
  G.idats <- lapply(greenFiles$id, function(x){ 
    message("  Loading:",x,"")
    xd <- drive_download(paste0('https://drive.google.com/drive/folders/', x), path = idat_tmp, overwrite = TRUE)
    readIDAT_epi(xd$local_path)
  })
  # G.idats <- lapply(GrnPath, function(x){ message("  Loading:",x," ---- (",which(GrnPath == x),"/",length(GrnPath),")");readIDAT(x)})
  count <- 1
  # R.idats <- lapply(RedPath, function(x){ message("  Loading:",x," ---- (",which(RedPath == x),"/",length(RedPath),")");readIDAT(x)})
  R.idats <- lapply(redFiles$id, function(x){ 
    message("  Loading:",x,"")
    xd <- drive_download(paste0('https://drive.google.com/drive/folders/', x), path = idat_tmp, overwrite = TRUE)
    readIDAT_epi(xd$local_path)
  })
  
  names(G.idats) <- pd$Sample_Name
  names(R.idats) <- pd$Sample_Name
  
  checkunique <- unique(c(sapply(G.idats, function(x) nrow(x$Quants)),sapply(R.idats, function(x) nrow(x$Quants))))
  
  if(length(checkunique) > 1) 
  {
    message("\n  !!! Important !!! ")
    message("  Seems your IDAT files not from one Array, because they have different numbers of probe.")
    message("  ChAMP wil continue analysis with only COMMON CpGs exist across all your IDAt files. However we still suggest you to check your source of data.\n")
  }
  
  CombineIDAT <- append(G.idats, R.idats)
  commonAddresses <- as.character(Reduce("intersect", lapply(CombineIDAT, function(x) rownames(x$Quants))))
  
  message("\n  Extract Mean value for Green and Red Channel Success")
  GreenMean <- do.call(cbind, lapply(G.idats, function(xx) xx$Quants[commonAddresses, "Mean"]))
  RedMean <- do.call(cbind, lapply(R.idats, function(xx) xx$Quants[commonAddresses, "Mean"]))
  message("    Your Red Green Channel contains ",nrow(GreenMean)," probes.")
  
  G.Load <- do.call(cbind,lapply(G.idats,function(x) x$Quants[commonAddresses,"Mean"]))
  R.Load <- do.call(cbind,lapply(R.idats,function(x) x$Quants[commonAddresses,"Mean"]))
  
  message("[ Section 2: Read IDAT Files Done ]")
  
  message("\n\n[ Section 3: Use Annotation Start ]")
  
  message("\n  Reading ", arraytype, " Annotation >>")
  # if(arraytype == "EPIC") data(AnnoEPIC) else data(Anno450K)
  # annoGFile <- drive_get('Epigenica/Dados/AnnoEPIC.Rda')
  # anno_tmp <- tempfile()
  # dfile <- drive_download(annoGFile$id, path=anno_tmp)
  # load(dfile$local_path)
  # unlink(anno_tmp)
  
  load("AnnoEPIC.Rda")
  
  
  message("\n  Fetching NEGATIVE ControlProbe.")
  control_probe <- rownames(Anno$ControlProbe)[which(Anno$ControlProbe[,1]=="NEGATIVE")]
  message("    Totally, there are ",length(control_probe)," control probes in Annotation.")
  control_probe <- control_probe[control_probe %in% rownames(R.Load)]
  message("    Your data set contains ",length(control_probe)," control probes.")
  rMu <- matrixStats::colMedians(R.Load[control_probe,])
  rSd <- matrixStats::colMads(R.Load[control_probe,])
  gMu <- matrixStats::colMedians(G.Load[control_probe,])
  gSd <- matrixStats::colMads(G.Load[control_probe,])
  
  rownames(G.Load) <- paste("G",rownames(G.Load),sep="-")
  rownames(R.Load) <- paste("R",rownames(R.Load),sep="-")
  
  IDAT <- rbind(G.Load,R.Load)
  
  message("\n  Generating Meth and UnMeth Matrix")
  
  message("    Extracting Meth Matrix...")
  M.check <- Anno$Annotation[,"M.index"] %in% rownames(IDAT)
  message("      Totally there are ",nrow(Anno$Annotation)," Meth probes in ",arraytype," Annotation.")
  message("      Your data set contains ",length(M.check), " Meth probes.")
  M <- IDAT[Anno$Annotation[,"M.index"][M.check],]
  
  message("    Extracting UnMeth Matrix...")
  U.check <- Anno$Annotation[,"U.index"] %in% rownames(IDAT)
  message("      Totally there are ",nrow(Anno$Annotation)," UnMeth probes in ",arraytype," Annotation.")
  message("      Your data set contains ",length(U.check), " UnMeth probes.")
  U <- IDAT[Anno$Annotation[,"U.index"][U.check],]
  
  if(!identical(M.check,U.check))
  {
    stop("  Meth Matrix and UnMeth Matrix seems not paried correctly.")
  } else {
    CpG.index <- Anno$Annotation[,"CpG"][M.check]
  }
  
  rownames(M) <- CpG.index
  rownames(U) <- CpG.index
  
  
  message("\n  Generating beta Matrix")
  BetaValue <- M / (M + U + offset)
  message("  Generating M Matrix")
  MValue <- log2(M/U)
  message("  Generating intensity Matrix")
  intensity <-  M + U
  
  message("  Calculating Detect P value")
  detP <- matrix(NA,nrow=nrow(intensity),ncol=ncol(intensity))
  rownames(detP) <- rownames(intensity)
  colnames(detP) <- colnames(intensity)
  
  type_II <- rownames(Anno$Annotation)[Anno$Annotation[,"Channel"] == "g+r"]
  type_II <- type_II[type_II %in% rownames(detP)]
  type_I.red <- rownames(Anno$Annotation)[Anno$Annotation[,"Channel"] == "r"]
  type_I.red <- type_I.red[type_I.red %in% rownames(detP)]
  type_I.grn <- rownames(Anno$Annotation)[Anno$Annotation[,"Channel"] == "g"]
  type_I.grn <- type_I.grn[type_I.grn %in% rownames(detP)]
  for(i in 1:ncol(detP))
  {
    detP[type_II,i] <- 1 - pnorm(intensity[type_II,i], mean=rMu[i]+gMu[i], sd=rSd[i]+gSd[i])
    detP[type_I.red,i] <- 1 - pnorm(intensity[type_I.red,i], mean=rMu[i]*2, sd=rSd[i]*2)
    detP[type_I.grn,i] <- 1 - pnorm(intensity[type_I.grn,i], mean=gMu[i]*2, sd=gSd[i]*2)
  }
  if(sum(is.na(detP))) message("    !!! There are NA values in your detP matrix.\n")
  
  
  message("  Counting Beads")
  NBeads <- do.call(cbind, lapply(R.idats, function(x) x$Quants[commonAddresses, "NBeads"]))
  Mbead <- NBeads[substr(Anno$Annotation$M.index[M.check],3,100),]
  Ubead <- NBeads[substr(Anno$Annotation$U.index[U.check],3,100),]
  Ubead[Ubead < 3 | Mbead < 3] <- NA
  rownames(Ubead) <- rownames(intensity)
  
  message("[ Section 3: Use Annotation Done ]")
  message("\n[<<<<< ChAMP.IMPORT END >>>>>>]")
  message("[===========================]")
  message("[You may want to process champ.filter() next.]\n")
  return(list("beta"=BetaValue,"M"=MValue,"pd"=pd,"intensity"=intensity,"detP"=detP,"beadcount"=Ubead,"Meth"=M,"UnMeth"=U))
}