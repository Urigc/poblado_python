import pandas as pd
from faker import Faker
import random
import string

fake = Faker('es_MX')

def generate_safe_ids(n, length, prefix="M_"):
    """Genera IDs únicos evitando colisiones."""
    chars = string.ascii_uppercase + string.digits
    return [f"{prefix}{''.join(random.choices(chars, k=length-len(prefix)))}" for _ in range(n)]

def get_personal_bulk(n):
    ids = generate_safe_ids(n, 20, "P_")
    return pd.DataFrame([{
        'codigo_personal': ids[i],
        'nombre': fake.first_name()[:100],
        'apellido_paterno': fake.last_name()[:200],
        'apellido_materno': fake.last_name()[:200]
    } for i in range(n)])

def get_fuente_bulk(n):
    ids = generate_safe_ids(n, 10, "F_")
    niveles = ['Federal', 'Estatal', 'Municipal', 'Privado']
    return pd.DataFrame([{
        'id_fuente': ids[i],
        'grado_nivel': random.choice(niveles),
        'programa': f"Fondo {fake.word().upper()} {random.randint(2025, 2030)}"[:100]
    } for i in range(n)])

def get_obra_bulk(n, ids_region, ids_const, ids_sup):
    ids_obra = generate_safe_ids(n, 20, "OB_")
    codigos_exp = generate_safe_ids(n, 15, "EXP_")
    data = []
    for i in range(n):
        data.append({
            'id_obra': ids_obra[i],
            'codigo_expediente': codigos_exp[i],
            'nombre_obra': f"Obra {fake.street_name()} {i}"[:100],
            'etapa': random.randint(1, 10),
            'fecha_inicio': fake.date_between(start_date='-2y', end_date='today'),
            'fecha_final': fake.date_between(start_date='today', end_date='+2y'),
            'descripcion': fake.sentence()[:250],
            'beneficiarios': f"Población {fake.city()}"[:100],
            'id_constructora': random.choice(ids_const),
            'id_region': random.choice(ids_region),
            'codigo_supervisor': random.choice(ids_sup)
        })
    return pd.DataFrame(data)

def generate_informes_chunk(args):
    """Generación paralela de informes con IDs masivos."""
    chunk_size, all_obra_sup_list, start_idx = args
    local_fake = Faker('es_MX')
    chunk_data = []
    total_obras = len(all_obra_sup_list)
    
    for i in range(chunk_size):
        current_idx = (start_idx + i) % total_obras
        id_o, cod_s = all_obra_sup_list[current_idx]
        chunk_data.append({
            'id_informe': f"INF{start_idx + i:017d}",
            'id_obra': id_o,
            'codigo_supervisor': cod_s,
            'ano_infor': 2026,
            'mes': ((start_idx + i) // total_obras) % 12 + 1,
            'porcentaje_avance_fisico': random.randint(0, 100),
            'porcentaje_avance_presupuestario': random.randint(0, 100),
            'doc_infome': f"https://evidencia.mx/doc_{start_idx+i}.pdf"[:100],
            'descripcion': local_fake.sentence(nb_words=6)[:250]
        })
    return pd.DataFrame(chunk_data)
