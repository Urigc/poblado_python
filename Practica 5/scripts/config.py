import os

USER = os.getenv("DB_USER", "urigc")
PASS = os.getenv("DB_PASSWORD", "123456")
HOST = os.getenv("DB_HOST", "localhost")
PORT = os.getenv("DB_PORT", "5433")
DB_NAME = os.getenv("DB_NAME", "Obras_Publicas")  

DATABASE_URL = f"postgresql://{USER}:{PASS}@{HOST}:{PORT}/{DB_NAME}"