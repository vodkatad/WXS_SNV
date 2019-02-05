library(scales)
library(ggplot2)
library(RColorBrewer)
library(reshape)

datafile <- snakemake@input[["data"]]
plotbin <- snakemake@output[["plotbin"]]
plotrand <- snakemake@output[["plotrand"]]
plotaf <- snakemake@output[["plotaf"]]
table <- snakemake@output[["table"]]
nrand <- snakemake@params[["nrand"]]
debug <- snakemake@params[["debug"]]

if (debug == "yes") {
  save.image(file=paste0(table,'.debug','.RData'))
}

d <- read.table(datafile, header=TRUE, row.names=1)
countdf <- as.data.frame(table(apply(d,1, function(x) {sum(x>0)})))
write.table(countdf, file=table, sep="\t", quote=FALSE)
countdf$count <- as.numeric(countdf$Var1)
md <- melt(d)
mdnz <- md[md$value != 0,]
ggplot(mdnz, aes(value, fill = variable)) + geom_histogram() + facet_wrap(~variable)
ggsave(plotaf)

onerand <- function(data, binomp) {
  rbinomnoz <- function(n, s, p) {
    binom <- rbinom(n, s, p)
    if (all(binom == 0)) {
      binom[sample(1:n, 1)] <- 1
    }
    binom
  }
  r <- t(replicate(nrow(d), rbinomnoz(ncol(data), 1, binomp)))
  count <- apply(r,1, function(x) {sum(x>0)})
  res <- as.data.frame(table(count))
  res$count <- as.numeric(res$count)
  if (nrow(res) != ncol(data)) { 
    res <- rbind(res, c(ncol(data), 0)) 
  }
  res
}

num <- apply(d, 2, function(x) { sum(x>0)})
manyrands <- replicate(nrand, onerand(d, mean(num)/nrow(d)), simplify=FALSE)
tog <- do.call(rbind, manyrands)
ggplot(tog, aes(x=Freq, color=as.factor(count))) + geom_density()
cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00" ,"#CC79A7")
ggplot(tog, aes(as.factor(count), Freq)) + geom_boxplot(aes(colour=as.factor(count)))+ geom_point(data=countdf, aes(x=as.factor(count), y=Freq),colour = "darkred", size=3)+theme_bw()+xlab("N. of mutated samples")+ylab("N. of muts")+ theme(legend.position = "none", text = element_text(size=15), axis.text=element_text(size=12))+scale_colour_manual(values=cbPalette)
ggsave(plotbin)

onerandpupido <- function(alldata, samples, muts) {
  samplenoz <- function(alld, samples) {
    pick <- sample(alld, samples)
    while (all(pick == 0)) {
      pick <- sample(alld, samples)
    }
    pick
  }
  r <- t(replicate(muts, samplenoz(alldata, samples)))
  count <- apply(r,1, function(x) {sum(x>0)})
  res <- as.data.frame(table(count))
  res$count <- as.numeric(res$count)
  if (nrow(res) != samples) {
    res <- rbind(res, c(samples, 0))
  }
  res
}

alld <- unlist(d)
manyrands <- replicate(nrand, onerandpupido(alld, ncol(d), nrow(d)), simplify=FALSE)
togp <- do.call(rbind, manyrands)
ggplot(togp, aes(x=Freq, color=as.factor(count))) + geom_density()
cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00" ,"#CC79A7")

ggplot(togp, aes(as.factor(count), Freq)) + geom_boxplot(aes(colour=as.factor(count)))+ geom_point(data=countdf, aes(x=as.factor(count), y=Freq),colour = "darkred", size=3)+theme_bw()+xlab("N. of mutated samples")+ylab("N. of muts")+ theme(legend.position = "none", text = element_text(size=15), axis.text=element_text(size=12))+scale_colour_manual(values=cbPalette)
ggsave(plotrand)

