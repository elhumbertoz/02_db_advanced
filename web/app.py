from flask import Flask, render_template
import db as database

app = Flask(__name__)


def _load_sql(filename: str) -> str:
    import os
    sql_dir = os.path.join(os.path.dirname(__file__), "..", "sql")
    with open(os.path.join(sql_dir, filename), encoding="utf-8") as f:
        return f.read()


# ── Queries ──────────────────────────────────────────────────────────────────

SQL_Q1 = """
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
ORDER BY p.pedido_id
"""

SQL_Q2 = """
SELECT
    p.pedido_id,
    c.nombre            AS cliente,
    c.ciudad,
    p.fecha,
    p.estado,
    COUNT(d.detalle_id)             AS lineas_detalle,
    SUM(d.cantidad * d.precio_unit) AS total_pedido
FROM pedido p
INNER JOIN cliente        c ON p.cliente_id = c.cliente_id
INNER JOIN pedido_detalle d ON p.pedido_id  = d.pedido_id
GROUP BY p.pedido_id, c.nombre, c.ciudad, p.fecha, p.estado
ORDER BY total_pedido DESC
"""

SQL_Q3 = """
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
ORDER BY p.pedido_id
"""

SQL_DASHBOARD = """
SELECT
    (SELECT COUNT(*) FROM cliente)                          AS total_clientes,
    (SELECT COUNT(*) FROM pedido)                           AS total_pedidos,
    (SELECT COUNT(*) FROM pago WHERE confirmado = true)     AS pagos_confirmados,
    (SELECT COALESCE(SUM(monto), 0)
       FROM pago WHERE confirmado = true)                   AS monto_recaudado
"""


# ── Rutas ────────────────────────────────────────────────────────────────────

@app.route("/")
def index():
    stats = database.query(SQL_DASHBOARD)[0]
    return render_template("index.html", stats=stats)


@app.route("/consulta/1")
def consulta1():
    rows = database.query(SQL_Q1)
    return render_template(
        "query1.html",
        rows=rows,
        sql=SQL_Q1.strip(),
        titulo="Consulta 2.1 — Todos los pedidos (con y sin pagos)",
        join_type="LEFT JOIN",
        justificacion=(
            "Se necesita listar TODOS los pedidos independientemente de si tienen o no "
            "un pago registrado. Un INNER JOIN excluiría los pedidos sin pagos. "
            "El LEFT JOIN preserva todas las filas de la tabla izquierda (pedido) y "
            "rellena con NULL las columnas de pago cuando no existe coincidencia."
        ),
    )


@app.route("/consulta/2")
def consulta2():
    rows = database.query(SQL_Q2)
    return render_template(
        "query2.html",
        rows=rows,
        sql=SQL_Q2.strip(),
        titulo="Consulta 2.2 — Pedidos con total calculado",
        join_type="INNER JOIN",
        justificacion=(
            "Solo interesan los pedidos que tienen líneas de detalle, ya que sin ellas "
            "no hay total que calcular. El INNER JOIN descarta automáticamente pedidos "
            "sin detalles. El total se obtiene con SUM(cantidad × precio_unit) agrupado "
            "por pedido con GROUP BY."
        ),
    )


@app.route("/consulta/3")
def consulta3():
    rows = database.query(SQL_Q3)
    return render_template(
        "query3.html",
        rows=rows,
        sql=SQL_Q3.strip(),
        titulo="Consulta 2.3 — Pedidos sin pagos confirmados",
        join_type="LEFT JOIN + WHERE",
        justificacion=(
            "Se debe capturar dos escenarios: pedidos sin ningún registro de pago "
            "(pg.pago_id IS NULL) y pedidos cuyo pago existe pero no está confirmado "
            "(pg.confirmado = false). Un INNER JOIN excluiría el primer escenario, "
            "por eso se usa LEFT JOIN y se filtra en el WHERE."
        ),
    )


# ── Init ─────────────────────────────────────────────────────────────────────

with app.app_context():
    database.init_pool()


if __name__ == "__main__":
    app.run(debug=True)
