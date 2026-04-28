# Guía de Solución de Problemas - Laboratorio 4

Esta guía contiene soluciones a errores comunes que pueden ocurrir durante la ejecución del Laboratorio 4: Página Web Dinámica con RDS.

## Errores Comunes

### Error: La base de datos RDS permanece en estado "Creando" por mucho tiempo

**Síntoma**: La base de datos RDS muestra estado **Creando** (color naranja) por más de 20 minutos.

**Causas posibles**:
1. El aprovisionamiento de RDS normalmente tarda 10-15 minutos, pero puede extenderse
2. AWS está experimentando alta demanda en la región
3. Hay un problema con la configuración de la base de datos

**Solución**:
1. Espere hasta 20 minutos antes de tomar acción
2. Verifique el estado en **RDS → Bases de datos**
3. Si después de 20 minutos sigue en "Creando", refresque la página de la consola
4. Si después de 25 minutos no cambia a "Disponible", notifique al instructor
5. NO intente eliminar y recrear la base de datos sin consultar al instructor

---

### Error: No puedo conectarme a la base de datos RDS desde EC2

**Síntoma**: La aplicación web no puede conectarse a la base de datos RDS, muestra errores de conexión o timeout.

**Causas posibles**:
1. El Security Group de RDS no permite conexiones desde el Security Group de EC2
2. El punto de enlace (endpoint) de RDS no fue reemplazado correctamente en el script user-data.sh
3. La base de datos RDS no está en estado "Disponible"
4. Las credenciales de la base de datos son incorrectas
5. La instancia EC2 y la base de datos RDS están en VPCs diferentes

**Solución**:
1. Verifique el Security Group de RDS:
   - En el panel de RDS, seleccione su base de datos
   - En la pestaña **Conectividad y seguridad**, haga clic en el Security Group
   - Verifique que existe una regla de entrada para MYSQL/Aurora (puerto 3306)
   - Confirme que el origen es `ec2-sg-lab4-{nombre-participante}`
2. Verifique el punto de enlace en el script user-data:
   - Conéctese por SSH a la instancia EC2
   - Ejecute: `cat /var/log/cloud-init-output.log` para ver los logs de inicialización
   - Busque errores relacionados con la conexión a la base de datos
3. Confirme que la base de datos está en estado **Disponible**:
   - En **RDS → Bases de datos**, verifique el estado
4. Verifique las credenciales:
   - Usuario: `admin`
   - Contraseña: `Lab123456**`
5. Si el problema persiste, termine la instancia EC2 y créela nuevamente asegurándose de reemplazar correctamente `[RDS-ENDPOINT]`

---

### Error: La aplicación web no se carga en el navegador

**Síntoma**: Al acceder a la dirección IP pública de la instancia EC2, la página no carga, muestra timeout o "No se puede acceder al sitio".

**Causas posibles**:
1. El Security Group de EC2 no permite tráfico HTTP (puerto 80)
2. La instancia EC2 no tiene IP pública asignada
3. El script user-data.sh aún está ejecutándose (puede tardar 5-10 minutos)
4. Hay un error en el script user-data.sh que impidió la instalación

**Solución**:
1. Verifique el Security Group de EC2:
   - En el panel de EC2, haga clic en **Grupos de seguridad**
   - Seleccione `ec2-sg-lab4-{nombre-participante}`
   - En la pestaña **Reglas de entrada**, confirme que existe una regla para HTTP (puerto 80) con origen `0.0.0.0/0`
2. Verifique que la instancia tiene IP pública:
   - En la lista de instancias, confirme que la columna **IPv4 pública** tiene una dirección IP
3. Espere 5-10 minutos después de que la instancia esté en estado "En ejecución":
   - El script user-data necesita tiempo para instalar Apache, PHP y configurar la aplicación
4. Verifique los logs del script user-data:
   - Conéctese por SSH a la instancia
   - Ejecute: `sudo tail -f /var/log/cloud-init-output.log`
   - Busque errores en la instalación
5. Verifique que Apache está ejecutándose:
   - Ejecute: `sudo systemctl status httpd`
   - Si no está activo, ejecute: `sudo systemctl start httpd`

---

### Error: El formulario no guarda datos en la base de datos

**Síntoma**: La aplicación web se carga correctamente, pero al enviar el formulario los datos no se guardan o no aparecen en "Ver Registros".

**Causas posibles**:
1. La conexión a la base de datos RDS no está funcionando
2. La tabla de la base de datos no fue creada correctamente
3. Hay un error en el código PHP de la aplicación
4. Las credenciales de la base de datos son incorrectas

**Solución**:
1. Verifique la conectividad a RDS desde EC2:
   - Conéctese por SSH a la instancia EC2
   - Ejecute: `mysql -h [RDS-ENDPOINT] -u admin -p`
   - Ingrese la contraseña: `Lab123456**`
   - Si no puede conectar, revise el error anterior sobre conectividad RDS
2. Verifique que la tabla existe:
   - Una vez conectado a MySQL, ejecute: `USE lab4_rds;`
   - Ejecute: `SHOW TABLES;`
   - Debería ver la tabla `formulario`
   - Si no existe, ejecute el script de configuración:
     ```sql
     CREATE DATABASE IF NOT EXISTS lab4_rds;
     USE lab4_rds;
     CREATE TABLE IF NOT EXISTS formulario (
       id INT AUTO_INCREMENT PRIMARY KEY,
       nombre VARCHAR(100) NOT NULL,
       apellido VARCHAR(100) NOT NULL,
       email VARCHAR(150) NOT NULL UNIQUE,
       telefono VARCHAR(20),
       fecha_registro DATETIME DEFAULT (NOW())
     );
     ```
3. Verifique los logs de PHP:
   - Ejecute: `sudo tail -f /var/log/httpd/error_log`
   - Busque errores relacionados con la conexión a la base de datos
4. Verifique que el endpoint de RDS está correctamente configurado:
   - Ejecute: `cat /var/www/html/config.php | grep DB_HOST`
   - Confirme que el endpoint es correcto y no muestra `[RDS-ENDPOINT]`

---

### Error: No puedo copiar el punto de enlace (endpoint) de RDS

**Síntoma**: No encuentro dónde copiar el punto de enlace de la base de datos RDS o el valor copiado parece incorrecto.

**Causas posibles**:
1. La base de datos aún no está en estado "Disponible"
2. No está viendo la sección correcta en la consola de RDS
3. Copió el identificador de la base de datos en lugar del endpoint

**Solución**:
1. Verifique que la base de datos está en estado **Disponible**:
   - En **RDS → Bases de datos**, el estado debe ser verde
2. Acceda al endpoint correcto:
   - Haga clic en el identificador de su base de datos `database-lab4-{nombre-participante}`
   - En la pestaña **Conectividad y seguridad**, busque la sección **Punto de enlace y puerto**
   - Copie el valor del **Punto de enlace** (termina en `.rds.amazonaws.com`)
3. NO copie el identificador de la base de datos (que es solo `database-lab4-{nombre-participante}`)
4. El formato correcto del endpoint es: `database-lab4-nombre.xxxxx.us-east-1.rds.amazonaws.com`

---

### Error: Olvidé reemplazar [RDS-ENDPOINT] en el script user-data.sh

**Síntoma**: La aplicación web no funciona y al revisar los logs aparecen errores de conexión a `[RDS-ENDPOINT]`.

**Causas posibles**:
1. No reemplazó el placeholder `[RDS-ENDPOINT]` con el punto de enlace real de RDS
2. Copió el script user-data.sh sin modificarlo

**Solución**:
1. Termine la instancia EC2 actual:
   - En el panel de EC2, seleccione la instancia
   - Haga clic en **Estado de la instancia → Terminar instancia**
2. Copie el punto de enlace correcto de RDS (ver error anterior)
3. Abra el archivo `user-data.sh` en un editor de texto
4. Busque la línea que contiene `[RDS-ENDPOINT]`
5. Reemplace `[RDS-ENDPOINT]` con el punto de enlace real de su base de datos
6. Guarde el archivo modificado
7. Lance una nueva instancia EC2 siguiendo las instrucciones del Paso 5
8. Esta vez, copie y pegue el contenido del archivo `user-data.sh` YA MODIFICADO

---

### Error: El Security Group de RDS no tiene el Security Group de EC2 como origen

**Síntoma**: La aplicación no puede conectarse a RDS, aparecen errores de timeout o "Connection refused".

**Causas posibles**:
1. Al crear el Security Group de RDS, no seleccionó el Security Group de EC2 como origen
2. Seleccionó una dirección IP en lugar del Security Group
3. El Security Group de EC2 fue eliminado o modificado

**Solución**:
1. Verifique la configuración del Security Group de RDS:
   - En el panel de EC2, haga clic en **Grupos de seguridad**
   - Seleccione `rds-sg-lab4-{nombre-participante}`
   - En la pestaña **Reglas de entrada**, verifique la regla MYSQL/Aurora
2. Si el origen NO es `ec2-sg-lab4-{nombre-participante}`:
   - Haga clic en **Editar reglas de entrada**
   - Elimine la regla incorrecta
   - Haga clic en **Agregar regla**
   - **Tipo**: MYSQL/Aurora
   - **Origen**: Personalizado
   - En el campo de búsqueda, escriba y seleccione `ec2-sg-lab4-{nombre-participante}`
   - Haga clic en **Guardar reglas**
3. Espere 1-2 minutos y pruebe la aplicación nuevamente

---

### Error: No puedo conectarme por SSH a la instancia EC2

**Síntoma**: Al intentar conectar por SSH a la instancia EC2, aparece un error de timeout o "Connection refused".

**Causas posibles**:
1. El Security Group de EC2 no permite tráfico SSH (puerto 22)
2. Su dirección IP cambió y ya no está permitida en el Security Group
3. La instancia no tiene IP pública
4. El par de claves no es correcto

**Solución**:
1. Verifique el Security Group de EC2:
   - En el panel de EC2, haga clic en **Grupos de seguridad**
   - Seleccione `ec2-sg-lab4-{nombre-participante}`
   - En la pestaña **Reglas de entrada**, confirme que existe una regla para SSH (puerto 22)
   - Verifique que el origen incluye su IP actual
2. Si su IP cambió:
   - Haga clic en **Editar reglas de entrada**
   - Modifique la regla SSH
   - Cambie el origen a **Mi IP** (esto detectará automáticamente su IP actual)
   - Haga clic en **Guardar reglas**
3. Verifique que la instancia tiene IP pública asignada
4. Confirme que está usando el par de claves correcto del Laboratorio 1
5. Use el usuario correcto: `ec2-user`

---

### Error: La contraseña de RDS no funciona

**Síntoma**: Al intentar conectarse a la base de datos RDS, aparece "Access denied" o error de autenticación.

**Causas posibles**:
1. La contraseña ingresada es incorrecta
2. Hay espacios adicionales al copiar la contraseña
3. El usuario maestro es incorrecto
4. La contraseña no cumple con los requisitos de complejidad de RDS

**Solución**:
1. Verifique las credenciales correctas:
   - **Usuario**: `admin`
   - **Contraseña**: `Lab123456**`
2. Asegúrese de escribir la contraseña exactamente como se muestra (distingue mayúsculas y minúsculas)
3. No incluya espacios antes o después de la contraseña
4. Si creó la base de datos con una contraseña diferente:
   - Necesitará usar esa contraseña en lugar de la del laboratorio
   - Actualice el archivo `user-data.sh` con la contraseña correcta antes de lanzar EC2
5. Si olvidó la contraseña, puede modificarla:
   - En **RDS → Bases de datos**, seleccione su base de datos
   - Haga clic en **Modificar**
   - En **Configuración**, ingrese una nueva contraseña maestra
   - Haga clic en **Continuar** y **Modificar instancia de base de datos**
   - Actualice el script user-data.sh con la nueva contraseña

---

### Error: Eliminé accidentalmente el Security Group predeterminado de RDS

**Síntoma**: Al crear la instancia RDS, eliminé el grupo `default` pero ahora RDS no tiene ningún Security Group asignado.

**Causas posibles**:
1. Eliminó el grupo `default` antes de agregar `rds-sg-lab4-{nombre-participante}`
2. La base de datos quedó sin Grupos de seguridad

**Solución**:
1. Si la base de datos aún está en estado "Creando":
   - Espere a que esté en estado **Disponible**
2. Modifique el Security Group de la base de datos:
   - En **RDS → Bases de datos**, seleccione su base de datos
   - Haga clic en **Modificar**
   - Desplácese hasta la sección **Conectividad**
   - En **Grupo de seguridad de VPC**, seleccione `rds-sg-lab4-{nombre-participante}`
   - Haga clic en **Continuar**
   - Seleccione **Aplicar inmediatamente**
   - Haga clic en **Modificar instancia de base de datos**
3. Espere 2-3 minutos para que el cambio se aplique
4. Verifique que el Security Group está correctamente asignado en la pestaña **Conectividad y seguridad**

---

### Error: La aplicación muestra "Error al conectar a la base de datos"

**Síntoma**: La página web se carga pero muestra un mensaje de error relacionado con la conexión a la base de datos.

**Causas posibles**:
1. El endpoint de RDS no está correctamente configurado en el código PHP
2. La base de datos RDS no está accesible desde EC2
3. Las credenciales son incorrectas
4. La base de datos o tabla no existe

**Solución**:
1. Conéctese por SSH a la instancia EC2
2. Verifique la conectividad a RDS:
   ```bash
   mysql -h [RDS-ENDPOINT] -u admin -p
   ```
   - Ingrese la contraseña: `Lab123456**`
   - Si no puede conectar, revise los errores de Grupos de seguridad anteriores
3. Si puede conectar, verifique la base de datos:
   ```sql
   SHOW DATABASES;
   USE lab4_rds;
   SHOW TABLES;
   ```
4. Si la base de datos o tabla no existe, créela:
   ```sql
   CREATE DATABASE IF NOT EXISTS lab4_rds;
   USE lab4_rds;
   CREATE TABLE IF NOT EXISTS formulario (
     id INT AUTO_INCREMENT PRIMARY KEY,
     nombre VARCHAR(100) NOT NULL,
     apellido VARCHAR(100) NOT NULL,
     email VARCHAR(150) NOT NULL UNIQUE,
     telefono VARCHAR(20),
     fecha_registro DATETIME DEFAULT (NOW())
   );
   ```
5. Verifique los logs de Apache:
   ```bash
   sudo tail -f /var/log/httpd/error_log
   ```

---

## Errores que Requieren Asistencia del Instructor

Si encuentra alguno de los siguientes errores, **notifique al instructor inmediatamente**. No intente solucionar estos errores por su cuenta:

### Error de permisos IAM

**Síntoma**: Aparece un mensaje indicando que no tiene permisos para realizar una acción en RDS o EC2 (por ejemplo, "You are not authorized to perform this operation" o "No está autorizado para realizar esta operación").

**Acción**: ⚠️ Notifique al instructor de inmediato. Este error requiere ajustes en las políticas IAM de su cuenta.

---

### Error de límites de cuota de AWS

**Síntoma**: Aparece un mensaje indicando que ha alcanzado el límite de recursos (por ejemplo, "DB instance limit exceeded", "Security group limit exceeded", "Cannot exceed quota for DBInstances").

**Acción**: ⚠️ Notifique al instructor de inmediato. Este error requiere solicitar un aumento de cuota o liberar recursos existentes.

---

### Error: La base de datos RDS está en estado "Failed"

**Síntoma**: La base de datos RDS muestra estado **Failed** (fallido) en lugar de **Disponible**.

**Acción**: ⚠️ Notifique al instructor de inmediato. La base de datos necesita ser eliminada y recreada. El instructor puede ayudarle a identificar la causa del fallo y recrear la base de datos correctamente.

---

### Error: "InsufficientInstanceCapacity" al lanzar instancias EC2 o RDS

**Síntoma**: Aparece un mensaje indicando "InsufficientInstanceCapacity" al intentar lanzar la instancia EC2 o crear la base de datos RDS.

**Acción**: ⚠️ Notifique al instructor de inmediato. Este error indica que AWS no tiene capacidad disponible para el tipo de instancia en esa zona de disponibilidad. El instructor puede sugerir usar una zona de disponibilidad diferente o un tipo de instancia alternativo.

---

### Error: No puedo ver la VPC predeterminada

**Síntoma**: Al crear los Grupos de seguridad o la instancia RDS, no aparece ninguna VPC en la lista de opciones o la VPC predeterminada no está disponible.

**Acción**: ⚠️ Notifique al instructor de inmediato. Esto puede indicar que la VPC predeterminada fue eliminada o que hay un problema con la configuración de su cuenta.

---

### Error: La base de datos RDS se eliminó accidentalmente

**Síntoma**: Eliminó accidentalmente la base de datos RDS y necesita recrearla, pero ya tiene recursos dependientes configurados.

**Acción**: ⚠️ Notifique al instructor de inmediato. El instructor puede ayudarle a recrear la base de datos y reconfigurar la aplicación correctamente.

---

### Error: No puedo eliminar el Security Group porque está en uso

**Síntoma**: Al intentar eliminar un Security Group, aparece un error indicando que está en uso por una instancia RDS o EC2.

**Acción**: Si necesita eliminar el Security Group:
1. Primero elimine o modifique los recursos que lo están usando (instancias EC2 o RDS)
2. Si el problema persiste después de eliminar los recursos, espere 5-10 minutos
3. Si aún no puede eliminarlo, notifique al instructor

