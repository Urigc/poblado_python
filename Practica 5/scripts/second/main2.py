import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import io
import pandas as pd
from connection import DBConnection
from config import DATABASE_URL
import generators as gen

def copy_to_db(df, table_name, engine):
    """Método de carga ultra rápida usando COPY"""
    output = io.StringIO()
    # Escribimos el dataframe a un buffer tipo CSV (sin índice y separado por tabuladores)
    df.to_csv(output, sep='\t', header=False, index=False)
    output.seek(0)
    
    # Obtenemos la conexión cruda de psycopg2
    connection = engine.raw_connection()
    cursor = connection.cursor()
    try:
        cursor.copy_from(output, table_name, sep='\t', null="")
        connection.commit()
        print(f"{len(df)} registros cargados en {table_name}")
    except Exception as e:
        connection.rollback()
        print(f"Error en COPY para {table_name}: {e}")
    finally:
        cursor.close()
        connection.close()

def run_poblado_masivo():
    db = DBConnection(DATABASE_URL)
    engine = db.get_engine()

    # 1. Generar Catálogos Principales (5,000)
    print("--- Generando 5,000 registros para tablas base ---")
    df_per = gen.get_personal_bulk(5000)
    copy_to_db(df_per, 'personal', engine)
    
    # (Para Supervisor y Proyectista usamos una muestra del Personal)
    codigos = df_per['codigo_personal'].tolist()
    
    df_sup = pd.DataFrame({'codigo_personal': codigos[:2500], 'telefono': [gen.fake.phone_number()[:15] for _ in range(2500)]})
    copy_to_db(df_sup, 'supervisor', engine)

    # 2. Obras (5,000)
    # Recuperamos IDs necesarios de la DB
    with engine.connect() as conn:
        ids_reg = pd.read_sql("SELECT id_region FROM region", conn)['id_region'].tolist()
        ids_con = pd.read_sql("SELECT id_constructora FROM constructora", conn)['id_constructora'].tolist()
        ids_sup = pd.read_sql("SELECT codigo_personal FROM supervisor", conn)['codigo_personal'].tolist()

    df_obras = gen.get_obra_bulk(5000, ids_reg, ids_con, ids_sup)
    copy_to_db(df_obras, 'obra', engine)

    # 3. Informes (50,000)
    print("--- Generando 50,000 Informes ---")
    # Usamos los IDs de las obras recién creadas
    obra_sup_pairs = list(df_obras[['id_obra', 'codigo_supervisor']].itertuples(index=False, name=None))
    df_info = gen.get_informes_bulk(50000, obra_sup_pairs)
    copy_to_db(df_info, 'informes', engine)

if __name__ == "__main__":
    run_poblado_masivo()
