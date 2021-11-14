install.packages("ggplot2")
install.packages("dplyr")
library(ggplot2)
library(dplyr)
library(DBI)
library(odbc)
#libreria para read.transactions
install.packages('arules')
library('arules')

#la funcion apriori recibe un tipo de dato transactions
#transaccion@itemInfo devuelve un listado unico de los productos que forman parte de este set de transacciones
#image(transacion) hacer una grafica de las transacciones que se tiene
#resutlados de la fucion apriori
##minlen   y maxlen      de que tamano tiene cada conjunto de reglas minimo y max
#funcion inspect es para ver las reglas de apriori

###########################################
#ejemplo con el data set groceries
data("Groceries")
Groceries
class(Groceries)
Groceries@itemInfo
typeof(Groceries)

###algoritmo apriori
####definiomos las reglas
##soporte bastante bajo crea muchas reglas
rules<-apriori(Groceries, parameter = list(support=0.001, confidence=0.5)) #support y confidence son porcentajes
inspect(rules)

##como quedaron bastantes reglas podemos hacer filtrados para solo traernos las que nos interecen
#extraemos reglas con confianza =0.8 o mas
subrules <- rules[quality(rules)$confidence >0.8]
inspect(subrules)

#vemos solo el top 3 con mayor lift
rules_high_lift <- head(sort(rules, by="lift"),3)
inspect(rules_high_lift)

#se puede jugar con las reglas de soporte y de confianza para tener menos datos o si se tienen mucho con lo que nosotros escogemos
#de confianza se puede hacer distintas filtraciones

image(Groceries) ##dibuga un grafico de las transcacciones en este caso como son muchas se va ver mal
#transformar las transacciones en un data frame
a<-as(subrules,"data.frame")
#libreria para plotear arules
install.packages("arulesViz")
library("arulesViz")

plot(subrules)#hace una grafica de dispercion comparando el soporte vs la confiza, se coloren mas fuerte los que tienen un lift mas alto
#que generalmente son las reglas que mas nos interesan
plot(subrules, engine = "plotly") #plot interactivo

#tablas para visulizar reglas
inspectDT(subrules)
inspectDT(rules_high_lift)

#plot de frafico que simula un mapa conseptual donde muestra las reglas y resaltan las que tiene un lift mas alto y muestra los productos que estan asociados a mas de una regla
plot(rules_high_lift, method = "graph", engine = "htmlwidget")


##################################################################################################################
