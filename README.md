# Script de Monitoreo de Recursos

Este script monitorea el uso de CPU y RAM de manera continua, ajustando las prioridades de los procesos o finalizándolos si el uso de recursos supera los límites especificados. Además, registra eventos, envía alertas por correo electrónico y almacena los datos en una base de datos MySQL.

## Requisitos Previos

### 1. Requisitos del Sistema
- Sistema basado en Linux
- `mailutils` para alertas por correo electrónico
- Base de datos MySQL para almacenamiento de datos
- `bc` para cálculos de punto flotante

### 2. Paquetes Necesarios
Instala los siguientes paquetes si aún no están instalados:
```bash
sudo apt update
sudo apt install mailutils mysql-client bc
```

### 3. Configuración de la Base de Datos
Crea una base de datos y una tabla en MySQL para almacenar los datos de monitoreo:
```sql
CREATE DATABASE monitor_servidor;

USE monitor_servidor;

CREATE TABLE stats (
    id INT AUTO_INCREMENT PRIMARY KEY,
    timestamp DATETIME NOT NULL,
    cpu_usage FLOAT NOT NULL,
    ram_usage FLOAT NOT NULL,
    action_taken TEXT
);
```

### 4. Configuración del Script
Edita las siguientes variables al inicio del script para adaptarlas a tu entorno:
```bash
LIMITE_CPU=60             # Límite de uso de CPU (%) para ajustar prioridades
LIMITE_RAM=60             # Límite de uso de RAM (%) para tomar acción
LIMITE_FINALIZAR=90       # Límite de uso de CPU (%) para finalizar procesos
DURACION_EXCESO=30        # Tiempo (segundos) para confirmar uso excesivo
ARCHIVO_LOG="/ruta/a/log/monitoreo_recursos.log"
USUARIO_BD="tu_usuario_mysql"
CONTRASENA_BD="tu_contraseña_mysql"
NOMBRE_BD="monitor_servidor"
CORREO="tu_correo@example.com"
```

### 5. Permisos
Asegúrate de que el script tenga permisos de ejecución:
```bash
chmod +x monitoring_script.sh
```

### 6. Configuración del Correo
Verifica la configuración de correo en `/etc/ssmtp/ssmtp.conf` o configura `mailutils` para usar un servidor SMTP. Por ejemplo:
```plaintext
root=tu_correo@example.com
mailhub=smtp.tuproveedor.com:587
AuthUser=tu_correo@example.com
AuthPass=tu_contraseña
UseTLS=YES
UseSTARTTLS=YES
hostname=nombre_de_tu_servidor
```

## Cómo Ejecutarlo
Ejecuta el script como un proceso en segundo plano:
```bash
./monitoring_script.sh &
```

### Configuración del Crontab para Ejecución al Inicio
Agrega el script al `crontab` del sistema para que se inicie automáticamente:

1. Edita el crontab del usuario:
   ```bash
   crontab -e
   ```

2. Agrega la siguiente línea al final del archivo:
   ```bash
   @reboot /ruta/completa/al/script/monitoring_script.sh &
   ```

3. Guarda y cierra el archivo.

Ahora el script se ejecutará automáticamente cada vez que el sistema inicie.

## Funcionalidades
1. **Monitoreo de CPU y RAM**
   - Detecta el uso excesivo de CPU y RAM.
2. **Gestión de Procesos**
   - Ajusta las prioridades de los procesos cuando el uso de CPU excede `LIMITE_CPU`.
   - Finaliza procesos cuando el uso de CPU excede `LIMITE_FINALIZAR`.
3. **Registros**
   - Registra acciones y uso de recursos en un archivo de log.
4. **Notificaciones por Correo**
   - Envía alertas por correo para acciones críticas.
5. **Almacenamiento en Base de Datos**
   - Almacena datos de uso de recursos y acciones en una base de datos MySQL.

## Solución de Problemas
1. **No se Generan Logs**
   - Verifica la ruta del archivo de log y asegúrate de que el script tiene permisos de escritura.
2. **No se Envían Correos**
   - Revisa la configuración del SMTP y la instalación de `mailutils`.
3. **Errores en la Base de Datos**
   - Asegúrate de que la base de datos sea accesible y que las credenciales sean correctas.

## Contribuciones
No dudes en enviar problemas o solicitudes de mejora mediante `pull requests` o `issues`.
