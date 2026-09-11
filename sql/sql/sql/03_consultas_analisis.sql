-- =============================================
-- CONSULTAS DE ANÁLISIS
-- 5 preguntas de negocio sobre churn y portabilidad
-- Ajustado al esquema real: CHURN_FLAG (0/1),
-- MONTO_FACTURADO, ANTIGUEDAD_MESES en DIM_CLIENTE
-- =============================================

-- ---------------------------------------------
-- 1) Tasa de churn por distrito
-- ---------------------------------------------
SELECT
    g.DISTRITO,
    COUNT(*)                                    AS total_clientes,
    SUM(f.CHURN_FLAG)                           AS clientes_fugados,
    ROUND(SUM(f.CHURN_FLAG) / COUNT(*) * 100, 2) AS tasa_churn_pct
FROM FACT_CHURN_PORTABILIDAD f
JOIN DIM_GEOGRAFIA g ON f.GEOGRAFIA_ID = g.GEOGRAFIA_ID
GROUP BY g.DISTRITO
ORDER BY tasa_churn_pct DESC;


-- ---------------------------------------------
-- 2) Factores de riesgo de fuga: tecnología de red + tipo de plan
--    (RECLAMOS_SOPORTE se descarta: viene vacío en toda la tabla)
-- ---------------------------------------------
SELECT
    g.DISTRITO,
    p.TECNOLOGIA,
    p.TIPO_PLAN,
    COUNT(*)                                    AS total_clientes,
    SUM(f.CHURN_FLAG)                           AS clientes_fugados,
    ROUND(SUM(f.CHURN_FLAG) / COUNT(*) * 100, 2) AS tasa_churn_pct
FROM FACT_CHURN_PORTABILIDAD f
JOIN DIM_GEOGRAFIA g ON f.GEOGRAFIA_ID = g.GEOGRAFIA_ID
JOIN DIM_PLAN p       ON f.PLAN_ID = p.PLAN_ID
GROUP BY g.DISTRITO, p.TECNOLOGIA, p.TIPO_PLAN
ORDER BY tasa_churn_pct DESC;


-- ---------------------------------------------
-- 3) Valor del cliente (facturación) por distrito vs. churn
-- ---------------------------------------------
SELECT
    g.DISTRITO,
    ROUND(AVG(f.MONTO_FACTURADO), 2)                                          AS facturacion_promedio,
    ROUND(AVG(CASE WHEN f.CHURN_FLAG = 1 THEN f.MONTO_FACTURADO END), 2)      AS facturacion_prom_fugados,
    ROUND(AVG(CASE WHEN f.CHURN_FLAG = 0 THEN f.MONTO_FACTURADO END), 2)      AS facturacion_prom_activos
FROM FACT_CHURN_PORTABILIDAD f
JOIN DIM_GEOGRAFIA g ON f.GEOGRAFIA_ID = g.GEOGRAFIA_ID
GROUP BY g.DISTRITO
ORDER BY facturacion_promedio DESC;


-- ---------------------------------------------
-- 4) Permanencia promedio (meses) antes de la fuga, por distrito
--    (ANTIGUEDAD_MESES vive en DIM_CLIENTE, se une por CLIENTE_ID)
-- ---------------------------------------------
SELECT
    g.DISTRITO,
    ROUND(AVG(c.ANTIGUEDAD_MESES), 1) AS permanencia_promedio_meses,
    COUNT(*)                          AS total_fugados
FROM FACT_CHURN_PORTABILIDAD f
JOIN DIM_GEOGRAFIA g ON f.GEOGRAFIA_ID = g.GEOGRAFIA_ID
JOIN DIM_CLIENTE c   ON f.CLIENTE_ID = c.CLIENTE_ID
WHERE f.CHURN_FLAG = 1
GROUP BY g.DISTRITO
ORDER BY permanencia_promedio_meses ASC;


-- ---------------------------------------------
-- 5) Top 3 distritos por volumen de clientes vs. top 3 por riesgo de fuga
-- ---------------------------------------------

-- Top 3 por volumen de clientes
SELECT DISTRITO, total_clientes
FROM (
    SELECT
        g.DISTRITO,
        COUNT(*) AS total_clientes
    FROM FACT_CHURN_PORTABILIDAD f
    JOIN DIM_GEOGRAFIA g ON f.GEOGRAFIA_ID = g.GEOGRAFIA_ID
    GROUP BY g.DISTRITO
    ORDER BY total_clientes DESC
)
WHERE ROWNUM <= 3;

-- Top 3 por riesgo de fuga (tasa de churn)
SELECT DISTRITO, tasa_churn_pct
FROM (
    SELECT
        g.DISTRITO,
        ROUND(SUM(f.CHURN_FLAG) / COUNT(*) * 100, 2) AS tasa_churn_pct
    FROM FACT_CHURN_PORTABILIDAD f
    JOIN DIM_GEOGRAFIA g ON f.GEOGRAFIA_ID = g.GEOGRAFIA_ID
    GROUP BY g.DISTRITO
    ORDER BY tasa_churn_pct DESC
)
WHERE ROWNUM <= 3;


-- ---------------------------------------------
-- BONUS: Motivos de fuga más frecuentes (aprovecha DIM_MOTIVO_FUGA)
-- ---------------------------------------------
SELECT
    m.DESCRIPCION_MOTIVO,
    COUNT(*) AS total_casos
FROM FACT_CHURN_PORTABILIDAD f
JOIN DIM_MOTIVO_FUGA m ON f.MOTIVO_ID = m.MOTIVO_ID
WHERE f.CHURN_FLAG = 1
GROUP BY m.DESCRIPCION_MOTIVO
ORDER BY total_casos DESC;
