# Guía de Solución de Problemas - Laboratorio 1

Esta guía contiene soluciones a errores comunes que pueden ocurrir durante la ejecución del Laboratorio 1: Servidor Web en EC2.

## Errores Comunes

### Error: No se puede acceder a la página web (timeout o no carga)

**Síntoma**: Al intentar acceder a la dirección IP pública de la instancia en el navegador, la página no carga o muestra un error de timeout.

**Causas posibles**:
1. El Security Group no tiene el puerto 80 (HTTP) abierto correctamente
2. El Security Group tiene el puerto 80 abierto pero con origen incorrecto
3. La instancia aún está iniciando y el User Data no ha terminado de ejecutarse
4. El servidor web Apache no se instaló correctamente

**Solución**:
1. Verifique el Security Group de la instancia:
   - En la consola de EC2, seleccione su instancia
   - En la pestaña **Seguridad**, haga clic en el nombre del Security Group
   - Verifique que existe una regla de entrada para el puerto 80 con origen 0.0.0.0/0
   - Si no existe, haga clic en **Editar reglas de entrada** y agregue la regla HTTP
2. Espere 3-5 minutos después del lanzamiento para que el User Data termine de ejecutarse
3. Verifique que las comprobaciones de estado muestren "2/2 comprobaciones aprobadas"
4. Si el problema persiste, conéctese por SSH y verifique el estado del servicio Apache con: `sudo systemctl status httpd`

---

### Error: No se puede conectar por SSH a la instancia EC2

**Síntoma**: Al intentar conectar por SSH, aparece un error de timeout o "Connection refused".

**Causas posibles**:
1. El Security Group no tiene el puerto 22 (SSH) abierto
2. El Security Group tiene el puerto 22 abierto pero con origen incorrecto (no incluye su IP actual)
3. La instancia no tiene IP pública asignada
4. El par de claves utilizado no coincide con el configurado en la instancia

**Solución**:
1. Verifique el Security Group:
   - Confirme que existe una regla de entrada para el puerto 22
   - Verifique que el origen incluye su dirección IP actual (puede usar "Mi IP" al crear la regla)
2. Verifique que la instancia tiene una IP pública asignada en los detalles de la instancia
3. Asegúrese de usar el par de claves correcto al conectar
4. Verifique que está usando el usuario correcto: `ec2-user` para Amazon Linux 2023

---

### Error: La instancia está en estado "pending" por mucho tiempo

**Síntoma**: La instancia permanece en estado "pending" (pendiente) por más de 5 minutos.

**Causas posibles**:
1. Problema temporal con la disponibilidad de recursos en AWS
2. Error en el User Data que impide el inicio correcto
3. Problema con la AMI seleccionada

**Solución**:
1. Espere hasta 10 minutos, ya que ocasionalmente el lanzamiento puede tardar más de lo normal
2. Si después de 10 minutos sigue en "pending", detenga la instancia y lance una nueva
3. Verifique que seleccionó la AMI correcta: Amazon Linux 2023
4. Si el problema persiste, notifique al instructor

---

### Error: Las comprobaciones de estado fallan (1/2 o 0/2)

**Síntoma**: En la columna **Comprobaciones de estado**, aparece "1/2 comprobaciones aprobadas" o "0/2 comprobaciones aprobadas" después de varios minutos.

**Causas posibles**:
1. Error en el script de User Data que impide el inicio correcto del sistema
2. Problema con la configuración de red de la instancia
3. Problema con el tipo de instancia o recursos insuficientes

**Solución**:
1. Espere al menos 5 minutos después del lanzamiento, ya que las comprobaciones pueden tardar
2. Revise el script de User Data para asegurarse de que no tiene errores de sintaxis
3. Conéctese por SSH (si es posible) y revise los logs del sistema: `sudo cat /var/log/cloud-init-output.log`
4. Si las comprobaciones siguen fallando después de 10 minutos, termine la instancia y lance una nueva
5. Si el problema persiste, notifique al instructor

---

### Error: La página web muestra "403 Forbidden" o "404 Not Found"

**Síntoma**: La página web carga pero muestra un error 403 Forbidden o 404 Not Found en lugar del contenido esperado.

**Causas posibles**:
1. El User Data no se ejecutó correctamente
2. Los archivos del sitio web no se crearon en la ubicación correcta
3. Los permisos de los archivos no son correctos
4. El servicio Apache no está configurado correctamente

**Solución**:
1. Conéctese por SSH a la instancia
2. Verifique que el servicio Apache está en ejecución: `sudo systemctl status httpd`
3. Verifique que existe el archivo index.html: `ls -la /var/www/html/`
4. Revise los logs de User Data para identificar errores: `sudo cat /var/log/cloud-init-output.log`
5. Si el archivo no existe, ejecute manualmente los comandos del User Data
6. Verifique los permisos del directorio: `sudo chmod 755 /var/www/html/`

---

### Error: No puedo crear el Security Group con el nombre especificado

**Síntoma**: Al intentar crear el Security Group, aparece un error indicando que el nombre ya existe.

**Causas posibles**:
1. Ya existe un Security Group con ese nombre en su cuenta
2. Eliminó una instancia anterior pero el Security Group no se eliminó

**Solución**:
1. En el panel de navegación de EC2, haga clic en **Grupos de seguridad**
2. Busque el Security Group con el nombre `ec2-sg-webserver-{nombre-participante}`
3. Si existe y no está en uso, selecciónelo y haga clic en **Acciones** > **Eliminar grupos de seguridad**
4. Si está en uso por otra instancia, primero elimine o modifique esa instancia
5. Intente crear el Security Group nuevamente

---

### Error: La instancia se lanza pero no aparece en la lista

**Síntoma**: Después de hacer clic en "Lanzar instancia", no aparece ninguna instancia nueva en la lista.

**Causas posibles**:
1. Está viendo la región AWS incorrecta
2. El filtro de la lista de instancias está ocultando la nueva instancia
3. Error temporal en la consola de AWS

**Solución**:
1. Verifique la región AWS en la esquina superior derecha de la consola
2. Asegúrese de estar en la región correcta estipulada por el instructor
3. En la lista de instancias, verifique que no hay filtros activos (busque el ícono de filtro)
4. Actualice la página del navegador (F5)
5. Si la instancia no aparece después de 2 minutos, revise la sección de notificaciones en la consola para ver si hubo algún error

---

## Errores que Requieren Asistencia del Instructor

Si encuentra alguno de los siguientes errores, **notifique al instructor inmediatamente**. No intente solucionar estos errores por su cuenta:

### Error de permisos IAM

**Síntoma**: Aparece un mensaje indicando que no tiene permisos para realizar una acción (por ejemplo, "You are not authorized to perform this operation").

**Acción**: ⚠️ Notifique al instructor de inmediato. Este error requiere ajustes en las políticas IAM de su cuenta.

---

### Error de límites de cuota de AWS

**Síntoma**: Aparece un mensaje indicando que ha alcanzado el límite de recursos (por ejemplo, "You have reached your quota for instances" o "vCPU limit exceeded").

**Acción**: ⚠️ Notifique al instructor de inmediato. Este error requiere solicitar un aumento de cuota o liberar recursos existentes.

---

### Error de VPC o subredes no disponibles

**Síntoma**: Al intentar lanzar la instancia, aparece un error indicando que no hay VPC o subredes disponibles.

**Acción**: ⚠️ Notifique al instructor de inmediato. Este error puede indicar un problema con la configuración de red de la cuenta.

---

### Error: "InsufficientInstanceCapacity"

**Síntoma**: Aparece un mensaje indicando "InsufficientInstanceCapacity" al intentar lanzar la instancia.

**Acción**: ⚠️ Notifique al instructor de inmediato. Este error indica que AWS no tiene capacidad disponible para el tipo de instancia en esa zona de disponibilidad.
