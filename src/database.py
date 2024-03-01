import os
import psycopg2

conn = None


def get_db_connection():
    global conn
    if not conn:
        conn = psycopg2.connect(
            host=os.environ.get("DB_HOST", "localhost"),
            database=os.environ.get("DB_NAME", "postgres"),
            user=os.environ.get("DB_USER", "postgres"),
            password=os.environ.get("DB_PASSWORD", "postgres"),
            sslmode=os.environ.get("DB_SSLMODE", "prefer"),
        )
    return conn


def migrate():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        "CREATE TABLE IF NOT EXISTS users (id SERIAL PRIMARY KEY, name VARCHAR(255))"
    )
    cur.execute("INSERT INTO users (name) VALUES ('John')")
    cur.execute("INSERT INTO users (name) VALUES ('Oliver')")
    conn.commit()
