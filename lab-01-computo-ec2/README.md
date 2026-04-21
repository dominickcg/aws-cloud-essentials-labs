# 🖥️ Laboratorio 1: Servidor Web en EC2

## Índice
- [Objetivos de aprendizaje](#objetivos-de-aprendizaje)
- [Tiempo estimado](#tiempo-estimado)
- [Prerrequisitos](#prerrequisitos)
- [Conceptos clave](#conceptos-clave)
- [Paso 1: Verificar región AWS](#paso-1-verificar-region-aws)
- [Paso 2: Crear la instancia EC2](#paso-2-crear-la-instancia-ec2)
- [Paso 3: Verificar despliegue](#paso-3-verificar-despliegue)
- [Paso 4: Notas y buenas prácticas](#paso-4-notas-y-buenas-practicas)
- [Solución de problemas](#solucion-de-problemas)
- [Limpieza de recursos](#limpieza-de-recursos)

## Objetivos de aprendizaje
- Lanzar una instancia EC2 que despliegue automáticamente una página web usando User Data
- Configurar Grupos de seguridad para permitir tráfico HTTP y SSH
- Entender conceptos básicos de EC2, Grupos de seguridad y User Data
- Verificar el despliegue de una aplicación web en EC2

## Tiempo estimado
30-45 minutos

## Prerrequisitos
- Cuenta de AWS con permisos para EC2 y Grupos de seguridad
- Navegador web para acceder a la consola de AWS y verificar el sitio web
- Cliente SSH opcional (no es necesario para desplegar el sitio web debido al User Data)

⚠️ **Importante - Entorno compartido**: Este laboratorio se realiza en una cuenta AWS compartida con otros participantes. Para evitar conflictos y facilitar la identificación de sus recursos:

- Todos los recursos que cree deben incluir su nombre al final
- Utilizaremos el formato `{nombre-participante}` en las instrucciones
- **Ejemplo**: Si su nombre es "carlos", cuando vea `ec2-webserver-{nombre-participante}`, debe escribir `ec2-webserver-carlos`
- **Nunca modifique o elimine recursos que no tengan su nombre**

## Conceptos clave

Antes de comenzar, es útil conocer los servicios de AWS que utilizará en este laboratorio:

- **Amazon EC2 (Elastic Compute Cloud)**: Es un servicio que proporciona servidores virtuales en la nube. Cada servidor virtual se denomina "instancia" y permite ejecutar aplicaciones sin necesidad de adquirir hardware físico.
- **Grupo de seguridad**: Actúa como un firewall virtual que controla el tráfico de red entrante y saliente de una instancia EC2. En este laboratorio, configurará reglas para permitir tráfico HTTP (puerto 80) y SSH (puerto 22).
- **User Data**: Es un script que se ejecuta automáticamente cuando una instancia EC2 se inicia por primera vez. Permite automatizar la configuración inicial del servidor, como instalar software o desplegar una aplicación web.

## Paso 1: Verificar región AWS

1. Verifique que está trabajando en la región correcta:
   - En la esquina superior derecha de la consola de AWS
   - Confirme que dice la región estipulada por el instructor
   - Si no es correcta, haga clic y seleccione la región indicada

## Paso 2: Crear la instancia EC2

1. En la consola de AWS, utilice la barra de búsqueda global (parte superior) y escriba **EC2**, luego haga clic en el servicio EC2.

2. En el panel de navegación de la izquierda, haga clic en **Instancias**.

3. Haga clic en el botón naranja **Lanzar instancia** en la esquina superior derecha.

4. Configure los siguientes parámetros:
   - **Nombre**: `ec2-webserver-{nombre-participante}`
   - **AMI**: Amazon Linux 2023
   - **Tipo de instancia**: t2.micro
   - **Par de claves**: Seleccione su par de claves existente o cree uno nuevo

5. En la sección **Configuración de red**, configure el Grupo de seguridad:
   - **Nombre del grupo de seguridad**: `ec2-sg-webserver-{nombre-participante}`
   - **Regla 1 - SSH**: Puerto 22, origen desde su IP
   - **Regla 2 - HTTP**: Puerto 80, origen desde cualquier lugar (0.0.0.0/0)

6. En la sección **Detalles avanzados**, desplácese hasta el campo **Datos de usuario**.

7. Copie el contenido del archivo [`user-data.sh`](user-data.sh) ubicado en esta carpeta y péguelo en el campo de datos de usuario.
   > Este script instala un servidor web Apache, obtiene las IPs de la instancia, y crea una página web automáticamente con esos datos.

8. Haga clic en el botón naranja **Lanzar instancia** en la parte inferior derecha.

**✓ Verificación**: En la lista de instancias, confirme que:
- El nombre de la instancia es `ec2-webserver-{nombre-participante}`
- El estado de la instancia es **En ejecución** (verde)
- La columna **Comprobaciones de estado** muestra "2/2 comprobaciones aprobadas" (esto puede tardar 2-3 minutos)

## Paso 3: Verificar despliegue

1. En la lista de instancias, seleccione su instancia `ec2-webserver-{nombre-participante}`.

2. En el panel de detalles inferior, copie la **Dirección IPv4 pública**.

3. Abra una nueva pestaña en su navegador y pegue la dirección IP pública.

4. Debería ver la página web con:
   - Mensaje de bienvenida
   - IP privada de la instancia
   - IP pública de la instancia

**✓ Verificación**: Confirme que la página web muestra correctamente las direcciones IP privada y pública de su instancia EC2.

## Paso 4: Notas y buenas prácticas

- User Data ejecuta comandos como root al iniciar la instancia. Solo incluya scripts de prueba o configuración inicial.
- El puerto SSH (22) puede cerrarse después del laboratorio para mayor seguridad si no necesita acceso remoto.

## Solución de problemas

Si encuentra dificultades durante este laboratorio, consulte la [Guía de Solución de Problemas](TROUBLESHOOTING.md) que contiene soluciones a errores comunes.

**Errores que requieren asistencia del instructor:**
- Errores de permisos IAM
- Errores de límites de cuota de AWS

## Limpieza de recursos

⚠️ **Importante**: Esta limpieza es opcional. Solo realícela si NO continuará con el Laboratorio 4 del programa.

Para instrucciones detalladas sobre cómo eliminar los recursos creados en este laboratorio, consulte el documento [LIMPIEZA.md](LIMPIEZA.md).