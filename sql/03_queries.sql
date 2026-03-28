-- =============================================
-- PARTE 3: CONSULTAS AVANZADAS CON JOINs
-- =============================================

-- CONSULTA 2.1: Todos los pedidos (con y sin pagos)
-- JOIN: LEFT JOIN — preserva todos los pedidos aunque no tengan pago
SELECT
    p.pedido_id,
    c.nombre            AS cliente,
    p.fecha             AS fecha_pedido,
    p.estado,
    pg.pago_id,
    pg.monto,
    pg.confirmado,
    CASE
        WHEN pg.pago_id IS NULL THEN 'SIN PAGO'
        ELSE 'CON PAGO'
    END                 AS estado_pago
FROM pedido p
LEFT JOIN cliente c  ON p.cliente_id = c.cliente_id
LEFT JOIN pago    pg ON p.pedido_id  = pg.pedido_id
ORDER BY p.pedido_id;


-- CONSULTA 2.2: Pedidos con cliente y total calculado
-- JOIN: INNER JOIN — solo pedidos con al menos una línea de detalle
SELECT
    p.pedido_id,
    c.nombre            AS cliente,
    c.ciudad,
    p.fecha,
    p.estado,
    COUNT(d.detalle_id) AS lineas_detalle,
    SUM(d.cantidad * d.precio_unit) AS total_pedido
FROM pedido p
INNER JOIN cliente        c ON p.cliente_id = c.cliente_id
INNER JOIN pedido_detalle d ON p.pedido_id  = d.pedido_id
GROUP BY p.pedido_id, c.nombre, c.ciudad, p.fecha, p.estado
ORDER BY total_pedido DESC;


-- CONSULTA 2.3: Pedidos sin pagos confirmados
-- JOIN: LEFT JOIN + WHERE — incluye pedidos sin pago y con pago no confirmado
SELECT
    p.pedido_id,
    c.nombre            AS cliente,
    p.fecha             AS fecha_pedido,
    p.estado,
    pg.pago_id,
    pg.monto,
    pg.confirmado,
    CASE
        WHEN pg.pago_id IS NULL    THEN 'Sin pago registrado'
        WHEN pg.confirmado = false THEN 'Pago no confirmado'
    END                 AS motivo
FROM pedido p
LEFT JOIN cliente c  ON p.cliente_id = c.cliente_id
LEFT JOIN pago    pg ON p.pedido_id  = pg.pedido_id
WHERE pg.pago_id IS NULL
   OR pg.confirmado = false
ORDER BY p.pedido_id;
