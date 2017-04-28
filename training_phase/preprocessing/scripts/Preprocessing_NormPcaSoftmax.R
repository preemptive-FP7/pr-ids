# =============================================
# Preprocessing_NormPcaSoftmax.R github version
# =============================================
# 
# This script is used for preprocessing the data before introducing them 
# in the V-detector algorithm. 
# 
# The script
# -- normalizes the data with a window of size normalize.n,
# -- reduces the dimension by means of PCA transformation, and 
# -- applies a SoftMax transformation to make values range between 0 and 1
#    (requirement of the V-detector algorithm). 
#    
# Data are saved to be used as training (and test) input for V-detector 
# java program and all information regarding the various transformations 
# are saved in files (*.txt) to be used as input configurations by 
# STORM V-detector. 
# 
# The script is thought to be executed sequentially.
# 
# Parameters are defined after initialization section.
# 
# =============================================
# 
# Script that sources {Data_set_Name}_load_data2preprocess.R and loads data 
# with load.data(). 
# 
# These data are:
# -- normalized within windows of normalize.n size, 
# -- reduced in dimension by means of PCA transformation, keeping up to
#     pca.dimension.max dimensions, and
# -- applied a SoftMax transformation to make values range between 0 and 1.
# 
# Outputs are stored in export.path:
# -- Data. Data are saved to be used as training (and test) input for 
#    V-detector java program.
# ++++ {export.filename}_train.vd
# ++++ {export.filename}_test.vd (optional) 
# -- Configurations. All information regarding the various transformations 
#    are saved to be used as input configurations by STORM V-detector.
# ++++ {export.filename}_idx.txt
# ++++ {export.filename}_dimRed.txt
# ++++ {export.filename}_softmax.txt
# ++++ {export.filename}_normalization.txt
# 
# 
# Authors:
# -- xclotet
# =============================================
 

# Initialization ----------------------------------------------------------

rm(list = ls())
if (dev.cur() != 1) dev.off()
library(data.table)
library(RcppRoll)
library(lubridate)
library(car)
library(corrgram)

source("functions/original2svdet.R")
source("functions/export2STORM.R")

source("functions/date_time_func.R")
source("functions/PCA_func.R")



# Parameters --------------------------------------------------------------

data2load <- c("")
test. <- F
normalize.n <- 20
pca.dimension.max <- 3

# File path to the *_load_data2preprocess.R where * depends on the data used.
data2preprocess <- "file_path_to/DATA_load_data2preprocess.R"

# Export folder path
export.path1 <- "preprocessed"
export.path2 <- "name_of_the_analysis"
export.path <- file.path(export.path1, export.path2)
if (!dir.exists(export.path)) {
  dir.create(export.path)
}

# Export file name
export.filename1 <- "Agent_name"
export.filename <- file.path(export.path, export.filename1)


# Extra functions ---------------------------------------------------------

normalize.fun <- function(x) {
  (x - roll_meanr(x, n = normalize.n, fill = T))/roll_sdr(x, n = normalize.n, fill = T)
}


# Load data ---------------------------------------------------------------

source(data2preprocess)
res <- load.data()
subs <- res[["subs"]]
subs.temporal <- res[["subs.temporal"]]
subs.idx <- res[["subs.idx"]]
if (test.) {
  subs.test <- res[["subs.test"]]
  subs.test.idx <- res[["subs.test.idx"]]
}
rm(res)


# Normalization -----------------------------------------------------------

subs <- subs[ , lapply(.SD, normalize.fun)]
if (test.) {
  subs.test <- subs.test[ , lapply(.SD, normalize.fun)]
}



# PCA ---------------------------------------------------------------------
# 
# PCA train 
# 
initialization <- normalize.n
data.train.2pca <- subs
data.train.2pca <- data.train.2pca[initialization:nrow(data.train.2pca),]
data.train.pca <- PCA.train(data.train.2pca)
summary(data.train.pca)
data.train.datetime <- PCA.datetime(subs.temporal[initialization:nrow(subs.temporal),])
data.train.results <- PCA.train.results(data.train.pca, datetime = data.train.datetime)
# 
# save pca results (optional)
if (F) {
  filename.save <- paste0(export.filename, "_PCA_train_results.RData")
  save(data.train.results, data.train.datetime, data.train.pca, file= filename.save)
}
# 
# PCA test
# 
if (test.) {
  data.test.2pca <- subs.test
  initialization.test <- normalize.n
  data.test.2pca <- data.test.2pca[initialization.test:nrow(data.test.2pca),]
  data.test.datetime <- PCA.datetime(data.test.temporal[initialization.test:nrow(data.test.temporal),])
  data.test.results <- PCA.test(model = data.train.pca[, group:=NULL], 
                                newdata = data.test.2pca,
                                datetime = data.test.datetime)
  # 
  # save pca results (optional)
  # 
  if (F) {
    filename.test.save <- paste0(export.filename, "_PCA_test_results.RData")
    save(data.test.results, data.test.datetime, file= filename.test.save)
  }
}



# Export PCA data to sVdetector -------------------------------------------

pca.dimension.calc <- length(grep("PC", names(data.train.results)))
pca.dimension <- ifelse(pca.dimension.max >= pca.dimension.calc, 
                        pca.dimension.calc,  pca.dimension.max)
# 
# Train 
# 
data.export <- copy(data.train.results)
data.train.datetime.export <- data.train.datetime
export2svdet(data.export, dimension = pca.dimension, id. = T, test.data. = F, 
             filename = export.filename, id.name = "date")                                                   
saveRDS(data.train.datetime.export, 
        file = paste0(export.filename, "_train_datetime.rds"))
# 
# Test 
# 
if (test.) {
  data.export <- copy(data.table(data.test.results))
  data.test.export <- data.test.datetime
  export2svdet(data.export, dimension = pca.dimension, id. = T, test.data. = T,
               filename = export.filename, id.name = "date")
  saveRDS(data.test.export, 
          file = paste0(export.filename, "_test_datetime.rds"))
  # 
  # Check
  # 
  labels.  <-  rep("NORMAL", dim(data.export)[1])
  if (F) {
    # Set datetime range with abnormal beahviour was observed (Optional)
    labels.[data.test.export > ymd_hms("2015-07-11 06:01:55") &
            data.test.export < ymd_hms("2015-07-11 10:02:00") ] <- rep("ABNORMAL")
  }
  
  export2svdet(data.export, dimension = pca.dimension, id. = T, test.data. = T,
               filename = export.filename, id.name = "date",test.labelled. = T, test.labels = labels.)
  saveRDS(data.test.export, 
          file = paste0(export.filename, "_testcheck_datetime.rds"))
}



# Export normalization ----------------------------------------------------

filename.STORM <- paste0(export.filename, "_normalization.txt")
export2STORM.idx(data = normalize.n, filename = filename.STORM)

# Export idx --------------------------------------------------------------

filename.STORM <- paste0(export.filename, "_idx.txt")
export2STORM.idx(data = subs.idx, filename = filename.STORM)

# Export Dimensional Reduction --------------------------------------------

data.export.dimRed <- data.train.pca$rotation
filename.STORM <- paste0(export.filename, "_dimRed.txt")
export2STORM.dimReduction(data = data.export.dimRed, filename = filename.STORM)

# Export softmax ----------------------------------------------------------

filename.SMprops <- paste0(export.filename, "_SM.props.rds")  
data.export.SMprops <- readRDS(file = filename.SMprops)
data.export.SMprops[, name:=NULL]
filename.STORM <- paste0(export.filename, "_softmax.txt")
export2STORM.softmax(data = data.export.SMprops, filename = filename.STORM)
