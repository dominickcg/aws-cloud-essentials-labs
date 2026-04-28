# Guía de Solución de Problemas - Laboratorio 7: TechShop HA

Esta guía contiene soluciones a los errores más comunes que pueden presentarse durante el laboratorio de TechShop - Arquitectura de Alta Disponibilidad.

---

## Fase 1: Despliegue con CloudFormation

### Error: La pila de CloudFormation falla durante la creación (CREATE_FAILED / ROLLBACK_COMPLETE)

**Síntoma**: El estado de la pila cambia a `CREATE_FAILED` o `ROLLBACK_COMPLETE` y algunos recursos muestran errores en la pestaña **Eventos**.

**Causas posibles**:
1. Los parámetros de VPC o subredes seleccionados son incorrectos o pertenecen a otra VPC
2. No se marcó el checkbox de capacidades IAM al crear la pila
3. Se alcanzó un límite de cuota de AWS (máximo de instancias EC2, VPCs, bases de datos RDS, etc.)
4. El nombre de la pila contiene caracteres no permitidos (espacios, caracteres especiales)
5. Ya existe una pila con el mismo nombre en la región

**Solución**:
1. Revise la pestaña **Eventos** de la pila y busque el primer recurso con estado `CREATE_FAILED` (este es el que inició el rollback)
2. Lea el mensaje de error en la columna **Motivo del estado** para identificar la causa raíz
3. Elimine la pila fallida (espere a que alcance el estado `ROLLBACK_COMPLETE` o `DELETE_COMPLETE`)
4. Vuelva a crear la pila verificando que:
   - El nombre sigue el formato `techshop-ha-{nombre-participante}` (solo letras minúsculas, números y guiones)
   - Los parámetros de VPC y subredes corresponden a la infraestructura compartida del instructor
   - Se marcó el checkbox de capacidades IAM
5. Si el error menciona límites de cuota, notifique al instructor

---

### Error: Checkbox de capacidades IAM olvidado

**Síntoma**: Al intentar crear la pila, aparece el mensaje de error: `Requires capabilities: [CAPABILITY_NAMED_IAM]`.

**Causas posibles**:
1. La plantilla `TechShop-HA-Lab.yaml` crea recursos IAM (Role e InstanceProfile) y CloudFormation requiere confirmación explícita del participante para crear estos recursos

**Solución**:
1. Regrese al paso de creación de la pila en CloudFormation
2. En la sección **Capacidades**, marque el checkbox que dice: "Reconozco que AWS CloudFormation podría crear recursos de IAM con nombres personalizados"
3. Haga clic en **Enviar** para iniciar la creación de la pila

---

### Error: Parámetros de VPC o subredes incorrectos

**Síntoma**: La pila falla durante la creación y los recursos muestran errores relacionados con subredes no encontradas, VPC no válida, o recursos creados en la VPC incorrecta.

**Causas posibles**:
1. Se seleccionó una VPC diferente a la infraestructura compartida del instructor
2. Las subredes seleccionadas no pertenecen a la VPC seleccionada
3. Se confundieron las subredes públicas con las privadas al seleccionar los parámetros

**Solución**:
1. Confirme con el instructor cuáles son los IDs correctos de la VPC y las subredes de la infraestructura compartida
2. Navegue a CloudFormation y revise las **Salidas** de la pila del instructor para obtener los valores correctos de `VpcId`, `PublicSubnetAId`, `PublicSubnetBId`, `PrivateSubnetAId` y `PrivateSubnetBId`
3. Elimine la pila fallida y vuelva a crearla seleccionando los parámetros correctos desde los menús desplegables
4. Verifique que las subredes públicas corresponden a us-east-1a y us-east-1b, y las subredes privadas también

---

## Fase 2: Alta Disponibilidad y Almacenamiento

### Error: La URL de CloudFront no es accesible después de crear la pila

**Síntoma**: Al hacer clic en la URL de CloudFront desde la pestaña **Salidas** de la pila, el navegador muestra un error de tiempo de espera, "403 Forbidden", o "No se puede acceder al sitio".

**Causas posibles**:
1. La distribución de CloudFront aún está propagándose (este proceso tarda aproximadamente 5 minutos después de la creación)
2. Las instancias EC2 aún están inicializándose y no han completado la instalación del servidor web
3. El Health Check del grupo de destino aún no ha marcado las instancias como saludables

**Solución**:
1. Espere 5 minutos después de que la pila alcance el estado `CREATE_COMPLETE` para que CloudFront termine de propagarse
2. Navegue a EC2 > **Grupos de destino**, seleccione el grupo de destino de la pila y verifique la pestaña **Destinos**
3. Confirme que al menos una instancia muestra estado **healthy** (saludable)
4. Si después de 10 minutos las instancias siguen en estado **unhealthy**, revise los grupos de seguridad y los logs de las instancias
5. Intente acceder nuevamente a la URL de CloudFront. Si persiste el error, limpie la caché del navegador o intente en una ventana de incógnito

---

### Error: Problemas de montaje de EFS en instancias EC2

**Síntoma**: Las instancias EC2 no inician correctamente, el sitio web no carga, o los archivos de la aplicación no están disponibles en `/var/www/html/`.

**Causas posibles**:
1. El grupo de seguridad SG-EFS no permite tráfico NFS en el puerto 2049 desde SG-EC2
2. Los mount targets de EFS no están creados en las subredes correctas (deben estar en las subredes privadas)
3. El paquete `amazon-efs-utils` no se instaló correctamente durante la inicialización de la instancia

**Solución**:
1. Navegue a EFS en la consola y verifique que el sistema de archivos tiene dos mount targets, uno en cada subred privada (us-east-1a y us-east-1b)
2. Verifique que el grupo de seguridad asociado a los mount targets permite tráfico TCP en el puerto 2049 desde el grupo de seguridad de las instancias EC2
3. Revise los logs de inicialización de la instancia EC2: navegue a EC2 > seleccione la instancia > **Acciones** > **Monitoreo y solución de problemas** > **Obtener registro del sistema**
4. Si el error persiste, puede ser necesario eliminar la pila y recrearla

---

### Error: Problemas de conectividad con RDS

**Síntoma**: La base de datos RDS no es accesible desde las instancias EC2, o la consola muestra la instancia RDS en estado diferente a **Disponible**.

**Causas posibles**:
1. El grupo de seguridad SG-RDS no permite tráfico MySQL en el puerto 3306 desde SG-EC2
2. El grupo de subredes de la base de datos no incluye las subredes privadas correctas
3. La instancia RDS Multi-AZ aún está en proceso de creación (puede tardar 15 minutos)

**Solución**:
1. Verifique que la instancia RDS muestra estado **Disponible** en la consola de RDS. Si muestra **Creando**, espere a que finalice el aprovisionamiento (aproximadamente 15 minutos)
2. Navegue a EC2 > **Grupos de seguridad** y verifique que SG-RDS tiene una regla de entrada que permite TCP 3306 desde el grupo de seguridad SG-EC2
3. En la consola de RDS, verifique que el **Grupo de subredes** de la base de datos incluye las subredes privadas en us-east-1a y us-east-1b
4. Si el error persiste después de verificar todos los puntos anteriores, notifique al instructor

---

### Error: El Auto Scaling Group no lanza una instancia de reemplazo después de terminar una instancia

**Síntoma**: Después de terminar una instancia EC2 para simular un fallo, pasan más de 5 minutos y el Auto Scaling Group no lanza una nueva instancia.

**Causas posibles**:
1. El período de gracia del Health Check aún no ha expirado (el ASG espera antes de evaluar la salud de las instancias)
2. El Launch Template tiene errores de configuración que impiden lanzar nuevas instancias
3. Se alcanzó el límite de cuota de instancias EC2 en la cuenta
4. No hay capacidad disponible en las zonas de disponibilidad seleccionadas

**Solución**:
1. Navegue a EC2 > **Auto Scaling** > **Grupos de Auto Scaling** y seleccione el grupo de la pila
2. Verifique que la **Capacidad deseada** es 2 y la **Capacidad mínima** es 2
3. Revise la pestaña **Actividad** del grupo de Auto Scaling para ver mensajes de error o actividades recientes de escalado
4. Espere 3-5 minutos adicionales, ya que el ASG necesita tiempo para detectar la instancia terminada y lanzar el reemplazo
5. Si la pestaña **Actividad** muestra errores de lanzamiento, revise el mensaje de error específico
6. Si el error menciona límites de cuota o capacidad, notifique al instructor

---

## Fase 3: Distribución de Contenido y Seguridad

### Error: Acceso directo a S3 denegado (comportamiento esperado)

**Síntoma**: Al intentar acceder directamente a un objeto del bucket S3 mediante su URL de S3, se recibe un error "403 Forbidden" o "Access Denied".

**Causas posibles**:
1. Este es el **comportamiento esperado y correcto**. La política del bucket S3 está configurada con Origin Access Control (OAC) para permitir acceso exclusivamente a través de CloudFront. El acceso público directo al bucket está bloqueado por diseño.

**Solución**:
1. No se requiere ninguna acción correctiva. Este comportamiento confirma que la configuración de seguridad OAC funciona correctamente
2. Para acceder a las imágenes de productos, utilice la URL de CloudFront con la ruta correspondiente (por ejemplo, `https://{dominio-cloudfront}/images/producto-1.svg`)
3. Verifique que el acceso a través de CloudFront funciona correctamente accediendo a una imagen mediante la URL de la distribución

---

### Error: La Web ACL de WAF no es visible en la consola

**Síntoma**: Al navegar a AWS WAF > **Web ACLs**, no aparece la Web ACL creada por la pila de CloudFormation.

**Causas posibles**:
1. El selector de región en la consola de WAF no está configurado en **Global (CloudFront)**. Las Web ACLs con scope `CLOUDFRONT` solo son visibles cuando se selecciona la región "Global (CloudFront)" en la consola de WAF, no en una región específica como us-east-1

**Solución**:
1. En la consola de AWS WAF, busque el selector de región en la parte superior de la página
2. Cambie la región seleccionada a **Global (CloudFront)** en lugar de una región específica
3. La Web ACL de la pila debería aparecer ahora en la lista
4. Si después de seleccionar "Global (CloudFront)" la Web ACL no aparece, verifique que la pila de CloudFormation alcanzó el estado `CREATE_COMPLETE` y que el recurso WAF se creó correctamente en la pestaña **Recursos** de la pila

---

### Error: El encabezado X-Cache muestra "Miss from cloudfront" en cada solicitud

**Síntoma**: Al inspeccionar los encabezados de respuesta en las herramientas de desarrollo del navegador, el encabezado `X-Cache` siempre muestra "Miss from cloudfront" en lugar de "Hit from cloudfront".

**Causas posibles**:
1. La primera solicitud a cualquier recurso siempre será un "Miss" porque CloudFront necesita obtener el contenido del origen y almacenarlo en caché
2. El recurso solicitado corresponde al comportamiento de caché predeterminado (contenido dinámico del ALB) que tiene la política `CachingDisabled`, por lo que nunca se almacena en caché
3. Se está accediendo a una URL diferente en cada solicitud

**Solución**:
1. Para ver un "Hit from cloudfront", acceda a un recurso estático (por ejemplo, una imagen en `/images/producto-1.svg` o un archivo CSS en `/css/styles.css`) que utilice el comportamiento de caché con la política `CachingOptimized`
2. Acceda al mismo recurso estático una segunda vez. La primera solicitud siempre será "Miss"; la segunda debería mostrar "Hit from cloudfront"
3. Si el recurso estático sigue mostrando "Miss" en la segunda solicitud, espere unos segundos y vuelva a intentar, ya que la propagación de caché entre edge locations puede tomar un momento
4. Recuerde que las páginas HTML servidas desde el ALB (comportamiento predeterminado `/*`) tienen la política `CachingDisabled` y siempre mostrarán "Miss" por diseño

---

## Fase 4: Observabilidad

### Error: El dashboard de CloudWatch no muestra datos

**Síntoma**: Al abrir el dashboard de CloudWatch creado por la pila, los widgets de métricas aparecen vacíos o muestran el mensaje "No hay datos disponibles".

**Causas posibles**:
1. Las métricas de CloudWatch tardan aproximadamente 5 minutos en comenzar a aparecer después de que los recursos están activos
2. No se ha generado suficiente tráfico hacia la aplicación para que las métricas se registren

**Solución**:
1. Espere al menos 5 minutos después de que la pila alcance el estado `CREATE_COMPLETE`
2. Genere tráfico accediendo a la URL de CloudFront varias veces y navegando por las páginas de TechShop
3. En el dashboard, verifique que el rango de tiempo seleccionado incluye el período actual (por ejemplo, "Últimas 3 horas")
4. Haga clic en el botón de actualizar del dashboard para cargar los datos más recientes
5. Si después de 10 minutos los widgets siguen vacíos, verifique en la pestaña **Recursos** de CloudFormation que el dashboard se creó correctamente

---

### Error: Las alarmas de CloudWatch muestran estado INSUFFICIENT_DATA

**Síntoma**: Al navegar a CloudWatch > **Alarmas**, las alarmas creadas por la pila muestran el estado **Datos insuficientes** (INSUFFICIENT_DATA) en lugar de **OK** o **En alarma**.

**Causas posibles**:
1. Este es el comportamiento normal para alarmas recién creadas. CloudWatch necesita acumular suficientes puntos de datos (datapoints) antes de poder evaluar el estado de la alarma
2. El período de evaluación de las alarmas es de 300 segundos (5 minutos) con 2 períodos de evaluación, por lo que se necesitan al menos 10 minutos de datos

**Solución**:
1. Espere entre 5 y 10 minutos después de la creación de la pila para que CloudWatch acumule suficientes datos
2. Genere tráfico accediendo a la URL de CloudFront para que las métricas de CPU y ALB se registren
3. Después del período de espera, las alarmas deberían cambiar al estado **OK** (si los umbrales no se han superado) o **En alarma** (si se han superado)
4. Si después de 15 minutos las alarmas siguen en estado **Datos insuficientes**, verifique que las instancias EC2 están en ejecución y que el ALB está recibiendo tráfico

---

## Errores que Requieren Asistencia del Instructor

Los siguientes errores NO deben intentar solucionarse por cuenta propia. Notifique al instructor de inmediato.

### Errores de permisos IAM

**Síntoma**: Mensajes de error que contienen "Access Denied", "UnauthorizedOperation", "You are not authorized to perform this operation", o "User is not authorized".

**Causas posibles**:
1. Los permisos IAM del usuario no son suficientes para crear o gestionar los recursos del laboratorio
2. Existe una política de control de servicios (SCP) que restringe las acciones permitidas
3. Los permisos del rol IAM de las instancias EC2 no están configurados correctamente

⚠️ **No intente solucionar este error por su cuenta.** Notifique al instructor de inmediato. El instructor verificará los permisos de su usuario y realizará los ajustes necesarios en las políticas IAM.

---

### Errores de límites de cuota de AWS

**Síntoma**: Mensajes de error que contienen "LimitExceededException", "ResourceLimitExceeded", "You have exceeded the maximum number of...", o "Insufficient capacity".

**Causas posibles**:
1. Se alcanzó el límite máximo de instancias EC2 en la cuenta
2. Se alcanzó el límite de bases de datos RDS
3. Se alcanzó el límite de distribuciones CloudFront o Web ACLs de WAF
4. Se alcanzó el límite de Elastic IPs, VPCs u otros recursos de red

⚠️ **No intente solucionar este error por su cuenta.** Notifique al instructor de inmediato. El instructor puede solicitar un aumento de cuota o liberar recursos no utilizados en la cuenta compartida.
