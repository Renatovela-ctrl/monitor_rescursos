# Función para calcular el uso de CPU
calcular_uso_cpu() {
    linea_cpu=$(top -bn1 | grep "Cpu(s)")
    cpu_inactiva=$(echo "$linea_cpu" | awk '{print $8}' | sed 's/,/./')
    uso_cpu=$(echo "100 - $cpu_inactiva" | bc)
    echo "$uso_cpu"
}

# Función para calcular el uso de memoria RAM
calcular_uso_memoria() {
    linea_memoria=$(free -m | grep "Mem")
    memoria_total=$(echo "$linea_memoria" | awk '{print $2}')
    memoria_disponible=$(echo "$linea_memoria" | awk '{print $7}')
    memoria_usada_real=$(echo "$memoria_total - $memoria_disponible" | bc)
    uso_memoria_porcentaje=$(echo "scale=2; ($memoria_usada_real / $memoria_total) * 100" | bc)
    echo "$uso_memoria_porcentaje"
}

# Función para calcular el uso de disco en la raíz
calcular_uso_disco() {
    uso_disco_porcentaje=$(df -h / | grep "/" | awk '{print $5}' | sed 's/%//')
    echo "$uso_disco_porcentaje"
}

# Archivo de salida
archivo_salida="resultados.txt"

# Encabezado de la tabla (solo se escribe una vez)
printf "%-10s %-20s %-15s %-15s\n" "Tiempo" "% Total de CPU libre" "% Memoria Libre" "% Disco Libre" > "$archivo_salida"

# Bucle para las mediciones
for i in {1..5}; do
    # Calcular el tiempo transcurrido en segundos
    tiempo_s=$((i * 60))

    # Obtener los valores de uso de CPU, memoria y disco
    uso_cpu=$(calcular_uso_cpu)
    uso_memoria=$(calcular_uso_memoria)
    uso_disco=$(calcular_uso_disco)

    # Guardar resultados en el archivo de salida en formato de tabla
    printf "%-10s %-20s %-15s %-15s\n" "${tiempo_s}s" "$uso_cpu%" "$uso_memoria%" "$uso_disco%" >> "$archivo_salida"
    
    #Ir a la siguiente linea
    ((linea++))

    #Esperar 60 segundos
    sleep 60
done
