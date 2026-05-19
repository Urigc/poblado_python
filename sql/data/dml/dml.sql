-- ============================================================
-- 3.1 CONSULTAS SELECT (mínimo 10)
-- ============================================================

-- Consulta 1 | JOIN múltiple (3+ tablas)
SELECT
    o.id_obra,
    TRIM(o.nombre_obra)         AS obra,
    TRIM(c.nombre_const)        AS constructora,
    TRIM(p.nombre)              AS supervisor,
    TRIM(p.apellido_paterno)    AS apellido_supervisor
FROM obra o
JOIN constructora c  ON o.id_constructora  = c.id_constructora
JOIN supervisor s    ON o.codigo_supervisor = s.codigo_personal
JOIN personal p      ON s.codigo_personal   = p.codigo_personal
ORDER BY o.fecha_inicio DESC;

-- Consulta 2 | JOIN múltiple (4 tablas) – obras con su proyectista
SELECT
    TRIM(o.nombre_obra)      AS obra,
    TRIM(c.nombre_const)     AS constructora,
    TRIM(per.nombre)         AS proyectista,
    TRIM(per.apellido_paterno) AS apellido,
    TRIM(pro.empresa)        AS empresa_proyectista
FROM obra o
JOIN constructora c       ON o.id_constructora  = c.id_constructora
JOIN proyectista pro      ON pro.id_constructora = c.id_constructora
JOIN personal per         ON pro.codigo_personal = per.codigo_personal
ORDER BY c.nombre_const;

-- Consulta 3 | JOIN múltiple con fuente de financiamiento (5 tablas)
SELECT
    TRIM(o.nombre_obra)      AS obra,
    TRIM(c.nombre_const)     AS constructora,
    TRIM(f.grado_nivel)      AS nivel_fuente,
    TRIM(f.programa)         AS programa_financiamiento,
    TRIM(per.nombre)         AS supervisor,
    TRIM(per.apellido_paterno) AS apellido_sup
FROM obra o
JOIN constructora c          ON o.id_constructora   = c.id_constructora
JOIN financia fi             ON fi.id_obra           = o.id_obra
JOIN fuente_presupuestaria f ON fi.id_fuente         = f.id_fuente
JOIN supervisor s            ON o.codigo_supervisor  = s.codigo_personal
JOIN personal per            ON s.codigo_personal    = per.codigo_personal
ORDER BY f.grado_nivel, o.nombre_obra;

-- Consulta 4 | Subconsulta correlacionada – obras cuyo avance físico supera el promedio de todos los informes
SELECT
    TRIM(o.nombre_obra) AS obra,
    TRIM(c.nombre_const) AS constructora,
    (SELECT AVG(i2.porcentaje_avance_fisico)
     FROM informes i2
     WHERE i2.id_obra = o.id_obra) AS promedio_avance_fisico
FROM obra o
JOIN constructora c ON o.id_constructora = c.id_constructora
WHERE (
    SELECT AVG(i.porcentaje_avance_fisico)
    FROM informes i
    WHERE i.id_obra = o.id_obra
) > (
    SELECT AVG(porcentaje_avance_fisico) FROM informes
)
ORDER BY promedio_avance_fisico DESC;

-- Consulta 5 | Subconsulta correlacionada – supervisores que han supervisado más de una obra
SELECT
    TRIM(p.nombre)           AS nombre,
    TRIM(p.apellido_paterno) AS apellido,
    (SELECT COUNT(*)
     FROM obra o2
     WHERE o2.codigo_supervisor = s.codigo_personal) AS total_obras
FROM supervisor s
JOIN personal p ON s.codigo_personal = p.codigo_personal
WHERE (
    SELECT COUNT(*)
    FROM obra o
    WHERE o.codigo_supervisor = s.codigo_personal
) > 1
ORDER BY total_obras DESC;

-- Consulta 6 | Funciones de agregación con GROUP BY y HAVING – constructoras con más de 1 obra
SELECT
    TRIM(c.nombre_const)  AS constructora,
    TRIM(c.tipo_ejecutor) AS tipo,
    COUNT(o.id_obra)      AS total_obras,
    MIN(o.fecha_inicio)   AS primera_obra,
    MAX(o.fecha_final)    AS ultima_entrega
FROM constructora c
JOIN obra o ON o.id_constructora = c.id_constructora
GROUP BY c.id_constructora, c.nombre_const, c.tipo_ejecutor
HAVING COUNT(o.id_obra) > 1
ORDER BY total_obras DESC;

-- Consulta 7 | Funciones de agregación con HAVING – fuentes que financian más de una obra
SELECT
    TRIM(f.grado_nivel)  AS nivel,
    TRIM(f.programa)     AS programa,
    COUNT(fi.id_obra)    AS obras_financiadas
FROM fuente_presupuestaria f
JOIN financia fi ON fi.id_fuente = f.id_fuente
GROUP BY f.id_fuente, f.grado_nivel, f.programa
HAVING COUNT(fi.id_obra) > 1
ORDER BY obras_financiadas DESC;

-- Consulta 8 | Window function RANK – ranking de supervisores por cantidad de informes emitidos
SELECT
    TRIM(p.nombre)           AS nombre,
    TRIM(p.apellido_paterno) AS apellido,
    COUNT(i.id_informe)      AS total_informes,
    RANK() OVER (ORDER BY COUNT(i.id_informe) DESC) AS ranking
FROM supervisor s
JOIN personal p  ON s.codigo_personal    = p.codigo_personal
JOIN informes i  ON i.codigo_supervisor  = s.codigo_personal
GROUP BY s.codigo_personal, p.nombre, p.apellido_paterno
ORDER BY ranking;

-- Consulta 9 | Window function ROW_NUMBER y PARTITION BY – numerar informes por obra
SELECT
    TRIM(o.nombre_obra)    AS obra,
    i.ano_infor            AS anio,
    TRIM(i.mes)            AS mes,
    i.porcentaje_avance_fisico AS avance_fisico,
    ROW_NUMBER() OVER (
        PARTITION BY i.id_obra
        ORDER BY i.ano_infor, i.mes
    ) AS num_informe_en_obra
FROM informes i
JOIN obra o ON o.id_obra = i.id_obra
ORDER BY o.nombre_obra, num_informe_en_obra;

-- Consulta 10 | Window function – avance acumulado promedio por constructora con PARTITION
SELECT
    TRIM(c.nombre_const)             AS constructora,
    TRIM(o.nombre_obra)              AS obra,
    i.ano_infor                      AS anio,
    i.porcentaje_avance_fisico       AS avance_fisico,
    AVG(i.porcentaje_avance_fisico) OVER (
        PARTITION BY c.id_constructora
        ORDER BY i.ano_infor, i.mes
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS avance_acumulado_prom
FROM informes i
JOIN obra o        ON o.id_obra          = i.id_obra
JOIN constructora c ON c.id_constructora = o.id_constructora
ORDER BY c.nombre_const, i.ano_infor;

-- Consulta 11 | UNION – personal que es supervisor O proyectista
SELECT
    TRIM(p.nombre)           AS nombre,
    TRIM(p.apellido_paterno) AS apellido,
    'Supervisor'             AS rol
FROM personal p
JOIN supervisor s ON s.codigo_personal = p.codigo_personal
UNION
SELECT
    TRIM(p.nombre),
    TRIM(p.apellido_paterno),
    'Proyectista'
FROM personal p
JOIN proyectista pr ON pr.codigo_personal = p.codigo_personal
ORDER BY apellido, nombre;

-- Consulta 12 | INTERSECT – personal que es a la vez supervisor y proyectista
SELECT codigo_personal FROM supervisor
INTERSECT
SELECT codigo_personal FROM proyectista;

-- Consulta 13 | EXCEPT – personal registrado que NO es ni supervisor ni proyectista
SELECT codigo_personal FROM personal
EXCEPT
SELECT codigo_personal FROM supervisor
EXCEPT
SELECT codigo_personal FROM proyectista;

-- Consulta 14 | CTE – obras con su costo total calculado
WITH costos_por_obra AS (
    SELECT
        po.id_obra,
        SUM(co.costo) AS costo_total_registrado
    FROM presupuesto_obra po
    JOIN costos co ON co.id_presupuesto = po.id_presupuesto
    GROUP BY po.id_obra
)
SELECT
    TRIM(o.nombre_obra)         AS obra,
    TRIM(c.nombre_const)        AS constructora,
    cpo.costo_total_registrado,
    po.presupuesto_total,
    (po.presupuesto_total - cpo.costo_total_registrado) AS diferencia
FROM obra o
JOIN constructora c   ON c.id_constructora = o.id_constructora
JOIN presupuesto_obra po ON po.id_obra     = o.id_obra
JOIN costos_por_obra cpo ON cpo.id_obra    = o.id_obra
ORDER BY diferencia;

-- Consulta 15 | CTE encadenada – supervisores y promedio de avance de sus obras
WITH avance_obras AS (
    SELECT
        id_obra,
        AVG(porcentaje_avance_fisico)         AS prom_fisico,
        AVG(porcentaje_avance_presupuestario) AS prom_presup
    FROM informes
    GROUP BY id_obra
),
supervisores_avance AS (
    SELECT
        o.codigo_supervisor,
        AVG(ao.prom_fisico)  AS prom_fisico_sup,
        AVG(ao.prom_presup)  AS prom_presup_sup,
        COUNT(o.id_obra)     AS obras_a_cargo
    FROM obra o
    JOIN avance_obras ao ON ao.id_obra = o.id_obra
    GROUP BY o.codigo_supervisor
)
SELECT
    TRIM(p.nombre)           AS nombre,
    TRIM(p.apellido_paterno) AS apellido,
    sa.obras_a_cargo,
    ROUND(sa.prom_fisico_sup::numeric, 2)  AS promedio_avance_fisico,
    ROUND(sa.prom_presup_sup::numeric, 2)  AS promedio_avance_presupuestario
FROM supervisores_avance sa
JOIN personal p ON p.codigo_personal = sa.codigo_supervisor
ORDER BY promedio_avance_fisico DESC;

-- Consulta 16 | CASE – clasificación de obras según etapa
SELECT
    TRIM(o.nombre_obra) AS obra,
    o.etapa,
    CASE o.etapa
        WHEN 1 THEN 'Planeación'
        WHEN 2 THEN 'Diseño'
        WHEN 3 THEN 'Licitación'
        WHEN 4 THEN 'Construcción'
        WHEN 5 THEN 'Entrega'
        ELSE        'Etapa desconocida'
    END AS descripcion_etapa,
    TRIM(c.nombre_const) AS constructora
FROM obra o
JOIN constructora c ON c.id_constructora = o.id_constructora
ORDER BY o.etapa, o.nombre_obra;

-- Consulta 17 | CASE – semáforo de avance físico en informes
SELECT
    TRIM(o.nombre_obra)            AS obra,
    i.ano_infor                    AS anio,
    TRIM(i.mes)                    AS mes,
    i.porcentaje_avance_fisico     AS avance_fisico,
    CASE
        WHEN i.porcentaje_avance_fisico >= 75 THEN 'Verde  – Avance óptimo'
        WHEN i.porcentaje_avance_fisico >= 50 THEN 'Amarillo – Avance aceptable'
        WHEN i.porcentaje_avance_fisico >= 25 THEN 'Naranja – Avance lento'
        ELSE                                       'Rojo – Avance crítico'
    END AS semaforo
FROM informes i
JOIN obra o ON o.id_obra = i.id_obra
ORDER BY i.porcentaje_avance_fisico DESC;

-- Consulta 18 | Análisis temporal – obras en ejecución en un rango de fechas
SELECT
    TRIM(o.nombre_obra)  AS obra,
    o.fecha_inicio,
    o.fecha_final,
    (o.fecha_final - o.fecha_inicio) AS dias_duracion,
    EXTRACT(YEAR FROM o.fecha_inicio) AS anio_inicio
FROM obra o
WHERE o.fecha_inicio BETWEEN '2020-01-01' AND '2024-12-31'
ORDER BY o.fecha_inicio;

-- Consulta 19 | Análisis temporal – obras que ya pasaron su fecha final pero no tienen informe al 100%
SELECT
    TRIM(o.nombre_obra)  AS obra,
    o.fecha_final,
    MAX(i.porcentaje_avance_fisico) AS maximo_avance_registrado
FROM obra o
JOIN informes i ON i.id_obra = o.id_obra
WHERE o.fecha_final < CURRENT_DATE
GROUP BY o.id_obra, o.nombre_obra, o.fecha_final
HAVING MAX(i.porcentaje_avance_fisico) < 100
ORDER BY o.fecha_final;

-- Consulta 20 | Expresiones regulares – constructoras cuyo nombre empieza con 'C' o contiene 'construccion' (insensible a mayúsculas)
SELECT
    TRIM(id_constructora) AS id,
    TRIM(nombre_const)    AS nombre,
    TRIM(tipo_ejecutor)   AS tipo
FROM constructora
WHERE nombre_const ~* '^C'
   OR nombre_const ~* 'construc'
ORDER BY nombre_const;


-- ============================================================
-- 3.2 OPERACIONES INSERT
-- ============================================================

-- INSERT 1 | INSERT múltiple – nuevas fuentes de financiamiento
INSERT INTO fuente_presupuestaria (id_fuente, grado_nivel, programa)
VALUES
    ('FP-NEW-01', 'Federal',    'Programa Nacional de Infraestructura 2025'),
    ('FP-NEW-02', 'Estatal',    'Fondo Estatal de Desarrollo Urbano'),
    ('FP-NEW-03', 'Municipal',  'Plan Municipal de Obras Comunitarias'),
    ('FP-NEW-04', 'Federal',    'Fondo Metropolitano de Accesibilidad');

-- INSERT 2 | INSERT múltiple – nuevo personal
INSERT INTO personal (codigo_personal, nombre, apellido_paterno, apellido_materno)
VALUES
    ('PER-NEW-001', 'Andrés',    'Ramírez',    'Torres'),
    ('PER-NEW-002', 'Beatriz',   'Hernández',  'Lozano'),
    ('PER-NEW-003', 'Carlos',    'Mendoza',    'Ríos'),
    ('PER-NEW-004', 'Diana',     'Fuentes',    'Vargas');

-- INSERT 3 | INSERT – nuevos supervisores (subclase de personal)
INSERT INTO supervisor (codigo_personal, telefono)
VALUES
    ('PER-NEW-001', '5512345678'),
    ('PER-NEW-002', '5598765432');

-- INSERT 4 | INSERT – nueva constructora
INSERT INTO constructora (id_constructora, rfc, nombre_const, tipo_ejecutor)
VALUES ('CONST-NEW1', 'CONST123456XX', 'Constructora Nueva Visión SA de CV', 'Empresa Privada');

-- INSERT 5 | INSERT – nuevos proyectistas (subclase de personal)
INSERT INTO proyectista (codigo_personal, empresa, id_constructora)
VALUES
    ('PER-NEW-003', 'Diseños Estructurales del Norte SC', 'CONST-NEW1'),
    ('PER-NEW-004', 'Ingeniería y Proyectos Unidos SA',   'CONST-NEW1');

-- INSERT 6 | INSERT con subconsulta – agregar relación de financiamiento para obras que no tienen ninguna fuente federal
INSERT INTO financia (id_obra, id_fuente)
SELECT o.id_obra, 'FP-NEW-01'
FROM obra o
WHERE NOT EXISTS (
    SELECT 1
    FROM financia fi
    JOIN fuente_presupuestaria fp ON fp.id_fuente = fi.id_fuente
    WHERE fi.id_obra = o.id_obra
      AND fp.grado_nivel = 'Federal'
)
LIMIT 3;

-- INSERT 7 | INSERT con valores calculados – nueva obra con fechas calculadas a partir de hoy
INSERT INTO obra (
    id_obra, codigo_expediente, nombre_obra, etapa,
    fecha_inicio, fecha_final, descripcion, beneficiarios,
    id_constructora, id_region, codigo_supervisor
)
SELECT
    'OBRA-NEW-001',
    'EXP-NEW-2025',
    'Pavimentación Avenida Central',
    1,
    CURRENT_DATE,
    CURRENT_DATE + INTERVAL '18 months',
    'Obra de pavimentación y drenaje pluvial en avenida principal',
    'Habitantes de la colonia Centro, aproximadamente 12,000 personas',
    'CONST-NEW1',
    id_region,
    'PER-NEW-001'
FROM region
LIMIT 1;

-- INSERT 8 | INSERT con subconsulta – presupuesto de la nueva obra tomando el promedio de presupuestos existentes
INSERT INTO presupuesto_obra (id_presupuesto, presupuesto_total, id_proyectista, id_obra)
VALUES (
    'PRES-NEW01',
    (SELECT AVG(presupuesto_total) FROM presupuesto_obra),
    'PER-NEW-003',
    'OBRA-NEW-001'
);

-- INSERT 9 | INSERT – informe para la nueva obra
INSERT INTO informes (
    id_informe, ano_infor, mes, porcentaje_avance_fisico,
    porcentaje_avance_presupuestario, doc_infome, descripcion,
    id_obra, codigo_supervisor
)
VALUES (
    'INF-NEW-0001',
    EXTRACT(YEAR FROM CURRENT_DATE)::integer,
    TO_CHAR(CURRENT_DATE, 'Month'),
    10,
    8,
    'informe_enero_2025_obra_new_001.pdf',
    'Inicio de trabajos de trazo y nivelación en tramo norte.',
    'OBRA-NEW-001',
    'PER-NEW-001'
);

-- INSERT 10 | UPSERT (INSERT ON CONFLICT DO UPDATE) – actualizar programa si la fuente ya existe
INSERT INTO fuente_presupuestaria (id_fuente, grado_nivel, programa)
VALUES ('FP-NEW-01', 'Federal', 'Programa Nacional de Infraestructura Actualizado 2026')
ON CONFLICT (id_fuente)
DO UPDATE SET programa = EXCLUDED.programa;


-- ============================================================
-- 3.3 OPERACIONES UPDATE
-- ============================================================

-- UPDATE 1 | UPDATE con JOIN (usando subconsulta correlacionada, compatible PostgreSQL) – actualizar etapa de obras cuya constructora es privada
UPDATE obra
SET etapa = etapa + 1
WHERE id_constructora IN (
    SELECT id_constructora
    FROM constructora
    WHERE tipo_ejecutor ILIKE '%privada%'
)
AND etapa < 5;

-- UPDATE 2 | UPDATE condicional con CASE – recategorizar nivel de fuentes presupuestarias
UPDATE fuente_presupuestaria
SET grado_nivel = CASE
    WHEN grado_nivel ILIKE '%federal%'    THEN 'Federal'
    WHEN grado_nivel ILIKE '%estatal%'    THEN 'Estatal'
    WHEN grado_nivel ILIKE '%municipal%'  THEN 'Municipal'
    ELSE 'Otro'
END;

-- UPDATE 3 | UPDATE condicional con CASE – ajustar avance presupuestario en informes según avance físico
UPDATE informes
SET porcentaje_avance_presupuestario = CASE
    WHEN porcentaje_avance_fisico >= 90 THEN LEAST(porcentaje_avance_presupuestario + 5, 100)
    WHEN porcentaje_avance_fisico >= 50 THEN LEAST(porcentaje_avance_presupuestario + 2, 100)
    ELSE porcentaje_avance_presupuestario
END;

-- UPDATE 4 | UPDATE masivo – normalizar espacios en nombre_const de constructora
UPDATE constructora
SET nombre_const = TRIM(nombre_const);

-- UPDATE 5 | UPDATE masivo – normalizar espacios en nombre de personal
UPDATE personal
SET nombre           = TRIM(nombre),
    apellido_paterno = TRIM(apellido_paterno),
    apellido_materno = TRIM(apellido_materno);

-- UPDATE 6 | UPDATE con subconsulta – actualizar etapa a 5 en obras que ya pasaron su fecha final
UPDATE obra
SET etapa = 5
WHERE id_obra IN (
    SELECT id_obra
    FROM obra
    WHERE fecha_final < CURRENT_DATE
      AND etapa < 5
);

-- UPDATE 7 | UPDATE con subconsulta – corregir teléfono de supervisores que no tienen informes recientes
UPDATE supervisor
SET telefono = CONCAT('55', SUBSTR(telefono, 3))
WHERE codigo_personal IN (
    SELECT s.codigo_personal
    FROM supervisor s
    WHERE NOT EXISTS (
        SELECT 1
        FROM informes i
        WHERE i.codigo_supervisor = s.codigo_personal
          AND i.ano_infor >= EXTRACT(YEAR FROM CURRENT_DATE)::integer - 1
    )
)
AND telefono IS NOT NULL
AND LENGTH(TRIM(telefono)) = 10;

-- UPDATE 8 | UPDATE masivo con JOIN – actualizar descripción de obras que tienen solo una fuente de financiamiento
UPDATE obra
SET descripcion = CONCAT(descripcion, ' [Una sola fuente de financiamiento]')
WHERE id_obra IN (
    SELECT id_obra
    FROM financia
    GROUP BY id_obra
    HAVING COUNT(id_fuente) = 1
);

-- UPDATE 9 | UPDATE con subconsulta – marcar en beneficiarios si la obra ya terminó
UPDATE obra
SET beneficiarios = CONCAT(beneficiarios, ' [OBRA CONCLUIDA]')
WHERE fecha_final < CURRENT_DATE
  AND beneficiarios NOT LIKE '%CONCLUIDA%';

-- UPDATE 10 | UPDATE masivo – normalizar campo mes en informes a formato titulo
UPDATE informes
SET mes = INITCAP(TRIM(mes));


-- ============================================================
-- 3.4 OPERACIONES DELETE
-- ============================================================

-- DELETE 1 | DELETE con subconsulta – eliminar fuentes de financiamiento que no financian ninguna obra
DELETE FROM fuente_presupuestaria
WHERE id_fuente NOT IN (
    SELECT DISTINCT id_fuente FROM financia
);

-- DELETE 2 | DELETE con subconsulta – eliminar informes de obras que ya no existen (huérfanos por si acaso)
DELETE FROM informes
WHERE id_obra NOT IN (
    SELECT id_obra FROM obra
);

-- DELETE 3 | Soft delete (marcado lógico) – agregar columna activo a constructora si no existe y marcar inactivas
ALTER TABLE constructora
    ADD COLUMN IF NOT EXISTS activo BOOLEAN NOT NULL DEFAULT TRUE;

UPDATE constructora
SET activo = FALSE
WHERE id_constructora NOT IN (
    SELECT DISTINCT id_constructora FROM obra
);

-- DELETE 4 | Soft delete – agregar columna activo a fuente_presupuestaria y marcar las que no financian nada
ALTER TABLE fuente_presupuestaria
    ADD COLUMN IF NOT EXISTS activo BOOLEAN NOT NULL DEFAULT TRUE;

UPDATE fuente_presupuestaria
SET activo = FALSE
WHERE id_fuente NOT IN (
    SELECT DISTINCT id_fuente FROM financia
);

-- DELETE 5 | Archivado antes de eliminación – crear tabla de archivo e insertar informes antiguos antes de borrarlos
CREATE TABLE IF NOT EXISTS informes_archivo (
    id_informe                      character(20),
    ano_infor                       integer,
    mes                             character(30),
    porcentaje_avance_fisico        smallint,
    porcentaje_avance_presupuestario smallint,
    doc_infome                      text,
    descripcion                     text,
    id_obra                         character(20),
    codigo_supervisor               character(20),
    fecha_archivado                 timestamp DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO informes_archivo (
    id_informe, ano_infor, mes,
    porcentaje_avance_fisico, porcentaje_avance_presupuestario,
    doc_infome, descripcion, id_obra, codigo_supervisor
)
SELECT
    id_informe, ano_infor, mes,
    porcentaje_avance_fisico, porcentaje_avance_presupuestario,
    doc_infome, descripcion, id_obra, codigo_supervisor
FROM informes
WHERE ano_infor < 2020;

DELETE FROM informes
WHERE ano_infor < 2020;

-- DELETE 6 | DELETE con JOIN (usando subconsulta) – eliminar registros de financia para obras marcadas como concluidas
DELETE FROM financia
WHERE id_obra IN (
    SELECT id_obra
    FROM obra
    WHERE beneficiarios LIKE '%CONCLUIDA%'
      AND fecha_final < CURRENT_DATE - INTERVAL '2 years'
);

-- DELETE 7 | DELETE con subconsulta – eliminar constructoras marcadas como inactivas (soft delete previo)
DELETE FROM constructora
WHERE activo = FALSE
  AND id_constructora NOT IN (
      SELECT DISTINCT id_constructora FROM obra
  );

-- DELETE 8 | Archivado antes de eliminación – respaldar personal sin rol antes de limpiar
CREATE TABLE IF NOT EXISTS personal_archivo (
    codigo_personal  character(20),
    nombre           character(100),
    apellido_paterno character(200),
    apellido_materno character(200),
    fecha_archivado  timestamp DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO personal_archivo (codigo_personal, nombre, apellido_paterno, apellido_materno)
SELECT codigo_personal, nombre, apellido_paterno, apellido_materno
FROM personal
WHERE codigo_personal NOT IN (SELECT codigo_personal FROM supervisor)
  AND codigo_personal NOT IN (SELECT codigo_personal FROM proyectista);

DELETE FROM personal
WHERE codigo_personal NOT IN (SELECT codigo_personal FROM supervisor)
  AND codigo_personal NOT IN (SELECT codigo_personal FROM proyectista);

-- DELETE 9 | Soft delete – agregar columna eliminado a informes y marcar sin borrar
ALTER TABLE informes
    ADD COLUMN IF NOT EXISTS eliminado BOOLEAN NOT NULL DEFAULT FALSE;

UPDATE informes
SET eliminado = TRUE
WHERE porcentaje_avance_fisico = 0
  AND porcentaje_avance_presupuestario = 0
  AND ano_infor < EXTRACT(YEAR FROM CURRENT_DATE)::integer - 3;

-- DELETE 10 | DELETE con subconsulta – limpiar relaciones de financia para fuentes desactivadas
DELETE FROM financia
WHERE id_fuente IN (
    SELECT id_fuente
    FROM fuente_presupuestaria
    WHERE activo = FALSE
);


-- ============================================================
-- 3.5 TRANSACCIONES
-- ============================================================

-- Transacción 1 | BEGIN / COMMIT – inserción segura de nueva constructora y su proyectista
BEGIN;

INSERT INTO constructora (id_constructora, rfc, nombre_const, tipo_ejecutor)
VALUES ('CONST-TX-01', 'TXRFC1234567A', 'Edificaciones del Pacífico SA', 'Empresa Privada');

INSERT INTO personal (codigo_personal, nombre, apellido_paterno, apellido_materno)
VALUES ('PER-TX-0001', 'Fernando', 'Castillo', 'Pérez');

INSERT INTO proyectista (codigo_personal, empresa, id_constructora)
VALUES ('PER-TX-0001', 'Arquitectura y Diseño del Pacífico', 'CONST-TX-01');

COMMIT;

-- Transacción 2 | ROLLBACK – demostración de rollback por error de integridad
BEGIN;

INSERT INTO personal (codigo_personal, nombre, apellido_paterno)
VALUES ('PER-TX-0002', 'Ghost', 'User');

INSERT INTO supervisor (codigo_personal, telefono)
VALUES ('PER-TX-0002', '5500000000');

INSERT INTO obra (
    id_obra, codigo_expediente, nombre_obra, etapa,
    fecha_inicio, fecha_final, descripcion, beneficiarios,
    id_constructora, id_region, codigo_supervisor
)
VALUES (
    'OBRA-TX-001', 'EXP-TX-001', 'Obra de Prueba TX', 3,
    '2023-01-01', '2020-01-01',
    'Esta obra tiene fechas inválidas y fallará el CHECK',
    'Ninguno',
    'CONST-TX-01',
    (SELECT id_region FROM region LIMIT 1),
    'PER-TX-0002'
);

ROLLBACK;

-- Transacción 3 | SAVEPOINTs – inserción de obra con punto de restauración parcial
BEGIN;

INSERT INTO personal (codigo_personal, nombre, apellido_paterno, apellido_materno)
VALUES ('PER-SP-0001', 'Lucia', 'Navarro', 'Ibarra');

INSERT INTO supervisor (codigo_personal, telefono)
VALUES ('PER-SP-0001', '5544332211');

SAVEPOINT sp_supervisor_ok;

INSERT INTO constructora (id_constructora, rfc, nombre_const, tipo_ejecutor)
VALUES ('CONST-SP-01', 'SPRFC9876543B', 'Infraestructura del Centro SA', 'Empresa Pública');

SAVEPOINT sp_constructora_ok;

INSERT INTO obra (
    id_obra, codigo_expediente, nombre_obra, etapa,
    fecha_inicio, fecha_final, descripcion, beneficiarios,
    id_constructora, id_region, codigo_supervisor
)
VALUES (
    'OBRA-SP-001', 'EXP-SP-001', 'Puente Peatonal Colonia Norte', 2,
    CURRENT_DATE, CURRENT_DATE + INTERVAL '12 months',
    'Construcción de puente peatonal con rampas de accesibilidad.',
    '8,500 habitantes de la colonia Norte',
    'CONST-SP-01',
    (SELECT id_region FROM region LIMIT 1),
    'PER-SP-0001'
);

SAVEPOINT sp_obra_ok;

INSERT INTO fuente_presupuestaria (id_fuente, grado_nivel, programa)
VALUES ('FP-SP-001', 'Estatal', 'Programa Estatal de Movilidad Urbana');

INSERT INTO financia (id_obra, id_fuente)
VALUES ('OBRA-SP-001', 'FP-SP-001');

COMMIT;

-- Transacción 4 | Niveles de aislamiento – lectura repetible para consulta de avances
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT
    TRIM(o.nombre_obra)              AS obra,
    AVG(i.porcentaje_avance_fisico)  AS promedio_fisico,
    MAX(i.porcentaje_avance_fisico)  AS maximo_fisico
FROM obra o
JOIN informes i ON i.id_obra = o.id_obra
GROUP BY o.id_obra, o.nombre_obra
ORDER BY promedio_fisico DESC;

COMMIT;

-- Transacción 5 | FOR UPDATE – bloqueo de fila para actualización concurrente segura de etapa de obra
BEGIN;

SELECT id_obra, etapa, nombre_obra
FROM obra
WHERE id_obra = 'OBRA-SP-001'
FOR UPDATE;

UPDATE obra
SET etapa = 3
WHERE id_obra = 'OBRA-SP-001';

COMMIT;

-- Transacción 6 | Control de errores con DO / EXCEPTION (bloque PL/pgSQL)
DO $$
BEGIN
    BEGIN
        INSERT INTO constructora (id_constructora, rfc, nombre_const, tipo_ejecutor)
        VALUES ('CONST-TX-01', 'TXRFC1234567A', 'Edificaciones del Pacífico SA', 'Empresa Privada');
    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE 'La constructora CONST-TX-01 ya existe. Se omite la inserción.';
    END;
END;
$$;

-- Transacción 7 | ROLLBACK a SAVEPOINT – revertir solo parte de una transacción
BEGIN;

INSERT INTO fuente_presupuestaria (id_fuente, grado_nivel, programa)
VALUES ('FP-SAVE-01', 'Federal', 'Fondo de Agua Potable y Saneamiento');

SAVEPOINT sp_fuente_ok;

INSERT INTO fuente_presupuestaria (id_fuente, grado_nivel, programa)
VALUES ('FP-SAVE-01', 'Municipal', 'Duplicado intencional para probar rollback');

ROLLBACK TO SAVEPOINT sp_fuente_ok;

UPDATE fuente_presupuestaria
SET programa = 'Fondo de Agua Potable y Saneamiento – Revisado'
WHERE id_fuente = 'FP-SAVE-01';

COMMIT;

-- Transacción 8 | Transacción completa – alta de obra con informe inicial y fuente de financiamiento
BEGIN;

INSERT INTO personal (codigo_personal, nombre, apellido_paterno, apellido_materno)
VALUES ('PER-FULL-01', 'Marco', 'Juárez', 'Salinas');

INSERT INTO supervisor (codigo_personal, telefono)
VALUES ('PER-FULL-01', '5566778899');

INSERT INTO constructora (id_constructora, rfc, nombre_const, tipo_ejecutor)
VALUES ('CONST-FULL1', 'FULLRFC123456', 'Constructora Integral del Bajío SA', 'Empresa Privada');

INSERT INTO personal (codigo_personal, nombre, apellido_paterno, apellido_materno)
VALUES ('PER-FULL-02', 'Rebeca', 'Soto', 'Guerrero');

INSERT INTO proyectista (codigo_personal, empresa, id_constructora)
VALUES ('PER-FULL-02', 'Proyectos Integrales del Bajío SC', 'CONST-FULL1');

INSERT INTO obra (
    id_obra, codigo_expediente, nombre_obra, etapa,
    fecha_inicio, fecha_final, descripcion, beneficiarios,
    id_constructora, id_region, codigo_supervisor
)
VALUES (
    'OBRA-FULL-01', 'EXP-FULL-001',
    'Red de Drenaje Sanitario Sector Oriente', 1,
    CURRENT_DATE, CURRENT_DATE + INTERVAL '24 months',
    'Instalación de red primaria de drenaje sanitario en el sector oriente de la ciudad.',
    '25,000 habitantes del sector oriente',
    'CONST-FULL1',
    (SELECT id_region FROM region LIMIT 1),
    'PER-FULL-01'
);

INSERT INTO presupuesto_obra (id_presupuesto, presupuesto_total, id_proyectista, id_obra)
VALUES ('PRES-FULL1', 4500000.000, 'PER-FULL-02', 'OBRA-FULL-01');

INSERT INTO fuente_presupuestaria (id_fuente, grado_nivel, programa)
VALUES ('FP-FULL-01', 'Federal', 'Programa de Agua Potable, Drenaje y Saneamiento');

INSERT INTO financia (id_obra, id_fuente)
VALUES ('OBRA-FULL-01', 'FP-FULL-01');

INSERT INTO informes (
    id_informe, ano_infor, mes,
    porcentaje_avance_fisico, porcentaje_avance_presupuestario,
    doc_infome, descripcion, id_obra, codigo_supervisor
)
VALUES (
    'INF-FULL-001',
    EXTRACT(YEAR FROM CURRENT_DATE)::integer,
    TO_CHAR(CURRENT_DATE, 'Month'),
    5, 3,
    'informe_inicial_drenaje_oriente.pdf',
    'Levantamiento topográfico y estudios de suelo completados. Inicio de excavaciones programado.',
    'OBRA-FULL-01',
    'PER-FULL-01'
);

COMMIT;

-- Transacción 9 | SERIALIZABLE – nivel de aislamiento más estricto para reporte de cierre
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT
    TRIM(c.nombre_const)             AS constructora,
    COUNT(DISTINCT o.id_obra)        AS total_obras,
    COUNT(DISTINCT fi.id_fuente)     AS fuentes_distintas,
    AVG(i.porcentaje_avance_fisico)  AS avance_promedio
FROM constructora c
JOIN obra o         ON o.id_constructora  = c.id_constructora
LEFT JOIN financia fi ON fi.id_obra       = o.id_obra
LEFT JOIN informes i  ON i.id_obra        = o.id_obra
GROUP BY c.id_constructora, c.nombre_const
ORDER BY total_obras DESC;

COMMIT;

-- Transacción 10 | Control de errores y rollback – verificación de integridad antes de eliminar fuente
DO $$
DECLARE
    v_count integer;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM financia
    WHERE id_fuente = 'FP-FULL-01';

    IF v_count > 0 THEN
        RAISE NOTICE 'No se puede eliminar FP-FULL-01: tiene % obra(s) asociada(s). Operación cancelada.', v_count;
    ELSE
        DELETE FROM fuente_presupuestaria WHERE id_fuente = 'FP-FULL-01';
        RAISE NOTICE 'Fuente FP-FULL-01 eliminada correctamente.';
    END IF;
END;
$$;