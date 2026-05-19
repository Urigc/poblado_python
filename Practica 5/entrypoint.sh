#!/bin/bash

echo "========================================="
echo "Iniciando proceso de poblado"
echo "Nivel seleccionado: ${NIVEL_POBLADO}"
echo "========================================="

# Función para esperar a que PostgreSQL esté listo
esperar_bd() {
    echo "Esperando a que la base de datos en $DB_HOST:$DB_PORT esté disponible..."
    until pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER"; do
        sleep 1
    done
    echo "Base de datos lista!"
}

# Llamar a la función de espera
esperar_bd

# Ejecutar según el nivel
case "$NIVEL_POBLADO" in
    leve)
        echo ">>> Ejecutando poblado LEVE"
        python /app/SCRIPTS/first/mainfirst.py
        ;;
    
    moderado)
        echo ">>> Ejecutando poblado MODERADO"
        echo ">>> Paso 1: Poblando tablas principales"
        python /app/SCRIPTS/second/main2.py
        
        echo ">>> Paso 2: Poblando tablas secundarias"
        python /app/SCRIPTS/second/pobladosecun/mainsecu.py
        ;;
    
    masivo)
        echo ">>> Ejecutando poblado MASIVO"
        python /app/SCRIPTS/third/main3.py
        ;;
    
    *)
        echo "ERROR: Nivel '$NIVEL_POBLADO' no válido."
        echo "Opciones válidas: leve, moderado, masivo"
        exit 1
        ;;
esac

echo "========================================="
echo "Poblado completado exitosamente"
echo "========================================="

# Mantener el contenedor vivo para que el profesor pueda inspeccionar
# (opcional, si quieres que se cierre automático, quita esta línea)
tail -f /dev/null