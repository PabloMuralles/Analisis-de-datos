#librerias
library(ggplot2)
library(dplyr)
library(DBI)
library(odbc)
#a
con <- dbConnect(odbc(),
                 Driver = "SQL Server",
                 Server = "DESKTOP-34T1EIQ",
                 Database = "Admisiones_DWH")
#b
dfsql<-dbGetQuery(con=con, "select e.*, c.NombreFacultad, CA.Genero, C.NombreCarrera, F.Year
                            from Fact.Examen E inner join
                            Dimension.Carrera C on (E.sk_Carrera=C.sk_Carrera)
                            inner join Dimension.Candidato CA on (E.sk_candidato=CA.sk_Candidato)
                            inner join Dimension.Fecha F on (E.DateKey=F.DateKey)")

##1
Df_CantidadFacultad<-dfsql %>% count(NombreFacultad)
##2
Df_CantidadGenero<-dfsql %>% count(Genero)
##3
Df_PrecioCarrera<- dfsql %>% group_by(NombreCarrera) %>% summarise(Ingresos=sum(Precio))
##4
Df_PromedioNota<- dfsql %>% arrange(NotaTotal) %>% group_by(NombreFacultad) %>% summarise(NotaTotal=mean(NotaTotal))

Df_PromedioNota<- tail(Df_PromedioNota,3)

#c
##1
ggplot(Df_CantidadFacultad, aes(x="", y=n, fill=NombreFacultad))+
  geom_bar(stat="identity", width=1)+
  coord_polar("y", start=0)
##2
Df_PromedioNota2<- dfsql %>% group_by(NombreCarrera) %>% summarise(Promedio=mean(NotaTotal))

ggplot(Df_PromedioNota2, aes(x=NombreCarrera, y=Promedio)) +
  geom_bar(stat="identity") +
  coord_flip()


##3
Df_CantidadFacultadAno<-dfsql %>% count(Year)
names(Df_CantidadFacultadAno)[2]<- "Total"
##Df_CantidadFacultadAno2<-dfsql %>% group_by(Year) %>% count(NombreFacultad)

ggplot(data=Df_CantidadFacultadAno, aes(x=Year, y=Total, group=1)) +
  geom_line()+
  geom_point()
  



