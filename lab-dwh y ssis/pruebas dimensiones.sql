select * 
from Dimension.Clientes

select *
from Dimension.Geografia

select * 
from Dimension.Partes

select *
from Dimension.Fecha

select *
from Fact.Orden

select *
from Factlog

select *
from staging.Orden

select 
	O.ID_Orden,
	C.ID_Cliente,
	O.ID_Ciudad,
	O.ID_StatusOrden,
	O.Total_Orden,
	O.Fecha_Orden,
	O.Fecha_Modificacion,
	DO.ID_DetalleOrden,
	DO.ID_Partes,
	DO.Cantidad,
	D.ID_Descuento,
	D.NombreDescuento,
	D.PorcentajeDescuento,
	S.NombreStatus
from dbo.Orden O
inner join dbo.Detalle_orden DO on (O.ID_Orden=DO.ID_Orden)
inner join dbo.Descuento D on (DO.ID_Descuento=D.ID_Descuento)
inner join dbo.StatusOrden S on (O.ID_StatusOrden=S.ID_StatusOrden)
inner join dbo.Clientes C on (O.ID_Cliente = C.ID_Cliente)
where ((Fecha_Orden>1900-01-01) or (Fecha_Modificacion>1900-01-01))

truncate table staging.Orden

SELECT ISNULL(MAX(FechaEjecucion),'1900-01-01') AS UltimaFecha
FROM FactLog
 