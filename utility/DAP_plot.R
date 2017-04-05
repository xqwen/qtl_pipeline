

colv = c( "#386CB0","#F0027F", "#7FC97F","#BEAED4","#FDC086","#FFFF99","#BF5B17","#666666","#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E","#E6AB02","#A6761D","#666666","#A6CEE3","#1F78B4","#B2DF8A","#33A02C","#FB9A99","#E31A1C","#FDBF6F","#FF7F00","#CAB2D6","#6A3D9A","#FFFF99","#B15928","#FBB4AE","#B3CDE3","#CCEBC5","#DECBE4","#FED9A6","#FFFFCC","#E5D8BD","#FDDAEC","#F2F2F2","#B3E2CD","#FDCDAC","#CBD5E8","#F4CAE4","#E6F5C9","#FFF2AE","#F1E2CC","#CCCCCC","#E41A1C","#377EB8","#4DAF4A","#984EA3","#FF7F00","#FFFF33","#A65628","#F781BF","#999999","#66C2A5","#FC8D62","#8DA0CB","#E78AC3","#A6D854","#FFD92F","#E5C494","#B3B3B3","#8DD3C7","#FFFFB3","#BEBADA","#FB8072","#80B1D3","#FDB462","#B3DE69","#FCCDE5","#D9D9D9","#BC80BD","#CCEBC5","#FFED6F")


 args = commandArgs(trailingOnly = TRUE)
pip_file = args[1]

gene = args[3]
d = read.table(pip_file)
attach(d)


pip_plot_file = paste(gene,"_pip_plot.pdf",sep="")
ld_plot_file = paste(gene,"_r2_plot.pdf",sep="")





pdf(file = pip_plot_file, width = 15, height = 5.25,bg="white")
pos = V3/1000
seq = sort(unique(V5))
nc = length(seq)

length = max(pos)-min(pos)

plot(V4~pos,xlab= "Genomic Position (kb) ", ylab = "Posterior Inclusion Probability",ylim=c(0.0,1), xlim = c(min(pos)-0.02*length, max(pos)+0.22*length),cex= 0.85, main = paste(gene, " (",V2[1],")", sep="")  )
#colors = sample(colv,length(seq))
sapply(seq, function(x) points(V4[V5==x]~pos[V5==x],pch=16,col=colv[x],cex=0.8))
pipv = sapply(seq, function(x) sum(V4[V5==x]))
countv = sapply(seq, function(x) length(V4[V5==x]))
labels = paste("cluster",seq, " (PIP=", pipv,  ", p=",countv, ")",sep="")
legend("topright", labels,pch=15,col=colv[1:nc])


dev.off()

geno_file = args[2]
library(LDheatmap)
pdf(file = ld_plot_file, width = 5.25, height = 5.25,bg="white")
G = as.matrix(read.table(geno_file))
r2= cor(t(G))^2
LDheatmap(r2,V3,color="blueToRed")
dev.off()
