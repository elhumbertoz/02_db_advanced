-- =============================================
-- TRABAJO FINAL - BASES DE DATOS AVANZADO
-- Estudiante: Humberto Zambrano Carreño
-- PARTE 1: CREACIÓN DE TABLAS
-- =============================================

CREATE TABLE IF NOT EXISTS cliente (
    cliente_id  SERIAL PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    ciudad      VARCHAR(80)  NOT NULL
);

CREATE TABLE IF NOT EXISTS pedido (
    pedido_id   SERIAL PRIMARY KEY,
    cliente_id  INTEGER      NOT NULL,
    fecha       DATE         NOT NULL DEFAULT CURRENT_DATE,
    estado      VARCHAR(20)  NOT NULL DEFAULT 'pendiente'
                CHECK (estado IN ('pendiente', 'enviado', 'entregado', 'cancelado')),
    CONSTRAINT fk_pedido_cliente
        FOREIGN KEY (cliente_id) REFERENCES cliente(cliente_id)
);

CREATE TABLE IF NOT EXISTS pedido_detalle (
    detalle_id  SERIAL PRIMARY KEY,
    pedido_id   INTEGER        NOT NULL,
    producto_id INTEGER        NOT NULL,
    cantidad    INTEGER        NOT NULL CHECK (cantidad > 0),
    precio_unit NUMERIC(10,2) NOT NULL CHECK (precio_unit > 0),
    CONSTRAINT fk_detalle_pedido
        FOREIGN KEY (pedido_id) REFERENCES pedido(pedido_id)
);

CREATE TABLE IF NOT EXISTS pago (
    pago_id     SERIAL PRIMARY KEY,
    pedido_id   INTEGER        NOT NULL,
    fecha       DATE           NOT NULL DEFAULT CURRENT_DATE,
    monto       NUMERIC(10,2) NOT NULL CHECK (monto > 0),
    confirmado  BOOLEAN        NOT NULL DEFAULT false,
    metadata    JSONB,
    CONSTRAINT fk_pago_pedido
        FOREIGN KEY (pedido_id) REFERENCES pedido(pedido_id)
);
