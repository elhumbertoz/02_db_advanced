-- =============================================
-- PARTE 2: INSERCIÓN DE DATOS DE PRUEBA
-- =============================================

-- 5 clientes
INSERT INTO cliente (nombre, ciudad) VALUES
    ('María López',     'Guayaquil'),
    ('Carlos Mendoza',  'Quito'),
    ('Ana Torres',      'Cuenca'),
    ('Pedro Ramírez',   'Ambato'),
    ('Lucía Fernández', 'Loja');

-- 8 pedidos (pedidos 7 y 8 sin pagos)
INSERT INTO pedido (cliente_id, fecha, estado) VALUES
    (1, '2025-11-10', 'entregado'),
    (1, '2025-12-05', 'enviado'),
    (2, '2025-12-15', 'entregado'),
    (3, '2026-01-08', 'pendiente'),
    (4, '2026-01-20', 'enviado'),
    (5, '2026-02-01', 'cancelado'),
    (2, '2026-02-14', 'pendiente'),
    (3, '2026-03-01', 'pendiente');

-- 10 detalles de pedido
INSERT INTO pedido_detalle (pedido_id, producto_id, cantidad, precio_unit) VALUES
    (1, 101, 2,  25.50),
    (1, 102, 1,  89.99),
    (2, 103, 3,  15.00),
    (3, 101, 1,  25.50),
    (3, 104, 2,  42.00),
    (4, 105, 1, 120.00),
    (5, 102, 2,  89.99),
    (5, 106, 1,  35.75),
    (6, 103, 4,  15.00),
    (7, 107, 1,  65.00);

-- 6 pagos (pedidos 7 y 8 sin pago; pedido 4 con pago NO confirmado)
INSERT INTO pago (pedido_id, fecha, monto, confirmado, metadata) VALUES
    (1, '2025-11-10', 140.99, true,
     '{"metodo":"tarjeta","pasarela":"PayPal","transaccion":"TXN-001","ultimos_4":"4532"}'::jsonb),
    (2, '2025-12-05',  45.00, true,
     '{"metodo":"transferencia","pasarela":"Stripe","transaccion":"TXN-002","banco":"Banco Pichincha"}'::jsonb),
    (3, '2025-12-15', 109.50, true,
     '{"metodo":"tarjeta","pasarela":"PayPal","transaccion":"TXN-003","ultimos_4":"7891"}'::jsonb),
    (4, '2026-01-10', 120.00, false,
     '{"metodo":"tarjeta","pasarela":"MercadoPago","transaccion":"TXN-004","error":"fondos insuficientes"}'::jsonb),
    (5, '2026-01-20', 215.73, true,
     '{"metodo":"tarjeta","pasarela":"Stripe","transaccion":"TXN-005","ultimos_4":"2156"}'::jsonb),
    (6, '2026-02-01',  60.00, false,
     '{"metodo":"efectivo","pasarela":"contraentrega","transaccion":"TXN-006","nota":"cliente canceló"}'::jsonb);
