import pandas as pd
from faker import Faker
import random
import string
import io

fake = Faker('es_MX')

def generate_unique_ids(n, length):
    ids = set()
    while len(ids) < n:
        ids.add(''.join(random.choices(string.ascii_uppercase + string.digits, k=length)))
    return list(ids)

def get_personal_bulk(n=5000):
    ids = generate_unique_ids(n, 20)
    data = []
    for i in range(n):
        data.append({
            'codigo_personal': ids[i],
            'nombre': fake.first_name()[:100],
            'apellido_paterno': fake.last_name()[:200],
            'apellido_materno': fake.last_name()[:200]
        })
    return pd.DataFrame(data)

def get_obra_bulk(n, ids_region, ids_const, ids_sup):
    data = []
    ids_obra = generate_unique_ids(n, 20)
    codigos_exp = generate_unique_ids(n, 15)
    for i in range(n):
        data.append({
            'id_obra': ids_obra[i],
            'codigo_expediente': codigos_exp[i],
            'nombre_obra': f"Obra {fake.bs()[:180]}",
            'etapa': random.randint(1, 5),
            'fecha_inicio': fake.date_between(start_date='-3y', end_date='-1y'),
            'fecha_final': fake.date_between(start_date='today', end_date='+2y'),
            'descripcion': fake.sentence(nb_words=8),
            'beneficiarios': f"Pobladores de {fake.city()}",
            'id_constructora': random.choice(ids_const),
            'id_region': random.choice(ids_region),
            'codigo_supervisor': random.choice(ids_sup)
        })
    return pd.DataFrame(data)

def get_informes_bulk(n, ids_obra_sup):
    """Genera 50,000 informes respetando la restricción UNIQUE(id_obra, mes, ano)"""
    data = []
    ids_informe = generate_unique_ids(n, 20)
    combinaciones = set()
    
    # Generar informes distribuidos entre las obras existentes
    while len(data) < n:
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
                'doc_infome': f"DOC-{random.randint(1000, 9999)}",
                'descripcion': fake.sentence(nb_words=5)
            })
            combinaciones.add((id_o, mes, ano))
    return pd.DataFrame(data)
