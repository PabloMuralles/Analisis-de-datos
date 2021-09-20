use RepuestosWeb
go
-----------query para llenar la diemnsion partes
select 
	P.ID_Partes,
	L.ID_Linea,
	C.ID_Categoria,
	P.Nombre as NombreParte,
	P.Descripcion as DescripcionParte,
	P.Precio as PrecioParte,
	C.Nombre as NombreCategoria,
	C.Descripcion as DescripcionCategoria,
	L.Nombre as NombreLinea,
	L.Descripcion as DescripcionLinea,
	GETDATE() AS FechaCreacion,
	CAST(SUSER_NAME() AS nvarchar(100)) AS UsuarioCreacion,
	GETDATE() AS FechaModificacion,
	CAST(SUSER_NAME() AS nvarchar(100)) AS UsuarioModificacion
from dbo.Categoria C 
inner join dbo.Partes P on(P.ID_Categoria=C.ID_Categoria)
inner join dbo.Linea L on (L.ID_Linea=C.ID_Linea)
-----------query para llenar la dimension geografia
select 
	P.ID_Pais,
	R.ID_Region,
	C.ID_Ciudad,
	P.Nombre as NombrePais,
	R.Nombre as NombreRegion,
	C.Nombre as NombreCiudad,
	C.CodigoPostal,
	GETDATE() as FechaCreacion,
	CAST(suser_name() as nvarchar(100)) as UsuarioCreacion,
	GETDATE() as FechaModificacion,
	CAST(suser_name() as nvarchar(100)) as UsuarioModificacion
from dbo.Region R
inner join dbo.Pais P on (R.ID_Pais=P.ID_Pais)
inner join dbo.Ciudad C on (R.ID_Region=C.ID_Region)
-----------query para llenar la dimension clientes
select 
	C.ID_Cliente,
	C.PrimerNombre,
	C.SegundoNombre,
	C.PrimerApellidO,
	C.SegundoApellido,
	C.Genero,
	C.Correo_Electronico,
	C.FechaNacimiento,
	GETDATE() as FechaCreacion,
	CAST(SUSER_NAME() as nvarchar(100)) as UsuarioCreacion,
	GETDATE() as FechaModificacion,
	CAST(SUSER_NAME() as nvarchar(100)) as UsuarioModificacion
from dbo.Clientes C