# Práctica 5 - Bases de Datos

**Ingeniería en Sistemas Computacionales**  
**Escuela Superior de Cómputo - IPN**

---

## Descripción

Esta práctica implementa una base de datos relacional para el dominio de **Obras Públicas**, con 6 tablas relacionadas, restricciones de integridad, y tres niveles de poblado (leve, moderado y masivo). Incluye scripts DML avanzados y está completamente dockerizada para su fácil ejecución.

---

## Requisitos previos

- Docker instalado
- Docker Compose instalado

---

## Estructura del proyecto
practica5/
├── sql/
│ ├── ddl/
│ │ └── 01_crear_tablas.sql
│ └── dml/
│ └── consultas_avanzadas.sql
├── SCRIPTS/
│ ├── config.py
│ ├── connection.py
│ ├── first/
│ ├── second/
│ └── third/
├── docker-compose.yml
├── Dockerfile
├── entrypoint.sh
├── requirements.txt
└── README.md


---

## Ejecución

### Poblado Leve (desarrollo)
```bash
docker-compose up


Poblado Moderado (pre-producción)
```bash
NIVEL_POBLADO=moderado docker-compose up

Poblado Masivo (producción)
```bash
NIVEL_POBLADO=masivo docker-compose up

Detener los contenedores
```bash
docker-compose down

Reiniciar desde cero
```bash
docker-compose down -v
docker-compose up

Conectar a la base de datos
```bash
docker exec -it nuevadb psql -U urigc -d Obras_Publicas

Comandos útiles dentro de psql
sql
\dt                          -- Listar tablas
SELECT COUNT(*) FROM obras;  -- Contar registros
\q                           -- Salir

Verificar logs del poblado
docker logs practica5_app

Ejecutar consultas DML
```bash
docker exec -i nuevadb psql -U urigc -d urigc < sql/dml/consultas_avanzadas.sql
