FROM python:3.11-slim

RUN apt-get update && \
    apt-get install -y postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# Crea el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia el archivo de dependencias desde tu PC al contenedor
COPY requirements.txt .

# Instala las dependencias de Python dentro del contenedor
RUN pip install --no-cache-dir -r requirements.txt

# Copia TODA la carpeta SCRIPTS dentro del contenedor
#    Se copiará a /app/SCRIPTS/
COPY SCRIPTS/ ./SCRIPTS/

# Copia el script de entrada (entrypoint.sh)
COPY entrypoint.sh .

# Da permiso de ejecución al entrypoint.sh
RUN chmod +x entrypoint.sh

# (Opcional pero recomendado) Añade /app/SCRIPTS al PYTHONPATH
#    Esto permite que dentro de cualquier script puedas hacer:
#    import config, import connection, from first.generatorsfirst import algo
ENV PYTHONPATH=/app/SCRIPTS

# Define qué se ejecuta cuando el contenedor arranca
ENTRYPOINT ["./entrypoint.sh"]