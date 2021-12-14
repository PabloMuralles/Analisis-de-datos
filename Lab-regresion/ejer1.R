install.packages("ggiraphExtra")
install.packages("ggiraph")
install.packages("ggplot2")
library(odbc)
library(dplyr)
library(ggplot2)
library(ggiraph)
library(ggiraphExtra)

con <- dbConnect(odbc(),
                 Driver = "SQL Server",
                 Server = "DESKTOP-34T1EIQ",
                 Database = "RepuestosWeb",
                 timeout = Inf)

dfsql<-dbGetQuery(con=con, "select * from  V_CantidadPorVehiculoyDescuento")
#limpiar data
dfsql <- na.omit(dfsql)

dfModify<- transform(dfsql,Marca=as.numeric(as.factor(Marca)))
dfModify<- transform(dfModify,Modelo=as.numeric(as.factor(Modelo)))
dfModify<- transform(dfModify,NombreParte=as.numeric(as.factor(NombreParte)))
dfModify<- transform(dfModify,NombreDescuento=as.numeric(as.factor(NombreDescuento)))
dfModify<- transform(dfModify,Anio=as.numeric(as.factor(Anio)))

##summarise_all(dfsql, funs(sum(is.na(.))))


#Creamos un modelo datos de train y test 80/20
##set.seed(90)  

trainingRowIndex <- sample(1:nrow(dfModify), 0.8*nrow(dfModify))  
trainingData <- dfModify[trainingRowIndex, ]  
testData  <- dfModify[-trainingRowIndex, ]  

###################################################################################################
#creamos el modelo lineal de las caracteristicas
lmCaracteristicasCarro <- lm(Cantidad ~ Marca + Modelo + Anio, data=trainingData)  
summary (lmCaracteristicasCarro) 
distPred1 <- predict(lmCaracteristicasCarro, testData)  # predecimos usanto test data

##graficas
##ggPredict(lmCaracteristicasCarro,interactive = TRUE)

##ggPredict(lmCaracteristicasCarro,se=TRUE,interactive=TRUE)
##scatterplot
scatter.smooth(x=dfModify$Cantidad, y=dfModify$Marca+dfModify$Modelo+dfModify$Anio, main="Cantidad~Marca+Modelo+Anio")

boxplot(dfModify$Cantidad, main="Cantidad", sub=paste("Outlier rows: ", boxplot.stats(dfModify$Cantidad)$out))
boxplot(dfModify$Marca, main="Marca", sub=paste("Outlier rows: ", boxplot.stats(dfModify$Marca)$out))
boxplot(dfModify$Modelo, main="Modelo", sub=paste("Outlier rows: ", boxplot.stats(dfModify$Modelo)$out))
boxplot(dfModify$Anio, main="Año", sub=paste("Outlier rows: ", boxplot.stats(dfModify$Anio)$out))
###################################################################################################
#lmPartes
#creamos el modelo lineal de los descuentos
lmNombreParte <- lm(Cantidad ~ NombreParte, data=trainingData)  
summary (lmNombreParte) 
distPred2 <- predict(lmNombreParte, testData)  # predecimos usanto test data

##graficas
##ggPredict(lmNombreParte,interactive = TRUE)

##ggPredict(lmNombreParte,se=TRUE,interactive=TRUE)
##scatterplot
scatter.smooth(x=dfModify$Cantidad, y=dfModify$NombreParte, main="Cantidad~NombreParte")
boxplot(dfModify$NombreParte, main="Nombre Parte", sub=paste("Outlier rows: ", boxplot.stats(dfModify$NombreParte)$out))
###################################################################################################
##lmDescuento
lmDescuento <- lm(Cantidad ~ NombreDescuento, data=trainingData)  
summary (lmDescuento) 
distPred3 <- predict(lmDescuento, testData)  # predecimos usanto test data

##graficas
##ggPredict(lmNombreParte,interactive = TRUE)

##ggPredict(lmNombreParte,se=TRUE,interactive=TRUE)
##scatterplot
scatter.smooth(x=dfModify$Cantidad, y=dfModify$NombreDescuento, main="Cantidad~NombreDescuento")
boxplot(dfModify$NombreDescuento, main="Nombre Descuento", sub=paste("Outlier rows: ", boxplot.stats(dfModify$NombreDescuento)$out))

