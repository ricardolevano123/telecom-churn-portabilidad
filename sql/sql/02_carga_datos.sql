-- =============================================
-- CARGA DE DATOS - ETL con manejo de excepciones
-- =============================================

-- 1) Carga de dimensiones (ejemplo de inserts base)
INSERT INTO DIM_GEOGRAFIA (distrito, nivel_socioeconomico, densidad_poblacional, calidad_conectividad)
VALUES ('San Juan de Lurigancho', 'C', 'Alta', 'Regular');

INSERT INTO DIM_GEOGRAFIA (distrito, nivel_socioeconomico, densidad_poblacional, calidad_conectividad)
VALUES ('Miraflores', 'A', 'Media', 'Buena');

INSERT INTO DIM_GEOGRAFIA (distrito, nivel_socioeconomico, densidad_poblacional, calidad_conectividad)
VALUES ('Villa El Salvador', 'D', 'Alta', 'Deficiente');

INSERT INTO DIM_PLAN (nombre_plan, tipo_plan, costo_mensual, tiene_promocion)
VALUES ('Plan Basico 20GB', 'Postpago', 49.90, 'N');

INSERT INTO DIM_MOTIVO_FUGA (descripcion, categoria)
VALUES ('Problemas de conectividad', 'Tecnico');

COMMIT;

-- 2) Bloque PL/SQL: carga de clientes con manejo de excepciones
--    Simula la carga masiva del dataset de Kaggle, capturando
--    errores de clave duplicada u otros en LOG_ERRORES_CARGA
--    en lugar de detener todo el proceso.

DECLARE
    v_codigo_cliente VARCHAR2(20);
BEGIN
    FOR i IN 1..10000 LOOP
        BEGIN
            v_codigo_cliente := 'CLI-' || LPAD(i, 6, '0');

            INSERT INTO DIM_CLIENTE (codigo_cliente, edad, genero, id_geografia, fecha_registro)
            VALUES (
                v_codigo_cliente,
                TRUNC(DBMS_RANDOM.VALUE(18, 70)),
                CASE WHEN MOD(i, 2) = 0 THEN 'Femenino' ELSE 'Masculino' END,
                TRUNC(DBMS_RANDOM.VALUE(1, 3)),
                SYSDATE - TRUNC(DBMS_RANDOM.VALUE(30, 1500))
            );

        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                INSERT INTO LOG_ERRORES_CARGA (tabla_afectada, codigo_error, descripcion_error, registro_origen)
                VALUES ('DIM_CLIENTE', 'ORA-00001', 'Codigo de cliente duplicado', v_codigo_cliente);

            WHEN OTHERS THEN
                INSERT INTO LOG_ERRORES_CARGA (tabla_afectada, codigo_error, descripcion_error, registro_origen)
                VALUES ('DIM_CLIENTE', SQLCODE, SQLERRM, v_codigo_cliente);
        END;
    END LOOP;

    COMMIT;
END;
/

-- 3) Verificación rápida de la carga
SELECT COUNT(*) AS total_clientes FROM DIM_CLIENTE;
SELECT COUNT(*) AS errores_registrados FROM LOG_ERRORES_CARGA;
