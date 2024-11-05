# Función para calcular el porcentaje de CPU libre
calcular_cpu_libre() {
    linea_cpu=$(top -bn1 | grep "Cpu(s)")
    cpu_inactiva=$(echo "$linea_cpu" | awk '{print $8}' | sed 's/,/./')
    cpu_libre=$(echo "$cpu_inactiva" | bc)
    echo "$cpu_libre"
}

# Función para calcular el porcentaje de memoria libre
calcular_memoria_libre() {
    linea_memoria=$(free -m | grep "Mem")
    memoria_total=$(echo "$linea_memoria" | awk '{print $2}')
    memoria_usada=$(echo "$linea_memoria" | awk '{print $4}')
    memoria_libre_porcentaje=$(echo "scale=2; 100 - ($memoria_usada / $memoria_total) * 100" | bc)
    echo "$memoria_libre_porcentaje"
}

# Función para calcular el porcentaje de disco libre
calcular_disco_libre() {
    disco_libre_porcentaje=$(df -h / | grep "/" | awk '{print 100 - $5}' | sed 's/%//')
    echo "$disco_libre_porcentaje"
}

# Archivo de salida
archivo_salida="resultados.txt"

# Encabezado de la tabla (solo se escribe una vez)
printf "%-10s %-20s %-15s %-15s\n" "Tiempo" "% Total de CPU libre" "% Memoria Libre" "% Disco Libre" > "$archivo_salida"

# Bucle para las mediciones
for i in {1..5}; do
    # Calcular el tiempo transcurrido en segundos
    tiempo_s=$((i * 60))

    # Obtener los valores de CPU libre, memoria libre y disco libre
    cpu_libre=$(calcular_cpu_libre)
    memoria_libre=$(calcular_memoria_libre)
    disco_libre=$(calcular_disco_libre)

    # Guardar resultados en el archivo de salida en formato de tabla
    printf "%-10s %-20s %-15s %-15s\n" "${tiempo_s}s" "$cpu_libre%" "$memoria_libre%" "$disco_libre%" >> "$archivo_salida"
    
    sleep 60
done
