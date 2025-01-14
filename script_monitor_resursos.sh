LIMITE_CPU=60             # Límite de uso de CPU (%) para ajustar prioridades
LIMITE_RAM=60             # Límite de uso de RAM (%) para actuar
LIMITE_FINALIZAR=90       # Límite de uso de CPU (%) para finalizar procesos
DURACION_EXCESO=30        # Tiempo necesario para confirmar exceso (segundos)
ARCHIVO_LOG="/home/renato/pfinal/log/monitoreo_recursos.log"
USUARIO_BD="root"
CONTRASENA_BD="14789632"
NOMBRE_BD="monitor_servidor"
CORREO="renato.vela@ucuenca.edu.ec"

# Función para registrar mensajes en el archivo de log
registrar() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$ARCHIVO_LOG"
}

enviar_correo() {
    ASUNTO="$1"
    MENSAJE="$2"
    echo "$MENSAJE" | mail -s "$ASUNTO" "$CORREO"
}

almacenar_en_bd() {
    USO_CPU=$1
    USO_RAM=$2
    ACCION=$3
    ACCION=$(echo "$ACCION" | sed "s/'/''/g")  # Escapar comillas simples en ACCION

    mysql -u "$USUARIO_BD" -p"$CONTRASENA_BD" "$NOMBRE_BD" -e \
    "INSERT INTO stats (timestamp, cpu_usage, ram_usage, action_taken) \
    VALUES (NOW(), $USO_CPU, $USO_RAM, '$ACCION');" 2>/dev/null || \
    registrar "Error al insertar en la base de datos"
}

ajustar_prioridad() {
    PID=$1
    PRIORIDAD=$2
    renice "$PRIORIDAD" -p "$PID" >/dev/null 2>&1
    registrar "Prioridad ajustada: PID $PID a $PRIORIDAD"
}

finalizar_proceso() {
    PID=$1
    kill -9 "$PID"
    registrar "Proceso finalizado: PID $PID"
}

monitorear_continuo() {
    EXCESOS_CPU=0
    EXCESOS_RAM=0

    while true; do
        USO_CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}' | sed 's/,/./')
        USO_RAM=$(free | grep Mem | awk '{print $3/$2 * 100.0}' | sed 's/,/./')

        if (( $(echo "$USO_CPU > $LIMITE_CPU" | bc -l) )); then
            ((EXCESOS_CPU++))
        else
            EXCESOS_CPU=0
        fi

        if (( $(echo "$USO_RAM > $LIMITE_RAM" | bc -l) )); then
            ((EXCESOS_RAM++))
        else
            EXCESOS_RAM=0
        fi

        if (( EXCESOS_CPU >= DURACION_EXCESO )); then
            PROCESO_TOP=$(ps -eo pid,%cpu,%mem,comm --sort=-%cpu | head -n 2 | tail -n 1)
            read -r PID USO_CPU_PROCESO USO_RAM_PROCESO COMANDO <<< "$PROCESO_TOP"

            if (( $(echo "$USO_CPU > $LIMITE_FINALIZAR" | bc -l) )); then
                finalizar_proceso "$PID"
                ACCION="Proceso finalizado: $COMANDO (PID $PID, CPU $USO_CPU_PROCESO%)"
                enviar_correo "Proceso Finalizado" "$ACCION"
                almacenar_en_bd "$USO_CPU" "$USO_RAM" "$ACCION"
            else
                ajustar_prioridad "$PID" 10
                ACCION="Prioridad ajustada: $COMANDO (PID $PID, CPU $USO_CPU_PROCESO%)"
                enviar_correo "Prioridad Ajustada" "$ACCION"
                almacenar_en_bd "$USO_CPU" "$USO_RAM" "$ACCION"
            fi

            EXCESOS_CPU=0
        fi

        if (( EXCESOS_RAM >= DURACION_EXCESO )); then
            ACCION="Uso excesivo de RAM detectado: $USO_RAM% durante $DURACION_EXCESO segundos"
            enviar_correo "Límite de RAM Excedido" "$ACCION"
            almacenar_en_bd "$USO_CPU" "$USO_RAM" "$ACCION"
            EXCESOS_RAM=0
        fi

        registrar "CPU: $USO_CPU%, RAM: $USO_RAM%"
        almacenar_en_bd "$USO_CPU" "$USO_RAM" ""
        sleep 1
    done
}

monitorear_continuo
