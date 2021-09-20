use RepuestosWebDWH
go

---creacion de tabla para los logs de los batches del fact
create table Factlog
(
	ID_Batch uniqueidentifier default(newid()),
	FechaEjecucion datetime default(getdate()),
	RegistrosNuevos int,
	constraint PK_Faclog primary key (ID_Batch)
)
go

--agregamos fk al fact
alter table Fact.Orden add constraint FK_IDBatch foreign key (ID_Batch) references Factlog(ID_Batch)

---creacion de staging
create schema staging
go

drop table if exists staging.Orden
go

Create table staging.Orden
(
	ID_Orden int not null,
	ID_Cliente int null,
	ID_Ciudad int null,
	ID_StatusOrden int null,
	Total_Orden decimal(12,2) null,
	Fecha_Orden datetime null,
	Fecha_Modificacion datetime null,
	ID_DetalleOrden int not null,
	ID_Partes int not null,
	Cantidad int null,
	ID_Descuento int null,
	NombreDescuento varchar(200) null,
	PorcentajeDescuento decimal(2,2),
	NombreStatus varchar(100) null
)on [PRIMARY]
go

--select * from staging.Orden