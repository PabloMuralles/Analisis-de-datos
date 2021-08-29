USE master
GO


DECLARE @EliminarDB BIT = 1;
--Eliminar BDD si ya existe y si @EliminarDB = 1
if (((select COUNT(1) from sys.databases where name = 'Admisiones_DWH')>0) AND (@EliminarDB = 1))
begin
	EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'Admisiones_DWH'
	
	
	use [master];
	ALTER DATABASE [Admisiones_DWH] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE;
		
	DROP DATABASE [Admisiones_DWH]
	print 'Admisiones_DWH ha sido eliminada'
end


CREATE DATABASE Admisiones_DWH
GO

USE Admisiones_DWH
GO

--crear estos tipos de datos nos ayuda a que si queremos cambiar un tipo de dato por ejemplo un varchar a 1000 solo lo tendriamos que hacer una vez y no ir uno por uno cambiandolo
--Enteros
 --User Defined Type _ Surrogate Key
	--Tipo para SK entero: Surrogate Key -> llave primaria que existe solo en el DH
	-- UDT= user define type
	CREATE TYPE [UDT_SK] FROM INT
	GO

	--Tipo para PK entero
	CREATE TYPE [UDT_PK] FROM INT
	GO

--Cadenas

	--Tipo para cadenas largas
	CREATE TYPE [UDT_VarcharLargo] FROM VARCHAR(600)
	GO

	--Tipo para cadenas medianas
	CREATE TYPE [UDT_VarcharMediano] FROM VARCHAR(300)
	GO

	--Tipo para cadenas cortas
	CREATE TYPE [UDT_VarcharCorto] FROM VARCHAR(100)
	GO

	--Tipo para cadenas cortas
	CREATE TYPE [UDT_UnCaracter] FROM CHAR(1)
	GO

--Decimal

	--Tipo Decimal 6,2
	-- 6 digitos del lado izquierdo del punto y dos del lado derecho
	CREATE TYPE [UDT_Decimal6.2] FROM DECIMAL(6,2)
	GO

	--Tipo Decimal 5,2
	CREATE TYPE [UDT_Decimal5.2] FROM DECIMAL(5,2)
	GO

--Fechas
	CREATE TYPE [UDT_DateTime] FROM DATETIME
	GO

--Schemas para separar objetos
--un esquema es una colecci�n de objetos sirve para facilitar la administracion de los objetos
	CREATE SCHEMA Fact
	GO

	CREATE SCHEMA Dimension
	GO

--------------------------------------------------------------------------------------------
-------------------------------MODELADO CONCEPTUAL------------------------------------------
--------------------------------------------------------------------------------------------
--Donde se define cuales son las dimenciones y cual va ser la tabla de hechos
--tambien se define si se utiliza el modelo copo de nieve o estrella
--estrella: las dimensiones carecen de jerarqu�as
--copo de nieve: las dimensiones tiene jerarqu�as
--Tablas Dimensiones
	--esta dimension siempre debe ir nunca va existir un modelo sin fecha
	CREATE TABLE Dimension.Fecha
	(
		DateKey INT PRIMARY KEY
	)
	GO
	-- union entre facultas y carrera
	CREATE TABLE Dimension.Carrera
	(
		SK_Carrera [UDT_SK] PRIMARY KEY IDENTITY
	)
	GO
	--union entre diversificado, candidadto y colegio candidato
	CREATE TABLE Dimension.Candidato
	(
		SK_Candidato [UDT_SK] PRIMARY KEY IDENTITY
	)
	GO

--Tablas Fact
	--examen se une con examen detalle, descuento y materia
	-- no es necesario poner las referencias ya que como la data entra al distema en bases de datos relacionales ellas se encargan de la integridad de la informacion
	--pero si no me afecta en nada ponerlas porque no ponerlas y esto tambien puede ayudar en el caso de que como la data viene de muchas bases de datos 
	--las otras bases de datos no esten bien hechas y con estas referencias poder captar esos errores y no tener datos sucios
	CREATE TABLE Fact.Examen
	(
		SK_Examen [UDT_SK] PRIMARY KEY IDENTITY,
		SK_Candidato [UDT_SK] REFERENCES Dimension.Candidato(SK_Candidato),
		SK_Carrera [UDT_SK] REFERENCES Dimension.Carrera(SK_Carrera),
		DateKey INT REFERENCES Dimension.Fecha(DateKey)
	)

--Metadata
--definicion datos de los datos
--sirve cuando las tablas no tienen nombres tan significativos o tambien para cuando no se sabe para que se usa una columna de una tabla
-- no es necesario pero son mejores practicas

	EXEC sys.sp_addextendedproperty 
     @name = N'Desnormalizacion', 
     @value = N'La dimension candidato provee una vista desnormalizada de las tablas origen Candidato, Diversificado y Colegio, dejando todo en una �nica dimensi�n para un modelo estrella', 
     @level0type = N'SCHEMA', 
     @level0name = N'Dimension', 
     @level1type = N'TABLE', 
     @level1name = N'Candidato';
	GO

	EXEC sys.sp_addextendedproperty 
     @name = N'Desnormalizacion', 
     @value = N'La dimension carrera provee una vista desnormalizada de las tablas origen Facultad y Carrera en una sola dimensi�n para un modelo estrella', 
     @level0type = N'SCHEMA', 
     @level0name = N'Dimension', 
     @level1type = N'TABLE', 
     @level1name = N'Carrera';
	GO

	EXEC sys.sp_addextendedproperty 
     @name = N'Desnormalizacion', 
     @value = N'La dimension fecha es generada de forma automatica y no tiene datos origen, se puede regenerar enviando un rango de fechas al stored procedure USP_FillDimDate', 
     @level0type = N'SCHEMA', 
     @level0name = N'Dimension', 
     @level1type = N'TABLE', 
     @level1name = N'Fecha';
	GO

	EXEC sys.sp_addextendedproperty 
     @name = N'Desnormalizacion', 
     @value = N'La tabla de hechos es una union proveniente de las tablas de Examen, Examen Detalle, Descuento y Materia', 
     @level0type = N'SCHEMA', 
     @level0name = N'Fact', 
     @level1type = N'TABLE', 
     @level1name = N'Examen';
	GO

--------------------------------------------------------------------------------------------
---------------------------------MODELADO LOGICO--------------------------------------------
--------------------------------------------------------------------------------------------
--Transformaci�n en modelo l�gico (mas detalles)
--complementar el dise�o que se empezo a crear, asignando los demas atributos y columnas que vienen de la base de datos relasional
--se elige que trabutos se van a traer puede ser que existan atributos que no sirvan entonces no se traen por ejemplo columnas de cuando se creo el registro

	--Fact
	ALTER TABLE Fact.Examen ADD ID_Examen [UDT_PK]
	ALTER TABLE Fact.Examen ADD ID_Descuento [UDT_PK]	
	ALTER TABLE Fact.Examen ADD DescripcionDescuento [UDT_VarcharMediano]
	ALTER TABLE Fact.Examen ADD PorcentajeDescuento [UDT_Decimal6.2]
	ALTER TABLE Fact.Examen ADD Precio [UDT_Decimal6.2]
	ALTER TABLE Fact.Examen ADD NotaTotal [UDT_Decimal5.2]
	ALTER TABLE Fact.Examen ADD NotaArea [UDT_Decimal5.2]
	ALTER TABLE Fact.Examen ADD NombreMateria [UDT_VarcharMediano]

	--DimFecha	
	ALTER TABLE Dimension.Fecha ADD [Date] DATE NOT NULL
    ALTER TABLE Dimension.Fecha ADD [Day] TINYINT NOT NULL
	ALTER TABLE Dimension.Fecha ADD [DaySuffix] CHAR(2) NOT NULL
	ALTER TABLE Dimension.Fecha ADD [Weekday] TINYINT NOT NULL
	ALTER TABLE Dimension.Fecha ADD [WeekDayName] VARCHAR(10) NOT NULL
	ALTER TABLE Dimension.Fecha ADD [WeekDayName_Short] CHAR(3) NOT NULL
	ALTER TABLE Dimension.Fecha ADD [WeekDayName_FirstLetter] CHAR(1) NOT NULL
	ALTER TABLE Dimension.Fecha ADD [DOWInMonth] TINYINT NOT NULL
	ALTER TABLE Dimension.Fecha ADD [DayOfYear] SMALLINT NOT NULL
	ALTER TABLE Dimension.Fecha ADD [WeekOfMonth] TINYINT NOT NULL
	ALTER TABLE Dimension.Fecha ADD [WeekOfYear] TINYINT NOT NULL
	ALTER TABLE Dimension.Fecha ADD [Month] TINYINT NOT NULL
	ALTER TABLE Dimension.Fecha ADD [MonthName] VARCHAR(10) NOT NULL
	ALTER TABLE Dimension.Fecha ADD [MonthName_Short] CHAR(3) NOT NULL
	ALTER TABLE Dimension.Fecha ADD [MonthName_FirstLetter] CHAR(1) NOT NULL
	ALTER TABLE Dimension.Fecha ADD [Quarter] TINYINT NOT NULL
	ALTER TABLE Dimension.Fecha ADD [QuarterName] VARCHAR(6) NOT NULL
	ALTER TABLE Dimension.Fecha ADD [Year] INT NOT NULL
	ALTER TABLE Dimension.Fecha ADD [MMYYYY] CHAR(6) NOT NULL
	ALTER TABLE Dimension.Fecha ADD [MonthYear] CHAR(7) NOT NULL
    ALTER TABLE Dimension.Fecha ADD IsWeekend BIT NOT NULL
  
	--DimCarrera
	ALTER TABLE Dimension.Carrera ADD ID_Carrera [UDT_PK]
	ALTER TABLE Dimension.Carrera ADD ID_Facultad [UDT_PK]
	ALTER TABLE Dimension.Carrera ADD NombreCarrera [UDT_VarcharMediano]
	ALTER TABLE Dimension.Carrera ADD NombreFacultad [UDT_VarcharMediano]
	
	--DimCandidato
	ALTER TABLE Dimension.Candidato ADD ID_Candidato [UDT_PK]
	ALTER TABLE Dimension.Candidato ADD ID_Colegio [UDT_PK]
	ALTER TABLE Dimension.Candidato ADD ID_Diversificado [UDT_PK]
	ALTER TABLE Dimension.Candidato ADD NombreCandidato [UDT_VarcharCorto]
	ALTER TABLE Dimension.Candidato ADD ApellidoCandidato [UDT_VarcharCorto]
	ALTER TABLE Dimension.Candidato ADD Genero [UDT_UnCaracter]
	ALTER TABLE Dimension.Candidato ADD FechaNacimiento [UDT_DateTime]
	ALTER TABLE Dimension.Candidato ADD NombreColegio [UDT_Varcharlargo]
	ALTER TABLE Dimension.Candidato ADD NombreDiversificado [UDT_Varcharlargo]



--Indices Columnares
--indices columnares hacen mas eficientes las funciones de agregacion
--este indice va ayudar para poder hacer el cubo posteriormente ya que el cubo hace un presosamiento de la informacion
	CREATE NONCLUSTERED COLUMNSTORE INDEX [NCCS-Precio] ON [Fact].[Examen]
	(
	   [Precio],
	   [NotaTotal]
	)WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0)
	GO

--Queries para llenar datos

--Dimensiones

	--DimCarrera
	INSERT INTO Dimension.Carrera
	(ID_Carrera, 
	 ID_Facultad, 
	 NombreCarrera, 
	 NombreFacultad
	)
	SELECT C.ID_Carrera, 
			F.ID_Facultad, 
			C.Nombre, 
			F.Nombre
	FROM Admisiones.dbo.Facultad F
		INNER JOIN Admisiones.dbo.Carrera C ON(C.ID_Facultad = F.ID_Facultad);
	
	SELECT * FROM Dimension.Carrera

	--DimCandidato
	INSERT INTO Dimension.Candidato
	([ID_Candidato], 
	 [ID_Colegio], 
	 [ID_Diversificado], 
	 [NombreCandidato], 
	 [ApellidoCandidato], 
	 [Genero], 
	 [FechaNacimiento], 
	 [NombreColegio], 
	 [NombreDiversificado]
	)
	SELECT C.ID_Candidato, 
			CC.ID_Colegio, 
			D.ID_Diversificado, 
			C.Nombre as NombreCandidato, 
			C.Apellido as ApellidoCandidato, 
			C.Genero, 
			C.FechaNacimiento, 
			CC.Nombre as NombreColegio, 
			D.Nombre as NombreDiversificado
	FROM Admisiones.DBO.Candidato C
		INNER JOIN Admisiones.DBO.ColegioCandidato CC ON(C.ID_Colegio = CC.ID_Colegio)
		INNER JOIN Admisiones.DBO.Diversificado D ON(C.ID_Diversificado = D.ID_Diversificado);

		SELECT * FROM Dimension.Candidato

--------------------------------------------------------------------------------------------
-----------------------CORRER CREATE de USP_FillDimDate PRIMERO!!!--------------------------
--------------------------------------------------------------------------------------------
--ctr + shift + r para refrescar los cambias ya creados como para poder ver el procedimiento creado 
	DECLARE @FechaMaxima DATETIME=DATEADD(YEAR,2,GETDATE())
	--Fecha
	IF ISNULL((SELECT MAX(Date) FROM Dimension.Fecha),'1900-01-01')<@FechaMaxima
	begin
		EXEC USP_FillDimDate @CurrentDate = '2016-01-01', 
							 @EndDate     = @FechaMaxima
	end
	SELECT * FROM Dimension.Fecha
	
	--Fact
	INSERT INTO [Fact].[Examen]
	([SK_Candidato], 
	 [SK_Carrera], 
	 [DateKey], 
	 [ID_Examen], 
	 [ID_Descuento], 	
	 [DescripcionDescuento], 
	 [PorcentajeDescuento], 
	 [Precio], 
	 [NotaTotal], 
	 [NotaArea], 
	 [NombreMateria]
	)
	SELECT  --Columnas de mis dimensiones en DWH
			SK_Candidato, 
			SK_Carrera, 
			F.DateKey, 
			R.ID_Examen, 
			R.ID_Descuento, 			
			D.Descripcion, 
			D.PorcentajeDescuento, 
			R.Precio, 
			R.Nota,
			RR.NotaArea, 
			EA.NombreMateria
				 
	FROM Admisiones.DBO.Examen R
		INNER JOIN Admisiones.DBO.Examen_Detalle RR ON(R.ID_Examen = RR.ID_Examen)
		INNER JOIN Admisiones.DBO.Materia EA ON(EA.ID_Materia = RR.ID_Materia)
		INNER JOIN Admisiones.DBO.Descuento D ON(D.ID_Descuento = R.ID_Descuento)
		--Referencias a DWH
		INNER JOIN Dimension.Candidato C ON(C.ID_Candidato = R.ID_Candidato)
		INNER JOIN Dimension.Carrera CA ON(CA.ID_Carrera = R.ID_Carrera)
		INNER JOIN Dimension.Fecha F ON(CAST((CAST(YEAR(R.FechaPrueba) AS VARCHAR(4)))+left('0'+CAST(MONTH(R.FechaPrueba) AS VARCHAR(4)),2)+left('0'+(CAST(DAY(R.FechaPrueba) AS VARCHAR(4))),2) AS INT)  = F.DateKey);


--------------------------------------------------------------------------------------------
------------------------------------Resultado Final-----------------------------------------
--------------------------------------------------------------------------------------------	

	SELECT *
	FROM	Fact.Examen AS E INNER JOIN
			Dimension.Candidato AS C ON E.SK_Candidato = C.SK_Candidato INNER JOIN
			Dimension.Carrera AS CA ON E.SK_Carrera = CA.SK_Carrera INNER JOIN
			Dimension.Fecha AS F ON E.DateKey = F.DateKey