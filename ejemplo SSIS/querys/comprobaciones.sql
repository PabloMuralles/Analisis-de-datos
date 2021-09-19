select *
from Fact.Examen

select *
from Dimension.Candidato

select *
from Admisiones.dbo.Examen

select * 
from Fact.Examen

select *
from FactLog

select *
from staging.Examen

select top 10 C.*,E.*
from Fact.Examen E inner join Dimension.Candidato C on (E.SK_Candidato=C.SK_Candidato)
where C.ID_Candidato = 1217
order by ID_Examen

select *
from Admisiones.dbo.Candidato C inner join Admisiones.dbo.ColegioCandidato CC on  (C.ID_Colegio=CC.ID_Colegio)
where ID_Candidato=1217

update Admisiones.dbo.Candidato
set ID_Colegio=1
Where ID_Candidato=1217

select *
from Dimension.Candidato
Where ID_Candidato=1217

Use Admisiones
go

INSERT INTO Admisiones.dbo.Examen
([ID_Candidato], [ID_Carrera], [ID_Descuento], [FechaPrueba], [Precio], [Nota], [FechaModificacion])
values (1217,1,NULL,GETDATE(),500,90,NULL)

INSERT INTO Admisiones.dbo.Examen_detalle
([ID_Examen], [ID_Materia], [NotaArea])
values(@@IDENTITY,1,90)

select * 
from Admisiones.dbo.Examen
where ID_Candidato=1217