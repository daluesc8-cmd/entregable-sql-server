-- Motor utilizado: SQL Server
-- Base de datos: Ventas_Tech_DB
-- Entregable M4: Consultas SQL de negocio
-- Título: Extrayendo métricas clave con SQL

USE Ventas_Tech_DB;
GO

/* =========================================================
   CONSULTA 1 - RESUMEN EJECUTIVO MENSUAL
   ========================================================= */
SELECT
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;
GO

/* =========================================================
   CONSULTA 2 - RANKING DE PRODUCTOS (TOP 5)
   ========================================================= */
SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_generado
FROM ventas
GROUP BY id_producto
ORDER BY total_generado DESC;
GO

/* =========================================================
   CONSULTA 3 - CLIENTES RECURRENTES
   ========================================================= */
SELECT
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY cantidad_pedidos DESC, total_gastado DESC;
GO

/* =========================================================
   CONSULTA 4 - PRODUCTOS POR ENCIMA / POR DEBAJO DEL PROMEDIO
   El promedio se calcula sobre los totales por producto,
   no sobre las filas individuales de ventas.
   ========================================================= */
WITH FacturacionPorProducto AS (
    SELECT
        id_producto,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY id_producto
)
SELECT
    id_producto,
    total_facturado,
    CASE
        WHEN total_facturado > (
            SELECT AVG(total_facturado)
            FROM FacturacionPorProducto
        ) THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparacion_con_promedio
FROM FacturacionPorProducto
ORDER BY total_facturado DESC;
GO

/* =========================================================
   HALLAZGOS DEL ANÁLISIS
   ========================================================= */
-- 1. El producto 1 es el de mayor facturación, con $3.600,00,
--    aproximadamente el 55,9% del total facturado ($6.444,00).
--
-- 2. Los productos 1 y 3 facturaron $3.600,00 y $1.350,00,
--    respectivamente; ambos quedaron por encima del promedio
--    de facturación por producto ($1.074,00).
--
-- 3. Los cinco clientes realizaron dos pedidos cada uno.
--    El cliente 1 registra el mayor gasto acumulado: $2.640,00.
