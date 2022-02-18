library("ggthemes")
library("lattice")
library("tidyverse")
library("plotly")
library("latticeExtra")

#Import data from csv file
wine<-read.csv(file="Dane_Surowe.csv", header=TRUE, dec=".", fill=TRUE, sep=",")

#Checking for missing data
print("Czy dane zawieraja braki?")
any(is.na(wine))

print("Dane sa kompletne - nie zawieraja zadnych brakow i nie wymagaj usuniecia np niekompletnych wierszy lub kolumn.")

#Printing basic statistics relevant to Acidity
cat("Fixed Acidity\n"); summary(wine$fixed.acidity);
cat("Volatile Acidity\n"); summary(wine$volatile.acidity); 
cat("Citric Acid\n"); summary(wine$citric.acid)

#Other statistics
cat("Alcohol\n"); summary(wine$alcohol);
cat("Quality\n"); summary(wine$quality);

#Checking mean quality rate of wines with devision of alcohol content
a<-wine %>% filter(alcohol<=10.5) %>% summarize(MeanQualityUnder10_5per=mean(quality))
b<-wine %>% filter(alcohol>10.5) %>% summarize(MeanQualityOver10_5per=mean(quality))
tempFrame<-data.frame(c(a,b))
colnames(tempFrame)<-c("Mean Quality Under 10.5%", "Mean Quality Over 10.5%")
tempFrame

#Distribution of PH
winepH<-wine %>% count(round(pH,1))
colnames(winepH)[1:2]<-c("pH","amount")
winepH

#Comparison of highest and lowest rated wines
rbind(head(wine %>% filter(quality==8),4),tail(wine %>% filter(quality==3),4))

#Distibution of Quality
tempq<-wine%>% count(quality)
colnames(tempq)[2]<-c("Amount")
tempq

#Amount of average Quality wines
fiveorsix<-wine%>%filter(quality==5 | quality==6)
cat("Sposrod", nrow(wine), "probek, az", nrow(fiveorsix), "zostalo uznanych za wina sredniej jakosci.")

#Selected chemical compounds depending on alcohol value 
par(mfrow=c(2,2), mai = c(0.7, 0.9, 0.5, 0.01))

plot(wine$alcohol, wine$residual.sugar, cex=0.6, pch=1, xlab="Alcohol(%)", ylab="Residual Sugar", col="#3300CC")
plot(wine$alcohol, wine$chlorides,cex=0.6, pch=1, xlab="Alcohol(%)", ylab="Chlorides", col="#00FF33")
plot(wine$alcohol, wine$sulphates, cex=0.6, pch=1, xlab="Alcohol(%)", ylab="Sulphates",col="#FFCC33")
plot(wine$alcohol, wine$citric.acid, cex=0.6, pch=1, xlab="Alcohol(%)", ylab="Citric Acid", col="#FF3333")
mtext(expression(bold("Selected chemical compounds depending on alcohol value")), side = 3, line = -2, outer = TRUE, cex=1.15,font=1)

#Distribution of Alcohol Content 
ggplot(data=wine, aes(x=alcohol))+
  geom_histogram(color="ORANGE",fill="#FFEA00",binwidth=0.35)+
  geom_vline(aes(xintercept=mean(alcohol)),color="blue", linetype="dashed", size=0.8)+
  scale_x_continuous(breaks=c(8:15))+
  scale_y_continuous(breaks=c(0,50,100,150,200,250,300,350))+
  xlab("Alcohol(%)")+
  ylab("Amount")+
  ggtitle("Amount by alcohol")+
  theme(plot.title=element_text(size=24, face="bold", color="#00009C", hjust=0.5, lineheight=1.2),plot.background = element_rect(fill = "#A5A5A5"))+
  theme(plot.margin=unit(c(0.7,0.7,0.7,0.7),"cm"))+
  theme(axis.title.x=element_text(size=14,face="bold",color="#00009C"))+
  theme(axis.title.y=element_text(size=16,face="bold",color="#00009C"))

#Relationship between pH and Fixed Acidity
xyplot( fixed.acidity~pH | factor(quality), data=wine,
        group=desc(quality), grid=TRUE,type = c("p", "smooth"),
        auto.key = list(space = "right",title = "quality",
                        text = c("3","4","5","6","7","8")),
        main="Fixed Acidity",xlab="pH", ylab="Fixed Acidity" )

#Plot shows Amount of wines divided into Quality and Alcohol Content
AlcLow<-wine%>%filter(alcohol<9.6)%>%mutate(perc="Low")
AlcMedium<-wine%>%filter(alcohol>=9.6 & alcohol<10.9)%>%mutate(perc="Medium")
AlcHigh<-wine%>%filter(alcohol>=10.9)%>%mutate(perc="High")

Alcohol<-rbind(AlcLow,AlcMedium,AlcHigh)
Alcohol$perc <- factor(Alcohol$perc, levels = c("Low","Medium","High"))

ggplot(data=Alcohol)+
  geom_bar(aes(x=as.character(quality), fill=perc), position=position_dodge(0.7), width = 0.62,color="#6A1B9A")+
  scale_x_discrete(name="Quality")+
  scale_y_continuous(name="Amount",breaks=c(0,100,200,300))+
  scale_fill_manual(name="Alcohol Ratio",values=c("#E1BEE7","#BA68C8","#8E24AA"))+
  theme( panel.background = element_rect(fill = "#000000", colour = "#6A1B9A",
                                         size = 2, linetype = "solid"))+
  ggtitle("Amount by alcohol")+
  theme(plot.title=element_text(size=24, face="bold", color="#000000", hjust=0.5, lineheight=1.5),plot.background = element_rect(fill = "#D8BFD8"))+
  theme(plot.margin=unit(c(0.5,0.5,0.5,0.5),"cm"))+
  theme(axis.title.x=element_text(size=14,face="bold",color="#000000"))+
  theme(axis.title.y=element_text(size=16,face="bold",color="#000000"))+
  theme(legend.background = element_rect(fill="#F3E5F5",
                                         size=0.5, linetype="solid", 
                                         colour ="#6A1B9A"))
#Last plot compares Fixed and Volatile Acid included variable Density
temporary<-wine%>%select(fixed.acidity,density)
temporary<-temporary%>%mutate_at(vars(density),funs(round(.,4)))
temporary<-temporary%>%group_by(density)%>%summarize(FixedMean=mean(fixed.acidity))


temporary2<-wine%>%select(volatile.acidity,density)
temporary2<-temporary2%>%mutate_at(vars(density),funs(round(.,4)))
temporary2<-temporary2%>%group_by(density)%>%summarize(VolatileMean=mean(volatile.acidity))

WineAcidity<-merge(temporary,temporary2,by="density")

m <- list(
  l = 50,
  r = 50,
  b = 50,
  t = 50,
  pad = 4
)
 
n <- list(
  tickfont = list(color = "red"),
  overlaying = "y",
  side = "right",
  title = "Volatile")

fig <- plot_ly(data=WineAcidity, x=density)
fig <- fig %>% add_lines(x = ~WineAcidity$density, y = ~WineAcidity$FixedMean, name = "Fixed", color=I("red"))
fig <- fig %>% add_lines(x = ~WineAcidity$density, y = ~WineAcidity$VolatileMean, name = "Volatile", yaxis ="y2", color=I("purple"))
fig <- fig %>% layout(title = "Acidity",titlefont=list(size=30) ,yaxis2=n, xaxis = list(title="Density"))
fig <- fig %>% layout(yaxis=list(title="Fixed",tickfont=list(color="purple")))
fig <- fig %>% layout(legend = list(x = 0.1, y = 0.95,bgcolor = "#E2E2E2"),margin=m)

fig
