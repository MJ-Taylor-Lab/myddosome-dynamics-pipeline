# For loading custom functions used throughout the script

print(":::::::::::::::::::: START CUSTOM FX ::::::::::::::::::::")
tryCatch({
  select <- dplyr::select
  #CustomFx for the correlation since method doesn't work in original
  chart.Correlation.Custom <-
    function (
      R, histogram = TRUE,
      method=c("pearson", "kendall", "spearman"), ...)
    { 
      x = checkData(R, method="matrix")
      if(missing(method)) method = method[1]
      panel.cor <-
        function(
          x, y, digits=2, prefix="",
          use="pairwise.complete.obs",
          meth = method, cex.cor, ...)
        {
          usr <- par("usr"); on.exit(par(usr))
          par(usr = c(0, 1, 0, 1))
          r <- cor(x, y, use=use, method=meth)
          txt <- format(c(r, 0.123456789), digits=digits)[1]
          txt <- paste(prefix, txt, sep="")
          if(missing(cex.cor)) cex <- 0.8/strwidth(txt)
          
          test <- cor.test(as.numeric(x),as.numeric(y), method=meth)
          
          Signif <-
            symnum(
              test$p.value, corr = FALSE, na = FALSE,
              cutpoints = c(0, 0.001, 0.01, 0.05, 0.1, 1),
              symbols = c("***", "**", "*", ".", " "))
          text(0.5, 0.5, txt, cex = cex * (abs(r) + .3) / 1.3)
          text(.8, .8, Signif, cex=cex, col=2)
        }
      f <- function(t) {
        dnorm(t, mean=mean(x), sd=sd.xts(x) )
      }
      
      hist.panel = function (x, ...=NULL ) {
        par(new = TRUE)
        hist(x,
             col = "light gray",
             probability = TRUE,
             axes = FALSE,
             main = "",
             breaks = "FD")
        lines(density(x, na.rm=TRUE),
              col = "red",
              lwd = 1)
        #lines(f, col="blue", lwd=1, lty=1) how to add gaussian normal overlay?
        rug(x)
      }
      
      # Draw the chart
      if(histogram)
        pairs(
          x, gap=0, lower.panel=panel.smooth,
          upper.panel=panel.cor, diag.panel=hist.panel)
      else
        pairs(
          x, gap=0, lower.panel=panel.smooth,
          upper.panel=panel.cor) 
    }
  
  #For finding the mode
  my.mode <- function(v) {
    uniqv <- unique(v)
    uniqv[which.max(tabulate(match(v, uniqv)))]
  }
  
  #For getting n characters to the left
  my.left = function (string,char){
    substr(string, 1, char)
  }
  
  #For getting n characters to the right
  my.right = function (string, char){
    substr(string, nchar(string) - (char - 1), nchar(string))
  }
  
  #For finding local maxima
  my.localmaxima <- function(x) {
    # Use -Inf instead if x is numeric (non-integer)
    y <- diff(c(-.Machine$integer.max, x)) > 0L
    rle(y)$lengths
    y <- cumsum(rle(y)$lengths)
    y <- y[seq.int(1L, length(y), 2L)]
    if (x[[1]] == x[[2]]) {
      y <- y[-1]
    }
    y
  }
  
  #For finding local minima
  my.localminima <- function(x) {
    # Use -Inf instead if x is numeric (non-integer)
    y <- diff(c(.Machine$integer.max, x)) > 0L
    rle(y)$lengths
    y <- cumsum(rle(y)$lengths)
    y <- y[seq.int(1L, length(y), 2L)]
    if (x[[1]] == x[[2]]) {
      y <- y[-1]
    }
    y
  }
  
}, error=function(e) {print("ERROR Custom Fx")})
print(":::::::::::::::::::: END CUSTOM FX ::::::::::::::::::::")