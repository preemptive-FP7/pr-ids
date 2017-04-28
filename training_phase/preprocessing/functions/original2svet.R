# --------------------------------------------
# original2svet.R
# 
# Functions to export data from R analysis scripts 
# to sVdetector input.
# Used in 
# 
# - Softmax & related functions:
#   Functions to rescale data between 0 and 1.
# 
# - export2svdet
#   Creates the filename with the data to be used by sVdetector.java
#   inputs:
#     data.export: data to be exported
#     dimension = 2 : dimension of the output vector
#     id. = T : do data have id?
#     filename = "or2sved" : filename to be saved to 
#     id.name = "date" : name of the column of id
#     test.data. = F : is it test or train data? (to add a suffix to filename)
# 
# 
# Authors:
# -- xclotet (clotetx@aia.es)
# --------------------------------------------
require(data.table)

# Functions for data normalization ---------------------------------------
# Abslog function 
# (x may be multiplied by a factor before entered in splog to spread values close to 0)
Splog <- function(x) { ifelse(x > 1, log(x), ifelse(x < -1, -log(-x), 0)) }

# From Markus Koskela book 'Data Preparation for Data Mining', Chapter 7 'Normalizing and Redistributing Variables'
SoftmaxTransform <- function(x, mean., sd., lambda) { (x - mean.)/(lambda * (sd. / (2 * pi))) }
Softmax <- function(x, mean. = mean(x), sd. = sd(x), lambda = 1 + (max(x) - min(x))/sd(x)) { 
  x1 <- SoftmaxTransform(x, mean., sd., lambda)
  cat("Softmax: mean = ", mean., ", sd = ", sd., "\n")
  1 / (1 + exp( -x1)) 
}

export2svdet <- function(data.export, dimension = 2, id. = T, 
                         filename = "or2sved", id.name = "date",
                         test.data. = F, test.labelled. = F, test.labels = NULL) {
  data.export <- data.export[complete.cases(data.export)]
  filename.SMprops <- paste0(filename, "_SM.props.rds")
  if (!test.data.) {
    filename.vd <- paste0(filename, "_train.vd")
  } else {
    if (!test.labelled.) {
      filename.vd <- paste0(filename, "_test.vd")
    } else {
      test.data <- T
      filename.vd <- paste0(filename, "_testcheck.vd")
    }
  }
  lambda. <- NULL # 2
  # prepare data
  if (!data.table::is.data.table(data.export)) {
    data.export <- data.table(data.export)
  }
  data.export.names <- names(data.export)
  names.PC <- length(grep("PC", data.export.names))
  if (names.PC != 0) {
    names.X <- paste0("X",seq(1,names.PC))
    setnames(data.export, data.export.names[grep("PC", data.export.names)],
             names.X)
  } else{
    names.X <- grep("X", data.export.names,value = TRUE)
    if (length(names.X) == 0) {
      names.X <- paste0("X",seq(1,length(data.export.names) - 1))
      setnames(data.export, data.export.names[!(data.export.names %in% id.name)],
               names.X)
    }
  }
  # check id
  if (id.) {
    if (id.name %in% data.export.names) {
      id <- data.export[, as.numeric(date)]
    } else{
      stop("No valid id.name provided.")
    }
    id.flag <- "hasId"
  } else {
    id.flag <- "noId"
  }
  # calculate Softmax normalization
  data.export.SMprops <- data.table("name" = c("mean", "sd", "lambda"))
  if (!test.data.) {
    for (n.X in names.X) {
      aux <- data.export[[n.X]]
      if (is.null(lambda.)) {
        lambda. <- 1 + (max(aux) - min(aux))/sd(aux)
        mean. <- mean(aux)
        sd. <- sd(aux)
        aux <- Softmax(aux)
      } else {
        mean. <- mean(aux)
        sd. <- sd(aux)
        aux <- Softmax(aux, lambda = lambda.)
      }
      data.export[, (n.X) := aux]
      data.export.SMprops[, (n.X) := c(mean., sd., lambda.)]
    }
    saveRDS(data.export.SMprops, file = filename.SMprops)
  } else {
    data.export.SMprops <- readRDS(file = filename.SMprops)
    for (n.X in names.X) {
      aux <- as.matrix(data.export[, n.X, with = F])
      mean. <- as.numeric(data.export.SMprops[name == "mean", n.X, with = F])
      sd. <- as.numeric(data.export.SMprops[name == "sd", n.X, with = F])
      lambda. <- as.numeric(data.export.SMprops[name == "lambda", n.X, with = F])
      aux <- Softmax(aux, mean. = mean. , sd. = sd., lambda = lambda.)
      data.export[, (n.X) := aux]
    }
  }
  
  # write header
  write(paste(as.character(dimension), "-1", id.flag, sep = " "), file = filename.vd)
  
  # write points
  if (id.) {
    data.export[, (id.name) := NULL]
    x <- cbind(id, data.export[, 1:dimension, with = F])
  } else {
    x <- data.export[, 1:dimension, with = F]
  }
  if (test.labelled.) {
    if (length(test.labels) == 1) {
      test.labels <- rep(test.labels, dim(x)[1])
    } else {
      if (is.null(test.labels)) {
        stop("test.labels is empty ------------")
      }
    }
    x <- cbind(x,test.labels)
  }
  write.table(x, file = filename.vd,
              append = TRUE, col.names = FALSE, row.names = FALSE, quote = FALSE)
  return(paste0("--- data saved in ", filename.vd, " ---"))
}
