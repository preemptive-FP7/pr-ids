#######################################################
# date_time_func.R
# 
# Different date and time functions used in various
# analysis. Functions:
#   - getDateInfo
#   
# Authors:
# -- xclotet (clotetx@aia.es)
#######################################################

getDateInfo <- function(data) {
  library(lubridate)
  # Creates new columns thour, month, year, wday, we, day
  # in a data.frame or data.table which contains a column
  # date (e.g., as.POSIXct("2015-01-01 00:00:00 UTC"))
  #
  # Args:
  #   data: data.frame or data.table with a column date
  #
  # Returns:
  #   List with:
  #       - same data.frame/data.table without temporal info
  #       - data.table with the extra (date time related) columns
  df_ <- 0
  if (sum(class(data) == "data.table") == 0) {
    data <- as.data.table(data)
    df_ <- 1
  }
  if ("t" %in% names(data)) {
    data.temporal <- data[,c("t","date"),with = F]
    data <- data[,!c("t","date"),with = F]
  } else {
    data.temporal <- data[,c("date"),with = F]
    data <- data[,!c("date"),with = F]
  }
  
  data.temporal[, tday := hour(date) + minute(date)/60 + second(date)/3600]
  data.temporal[, thour := hour(date)]
  data.temporal[, month := month(date)]
  data.temporal[, year := year(date)]
  data.temporal[, wday := format(as.Date(date),"%u")]
  data.temporal[, wnum := isoweek(date)]
  data.temporal[, we := ifelse(wday %in% c(6,7),1,0)]
  data.temporal[, day := as.POSIXlt(date)$mday]
  if (df_) {
    data.temporal <- as.data.frame(data.temporal)
    data.temporal <- as.data.frame(data.temporal)
  }  
  list.data <- list(data, data.temporal)
  return(list.data)
}
