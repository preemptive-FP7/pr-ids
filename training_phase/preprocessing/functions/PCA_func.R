#######################################################
# PCA_func.R
# 
# Provides functions for
# -- PCA analysis:
#    +++PCA.datetime
#    +++PCA.train
#    +++PCA.train.results
#    +++PCA.test
# -- PCA 3D plots:
#    +++PCA.plot3D.new
#    +++PCA.plot3D
#    +++PCA.plot3D.save
#    +++PCA.plot3D.saveWebGL
#    +++PCA.plot3D.identify
#    +++PCA.scatter3D
# 
# Authors:
# -- xclotet (clotetx@aia.es)
#######################################################

require(data.table)
require(rgl)
require(stats)
require(car)
require(colorspace)
require(ggplot2)
require(lubridate)
source("date_time_func.R")

# ===========================================================
# PCA analysis
# ===========================================================
PCA.datetime <- function(data.traintest) {
  data.traintest.datetime <- NULL
  if ("datetime" %in% names(data.traintest)) {
    if (data.traintest[, is.POSIXct(datetime)]) {
      data.traintest.datetime <- data.traintest[, datetime]
    }
  }
  if ("t" %in% names(data.traintest)) {
    if (data.traintest[, is.POSIXct(t)]) {
      data.traintest.datetime <- data.traintest[, t]
    } 
  }
  if ("date" %in% names(data.traintest)) {
    if (data.traintest[, is.POSIXct(date)]) {
      data.traintest.datetime <- data.traintest[, date]
    }
  }
  if (is.null(data.traintest.datetime)) {
    stop("no POSIXct data provided")
  }
  data.traintest.datetime
}

PCA.train <- function(data.train, 
                      center = T, scale. = T, tol = 0.1) {
  if ("datetime" %in% names(data.train)) {
    data.train[, datetime := NULL]
  }
  if ("wk" %in% names(data.train)) {
    data.train[, wk := NULL]
  }
  if ("wnum" %in% names(data.train)) {
    data.train[, wnum := NULL]
  }
  if ("t" %in% names(data.train)) {
    data.train[, t := NULL]
  }
  if ("tt" %in% names(data.train)) {
    data.train[, tt := NULL]
  }
  if ("date" %in% names(data.train)) {
    data.train[, date := NULL]
  }
  if ("tt" %in% names(data.train)) {
    data.train[, tt := NULL]
  }
  # Remove Date column
  data.train.2pca <- data.train[complete.cases(data.train)]
  # Remove columns with variance zero
  cols <- sapply(data.train.2pca, function(x) var(x, na.rm = TRUE) != 0)
  data.train.2pca <- data.train.2pca[, cols,with = F]
  # Tolerance 0.1 means only use pc with deviation > tol * deviation pc1
  data.train.pca <- prcomp(data.train.2pca, center = T, scale. = T, tol = 0.1)
  summary(data.train.pca)
  data.train.pca
}

PCA.train.results <- function(data.train.pca, datetime = data.train.datetime) {
  data.train.results <- as.data.table(data.train.pca$x)
  data.train.results[, date := datetime]
  aux <- getDateInfo(data.train.results)
  data.train.results <- cbind(aux[[1]], aux[[2]])
  data.train.results
}

PCA.test <- function(model = data.train.pca, newdata = data.test,
                     datetime = data.test.datetime) {
  if ("datetime" %in% names(newdata)) {
    newdata[, datetime := NULL]
  }
  if ("wk" %in% names(newdata)) {
    newdata[, wk := NULL]
  }
  if ("t" %in% names(newdata)) {
    newdata[, t := NULL]
  }
  if ("tt" %in% names(newdata)) {
    newdata[, tt := NULL]
  }
  if ("date" %in% names(newdata)) {
    newdata[, date := NULL]
  }
  # Remove columns with variance zero
  data.test.2pca <- newdata
  cols <- sapply(data.test.2pca, function(x) var(x, na.rm = TRUE) != 0)
  data.test.2pca <- data.test.2pca[,cols,with = F]
  # Get transformed data
  data.test.pc <- data.table(predict(data.train.pca, newdata = newdata))
  data.test.pc[, date := datetime]
  aux <- getDateInfo(data.test.pc)
  data.test.results <- cbind(aux[[1]], aux[[2]])
  data.test.results <- data.table(data.test.results)
}


# ===========================================================
# PCA 3D PLOTS
# ===========================================================
PCA.plot3D.new <- function() {
  open3d()
  fogtypes <- c("exp2", "linear", "exp", "none")
  fogtype <- fogtypes[1]
  # Prepare background
  rgl::rgl.bg(color = "white", fogtype = fogtype)
  rgl::rgl.lines(c(0,1), c(0,0), c(0,0), color = "red")
  rgl::rgl.lines(c(0,0), c(0,1), c(0,0), color = "green")
  rgl::rgl.lines(c(0,0), c(0,0), c(0,1), color = "blue")
} 

PCA.plot3D <- function(data.train.results, new = T, 
                       color. = NULL, radius. = 1, return. = F) {
  # PC components
  xx <- data.train.results$PC1
  yy <- data.train.results$PC2
  zz <- data.train.results$PC3
  coords <- xyz.coords(xx, yy, zz)
  # Color
  if (is.null(color.)) {
    cols <- "red"
  } else{
    pl.names <- names(data.train.results)
    if (color. %in% pl.names) {
      aux <- data.train.results[, color., with = F]
      cols.factor <- factor(as.matrix(aux))
      cols.num <- length(levels(cols.factor))
      cols.pal <- brewer.pal(cols.num, "RdYlBu")
      cols <- cols.pal[cols.factor]
    } else {
      cols <- color.
    }
  }
  # Prepare plot box if it doesn't exist or a new instance is required
  aux <- rgl.dev.list()
  if (!(!is.na((names(aux) == "wgl")[1]) & !new)) {
    PCA.plot3D.new()
  } 
  # Plot detectors
  spheres3d(coords, radius = radius.,
            alpha = 0.8, color = cols)
  if (return.) {
    return(coords)
  }
}

PCA.plot3D.save <- function(filename) {
  strspl <- strsplit(filename,split = ".", fixed = T)[[1]]
  if (length(strspl >= 2) & strspl[length(strspl)] == "png") {
    rgl.snapshot(filename)
  } else { 
    rgl.snapshot(paste0(filename, ".png"))
  }
}

PCA.plot3D.saveWebGL <- function(filename) {
  writeWebGL()
}

PCA.plot3D.identify <- function(plot.data = ev.coord, labels. = ev.datetime) {
  if (!is.null(labels.)) {
    id <- identify3d(ev.coord, labels = labels.)
  } else {
    id <- identify3d(ev.coord)
  }
  writeLines(as.character(labels.[id]))
  return(id)
}

PCA.scatter3D <- function(data.train.results, new = T, color. = NULL, return. = F) {
  # PC components
  coords <- PCA.getcoords(data.train.results)
  xx <- coords$x
  yy <- coords$y
  zz <- coords$z
  # Color
  if (is.null(color.)) {
    cols <- "red"
  } else{
    pl.names <- names(data.train.results)
    if (color. %in% pl.names) {
      aux <- data.train.results[, color., with = F]
      cols.factor <- factor(as.matrix(aux))
      cols.num <- length(levels(cols.factor))
      if (cols.num <= 11) {
        cols.pal <- brewer.pal(cols.num, "RdYlBu")
      } else {
        cols.pal <- colorspace::diverge_hcl(cols.num + 1)
      }
      cols <- cols.pal[cols.factor]
    } else {
      cols <- color.
    }
  }
  if (sum(zz == 0) == length(zz)) {
    print(' -------------------------')
    print(' -------------------------')
    print(' --- Data is 1- or 2-D ---')
    print(' -------------------------')
    print(' -------------------------')
    plot2D(data.train.results, cols)
    warning("Run last_plot() to see 2D PCA plot")
  } else {
    # Prepare plot box if it doesn't exist or a new instance is required
    aux <- rgl.dev.list()
    if (!(!is.na((names(aux) == "wgl")[1]) & !new)) {
      PCA.plot3D.new()
    } 
    # Plot detectors
    scatter3d(xx,yy,zz,
              #groups = factor(data.plot3[,wday]),
              point.col = cols, 
              sphere.size = 3,
              radius = 3,
              surface = FALSE)
    #   rgl.points(xx,yy,zz,
    #             col = cols)
  }
  if (return.) {
    return(coords)
  }
}
# ==========================================================/

# ===========================================================
# PCA preprocess data
# ===========================================================

# Residuals of linear fits over windows of time T
prep.resiuals <- function(Ttt, data.train.use, data.train.temporal) {
  # Ttt <- 30*60 # in seconds as tt
  tt <- data.train.temporal$t
  subs.T <- data.train.use
  subs.T[, tt := tt]
  subs.T.names <- names(subs.T)
  subs.T.namesX <- c(paste0("X", seq(1:(length(subs.T.names) - 1))))
  setnames(subs.T, subs.T.names, c(subs.T.namesX, "tt"))
  Ttt.breaks <- seq(tt[1], tt[length(tt)], by = Ttt)
  subs.T.all <- NULL
  # if (exists("subs.T.all")) {
  #   rm(subs.T.all)
  # }
  for (i in seq(1, length(Ttt.breaks) - 1)) {
    aux <- subs.T[ tt >= Ttt.breaks[i] & tt < Ttt.breaks[i + 1]]
    for (name in subs.T.namesX) {
      form <- formula(paste0(name, " ~ tt"))
      aux[, name := residuals(lm(form, data = .SD)), with = F]
    }
    aux <- data.table(aux)
    if (exists("subs.T.all")) {
      subs.T.all <- rbind(subs.T.all, aux)
    } else {
      subs.T.all <- aux
    }
  }
  subs.T.all <- data.table(subs.T.all)
  
  # tt.Ttt <- tt[tt >= Ttt.breaks[1] & tt < Ttt.breaks[length(Ttt.breaks)]]
  # return(subs.T.all[, t:= tt.Ttt])
  return(subs.T.all)
}


# PCA get coords ----------------------------------------------------------

PCA.getcoords <- function(data.train.results) {
  xx <- data.train.results$PC1
  yy <- data.train.results$PC2
  zz <- data.train.results$PC3
  if (is.null(zz)) {
    print(' -------------------------')
    print(' -------------------------')
    warning('--- Data is 1- or 2-D ---')
    print(' -------------------------')
    print(' -------------------------')
    zz <- rep(0, length(xx))
  }
  coords <- xyz.coords(xx, yy, zz)
  return(coords)
}

PCA.plot2D <- function(data.train.results, cols) {
  require(ggplot2)
  ggplot(data.train.results) + geom_point(aes(PC1, PC2, color = cols)) 
}

PCA.plot2D.comparison <- function(data.train.results, data.test.results, ndim = 3) {
  require(gridExtra)
  g_legend <- function(a.gplot) {
    tmp <- ggplot_gtable(ggplot_build(a.gplot)) 
    leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box") 
    legend <- tmp$grobs[[leg]] 
    return(legend)
  } 
  
  data.plot <- rbindlist(list(data.train.results[, label := "train"], 
                              data.test.results[, label := "test"]))
  cols <- c(names(data.plot)[1:ndim])
  g <- ggplot(data.plot) +
    geom_point(aes(x = PC1, y = PC2, color = label), alpha = 0.5)
  if (ndim > 2) {
    g2 <- ggplot(data.plot) +
      geom_point(aes(x = PC3, y = PC2, color = label), alpha = 0.5) 
    g3 <- ggplot(data.plot) +
      geom_point(aes(x = PC1, y = PC3, color = label), alpha = 0.5) 
    legend <- g_legend(g3)
    g <- grid.arrange(g + theme(legend.position = 'none') , 
                      g2 + theme(legend.position = 'none'),
                      g3 + theme(legend.position = 'none'),
                      legend, ncol = 2)
  }
  g  
}