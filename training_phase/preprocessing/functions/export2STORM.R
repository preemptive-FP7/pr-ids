# --------------------------------------------
# export2STORM.R
# 
# Functions to export data from R analysis scripts 
# to STORM configuration files. 
# 
# Authors:
# -- xclotet (clotetx@aia.es)
# --------------------------------------------

export2STORM.raw <- function(data = x.raw, filename = filename){
  filename.STORM <- paste0(filename, "_raw.csv")
  write.table(data, file = filename.STORM, sep = ",",
              append = FALSE, col.names = FALSE, row.names = FALSE, quote = FALSE)
}

export2STORM.idx <- function(data = x.idx, filename = filename){
  filename.STORM <- paste0(filename, "_idx.txt")
  write.table(t(as.matrix(data)), file = filename.STORM, sep = ",", 
              append = FALSE, col.names = FALSE, row.names = FALSE, quote = FALSE)
}

export2STORM.quantiles <- function(data = quantiles, filename = filename){
  filename.STORM <- paste0(filename, "_quantiles.txt")
  write.table(data, file = filename.STORM, sep = ",", 
              append = FALSE, col.names = FALSE, row.names = FALSE, quote = FALSE)
}

export2STORM.dimReduction <- function(data = x.dimReduction, filename = filename){
  filename.STORM <- paste0(filename, "_dimRed.txt")
  write.table(data, file = filename.STORM, sep = ",", 
              append = FALSE, col.names = FALSE, row.names = FALSE, quote = FALSE)
}

export2STORM.softmax <- function(data = x.softmax, filename = filename){
  filename.STORM <- paste0(filename, "_softMax.txt")
  write.table(data, file = filename.STORM, sep = ",", 
              append = FALSE, col.names = FALSE, row.names = FALSE, quote = FALSE)
}

export2STORM.detectors <- function(results = results, filename.folder = filename.folder,
                                   export.STORM.folder = export.STORM.folder, 
                                   max.false.positive.rate = 0.10, num.detectors.export = 10){
  setorder(results, -true.positive.rate, false.positive.rate)
  aux <- results[false.positive.rate < max.false.positive.rate]
  aux <- aux[1:num.detectors.export]
  flist <- aux[, paste0(filename.complete, "/vdetector_test.txt_", vdet.run, ".vd")]
  flist <- paste0(filename.folder, flist)
  flist.cp <- paste0(export.STORM.folder,"detectors_", seq(1:num.detectors.export - 1), ".cfg")
  aux.cp <- file.copy(flist, flist.cp)
  flist.names <- paste0(export.STORM.folder, "config_detectors.txt")
  stopifnot(sum(aux.cp) == num.detectors.export)
  write.csv(aux, file = flist.names, row.names = F)
}

export2STORM.allConfig <- function(filename, idx, quantiles, softmax, dimred){
  export2STORM.idx(data = idx, filename = filename)
  export2STORM.quantiles(data = quantiles, filename = filename)
  export2STORM.softmax(data = softmax, filename = filename)
  export2STORM.dimReduction(data = dimred, filename = filename)
}