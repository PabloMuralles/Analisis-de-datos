#comandos para installar paquetes y utlizar librerias
install.packages("ggplot2")
install.packages("dplyr")
library(ggplot2)
library(dplyr)
library(DBI)
library(odbc)

#creacion de diferentes objetos
##se le pude asignar tanto con = o con <-
ObjetoCadena<-"Esta es una cadena"
ObjetoEntero<-2
ObjetoVector<-c(1:5)
##exploracion de objetos
###enformacion resumida del objeto
str(ObjetoCadena)
str(ObjetoEntero)
str(ObjetoVector)
###tipo de dato 
typeof(ObjetoVector)
###tipo de clase de donde se instancion
class(ObjetoVector)

##data frames, coleccion de datos
###los tributos son las columnas de nuestra columna de datos:anios
###las observaciones son nuesntros registros;2015-2018
Temperaturas<-data.frame(Anios=c(2015,2016,2017,2018),
                         Invierno=c(5,8,7,10),
                         Primavera=c(10,12,15,13),
                         Verano=c(25,26,29,32),
                         Otoño=c(13,14,12,10))

Temperaturas
Temperaturas$Invierno
##primeras 2
head(Temperaturas,2)
##ultimas 2
tail(Temperaturas,2)


#uso de dplyr
##filtrar informacion, esos caracteres es que toma el input y corre alguna manipulacion de datos
###es como querys en sql
Temperaturas %>% filter(Anios==2018)
Temperaturas %>% slice(1:2)

##ordenar datos
Temperaturas %>% arrange(desc(Invierno)) ##decendente

##group by
TemperaturasRandom <-data.frame(Anios=(sample(c(2015:2018),20,replace = TRUE)),
                                Invierno=rnorm(20,mean=2,sd=1),
                                Primavera=rnorm(20,mean=15,sd=3),
                                Verano=rnorm(20,mean=22,sd=4),
                                Otoño=rnorm(20,mean=10,sd=2))
##output es un data frame nuevo
TemperaturasRandom %>% summarise(TemperaturaPromedio = mean(Invierno))
TemperaturasRandom %>% group_by(Anios) %>% summarise(TemperaturaPromedio = mean(Invierno))
TemperaturasRandom %>% slice(1:5) %>% group_by(Anios) %>% summarise(TemperaturaPromedio = mean(Invierno))

#ggplot

TemperaturasRandomPromedio <- TemperaturasRandom %>% group_by(Anios) %>% summarise(TemperaturaPromedio = mean(Invierno))

ggplot(data=TemperaturasRandomPromedio, aes(x=Anios,y=TemperaturaPromedio))+
    geom_line()+
    geom_text(
      label=TemperaturasRandomPromedio$TemperaturaPromedio,
      nudge_x= 0.25, nudge_y=0.25,
      check_overlap = T
    )
##conexion con db
con <- dbConnect(odbc(),
                 Driver = "SQL Server",
                 Server = "DESKTOP-34T1EIQ",
                 Database = "Admisiones_DWH")

dfsql<-dbGetQuery(con=con,"select e.*, c.NombreFacultad
                          from Fact.Examen E inner join
                          Dimension.Carrera c on (E.sk_carrera=C.sk_carrera)")

Df_ConteoFacultad<- dfsql %>% count(NombreFacultad)

ggplot(Df_ConteoFacultad, aes(x="", y=n, fill=NombreFacultad))+
    geom_bar(stat="identity", width=1)+
    coord_polar("y", start=0)
