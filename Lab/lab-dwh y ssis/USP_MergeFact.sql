use RepuestosWebDWH
go

--DROP PROCEDURE USP_MergeFact
--GO  
--Script de SP para MERGE
CREATE or ALTER PROCEDURE USP_MergeFact
as
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN
		--generar nuevo gui para la tabla de log, y declaracion de variables de maxima fecha de ejecion con cantidad de registros afectas
		DECLARE @NuevoGUIDInsert UNIQUEIDENTIFIER = NEWID(), @MaxFechaEjecucion DATETIME, @RowsAffected INT
		--print @MaxFechaEjecucion
		--insertar en tabla de log
		INSERT INTO FactLog (ID_Batch, FechaEjecucion, RegistrosNuevos)
		VALUES (@NuevoGUIDInsert,NULL,NULL)
		--merge me ayuda integrar tablas: si vienen cosas del destino que no existen insertarlas, si existen cosas en los dos modificalas y si no esta en fuente pero si en el destino borrarla
		--aca en los hechos lo que mas se espera son inserciones nuevas
		MERGE Fact.Orden AS T
		USING (
			select
				SK_Partes,
				SK_Geografia,
				SK_Clientes,
				DateKey,
				O.ID_Orden,
				O.ID_Descuento,
				O.ID_DetalleOrden,
				O.NombreDescuento,
				O.PorcentajeDescuento,
				O.Total_Orden,
				O.Cantidad,
				O.NombreStatus,
				O.Fecha_Orden,
				O.Fecha_Modificacion,
				getdate() as FechaCreacion,
				'ETL' as UsuarioCreacion, 
				NULL as FechaModificacion, 
				NULL as UsuarioModificacion, 
				@NuevoGUIDINsert as ID_Batch,
				'ssis' as ID_SourceSystem
			from staging.Orden O
			inner join Dimension.Clientes C on (O.ID_Cliente=C.ID_Cliente and O.Fecha_Orden between C.FechaInicioValidez and isnull(C.FechaFinValidez, '9999-12-31'))
			inner join Dimension.Partes P on (O.ID_Partes=P.ID_Partes and O.Fecha_Orden between P.FechaInicioValidez and isnull(P.FechaFinValidez, '9999-12-31'))
			inner join Dimension.Geografia G on (O.ID_Ciudad=G.ID_Ciudad and O.Fecha_Orden between G.FechaInicioValidez and isnull(G.FechaFinValidez, '9999-12-31'))
			left join Dimension.Fecha F on (CAST( (CAST(YEAR(O.Fecha_Orden) AS VARCHAR(4)))+left('0'+CAST(MONTH(O.Fecha_Orden) AS VARCHAR(4)),2)+left('0'+(CAST(DAY(O.Fecha_Orden) AS VARCHAR(4))),2) AS INT)  = F.DateKey)
			--SELECT [SK_Candidato], [SK_Carrera], [DateKey], [ID_Examen], [ID_Descuento], r.Descripcion AS DescripcionDescuento, [PorcentajeDescuento], [Precio], r.Nota as NotaTotal, [NotaArea], [NombreMateria], getdate() as FechaCreacion, 'ETL' as UsuarioCreacion, NULL as FechaModificacion, NULL as UsuarioModificacion, @NuevoGUIDINsert as ID_Batch, 'ssis' as ID_SourceSystem, r.FechaPrueba, r.FechaModificacionSource
			--FROM STAGING.Examen R
			--	INNER JOIN Dimension.Candidato C ON(C.ID_Candidato = R.ID_Candidato and
			--										R.FechaPrueba BETWEEN c.FechaInicioValidez AND ISNULL(c.FechaFinValidez, '9999-12-31')) 
			--	INNER JOIN Dimension.Carrera CA ON(CA.ID_Carrera = R.ID_Carrera and
			--										R.FechaPrueba BETWEEN CA.FechaInicioValidez AND ISNULL(CA.FechaFinValidez, '9999-12-31')) 
			--	LEFT JOIN Dimension.Fecha F ON(CAST( (CAST(YEAR(R.FechaPrueba) AS VARCHAR(4)))+left('0'+CAST(MONTH(R.FechaPrueba) AS VARCHAR(4)),2)+left('0'+(CAST(DAY(R.FechaPrueba) AS VARCHAR(4))),2) AS INT)  = F.DateKey)
				) AS S ON (S.ID_Orden = T.ID_Orden)

		WHEN NOT MATCHED BY TARGET THEN --No existe en Fact
		INSERT (SK_Partes, SK_Geografia, SK_Clientes, DateKey, ID_Orden, ID_Descuento, ID_DetalleOrden, NombreDescuento, PorcentajeDescuento, Total_Orden, Cantidad, NombreStatus, Fecha_Orden, Fecha_Modificacion, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion, ID_Batch, ID_SourceSystem)
		VALUES (S.SK_Partes, S.SK_Geografia, S.SK_Clientes, S.DateKey, S.ID_Orden, S.ID_Descuento, S.ID_DetalleOrden, S.NombreDescuento, S.PorcentajeDescuento, S.Total_Orden, S.Cantidad, S.NombreStatus,S.Fecha_Orden, S.Fecha_Modificacion, S.FechaCreacion, S.UsuarioCreacion,S.FechaModificacion, S.UsuarioModificacion, S.ID_Batch, S.ID_SourceSystem);

		SET @RowsAffected =@@ROWCOUNT

		SELECT @MaxFechaEjecucion=MAX(MaxFechaEjecucion)
		FROM(
			SELECT MAX(Fecha_Orden) as MaxFechaEjecucion
			FROM FACT.Orden
			UNION
			SELECT MAX(Fecha_Modificacion)  as MaxFechaEjecucion
			FROM FACT.Orden
		)AS A

		UPDATE FactLog
		SET RegistrosNuevos=@RowsAffected, FechaEjecucion = @MaxFechaEjecucion
		WHERE ID_Batch = @NuevoGUIDInsert

		COMMIT
	END TRY
	BEGIN CATCH
		SELECT @@ERROR,'Ocurrio el siguiente error: '+ERROR_MESSAGE()
		IF (@@TRANCOUNT>0)
			ROLLBACK;
	END CATCH

END
go

--exec USP_MergeFact
--rollback
