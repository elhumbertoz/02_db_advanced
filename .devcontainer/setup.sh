#!/usr/bin/env bash
set -e

echo "==> Instalando dependencias Python..."
pip install -r requirements.txt --quiet

echo "==> Configurando .env..."
cp .env.example .env

echo "==> Esperando a que PostgreSQL esté listo..."
until pg_isready -U postgres -q; do sleep 1; done

echo "==> Creando base de datos..."
createdb -U postgres ecommerce_db 2>/dev/null || echo "     (ya existe, continuando)"

echo "==> Cargando tablas y datos de prueba..."
python src/setup.py

echo ""
echo "Setup completo."
echo ""
echo "Para iniciar la aplicación web:"
echo "  cd web && flask --app app run --host 0.0.0.0"
