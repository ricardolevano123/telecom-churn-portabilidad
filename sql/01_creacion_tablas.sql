-- =============================================
-- MODELO ESTRELLA: Churn y Portabilidad Telecom
-- =============================================

-- DIMENSIÓN: Geografía (distritos de Lima)
CREATE TABLE DIM_GEOGRAFIA (
    id_geografia        NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    distrito             VARCHAR2(60) NOT NULL,
    nivel_socioeconomico VARCHAR2(20),        -- A, B, C, D, E
    densidad_poblacional VARCHAR2(20),        -- Alta, Media, Baja
    calidad_conectividad VARCHAR2(20)         -- Buena, Regular, Deficiente
);

-- DIMENSIÓN: Plan contratado
CREATE TABLE DIM_PLAN (
    id_plan          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_plan      VARCHAR2(50) NOT NULL,
    tipo_plan        VARCHAR2(30),            -- Prepago, Postpago
    costo_mensual    NUMBER(8,2),
    tiene_promocion  CHAR(1) DEFAULT 'N'      -- S / N
);

-- DIMENSIÓN: Motivo de fuga (churn)
CREATE TABLE DIM_MOTIVO_FUGA (
    id_motivo        NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    descripcion      VARCHAR2(100) NOT NULL,  -- Conectividad, Precio, Servicio al cliente, etc.
    categoria        VARCHAR2(30)             -- Técnico, Comercial, Competencia
);

-- DIMENSIÓN: Cliente
CREATE TABLE DIM_CLIENTE (
    id_cliente       NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo_cliente   VARCHAR2(20) UNIQUE NOT NULL,
    edad             NUMBER(3),
    genero           VARCHAR2(15),
    id_geografia     NUMBER REFERENCES DIM_GEOGRAFIA(id_geografia),
    fecha_registro   DATE
);

-- HECHOS: Churn y portabilidad
CREATE TABLE FACT_CHURN_PORTABILIDAD (
    id_fact          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_cliente       NUMBER REFERENCES DIM_CLIENTE(id_cliente),
    id_plan          NUMBER REFERENCES DIM_PLAN(id_plan),
    id_geografia     NUMBER REFERENCES DIM_GEOGRAFIA(id_geografia),
    id_motivo        NUMBER REFERENCES DIM_MOTIVO_FUGA(id_motivo),
    fecha_alta       DATE,
    fecha_baja       DATE,
    meses_permanencia NUMBER(4),
    facturacion_mensual NUMBER(10,2),
    fugo              CHAR(1) DEFAULT 'N',    -- S / N
    portado_a_otro_operador CHAR(1) DEFAULT 'N'
);

-- LOG de errores de carga (evidencia de manejo de excepciones en el ETL)
CREATE TABLE LOG_ERRORES_CARGA (
    id_log           NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tabla_afectada   VARCHAR2(50),
    codigo_error     VARCHAR2(20),
    descripcion_error VARCHAR2(4000),
    fecha_error      TIMESTAMP DEFAULT SYSTIMESTAMP,
    registro_origen  VARCHAR2(200)
);
