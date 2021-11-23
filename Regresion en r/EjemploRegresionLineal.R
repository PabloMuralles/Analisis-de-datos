#ejemplo con cars
head(cars)
data("cars")

##analisis de variables

##scatterplot
scatter.smooth(x=cars$speed, y=cars$dist, main="Dist~Speed") ##crea un graficos de dispercion y dibuja la ecuacion de regresion
#con la grafica podemos analisar si si se adapata al modelo de regresion lineal

#bloxplots
par(mfrow=c(1, 2))  # divide grafico en 2 columnas
boxplot(cars$speed, main="Speed", sub=paste("Outlier rows: ", boxplot.stats(cars$speed)$out))#crea un grafico de la primera mitad de los datos 
boxplot(cars$dist, main="Distance", sub=paste("Outlier rows: ", boxplot.stats(cars$dist)$out)) #crea un grafico de la segunda mitad de los datos
#con estas graficas se puede ver la media y las desviaciones que existen, tambien ver si existen datos afuera de estos rangos de desviacion y si no hay muchos puntitos aguera signfica que se puede usar la variable como de entrada para la regresion
#identifican valos que se salen de la desviacion estadar

#densityplots muestra el comportmaiento de la distribucion probabilistica de las variables
library(e1071)
par(mfrow=c(1, 2))  # divide grafico en 2 columnas
plot(density(cars$speed), main="Density Plot: Speed", ylab="Frequency", sub=paste("Skewness:", round(e1071::skewness(cars$speed), 2)))  # density plot para 'speed'
polygon(density(cars$speed), col="red")
plot(density(cars$dist), main="Density Plot: Distance", ylab="Frequency", sub=paste("Skewness:", round(e1071::skewness(cars$dist), 2)))  # density plot para 'dist'
polygon(density(cars$dist), col="red")
#si las graficas son muy parecidas a las de una distribuicion normal es un visto bueno para poder seguir

#correlacion
cor(cars$speed, cars$dist)  # calcular velocidad y distancia en correlacion
#correlacion de las dos variables entre mas alta mejor es la correlacion 

#modelo de regresion lineal
lmcarros <- lm(dist ~ speed, data=cars)
summary(lmcarros)
##la clasificacion de las estrellas que da r entre mas bajo este en ese ranjo es mas significativa la variable
# si las dos estan en el mismo rango se evalua las demas variables y en la que sea mayor en las demas y mas bajas en pr es la mas significativa

carro<-data.frame(13)
names(carro)[1]<-"speed"

predict(lmcarros,carro)

#Creamos un modelo datos de train y test 80/20
##set.seed(90)  

trainingRowIndex <- sample(1:nrow(cars), 0.8*nrow(cars))  
trainingData <- cars[trainingRowIndex, ]  
testData  <- cars[-trainingRowIndex, ]   

#creamos el modelo lineal
lmMod <- lm(dist ~ modelo, data=trainingData)  
distPred <- predict(lmMod, testData)  # predecimos usanto test data

#Revisamos el modelo creado
summary (lmMod)  # model summary

#cbiend que une los test con los valores predecidos y se calcula el nivel de precision
actuals_preds <- data.frame(cbind(actuals=testData$dist, predicteds=distPred))  # make actuals_predicteds dataframe.
correlation_accuracy <- cor(actuals_preds)
correlation_accuracy
#nos interesan los predecidos y en este caso tuvo un % del 88 

#otras metricas 
#calculamos el MAD,desviacion absoluta media que nos dice cuanto se desviaron 
mad <- mean(abs((actuals_preds$predicteds - actuals_preds$actuals)))  
mad

#ploteamos el modelo con intervalos, esto no lo explico
par(mfrow=c(1, 1)) 

library(ggplot2)
ggplot(cars, aes(x=speed, y=dist)) + 
  geom_point(color='#2980B9', size = 4) + 
  geom_smooth(method=lm, color='#2C3E50')

#vemos las predicciones y sus intervalos
actuals_preds_intervalos <- data.frame(cbind(actuals_preds,predict(lmMod, newdata = testData, interval = 'confidence')))
actuals_preds_intervalos$fit<-NULL
actuals_preds_intervalos

#### Ejemplo de prediccion de stock_index_price

Year <- c(2017,2017,2017,2017,2017,2017,2017,2017,2017,2017,2017,2017,2016,2016,2016,2016,2016,2016,2016,2016,2016,2016,2016,2016)
Month <- c(12, 11,10,9,8,7,6,5,4,3,2,1,12,11,10,9,8,7,6,5,4,3,2,1)
Interest_Rate <- c(2.75,2.5,2.5,2.5,2.5,2.5,2.5,2.25,2.25,2.25,2,2,2,1.75,1.75,1.75,1.75,1.75,1.75,1.75,1.75,1.75,1.75,1.75)
Unemployment_Rate <- c(5.3,5.3,5.3,5.3,5.4,5.6,5.5,5.5,5.5,5.6,5.7,5.9,6,5.9,5.8,6.1,6.2,6.1,6.1,6.1,5.9,6.2,6.2,6.1)
Stock_Index_Price <- c(1464,1394,1357,1293,1256,1254,1234,1195,1159,1167,1130,1075,1047,965,943,958,971,949,884,866,876,822,704,719)        

plot(x=Interest_Rate, y=Stock_Index_Price) #no ayudan a ver si si sigue un comportamiento de regresion lineal
plot(x=Unemployment_Rate, y=Stock_Index_Price) 

model <- lm(Stock_Index_Price ~ Interest_Rate + Unemployment_Rate)#no siempre es necesario un dataframe para el modelo
summary(model)
