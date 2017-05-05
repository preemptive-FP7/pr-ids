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
# data2preprocess <- "file_path_to/DATA_load_data2preprocess.R"
data2preprocess <- "scripts/Preprocessing_NormPcaSoftmax.R"

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

# Approach A
# normalize.fun <- function(x) {
#   (x - roll_meanr(x, n = normalize.n, fill = T))/roll_sdr(x, n = normalize.n, fill = T)
# }

# Approach B
normalize.getQuantile <- function(x) {
  quantiles <- quantile(x, c(0.05, 0.95))
  return(quantiles)
}

normalize.fun <- function(x, quantiles){
  resc <- as.numeric((quantiles[2] - quantiles[1])/2)
  xx <- (x - as.numeric(resc + quantiles[1]))/resc
  return(xx)
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

# Approach A --
# subs <- subs[ , lapply(.SD, normalize.fun)]
# if (test.) {
#   subs.test <- subs.test[ , lapply(.SD, normalize.fun)]
# }

# Approach B --
# Quantiles obtained from training only 
# TODO: they have to be stored for using them on STORM
quantiles <- subs[ , lapply(.SD, normalize.getQuantile)]

subs.n <- copy(subs)
cols <- names(subs.n)
for (j in cols) set(subs.n, 
                    j = j,
                    value = normalize.fun(subs.n[[j]], quantiles[, .SD, .SDcols = j]))

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
  save(data.train.results, data.train.datetime, data.train.pca, file = filename.save)
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
    save(data.test.results, data.test.datetime, file = filename.test.save)
  }
}



# Export PCA data to sVdetector -------------------------------------------

pca.dimension.calc <- length(grep("PC", names(data.train.results)))
pca.dimension <- ifelse(pca.dimension.max >= pca.dimension.calc, 
                        pca.dimension.calc,  pca.dimension.max)

# If export normal results as test
test.normal. <- T


# 
# Train 
# 
if (!test.normal.) {
  data.export <- copy(data.train.results)
  data.train.datetime.export <- data.train.datetime
} else {
  train.num <- dim(data.train.results)[1]
  idx.train <- sample(1:train.num, round(train.num*0.75))
  data.export <- data.train.results[idx.train]
  data.train.datetime.export <- data.train.datetime[idx.train]
}
# data.export <- data.export[day != 11,]
# data.train.datetime.export <- data.train.datetime[data.train.datetime < ymd("2015/07/11") | 
# data.train.datetime > ymd("2015/07/12")]
export2svdet(data.export, dimension = pca.dimension, id. = T, test.data. = F, 
             filename = export.filename, id.name = "date")                                                   
saveRDS(data.train.datetime.export, 
        file = paste0(export.filename, "_train_datetime.rds"))
# 
# Test 
# 
if (test.) {
  data.test.export <- copy(data.table(data.test.results))
  # data.export <- data.export[day == 11,]
  data.train.datetime.export <- data.train.datetime
  # data.test.export <- data.test.datetime[data.test.datetime > ymd("2015/07/11") & 
  #                                          data.test.datetime < ymd("2015/07/12")]
  export2svdet(data.test.export, dimension = pca.dimension, id. = T, test.data. = T,
               filename = export.filename, id.name = "date")
  saveRDS(data.test.export, 
          file = paste0(export.filename, "_test_datetime.rds"))
  # 
  # Check
  # 
  data.testcheck.export <- copy(data.table(data.test.results))
  # data.export <- data.export[day == 11,]
  data.train.datetime.export <- data.train.datetime
  # data.test.export <- data.test.datetime[data.test.datetime > ymd("2015/07/11") & 
  #                                          data.test.datetime < ymd("2015/07/12")]
  # labels.  <-  rep("ABNORMAL", dim(data.export)[1])
  labels.  <-  ifelse(testcheck.labels == "Normal", "NORMAL", "ABNORMAL")
  # labels.[data.test.export > ymd_hms("2015-07-11 06:01:55") &
  #           data.test.export < ymd_hms("2015-07-11 10:02:00") ] <- rep("ABNORMAL")
  #           
  # TEST function:
  export2svdet(data.testcheck.export, dimension = pca.dimension, id. = T, test.data. = T,
               filename = export.filename, id.name = "date",
               test.labelled. = T, test.labels = labels.)
  saveRDS(data.test.export, 
          file = paste0(export.filename, "_testcheck_datetime.rds"))
}
if (test.normal.) {
  data.testcheck.export <- data.train.results[-idx.train]
  data.train.datetime.export <- data.train.datetime[-idx.train]
  labels. <- rep("NORMAL", dim(data.export)[1])
  export2svdet(data.testcheck.export, dimension = pca.dimension, id. = T, test.data. = T,
               filename = export.filename, id.name = "date")
  export2svdet(data.testcheck.export, dimension = pca.dimension, id. = T, test.data. = T,
               filename = export.filename, id.name = "date",
               test.labelled. = T, test.labels = labels.)
  saveRDS(data.testcheck.export, 
          file = paste0(export.filename, "_testcheck_datetime.rds"))
}



# <<<<< Export config 2 STORM ---------------------------------------------


export.config.path <- file.path(export.path, paste0("config_", export.filename1))
if (!dir.exists(export.config.path)) {
  dir.create(export.config.path)
}

filename.STORM <- file.path(export.config.path, export.filename1)
data.export.dimRed <- data.train.pca$rotation
filename.SMprops <- paste0(export.filename, "_SM.props.rds")  
data.export.SMprops <- readRDS(file = filename.SMprops)
data.export.SMprops[, name := NULL]
export2STORM.allConfig(filename = filename.STORM,
                       idx = subs.idx,
                       quantiles = quantiles,
                       softmax = data.export.SMprops, 
                       dimred = data.export.dimRed)
export.rawdata(filename.STORM, data2export = "test")
