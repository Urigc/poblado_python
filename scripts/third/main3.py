import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import time
import io
import random
import string
import multiprocessing as mp
import pandas as pd
from sqlalchemy import text
from connection import DBConnection
from config import DATABASE_URL
import generators as gen

def copy_to_db(df, table_name, engine):
    """Carga masiva robusta con gestión de transacciones limpia."""
    if df is None or df.empty: return
    
    output = io.StringIO()
    df.to_csv(output, sep='\t', header=False, index=False)
    output.seek(0)
    
    conn = engine.raw_connection()
    cursor = conn.cursor()
    columns = ', '.join([f'"{c}"' for c in df.columns])
    
    try:
        cursor.execute("SET session_replication_role = 'replica';")
        sql = f"COPY {table_name} ({columns}) FROM STDIN WITH CSV DELIMITER '\t' NULL ''"
        cursor.copy_expert(sql, output)
        conn.commit()
        print(f"✅ {len(df)} registros cargados en '{table_name}'")
    except Exception as e:
        conn.rollback() # Vital para evitar InFailedSqlTransaction
        print(f"❌ Error en '{table_name}': {e}")
        raise e
    finally:
        try:
            cursor.execute("SET session_replication_role = 'origin';")
            conn.commit()
        except: pass
        cursor.close()
        conn.close()

def get_db_columns(engine, table_name):
    """Inspección dinámica para evitar errores de nombres de columna."""
    with engine.connect() as conn:
        query = text(f"SELECT column_name FROM information_schema.columns WHERE table_name = '{table_name}'")
        return [row[0] for row in conn.execute(query).fetchall()]

def run_total_poblado():
    db = DBConnection(DATABASE_URL)
    engine = db.get_engine()
    start_global = time.perf_counter()

    print("🚀 Iniciando Carga Maestra (Poblado Masivo Total)...")

    try:
        # --- 1. TABLAS INDEPENDIENTES ---
        # Personal (200k)
        df_per = gen.get_personal_bulk(200000)
        copy_to_db(df_per, 'personal', engine)
        p_ids = df_per['codigo_personal'].tolist()

        # Constructoras (100k) - RFC 12 chars fix
        rfcs = [f"{''.join(random.choices(string.ascii_uppercase, k=3))}{''.join(random.choices(string.digits, k=6))}{''.join(random.choices(string.ascii_uppercase + string.digits, k=3))}" for _ in range(100000)]
        ids_const = gen.generate_safe_ids(100000, 10, "C_")
        df_con = pd.DataFrame({
            'id_constructora': ids_const,
            'rfc': rfcs,
            'nombre_const': [gen.fake.company()[:100] for _ in range(100000)],
            'tipo_ejecutor': 'Empresa Masiva'
        })
        copy_to_db(df_con, 'constructora', engine)

        # Fuentes (100k)
        df_fue = gen.get_fuente_bulk(100000)
        copy_to_db(df_fue, 'fuente_presupuestaria', engine)
        f_ids = df_fue['id_fuente'].tolist()

        # --- 2. ROLES Y ESPECIALIZACIÓN ---
        with engine.connect() as conn:
            res_reg = conn.execute(text("SELECT id_region FROM region LIMIT 1")).fetchone()
            if not res_reg: raise Exception("Necesitas al menos una región en la DB.")
            id_reg = res_reg[0]

        # Supervisores (100k)
        df_sup = pd.DataFrame({'codigo_personal': p_ids[:100000], 'telefono': '55-0000-0000'})
        copy_to_db(df_sup, 'supervisor', engine)

        # Proyectistas (100k)
        df_pro = pd.DataFrame({
            'codigo_personal': p_ids[100000:200000], 
            'empresa': 'ESCOM_CORP', 
            'id_constructora': random.choices(ids_const, k=100000)
        })
        copy_to_db(df_pro, 'proyectista', engine)

        # --- 3. OBRAS Y FINANCIA (N:M DINÁMICO) ---
        df_obras = gen.get_obra_bulk(100000, [id_reg], ids_const, p_ids[:100000])
        copy_to_db(df_obras, 'obra', engine)

        cols_financia = get_db_columns(engine, 'financia')
        data_fin = {'id_obra': df_obras['id_obra'], 'id_fuente': random.choices(f_ids, k=100000)}
        for c in cols_financia:
            if c not in data_fin: data_fin[c] = 100.0 # Porcentaje dinámico
        
        df_fin = pd.DataFrame(data_fin)[cols_financia]
        copy_to_db(df_fin, 'financia', engine)

        # --- 4. EL MILLÓN DE INFORMES (PARALELO) ---
        print("⏳ Generando 1,000,000 de informes en paralelo...")
        obra_sup_list = list(df_obras[['id_obra', 'codigo_supervisor']].itertuples(index=False, name=None))
        
        n_procs = mp.cpu_count()
        chunk_size = 1000000 // n_procs
        tasks = [(chunk_size, obra_sup_list, i * chunk_size) for i in range(n_procs)]

        with mp.Pool(n_procs) as pool:
            results = pool.map(gen.generate_informes_chunk, tasks)
        
        for df_chunk in results:
            copy_to_db(df_chunk, 'informes', engine)

        print(f"\n✅ PROCESO EXITOSO: {(time.perf_counter() - start_global)/60:.2f} MINUTOS")

    except Exception as e:
        print(f"❌ ERROR CRÍTICO: {e}")

if __name__ == "__main__":
    run_total_poblado()
