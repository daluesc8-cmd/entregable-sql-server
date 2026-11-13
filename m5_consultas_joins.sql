-- Motor utilizado: SQL Server
-- Base de datos: Ventas_Tech_DB
-- Entregable M5: Consultas con JOINs para el proyecto
-- Título: Cruzando tablas para enriquecer el análisis
--
-- Nota sobre el esquema:
-- Se utiliza la estructura creada en M3: ventas, clientes,
-- productos y categorias. La columna clientes.ciudad aporta
-- una dimensión geográfica para agrupar o filtrar en Power BI.

USE Ventas_Tech_DB;
GO

/* =========================================================
   CONSULTA 1 - VISTA BASE DEL PROYECTO (INNER JOIN)
   Propósito: reunir cada venta con los datos del cliente,
   producto y categoría, incluyendo la ciudad del cliente.
   ========================================================= */
SELECT
    v.fecha_venta AS fecha,
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.email,
    c.ciudad,
    p.id_producto,
    p.nombre_producto AS descripcion_producto,
    cat.nombre_categoria AS categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario AS total_venta
FROM ventas AS v
INNER JOIN clientes AS c
    ON v.id_cliente = c.id_cliente
INNER JOIN productos AS p
    ON v.id_producto = p.id_producto
INNER JOIN categorias AS cat
    ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta, v.id_venta;

-- Hallazgo: las 10 ventas quedan enriquecidas con nombre del cliente,
-- producto, categoría y ciudad. La ciudad permite segmentar el análisis
-- geográficamente en Power BI.
GO

/* =========================================================
   CONSULTA 2 - CLIENTES SIN VENTAS (LEFT JOIN)
   Propósito: detectar clientes registrados que todavía no
   realizaron compras, para que CRM pueda evaluar acciones.
   ========================================================= */
SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes AS c
LEFT JOIN ventas AS v
    ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL
ORDER BY c.fecha_registro;

-- Hallazgo: no aparecen clientes sin ventas (0 registros).
-- En esta muestra, los cinco clientes registrados realizaron compras;
-- CRM no tiene clientes inactivos por primera compra para contactar.
GO

/* =========================================================
   CONSULTA 3 - PRODUCTOS SIN VENTAS (LEFT JOIN)
   Propósito: encontrar productos del catálogo sin movimiento,
   para que el área de Producto revise su desempeño.
   ========================================================= */
SELECT
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos AS p
LEFT JOIN ventas AS v
    ON p.id_producto = v.id_producto
LEFT JOIN categorias AS cat
    ON p.id_categoria = cat.id_categoria
WHERE v.id_venta IS NULL
ORDER BY p.nombre_producto;

-- Hallazgo: no aparecen productos sin ventas (0 registros).
-- Los seis productos del catálogo tienen movimiento en la muestra;
-- el área de Producto no tiene artículos sin vender para revisar.
GO

/* =========================================================
   CONSULTA 4 - CONSOLIDADO POR ORIGEN (UNION ALL)
   Propósito: comparar la facturación de dos períodos.
   La etiqueta de origen se crea como literal en cada SELECT;
   no representa un canal real registrado en la base.
   ========================================================= */
SELECT
    consolidado.canal,
    SUM(consolidado.total) AS total_canal
FROM (
    SELECT
        fecha_venta,
        cantidad * precio_unitario AS total,
        'Primer período (1 al 10 de marzo)' AS canal
    FROM ventas
    WHERE fecha_venta >= '2024-03-01'
      AND fecha_venta <  '2024-03-11'

    UNION ALL

    SELECT
        fecha_venta,
        cantidad * precio_unitario AS total,
        'Segundo período (11 al 31 de marzo)' AS canal
    FROM ventas
    WHERE fecha_venta >= '2024-03-11'
      AND fecha_venta <  '2024-04-01'
) AS consolidado
GROUP BY consolidado.canal
ORDER BY consolidado.canal;

-- Hallazgo: el primer período facturó $3.620,00 y el segundo $2.824,00.
-- El primer período superó al segundo por $796,00. La comparación
-- corresponde a períodos de marzo, no a canales reales de venta.
GO
