import pandas as pd
from faker import Faker
import random
import string

fake = Faker('es_MX')

def generate_unique_ids(n, length):
    ids = set()
    while len(ids) < n:
        ids.add(''.join(random.choices(string.ascii_uppercase + string.digits, k=length)))
    return list(ids)

def get_informes_bulk(n, ids_obra_sup):
    """
    Genera N informes asegurando la restricción UNIQUE(id_obra, mes, ano_infor).
    ids_obra_sup: Lista de tuplas (id_obra, codigo_supervisor)
    """
    data = []
    ids_informe = generate_unique_ids(n, 20)
    combinaciones = set()
    
    intentos_max = n * 10
    intentos = 0
    
    while len(data) < n and intentos < intentos_max:
        # Seleccionamos una obra y su supervisor asignado
        id_o, cod_s = random.choice(ids_obra_sup)
        mes = random.randint(1, 12)
        ano = random.randint(2023, 2026)
        
        if (id_o, mes, ano) not in combinaciones:
            data.append({
                'id_informe': ids_informe[len(data)],
                'id_obra': id_o,
                'codigo_supervisor': cod_s,
                'ano_infor': ano,
                'mes': mes,
                'porcentaje_avance_fisico': random.randint(0, 100),
                'porcentaje_avance_presupuestario': random.randint(0, 100),
                'doc_infome': f"https://evidencias.obras.gob/INF-{random.randint(10000, 99999)}.pdf",
                'descripcion': fake.sentence(nb_words=12)
            })
            combinaciones.add((id_o, mes, ano))
        intentos += 1
            
    # CRÍTICO: Ordenar las columnas explícitamente para el comando COPY
    df = pd.DataFrame(data)
    column_order = [
        'id_informe', 'id_obra', 'codigo_supervisor', 'ano_infor', 
        'mes', 'porcentaje_avance_fisico', 'porcentaje_avance_presupuestario', 
        'doc_infome', 'descripcion'
    ]
    return df[column_order]