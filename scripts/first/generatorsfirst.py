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

def get_personal_data(n=50):
    ids = generate_unique_ids(n, 20)
    return pd.DataFrame([{
        'codigo_personal': ids[i],
        'nombre': fake.first_name()[:100],
        'apellido_paterno': fake.last_name()[:200],
        'apellido_materno': fake.last_name()[:200]
    } for i in range(n)])

def get_region_data(n=50):
    ids = generate_unique_ids(n, 5)
    return pd.DataFrame([{
        'id_region': ids[i],
        'comunidad': fake.city()[:50],
        'barrio': fake.street_name()[:150], # Cambiado de street_address a street_name para evitar exceder longitud
        'colonia': fake.city_prefix() if hasattr(fake, 'city_prefix') else "Colonia Centro" 
        # Si 'neighborhood' falla, usamos un prefijo de ciudad o un string fijo para la práctica
    } for i in range(n)])

def get_constructora_data(n=50):
    ids = generate_unique_ids(n, 10)
    rfcs = generate_unique_ids(n, 12)
    return pd.DataFrame([{
        'id_constructora': ids[i],
        'rfc': rfcs[i],
        'nombre_const': fake.company()[:150],
        'tipo_ejecutor': random.choice(['Privada', 'Pública', 'Mixta'])
    } for i in range(n)])
    

def get_fuente_financiamiento_data(n=10):
    ids = generate_unique_ids(n, 10)
    niveles = ['Federal', 'Estatal', 'Municipal']
    return pd.DataFrame([{
        'id_fuente': ids[i],
        'grado_nivel': random.choice(niveles),
        'programa': f"Programa de {fake.job()} {fake.year()}"
    } for i in range(n)])

def get_obra_data(n, ids_region, ids_const, ids_sup):
    data = []
    ids_obra = generate_unique_ids(n, 20)
    codigos_exp = generate_unique_ids(n, 15)
    
    for i in range(n):
        data.append({
            'id_obra': ids_obra[i],
            'codigo_expediente': codigos_exp[i],
            'nombre_obra': f"Construcción de {fake.bs()[:180]}",
            'etapa': random.randint(1, 5),
            'fecha_inicio': fake.date_between(start_date='-1y', end_date='today'),
            'fecha_final': fake.date_between(start_date='today', end_date='+1y'),
            'descripcion': fake.sentence(nb_words=10),
            # Cambiado fake.community() por fake.city() que es 100% seguro en es_MX
            'beneficiarios': f"Población de {fake.city()} y alrededores",
            'id_constructora': random.choice(ids_const),
            'id_region': random.choice(ids_region),
            'codigo_supervisor': random.choice(ids_sup)
        })
    return pd.DataFrame(data)

def get_financia_data(df_obras, df_fuentes):
    data = []
    ids_obra = df_obras['id_obra'].tolist()
    ids_fuente = df_fuentes['id_fuente'].tolist()
    
    for id_o in ids_obra:
        # Cada obra es financiada por 1 o 2 fuentes
        k_fuentes = min(len(ids_fuente), random.randint(1, 2))
        fuentes_seleccionadas = random.sample(ids_fuente, k=k_fuentes)
        for id_f in fuentes_seleccionadas:
            data.append({
                'id_obra': id_o,
                'id_fuente': id_f
            })
    return pd.DataFrame(data)
    
def get_informe_data(n, ids_obra_sup):
   
    data = []
    ids_informe = generate_unique_ids(n, 20)
    
    # Para evitar duplicados (obra, mes, año)
    combinaciones_usadas = set()
    
    intentos = 0
    while len(data) < n and intentos < n * 10:
        obra_seleccionada = random.choice(ids_obra_sup)
        id_o, cod_s = obra_seleccionada
        
        mes = random.randint(1, 12)
        ano = random.randint(2024, 2026)
        
        # Validar restricción UNIQUE
        if (id_o, mes, ano) not in combinaciones_usadas:
            data.append({
                'id_informe': ids_informe[len(data)],
                'id_obra': id_o,
                'codigo_supervisor': cod_s,
                'ano_infor': ano,
                'mes': mes,
                'porcentaje_avance_fisico': random.randint(0, 100),
                'porcentaje_avance_presupuestario': random.randint(0, 100),
                'doc_infome': f"URL_DOCUMENTO_{generate_unique_ids(1, 5)[0]}",
                'descripcion': fake.paragraph(nb_sentences=2)
            })
            combinaciones_usadas.add((id_o, mes, ano))
        intentos += 1
        
    return pd.DataFrame(data)
