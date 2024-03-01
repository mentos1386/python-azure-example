from flask import Flask, render_template
from database import get_db_connection, migrate

app = Flask(__name__)


@app.route("/health")
def health():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT 1")
    cursor.fetchone()
    return "OK"


@app.route("/")
def hello_world():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM users")
    users = cursor.fetchall()
    print(users)
    return render_template("index.html", users=users)


if __name__ == "__main__":
    migrate()
    app.run(host="0.0.0.0", port=8080)
