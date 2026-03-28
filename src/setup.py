"""
Ejecuta los scripts DDL y DML para preparar la base de datos.
Uso: python src/setup.py
"""
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from src.db import get_connection, execute_sql_file

BASE = os.path.dirname(os.path.dirname(__file__))
SQL_DIR = os.path.join(BASE, "sql")

SCRIPTS = [
    "01_create_tables.sql",
    "02_insert_data.sql",
]


def main():
    conn = get_connection()
    try:
        for script in SCRIPTS:
            path = os.path.join(SQL_DIR, script)
            print(f"Ejecutando {script}...")
            execute_sql_file(conn, path)
            print(f"  OK")
        print("\nSetup completado.")
    except Exception as e:
        conn.rollback()
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
    finally:
        conn.close()


if __name__ == "__main__":
    main()
