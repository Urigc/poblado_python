from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError

class DBConnection:
    def __init__(self, db_url):
        self.db_url = db_url
        self.engine = create_engine(db_url)

    def get_engine(self):
        return self.engine

    def test_connection(self):
        """Verifica que la base de datos esté lista."""
        try:
            with self.engine.connect() as conn:
                conn.execute(text("SELECT 1"))
                print("Conexión establecida con éxito.")
                return True
        except SQLAlchemyError as e:
            print(f"Error de conexión: {e}")
            return False

    def execute_query(self, query):
        """Para limpiezas rápidas o truncado de tablas."""
        try:
            with self.engine.begin() as conn:
                conn.execute(text(query))
        except SQLAlchemyError as e:
            print(f"Error ejecutando query: {e}")