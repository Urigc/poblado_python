import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from connection import DBConnection
from config import DATABASE_URL
import generators as gen
import pandas as pd

def run_poblado():
    db = DBConnection(DATABASE_URL)
    engine = db.get_engine()
    
    print("--- Generando 50 registros por tabla ---")
    
    try:
        df_personal = gen.get_personal_data(50)
        df_region = gen.get_region_data(50)
        df_const = gen.get_constructora_data(50)
        
        df_personal.to_sql('personal', engine, if_exists='append', index=False)
        df_region.to_sql('region', engine, if_exists='append', index=False)
        df_const.to_sql('constructora', engine, if_exists='append', index=False)
        print("Tablas base (Personal, Región, Constructora) pobladas.")

        codigos = df_personal['codigo_personal'].tolist()
        ids_const = df_const['id_constructora'].tolist()

        df_sup = pd.DataFrame({
            'codigo_personal': codigos[:25],
            'telefono': [gen.fake.phone_number()[:15] for _ in range(25)]
        })
        
        df_proy = pd.DataFrame({
            'codigo_personal': codigos[25:],
            'empresa': [gen.fake.company()[:150] for _ in range(25)],
            'id_constructora': [gen.random.choice(ids_const) for _ in range(25)]
        })

        df_sup.to_sql('supervisor', engine, if_exists='append', index=False)
        df_proy.to_sql('proyectista', engine, if_exists='append', index=False)
        print("Tablas de especialización (Supervisor, Proyectista) pobladas.")
        
        # 1. Recuperar IDs necesarios de tablas ya pobladas
        with engine.connect() as conn:
            ids_region = pd.read_sql("SELECT id_region FROM region", conn)['id_region'].tolist()
            ids_const = pd.read_sql("SELECT id_constructora FROM constructora", conn)['id_constructora'].tolist()
            ids_sup = pd.read_sql("SELECT codigo_personal FROM supervisor", conn)['codigo_personal'].tolist()

        print("--- Iniciando poblado del módulo financiero ---")

        # 2. Fuentes de Financiamiento
        df_fuentes = gen.get_fuente_financiamiento_data(10)
        df_fuentes.to_sql('fuente_presupuestaria', engine, if_exists='append', index=False)
        print("Catálogo de fuentes de financiamiento listo.")

        # 3. Obras
        df_obras = gen.get_obra_data(50, ids_region, ids_const, ids_sup)
        df_obras.to_sql('obra', engine, if_exists='append', index=False)
        print("50 registros de obras insertados.")

        # 4. Relación N:M (Financia)
        df_financia = gen.get_financia_data(df_obras, df_fuentes)
        df_financia.to_sql('financia', engine, if_exists='append', index=False)
        print(f"Relación 'financia' poblada con {len(df_financia)} registros.")

        
    except Exception as e:
        print(f"X Error durante el poblado: {e}")
        
def populate_informes():
    db = DBConnection(DATABASE_URL)
    engine = db.get_engine()
    
    print("--- Recuperando datos de obras para informes ---")
    try:
        with engine.connect() as conn:
            # Traemos la pareja obra-supervisor para mantener la lógica de negocio
            df_obras_info = pd.read_sql("SELECT id_obra, codigo_supervisor FROM obra", conn)
            ids_obra_sup = list(df_obras_info.itertuples(index=False, name=None))

        if not ids_obra_sup:
            print("No hay obras registradas para generar informes.")
            return

        print(f"--- Generando 100 registros para 'informes' ---")
        df_informes = gen.get_informe_data(100, ids_obra_sup)
        
        # Inserción masiva
        df_informes.to_sql('informes', engine, if_exists='append', index=False, method='multi')
        print(f"Se han insertado {len(df_informes)} informes correctamente.")

    except Exception as e:
        print(f"Error al poblar 'informes': {e}")

if __name__ == "__main__":
    populate_informes()

if __name__ == "__main__":
    run_poblado()
