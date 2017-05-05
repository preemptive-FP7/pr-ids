require(data.table)

load.data <- function() {
  # =====================================================
  # LOAD and PREPARE data for plot and PCA analysis
  # =====================================================
  
  source("functions/date_time_func.R")
  source("functions/PCA_func.R")
  
  path.data <- "data"
  file.use <- file.path(path.data, "CIGRE_MV_noDG_Julio.rds")
  file.use.test <- file.path(path.data, "CIGRE_MV_noDG_Julio_OLTCAttack.rds")
  all. <- F
  
  list.data <- readRDS(file.use)
  list.data.test <- readRDS(file.use.test)
  
  # --- Prepare loaded data for use: 
  data.train <- list.data[[1]]
  data.train.temporal <- list.data[[2]]
  rm(list.data)
  data.test <- list.data.test[[1]]
  data.test.temporal <- list.data.test[[2]]
  rm(list.data.test)
  
  setnames(data.test, 
           "B1 - Positive-Sequence Voltage, Magnitude in p.u.",
           "B1 - Line-Ground Positive-Sequence Voltage, Magnitude in p.u.")
  
  setnames(data.train,
           "B1 - Positive-Sequence Voltage, Magnitude in p.u.",
           "B1 - Line-Ground Positive-Sequence Voltage, Magnitude in p.u.")
  setcolorder(data.test, names(data.train))
  
  
  # Select columns ----------------------------------------------
  
  if (all.) {
    # Only Total Active Power:
    cols = grep("*Total Active Power*", colnames(data.train))
    cols.test = grep("*Total Active Power*", colnames(data.test))
    # Keep only chosen cols
    subs <- data.train[, cols, with = F]
  } else {
    a <- rep(0, 153)
    # Select left branch of the grid
    # patterns <- c("6", "7", "8", "9", "12", "13", "14")
    # Select buses and loads patternNums
    # patternNums <- c("12", "13", "14")
    patternNums <- c("4", "5", "10", "11")
    patterns <- paste0("Lo", patternNums, " ")
    patterns <- c(patterns, paste0("B", patternNums, "_"))
    patterns <- c(patterns, paste0("B", patternNums, " "))
    for (pat in patterns) {
      for (i in seq(1,153)) {
        if (length(grep(names(data.train)[i], pattern = pat))) {
          a[i] <- a[i] + 1
        }
      }
    }
    cols <- names(data.train)[a == 1]
    auxsubs <- data.train[, cols, with = F]
    auxsubs.test <- data.test[, cols, with = F]
    cols = grep("*Total Active Power*", colnames(auxsubs))
    cols.test = grep("*Total Active Power*", colnames(auxsubs.test))
    
    # Keep only chosen cols
    subs <- auxsubs[, cols, with = F]
    subs.test <- auxsubs.test[, cols.test, with = F]
  }
  res <- list()
  res[["subs"]] <- subs
  res[["subs.temporal"]] <- data.train.temporal
  res[["subs.test"]] <- subs.test
  res[["subs.idx"]] <- cols
  res[["subs.test.idx"]] <- cols.test
  return(res)
}