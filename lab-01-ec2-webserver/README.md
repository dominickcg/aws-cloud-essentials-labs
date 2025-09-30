# Lab 1: Servidor Web en EC2

## Objetivo
- Lanzar una instancia EC2 que despliegue automáticamente una página web usando User Data.
- Mostrar en la web la IP privada y pública de la instancia.
- Entender conceptos básicos de EC2, Security Groups y User Data.

## Duración estimada
30–45 minutos

## Requisitos
- Cuenta de AWS con permisos para EC2 y Security Groups.
- Navegador para acceder a la web.
- Cliente SSH opcional (no es necesario para desplegar sitio web debido al User Data).

## Pasos

### 1. Crear la instancia EC2
1. Ir a **EC2 → Lanzar instancia**.
2. Configurar:
   - **AMI:** Amazon Linux 2
   - **Tipo de instancia:** t2.micro
   - **Par de claves:** seleccionar o crear nueva
3. Configurar **Security Group**:
   - SSH (22) desde tu IP
   - HTTP (80) desde cualquier lugar
4. En **Detalles avanzados → Datos de usuario**, pegar el contenido de `user-data.sh`.
5. Lanzar la instancia.

### 2. Verificar despliegue
1. Esperar unos minutos a que la instancia inicie.
2. Abrir la IP pública de la EC2 en un navegador.
3. Deberías ver la página con:
   - Mensaje de bienvenida
   - IP privada
   - IP pública

### 3. Notas y buenas prácticas
- User Data ejecuta comandos como root. Solo incluye scripts de prueba.
- SSH puede cerrarse después del lab para mayor seguridad.
- Esta instancia servirá como base para los siguientes laboratorios.