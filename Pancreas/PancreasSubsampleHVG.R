#Code for the t-SNE plots of pancrease data sets and the Silhouette coefficients before and after batch correction by different methods (main text Figure 4).
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

load("./ObjectsForPlotting.RDS") #load the output of "preparedata.R"
rm(list=setdiff(ls(), c("datah1","datah2","datah3","datah4","hvg_genes","celltype1","celltype2","celltype3","celltype4")) )

require(WGCNA)
library(scales)
library(scran)
dir.create("results1500", showWarning=FALSE)

hvg_genes<-sample(hvg_genes,1500)

datah1<-as.matrix(datah1[hvg_genes,])
datah2<-as.matrix(datah2[hvg_genes,])
datah3<-as.matrix(datah3[hvg_genes,])
datah4<-as.matrix(datah4[hvg_genes,])

batch<-c(rep(3,ncol(datah3)), rep(4,ncol(datah4)), rep(2,ncol(datah2)), rep(1,ncol(datah1)))
######uncorrected data
raw.all<-cbind(datah3,datah4,datah2,datah1)
colnames(raw.all)<-c(rep(3,dim(datah3)[2]),rep(4,dim(datah4)[2]),rep(2,dim(datah2)[2]),rep(1,dim(datah1)[2]))

# tidy cell type

celltypes<-c(celltype3,celltype4,celltype2,celltype1)

#####set cell type colorings
allcolors<-labels2colors(celltypes)#[allsamples])

allcolors[allcolors=="red"]<-"deeppink"
allcolors[allcolors=="yellow"]<-"orange1"#"darkgoldenrod1"

library(RColorBrewer)
colors4<-brewer.pal(4,"Set3")
batch.cols<-colors4[batch]

set.seed(0)
ix2<-sample(ncol(raw.all)) # randomize index for fair representation plots

#### Uncorrected data 
t.unc<-t(raw.all)
all.dists2.unc <- as.matrix(dist(t.unc))
require(Rtsne)
par(mfrow=c(1,1))

set.seed(0)
tsne.unc<-Rtsne(all.dists2.unc, is_distance=TRUE)

png(file="results1500/unc_cell.png",width=900,height=700)
par(mfrow=c(1,1),mar=c(6,6,4,2),cex.axis=2,cex.main=3,cex.lab=2.5)
plot(tsne.unc$Y[ix2,1],tsne.unc$Y[ix2,2], pch=20,cex=2,col=alpha(allcolors[ix2],0.6),main="Uncorrected",xlab="tSNE 1",ylab="tSNE 2")
dev.off()

png(file="results1500/unc_batch.png",width=900,height=700)
par(mfrow=c(1,1),mar=c(6,6,4,2),cex.axis=2,cex.main=3,cex.lab=2.5)
plot(tsne.unc$Y[ix2,1],tsne.unc$Y[ix2,2], pch=20,cex=2,col=alpha(batch.cols[ix2],0.6),main="Uncorrected",xlab="tSNE 1",ylab="tSNE 2")
dev.off()

# Generating a PCA plot.
pca.unc <- prcomp(t.unc, rank=2)

png(file="results1500/unc_pca.png",width=900,height=700)
par(mfrow=c(1,1),mar=c(6,6,4,2),cex.axis=2,cex.main=3,cex.lab=2.5)
plot(pca.unc$x[ix2,1],pca.unc$x[ix2,2], pch=20,cex=2,col=alpha(batch.cols[ix2],0.6),main="Uncorrected",xlab="PC 1",ylab="PC 2")
dev.off()

### MNN batch correction
mnn.out<-mnnCorrect(datah3,datah4,datah2,datah1,k=20, sigma=0.1,cos.norm.in=TRUE, cos.norm.out=TRUE, var.adj=TRUE,compute.angle=TRUE)

X.mnn<-do.call(cbind, mnn.out$corrected)
t.mnn <- t(X.mnn)

png(file="results1500/angles.png",width=1000,height=300)
par(mfrow=c(1,3),mar=c(6,6,4,2),cex.axis=2,cex.main=3,cex.lab=2.5)
hist(mnn.out$angles[[2]],xlab="Angle",ylab="Frequency",main="") 
hist(mnn.out$angles[[3]],xlab="Angle",ylab="Frequency",main="") 
hist(mnn.out$angles[[4]],xlab="Angle",ylab="Frequency",main="") 
dev.off()

all.dists2.c <- as.matrix(dist(t.mnn))

set.seed(0)
tsne.c<-Rtsne(all.dists2.c, is_distance=TRUE)

png(file="results1500/mnn_cell.png",width=900,height=700)
par(mfrow=c(1,1),mar=c(6,6,4,2),cex.axis=2,cex.main=3,cex.lab=2.5)
plot(tsne.c$Y[ix2,1],tsne.c$Y[ix2,2], pch=20,cex=2,col=alpha(allcolors[ix2],0.6),main="MNN",xlab="tSNE 1",ylab="tSNE 2")
dev.off()

png(file="results1500/mnn_batch.png",width=900,height=700)
par(mfrow=c(1,1),mar=c(6,6,4,2),cex.axis=2,cex.main=3,cex.lab=2.5)
plot(tsne.c$Y[ix2,1],tsne.c$Y[ix2,2], pch=20,cex=2,col=alpha(batch.cols[ix2],0.6),main="MNN",xlab="tSNE 1",ylab="tSNE 2")
dev.off()

# Generating a PCA plot.
pca.mnn <- prcomp(t.mnn, rank=2)
#pca.mnn$x<-cosine.norm(pca.mnn$x)
#pca.mnn$x[ (pca.mnn$x<(-0.08))]<- (-0.08)

png(file="results1500/mnn_pca.png",width=900,height=700)
par(mfrow=c(1,1),mar=c(6,6,4,2),cex.axis=2,cex.main=3,cex.lab=2.5)
plot(pca.mnn$x[ix2,1],pca.mnn$x[ix2,2], pch=20,cex=2,col=alpha(batch.cols[ix2],0.6),main="MNN",xlab="PC 1",ylab="PC 2")
dev.off()

###conventional tsne (with pca preprocesing)
set.seed(0)
tsne.c2<-Rtsne(t.mnn)

png(file="results1500/mnn_cell_conven.png",width=900,height=700)
par(mfrow=c(1,1),mar=c(6,6,4,2),cex.axis=2,cex.main=3,cex.lab=2.5)
plot(tsne.c2$Y[ix2,1],tsne.c2$Y[ix2,2], pch=20,cex=2,col=alpha(allcolors[ix2],0.6),main="MNN",xlab="tSNE 1",ylab="tSNE 2")
dev.off()

png(file="results1500/mnn_batch_conven.png",width=900,height=700)
par(mfrow=c(1,1),mar=c(6,6,4,2),cex.axis=2,cex.main=3,cex.lab=2.5)
plot(tsne.c2$Y[ix2,1],tsne.c2$Y[ix2,2], pch=20,cex=2,col=alpha(batch.cols[ix2],0.6),main="MNN",xlab="tSNE 1",ylab="tSNE 2")
dev.off()

###limma batch correction
library(limma)
X.lm <- removeBatchEffect(raw.all, factor(colnames(raw.all)))
t.lm<-t(X.lm)
all.dists2.lm <- as.matrix(dist(t.lm))

set.seed(0)
tsne.lm<-Rtsne(all.dists2.lm, is_distance=TRUE)

png(file="results1500/lm_cell.png",width=900,height=700)
par(mfrow=c(1,1),mar=c(6,6,4,2),cex.axis=2,cex.main=3,cex.lab=2.5)
plot(tsne.lm$Y[ix2,1],tsne.lm$Y[ix2,2], pch=20,cex=2,col=alpha(allcolors[ix2],0.6),main="limma",xlab="tSNE 1",ylab="tSNE 2")
dev.off()

png(file="results1500/lm_batch.png",width=900,height=700)
par(mfrow=c(1,1),mar=c(6,6,4,2),cex.axis=2,cex.main=3,cex.lab=2.5)
plot(tsne.lm$Y[ix2,1],tsne.lm$Y[ix2,2], pch=20,cex=2,col=alpha(batch.cols[ix2],0.6),main="limma",xlab="tSNE 1",ylab="tSNE 2")
dev.off()

# Generating a PCA plot.
pca.lm <- prcomp(t.lm, rank=2)

png(file="results1500/lm_pca.png",width=900,height=700)
par(mfrow=c(1,1),mar=c(6,6,4,2),cex.axis=2,cex.main=3,cex.lab=2.5)
plot(pca.lm$x[ix2,1],pca.lm$x[ix2,2], pch=20,cex=2,col=alpha(batch.cols[ix2],0.6),main="limma",xlab="PC 1",ylab="PC 2")
dev.off()

####ComBat correction
library(sva)

Z <- colnames(raw.all)
X.combat <- ComBat(raw.all,Z,mod=NULL,prior.plots = FALSE)

t.combat<-t(X.combat)
all.dists2.combat <- as.matrix(dist(t.combat))

set.seed(0)
tsne.combat<-Rtsne(all.dists2.combat, is_distance=TRUE)

png(file="results1500/combat_cell.png",width=900,height=700)
par(mfrow=c(1,1),mar=c(6,6,4,2),cex.axis=2,cex.main=3,cex.lab=2.5)
plot(tsne.combat$Y[ix2,1],tsne.combat$Y[ix2,2], pch=20,cex=2,col=alpha(allcolors[ix2],0.6),main="ComBat",xlab="tSNE 1",ylab="tSNE 2")
dev.off()

png(file="results1500/combat_batch.png",width=900,height=700)
par(mfrow=c(1,1),mar=c(6,6,4,2),cex.axis=2,cex.main=3,cex.lab=2.5)
plot(tsne.combat$Y[ix2,1],tsne.combat$Y[ix2,2], pch=20,cex=2,col=alpha(batch.cols[ix2],0.6),main="ComBat",xlab="tSNE 1",ylab="tSNE 2")
dev.off()

# Generating a PCA plot.
pca.combat <- prcomp(t.combat, rank=2)

png(file="results1500/combat_pca.png",width=900,height=700)
par(mfrow=c(1,1),mar=c(6,6,4,2),cex.axis=2,cex.main=3,cex.lab=2.5)
plot(pca.combat$x[ix2,1],pca.combat$x[ix2,2], pch=20,cex=2,col=alpha(batch.cols[ix2],0.6),main="ComBat",xlab="PC 1",ylab="PC 2")
dev.off()

###save results1500
save(file="results1500/completedata_correcteds.RData", raw.all, X.mnn,X.lm,X.combat,celltypes,allcolors,batch,pca.unc,pca.mnn,pca.lm,pca.combat)
###### the legend
png(file="results1500/leg_tsne.png",width=900,height=700)
par(mfrow=c(1,1),mar=c(6,6,4,2),cex.axis=2,cex.main=3,cex.lab=2.5)
plot(1,2, pch=3,cex=4,col=alpha(allcolors[1],0.6),main="legend",xlim=c(-20,30),ylim=c(-13,13),xlab="",ylab="")
forleg<-table(celltypes,allcolors)
leg.txt<-unique(celltypes)
legend("bottomright", "(x,y)", legend = leg.txt, col =unique(allcolors) , pch = 20,cex = 2.5,bty = "n",lwd = 3,lty=0)   #, trace = TRUE)
dev.off()
##################### write.table
# Ns<-c(ncol(datah4),ncol(datah3),ncol(datah2),ncol(datah1))
# correh4<-corre[,1:Ns[1]]
# correh3<-corre[,(Ns[1]+1):(Ns[1]+Ns[2])]
# correh2<-corre[,(Ns[1]+Ns[2]+1):(Ns[1]+Ns[2]+Ns[3])]
# correh1<-corre[,(Ns[1]+Ns[2]+Ns[3]+1):(Ns[1]+Ns[2]+Ns[3]+Ns[4])]

# colnames(correh4)<-celltype4
# colnames(correh3)<-celltype3
# colnames(correh2)<-celltype2
# colnames(correh1)<-celltype1

# colnames(correh4)<-colnames(datah4)
# colnames(correh3)<-colnames(datah3)
# colnames(correh2)<-colnames(datah2)
# colnames(correh1)<-colnames(datah1)
# 
# write.table(file="C_Smartseq_GSE86473.txt",correh4,row.names = TRUE, col.names = TRUE)
# write.table(file="C_Smartseq_EMATB5061.txt",correh3,row.names = TRUE, col.names = TRUE)
# write.table(file="C_CELLseq_SSE85241.txt",correh2,row.names = TRUE, col.names = TRUE)
# write.table(file="C_CELLseq_GSE81076.txt",correh1,row.names = TRUE, col.names = TRUE)
##########

##########compute Silhouette coefficients on t-SNE coordinates
library(kBET)
ct.fac <- factor(celltypes)

dd.unc <- as.matrix(dist(tsne.unc$Y)) #all.dists2.unc#
score_sil <- (cluster::silhouette(as.numeric(ct.fac), dd.unc))
sil.unc<-score_sil[,3]  #for uncorrected data

dd.c <- as.matrix(dist(tsne.c$Y))#all.dists2.c#
score_sil <- (cluster::silhouette(as.numeric(ct.fac), dd.c))
sil.mnn<-score_sil[,3] #for MNN corrected data


dd.lm <- as.matrix(dist(tsne.lm$Y))#all.dists2.lm#
score_sil <- (cluster::silhouette(as.numeric(ct.fac), dd.lm))
sil.lm<-score_sil[,3] #for limma corrected data

dd.com <- as.matrix(dist(tsne.combat$Y))#all.dists2.combat#
score_sil <- (cluster::silhouette(as.numeric(ct.fac), dd.com))
sil.combat<-score_sil[,3] #for ComBat corrected data


### boxplot of Silhouette coefficients
sils<-cbind(sil.unc,sil.mnn,sil.lm,sil.combat)

png(file="results1500/sils_alltypes_tsnespace.png",width=900,height=700) #sils_alltypes_fullspace.png
par(mfrow=c(1,1),mar=c(8,8,5,3),cex.axis=3,cex.main=2,cex.lab=3)
boxplot(sils,main="",names=c("Uncorrected","MNN","limma","ComBat"),lwd=4,ylab="Silhouette coefficient")#,col="Yellow",ylab="Alpha dists")
dev.off()

################## Batch mixing entropy on PCAs
source('BatchMixingEntropy.R')

entropy.unc<-BatchEntropy(pca.unc$x[,1:2],batch)
entropy.mnn<-BatchEntropy(pca.mnn$x[,1:2],batch)
entropy.lm<-BatchEntropy(pca.lm$x[,1:2],batch)
entropy.combat<-BatchEntropy(pca.combat$x[,1:2],batch)

entropies<-cbind(entropy.unc,entropy.mnn,entropy.lm,entropy.combat)

png(file="results1500/entropy_batches_pcaspace.png",width=900,height=700) #sils_alltypes_fullspace.png
par(mfrow=c(1,1),mar=c(8,8,5,3),cex.axis=3,cex.main=2,cex.lab=3)
boxplot(entropies,main="",names=c("Uncorrected","MNN","limma","ComBat"),lwd=4,ylab="Batch mixing entropy")#,col="Yellow",ylab="Alpha dists")
dev.off()

########compare local vs. global
#local effects is as calculated above mnn.out
##calculate global eefects i.e large sigma i.e. equal weight averaging
mnn.out.g<-mnnCorrect(datah3,datah4,datah2,datah1,k=20, sigma=100,cos.norm.in=TRUE, cos.norm.out=TRUE, var.adj=TRUE,compute.angle=TRUE)

X.mnn.g<-do.call(cbind, mnn.out.g$corrected)
t.mnn.g <- t(X.mnn.g)

png(file="results1500/angles_global.png",width=1000,height=300)
par(mfrow=c(1,3),mar=c(6,6,4,2),cex.axis=2,cex.main=3,cex.lab=2.5)
hist(mnn.out.g$ang.with.ref[[2]],xlab="Angle",ylab="Frequency",main="") 
hist(mnn.out.g$ang.with.ref[[3]],xlab="Angle",ylab="Frequency",main="") 
hist(mnn.out.g$ang.with.ref[[4]],xlab="Angle",ylab="Frequency",main="") 
dev.off()

all.dists2.cg <- as.matrix(dist(t.mnn.g))

set.seed(0)
tsne.cg<-Rtsne(all.dists2.cg, is_distance=TRUE)

png(file="results1500/mnnglobal_cell.png",width=900,height=700)
par(mfrow=c(1,1),mar=c(6,6,4,2),cex.axis=2,cex.main=3,cex.lab=2.5)
plot(tsne.cg$Y[ix2,1],tsne.cg$Y[ix2,2], pch=20,cex=2,col=alpha(allcolors[ix2],0.6),main="MNN",xlab="tSNE 1",ylab="tSNE 2")
dev.off()

png(file="results1500/mnnglobal_batch.png",width=900,height=700)
par(mfrow=c(1,1),mar=c(6,6,4,2),cex.axis=2,cex.main=3,cex.lab=2.5)
plot(tsne.cg$Y[ix2,1],tsne.cg$Y[ix2,2], pch=20,cex=2,col=alpha(batch.cols[ix2],0.6),main="MNN",xlab="tSNE 1",ylab="tSNE 2")
dev.off()

# Generating a PCA plot.
pca.mnn.g <- prcomp(t.mnn.g, rank=2)
#pca.mnn$x<-cosine.norm(pca.mnn$x)
#pca.mnn$x[ (pca.mnn$x<(-0.08))]<- (-0.08)

png(file="results1500/mnnglobal_pca.png",width=900,height=700)
par(mfrow=c(1,1),mar=c(6,6,4,2),cex.axis=2,cex.main=3,cex.lab=2.5)
plot(pca.mnn.g$x[ix2,1],pca.mnn.g$x[ix2,2], pch=20,cex=2,col=alpha(batch.cols[ix2],0.6),main="MNN",xlab="PC 1",ylab="PC 2")
dev.off()

###compare Silhouette coefficients local vs. global
dd.cg <- as.matrix(dist(tsne.cg$Y))#all.dists2.cg#
score_sil <- (cluster::silhouette(as.numeric(ct.fac), dd.cg))
sil.cg<-score_sil[,3] #for global corrected data

sils.locglob<-cbind(sil.mnn,sil.cg)

png(file="results1500/sils_localglobal_tsnespace.png",width=900,height=700) #sils_alltypes_fullspace.png
par(mfrow=c(1,1),mar=c(8,8,5,3),cex.axis=3,cex.main=2,cex.lab=3)
boxplot(sils.locglob,main="",names=c("Local","Global"),lwd=4,ylab="Silhouette coefficient")#,col="Yellow",ylab="Alpha dists")
dev.off()
####compare batch mixing entropy local vs. global
entropy.cg<-BatchEntropy(pca.mnn.g$x[,1:2],batch)

entropies.locglob<-cbind(entropy.mnn,entropy.cg)

png(file="results1500/entropy_localgloba_pcaspace.png",width=900,height=700) #sils_alltypes_fullspace.png
par(mfrow=c(1,1),mar=c(8,8,5,3),cex.axis=3,cex.main=2,cex.lab=3)
boxplot(entropies.locglob,main="",names=c("Local","Global"),lwd=4,ylab="Batch mixing entropy")#,col="Yellow",ylab="Alpha dists")
dev.off()
