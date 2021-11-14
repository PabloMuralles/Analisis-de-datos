CREATE VIEW VW_ResultadoCandidato
as
select E.ID_Candidato, C.Genero, Co.Nombre as NombreColegio, Ca.Nombre as NombreCarrera, case when E.Nota < 65 then 'R' else 'A' end as Resultado
from Examen E inner join Candidato C on (E.ID_Candidato=C.ID_Candidato)
				inner join ColegioCandidato Co on (C.ID_Colegio=Co.ID_Colegio)
				inner join Carrera Ca on (E.ID_Carrera=Ca.ID_Carrera)