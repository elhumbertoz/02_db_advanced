# Trabajo Final - Bases de Datos Avanzado

**Estudiante:** Humberto Zambrano Carreño
**Materia:** Base de Datos Avanzados B
**Institución:** CEU Felipe Villanueva
**Fecha:** Marzo 2026

---

## Descripcion

Sistema de comercio electrónico implementado con PostgreSQL y Python. Demuestra el uso de JOINs avanzados, tipos de dato JSONB, constraints de integridad y consultas de agregación sobre un modelo relacional de cuatro entidades.

---

## Stack Tecnologico

| Capa | Tecnología |
|------|-----------|
| Base de datos | PostgreSQL 16+ |
| Lenguaje | Python 3.11+ |
| Web framework | Flask 3.x |
| Plantillas | Jinja2 (incluido en Flask) |
| Estilos | Bootstrap 5 (CDN) |
| Driver DB | psycopg2-binary |
| Migraciones / scripts | SQL puro (DDL + DML) |
| Entorno virtual | venv |

---

## Modelo de Datos

```
cliente (1) ──< pedido (1) ──< pedido_detalle
                    │
                    └──< pago (metadata: JSONB)
```

### Tablas

| Tabla | Descripción | Campos clave |
|-------|-------------|--------------|
| `cliente` | Clientes registrados | `cliente_id` PK, `nombre`, `ciudad` |
| `pedido` | Órdenes de compra | `pedido_id` PK, `cliente_id` FK, `fecha`, `estado` CHECK |
| `pedido_detalle` | Líneas de producto por pedido | `detalle_id` PK, `pedido_id` FK, `producto_id`, `cantidad`, `precio_unit` |
| `pago` | Pagos con metadata de pasarela | `pago_id` PK, `pedido_id` FK, `monto`, `confirmado`, `metadata` JSONB |

---

## Estructura del Proyecto

```
02_db_advanced/
├── .devcontainer/
│   ├── devcontainer.json         # Configuración de GitHub Codespaces
│   └── setup.sh                  # Script de inicialización automática
├── .env.example                  # Plantilla de variables de entorno (subir al repo)
├── .env                          # Credenciales locales (en .gitignore, NO subir)
├── .gitignore
├── README.md
├── requirements.txt
├── sql/
│   ├── 01_create_tables.sql      # DDL: creación de tablas y constraints
│   ├── 02_insert_data.sql        # DML: datos de prueba
│   └── 03_queries.sql            # Consultas avanzadas con JOINs
├── src/
│   ├── db.py                     # Conexión a PostgreSQL con psycopg2
│   ├── setup.py                  # Ejecuta los scripts SQL de setup
│   └── queries.py                # Ejecuta y muestra resultados de las consultas
└── web/
    ├── app.py                    # Flask app: definición de rutas
    ├── db.py                     # Pool de conexiones compartido
    ├── templates/
    │   ├── base.html             # Layout base con navbar y Bootstrap
    │   ├── index.html            # Dashboard con métricas generales
    │   ├── query1.html           # Consulta 2.1: todos los pedidos
    │   ├── query2.html           # Consulta 2.2: totales por pedido
    │   └── query3.html           # Consulta 2.3: sin pagos confirmados
    └── static/
        └── style.css             # Estilos adicionales (badges de estado)
```

---

## Aplicacion Web

La aplicación Flask expone cada consulta del trabajo como una vista independiente, mostrando el SQL ejecutado y el resultado en tabla HTML.

### Rutas

| Ruta | Vista | Descripción |
|------|-------|-------------|
| `GET /` | `index.html` | Dashboard: totales de clientes, pedidos, pagos confirmados y monto recaudado |
| `GET /consulta/1` | `query1.html` | Todos los pedidos con/sin pagos (LEFT JOIN) |
| `GET /consulta/2` | `query2.html` | Pedidos con total calculado (INNER JOIN + GROUP BY) |
| `GET /consulta/3` | `query3.html` | Pedidos sin pagos confirmados (LEFT JOIN + WHERE) |

### Diseño de cada vista de consulta

Cada página de consulta sigue la misma estructura de tres bloques:

1. **Encabezado** — nombre de la consulta, tipo de JOIN usado y justificación en texto.
2. **Bloque SQL** — el query completo en un `<pre><code>` con fondo oscuro.
3. **Tabla de resultados** — datos devueltos por PostgreSQL, con badges de color por estado del pedido y del pago.

### Dashboard (`/`)

Muestra cuatro tarjetas de métricas calculadas en tiempo real:

| Métrica | Consulta base |
|---------|--------------|
| Total de clientes | `SELECT COUNT(*) FROM cliente` |
| Total de pedidos | `SELECT COUNT(*) FROM pedido` |
| Pagos confirmados | `SELECT COUNT(*) FROM pago WHERE confirmado = true` |
| Monto total recaudado | `SELECT SUM(monto) FROM pago WHERE confirmado = true` |

### Convenciones visuales

| Estado pedido | Badge Bootstrap |
|---------------|----------------|
| `entregado` | `bg-success` (verde) |
| `enviado` | `bg-primary` (azul) |
| `pendiente` | `bg-warning` (amarillo) |
| `cancelado` | `bg-danger` (rojo) |

| Estado pago | Badge |
|-------------|-------|
| `CON PAGO` confirmado | `bg-success` |
| `Pago no confirmado` | `bg-warning` |
| `Sin pago registrado` | `bg-secondary` |

---

## Requisitos

- Python 3.11+
- PostgreSQL 16+ corriendo localmente
- pip

---

## Configuracion

### Opción A — GitHub Codespaces (sin instalar nada localmente)

1. Abre el repo en GitHub → **Code → Codespaces → Create codespace on main**.
2. El contenedor instala automáticamente Python 3.11, PostgreSQL 16, las dependencias y carga los datos.
3. Cuando termine el setup, ejecuta en la terminal integrada:

```bash
cd web && flask --app app run --host 0.0.0.0
```

4. Codespaces reenvía el puerto 5000 — haz clic en **Open in Browser**.

---

### Opción B — Ejecución local

#### 1. Clonar y configurar entorno

```bash
git clone <url-del-repo>
cd 02_db_advanced

python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

#### 2. Configurar credenciales

```bash
cp .env.example .env
# Edita .env con tu usuario y contraseña de PostgreSQL
```

#### 3. Crear la base de datos y cargar datos

```bash
psql -U postgres -c "CREATE DATABASE ecommerce_db;"
python src/setup.py
```

#### 4. Iniciar la aplicación web

```bash
cd web
flask --app app run --debug
```

Abre `http://localhost:5000` en el navegador.

---

## Consultas Implementadas

### 2.1 — Todos los pedidos, incluso sin pagos (`LEFT JOIN`)

Preserva todos los pedidos de la tabla izquierda. Los pedidos sin pago aparecen con `NULL` en las columnas de pago y `estado_pago = 'SIN PAGO'`.

```sql
SELECT p.pedido_id, c.nombre AS cliente, p.estado,
       pg.monto,
       CASE WHEN pg.pago_id IS NULL THEN 'SIN PAGO' ELSE 'CON PAGO' END AS estado_pago
FROM pedido p
LEFT JOIN cliente c  ON p.cliente_id = c.cliente_id
LEFT JOIN pago pg    ON p.pedido_id  = pg.pedido_id
ORDER BY p.pedido_id;
```

### 2.2 — Pedidos con total calculado (`INNER JOIN` + `GROUP BY`)

Solo pedidos que tienen líneas de detalle. El total se calcula como `SUM(cantidad × precio_unit)`.

```sql
SELECT p.pedido_id, c.nombre AS cliente, c.ciudad,
       COUNT(d.detalle_id) AS lineas_detalle,
       SUM(d.cantidad * d.precio_unit) AS total_pedido
FROM pedido p
INNER JOIN cliente       c ON p.cliente_id = c.cliente_id
INNER JOIN pedido_detalle d ON p.pedido_id  = d.pedido_id
GROUP BY p.pedido_id, c.nombre, c.ciudad, p.fecha, p.estado
ORDER BY total_pedido DESC;
```

### 2.3 — Pedidos sin pagos confirmados (`LEFT JOIN` + `WHERE`)

Combina pedidos sin ningún pago registrado y pedidos con pago no confirmado.

```sql
SELECT p.pedido_id, c.nombre AS cliente, p.estado,
       pg.pago_id, pg.monto,
       CASE WHEN pg.pago_id IS NULL     THEN 'Sin pago registrado'
            WHEN pg.confirmado = false  THEN 'Pago no confirmado'
       END AS motivo
FROM pedido p
LEFT JOIN cliente c ON p.cliente_id = c.cliente_id
LEFT JOIN pago pg   ON p.pedido_id  = pg.pedido_id
WHERE pg.pago_id IS NULL OR pg.confirmado = false
ORDER BY p.pedido_id;
```

---

## Datos de Prueba

| Pedido | Cliente | Estado | Pago | Confirmado |
|--------|---------|--------|------|-----------|
| 1 | María López | entregado | $140.99 | Si |
| 2 | María López | enviado | $45.00 | Si |
| 3 | Carlos Mendoza | entregado | $109.50 | Si |
| 4 | Ana Torres | pendiente | $120.00 | No |
| 5 | Pedro Ramírez | enviado | $215.73 | Si |
| 6 | Lucía Fernández | cancelado | $60.00 | No |
| 7 | Carlos Mendoza | pendiente | — | — |
| 8 | Ana Torres | pendiente | — | — |

---

## Decisiones de Diseno

- **JSONB vs JSON:** Se usa `JSONB` en `pago.metadata` porque soporta indexación GIN y operadores de búsqueda eficientes.
- **CHECK constraints:** El campo `pedido.estado` solo acepta `pendiente`, `enviado`, `entregado` o `cancelado`.
- **LEFT JOIN para nulos:** Siempre que se requiera incluir registros sin contraparte en otra tabla.
- **INNER JOIN para agregaciones:** Cuando la ausencia de filas en una tabla hace que el cálculo no tenga sentido.
