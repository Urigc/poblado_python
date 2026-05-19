import io
import pandas as pd
from connection import DBConnection
from config import DATABASE_URL
import generators as gen

def copy_to_db(df, table_name, engine):
    """Carga masiva ultra rápida mapeando nombres de columnas"""
    output = io.StringIO()
    # Escribimos a CSV en memoria sin cabeceras
    df.to_csv(output, sep='\t', header=False, index=False)
    output.seek(0)
    
    connection = engine.raw_connection()
    cursor = connection.cursor()
    
    # Creamos la lista de columnas entre comillas dobles para Postgres
    columns = ', '.join([f'"{c}"' for c in df.columns])
    
    try:
        # copy_expert nos permite definir el formato exacto del stream
        sql = f"COPY {table_name} ({columns}) FROM STDIN WITH CSV DELIMITER '\t' NULL ''"
        cursor.copy_expert(sql, output)
        connection.commit()
        print(f" ÉXITO: {len(df)} registros cargados en '{table_name}'")
    except Exception as e:
        connection.rollback()
        print(f" ERROR en COPY para {table_name}: {e}")
    finally:
        cursor.close()
        connection.close()

def run_poblado_informes_masivo(cantidad=50000):
    db = DBConnection(DATABASE_URL)
    engine = db.get_engine()
    
    print(f"--- Iniciando proceso para {cantidad} informes ---")
    
    try:
        # 1. Recuperar los pares Obra-Supervisor existentes
        with engine.connect() as conn:
            query = "SELECT id_obra, codigo_supervisor FROM obra"
            df_obras = pd.read_sql(query, conn)
            # Convertimos a lista de tuplas para el generador
            obra_sup_pairs = list(df_obras.itertuples(index=False, name=None))

        if not obra_sup_pairs:
            print("No se encontraron obras en la base de datos. Pobla 'obra' primero.")
            return

        # 2. Generar datos
        print("Generando DataFrame en memoria...")
        df_informes = gen.get_informes_bulk(cantidad, obra_sup_pairs)
        
        # 3. Ejecutar COPY
        copy_to_db(df_informes, 'informes', engine)

    except Exception as e:
        print(f" Error crítico en el orquestador: {e}")

if __name__ == "__main__":
    run_poblado_informes_masivo(50000)