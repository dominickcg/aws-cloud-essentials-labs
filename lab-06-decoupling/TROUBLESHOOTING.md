# Guía de Solución de Problemas - Laboratorio 6

Esta guía contiene soluciones a errores comunes que pueden ocurrir durante el Laboratorio 6: Desacoplamiento con Amazon SNS y SQS. Los problemas están organizados por fase del laboratorio para facilitar su búsqueda.

---

## Creación de Recursos

Esta sección cubre errores que pueden ocurrir al crear la cola SQS y el tema SNS.

### Error: No puedo crear la cola SQS

**Síntoma**: Al intentar crear la cola SQS, aparece un mensaje de error indicando que la operación no se puede completar, o el botón "Crear cola" no responde.

**Causas posibles**:
1. **Permisos IAM insuficientes**: Su usuario no tiene los permisos necesarios para crear colas SQS
2. **Límite de cuota alcanzado**: La cuenta AWS ha alcanzado el límite máximo de colas SQS permitidas en la región
3. **Nombre de cola duplicado**: Ya existe una cola con el mismo nombre en la región (recuerde usar su nombre de participante en el sufijo)
4. **Problema de conectividad**: Pérdida temporal de conexión con los servicios de AWS

**Solución**:
1. **Para nombre duplicado**: Verifique que está usando el formato correcto `sqs-almacen-pedidos-{nombre-participante}` con su nombre único. Si ya creó esta cola anteriormente, puede usarla directamente sin crear una nueva.
2. **Para problemas de conectividad**: Actualice la página del navegador (F5) y vuelva a intentar la creación de la cola.
3. **Para permisos IAM o límites de cuota**: ⚠️ Notifique al instructor de inmediato. No intente solucionar este error por su cuenta, ya que requiere ajustes a nivel de cuenta AWS.

### Error: No puedo crear el tema SNS

**Síntoma**: Al intentar crear el tema SNS, aparece un mensaje de error indicando que la operación falló, o el botón "Crear tema" no responde.

**Causas posibles**:
1. **Permisos IAM insuficientes**: Su usuario no tiene los permisos necesarios para crear temas SNS
2. **Límite de cuota alcanzado**: La cuenta AWS ha alcanzado el límite máximo de temas SNS permitidos en la región
3. **Nombre de tema duplicado**: Ya existe un tema con el mismo nombre en la región (recuerde usar su nombre de participante en el sufijo)
4. **Problema de conectividad**: Pérdida temporal de conexión con los servicios de AWS

**Solución**:
1. **Para nombre duplicado**: Verifique que está usando el formato correcto `sns-alerta-compra-{nombre-participante}` con su nombre único. Si ya creó este tema anteriormente, puede usarlo directamente sin crear uno nuevo.
2. **Para problemas de conectividad**: Actualice la página del navegador (F5) y vuelva a intentar la creación del tema.
3. **Para permisos IAM o límites de cuota**: ⚠️ Notifique al instructor de inmediato. No intente solucionar este error por su cuenta, ya que requiere ajustes a nivel de cuenta AWS.

---

## Suscripciones

Esta sección cubre errores relacionados con la creación y confirmación de suscripciones al tema SNS.

### Error: La suscripción SQS no aparece como "Confirmada"

**Síntoma**: Después de crear la suscripción de la cola SQS al tema SNS, el estado de la suscripción aparece como "Pendiente de confirmación" en lugar de "Confirmada".

**Causas posibles**:
1. **Permisos de política de acceso**: La cola SQS no tiene una política de acceso que permita al tema SNS enviar mensajes a la cola
2. **ARN incorrecto**: Se seleccionó el ARN incorrecto al crear la suscripción (por ejemplo, el ARN de otra cola o un ARN incompleto)
3. **Problema de propagación**: El cambio aún no se ha propagado completamente en los servicios de AWS (esto suele resolverse en segundos)

**Solución**:
1. **Verificar el ARN**: Navegue a la consola de SQS, abra su cola `sqs-almacen-pedidos-{nombre-participante}`, y copie el ARN completo que aparece en la sección de detalles. Compárelo con el ARN usado en la suscripción.
2. **Esperar propagación**: Actualice la página de suscripciones del tema SNS (F5) y espere 30 segundos. Las suscripciones SQS normalmente se confirman automáticamente de inmediato.
3. **Recrear la suscripción**: Si después de 1 minuto el estado sigue como "Pendiente de confirmación", elimine la suscripción y créela nuevamente:
   - En la pestaña **Suscripciones** del tema SNS, seleccione la suscripción problemática
   - Haga clic en **Eliminar**
   - Vuelva a crear la suscripción siguiendo el Paso 4 del laboratorio, asegurándose de seleccionar el protocolo **Amazon SQS** y el ARN correcto de su cola
4. **Para problemas persistentes**: ⚠️ Si después de recrear la suscripción el problema persiste, notifique al instructor, ya que puede ser un problema de permisos IAM o políticas de acceso a nivel de cuenta.

### Error: No recibo el correo de confirmación de suscripción

**Síntoma**: Después de crear la suscripción de correo electrónico al tema SNS, no llega ningún correo de confirmación a su bandeja de entrada.

**Causas posibles**:
1. **Correo en carpeta de spam**: El correo de AWS Notifications fue filtrado como spam por su proveedor de correo
2. **Dirección de correo incorrecta**: Se ingresó una dirección de correo electrónico con errores tipográficos
3. **Retraso en la entrega**: El correo puede tardar algunos minutos en llegar, especialmente en proveedores de correo con filtros estrictos
4. **Bloqueo del proveedor de correo**: Algunos proveedores de correo corporativos bloquean correos automáticos de AWS

**Solución**:
1. **Revisar carpeta de spam**: Abra la carpeta de spam o correo no deseado de su bandeja de entrada y busque un correo del remitente "AWS Notifications" o "no-reply@sns.amazonaws.com".
2. **Verificar la dirección de correo**: En la consola de SNS, en la pestaña **Suscripciones**, verifique que la dirección de correo electrónico mostrada en el punto de enlace es correcta. Si tiene un error tipográfico, elimine la suscripción y créela nuevamente con la dirección correcta.
3. **Esperar y actualizar**: Espere hasta 5 minutos y actualice su bandeja de entrada. Algunos proveedores de correo tienen retrasos en la entrega.
4. **Usar correo personal**: Si está usando un correo corporativo o institucional, intente crear una nueva suscripción usando una dirección de correo personal (Gmail, Outlook, Yahoo, etc.) que tenga menos restricciones de filtrado.
5. **Reenviar confirmación**: Si la suscripción aparece como "Pendiente de confirmación" en la consola SNS, puede eliminarla y crearla nuevamente para que se envíe un nuevo correo de confirmación.

### Error: El enlace de confirmación no funciona o expiró

**Síntoma**: Al hacer clic en el enlace "Confirm subscription" del correo de confirmación, aparece un mensaje de error indicando que el enlace no es válido, ya expiró, o la página no carga correctamente.

**Causas posibles**:
1. **Enlace expirado**: Los enlaces de confirmación de suscripción de SNS tienen un tiempo de validez de 3 días. Si pasó más de 3 días desde que se envió el correo, el enlace ya no es válido
2. **Enlace incompleto**: Al copiar y pegar el enlace, se cortó parte de la URL, haciendo que sea inválido
3. **Suscripción ya confirmada**: El enlace ya fue usado anteriormente y la suscripción ya está confirmada
4. **Problema de conectividad**: Pérdida temporal de conexión al intentar acceder al enlace

**Solución**:
1. **Verificar estado de la suscripción**: Antes de intentar solucionar el problema, navegue a la consola de SNS, abra su tema `sns-alerta-compra-{nombre-participante}`, y vaya a la pestaña **Suscripciones**. Si la suscripción de correo electrónico ya aparece como "Confirmada", no necesita hacer nada más.
2. **Copiar el enlace completo**: Si el enlace se cortó al copiarlo, abra el correo de confirmación nuevamente y haga clic directamente en el botón o enlace "Confirm subscription" en lugar de copiar y pegar la URL.
3. **Recrear la suscripción**: Si el enlace expiró (más de 3 días), debe eliminar la suscripción pendiente y crear una nueva:
   - En la consola de SNS, pestaña **Suscripciones**, seleccione la suscripción con estado "Pendiente de confirmación"
   - Haga clic en **Eliminar**
   - Vuelva a crear la suscripción siguiendo el Paso 5 del laboratorio
   - Revise su correo inmediatamente y confirme la suscripción dentro de las próximas horas
4. **Intentar desde otro navegador**: Si el enlace no carga, intente abrirlo desde otro navegador o en modo incógnito/privado para descartar problemas de caché o extensiones del navegador.

---

## Publicación y Verificación de Mensajes

Esta sección cubre errores que pueden ocurrir al publicar mensajes y verificar su recepción en correo electrónico y cola SQS.

### Error: El mensaje no aparece en la cola SQS

**Síntoma**: Después de publicar un mensaje en el tema SNS, al navegar a la cola SQS y hacer clic en "Sondear mensajes", no aparece ningún mensaje en la cola, o la cola aparece vacía.

**Causas posibles**:
1. **Suscripción SQS no confirmada**: La suscripción de la cola SQS al tema SNS no está en estado "Confirmada", por lo que los mensajes no se están entregando a la cola
2. **ARN incorrecto en la suscripción**: Se suscribió una cola SQS diferente (con ARN incorrecto) en lugar de su cola `sqs-almacen-pedidos-{nombre-participante}`
3. **Mensaje ya consumido o eliminado**: Si ya sondeó mensajes anteriormente y los visualizó, es posible que hayan sido eliminados automáticamente o que el tiempo de visibilidad haya expirado
4. **Tiempo de sondeo insuficiente**: No esperó suficiente tiempo después de hacer clic en "Sondear mensajes" para que aparezcan los resultados
5. **Mensaje publicado antes de crear la suscripción**: Si publicó el mensaje de prueba antes de crear y confirmar la suscripción SQS, ese mensaje no llegará a la cola (SNS solo envía mensajes a suscriptores activos en el momento de la publicación)

**Solución**:
1. **Verificar estado de la suscripción**: Navegue a la consola de SNS, abra su tema `sns-alerta-compra-{nombre-participante}`, y vaya a la pestaña **Suscripciones**. Confirme que la suscripción con protocolo "Amazon SQS" tiene estado "Confirmada". Si aparece como "Pendiente de confirmación", consulte la sección "La suscripción SQS no aparece como Confirmada" de esta guía.
2. **Verificar el ARN de la cola**: En la pestaña **Suscripciones** del tema SNS, verifique que el punto de enlace de la suscripción SQS corresponde al ARN de su cola `sqs-almacen-pedidos-{nombre-participante}`. Para confirmar el ARN correcto, navegue a SQS, abra su cola, y copie el ARN que aparece en la sección de detalles. Si el ARN es incorrecto, elimine la suscripción y créela nuevamente con el ARN correcto.
3. **Publicar un nuevo mensaje**: Si el mensaje original fue publicado antes de confirmar la suscripción, o si ya fue consumido, publique un nuevo mensaje de prueba:
   - Navegue a su tema SNS `sns-alerta-compra-{nombre-participante}`
   - Haga clic en **Publicar mensaje**
   - En el campo de cuerpo del mensaje, escriba: `¡Nuevo pedido #1051! 1 Mouse Inalámbrico enviado al cliente.`
   - Haga clic en **Publicar mensaje**
4. **Sondear nuevamente con tiempo suficiente**: Regrese a la consola de SQS, abra su cola, haga clic en **Enviar y recibir mensajes**, y luego en **Sondear mensajes**. Espere al menos 10-15 segundos para que aparezcan los resultados del sondeo. Los mensajes deberían aparecer en la lista con su ID de mensaje.
5. **Verificar configuración de visibilidad**: Si los mensajes desaparecen rápidamente después de sondear, es posible que el tiempo de visibilidad de la cola sea muy corto. Esto es normal en colas con configuración por defecto. Simplemente publique un nuevo mensaje y sondee inmediatamente para visualizarlo antes de que expire la visibilidad.

### Error: No recibo el correo con el mensaje publicado

**Síntoma**: Después de publicar un mensaje en el tema SNS, el mensaje no llega a su bandeja de entrada de correo electrónico, aunque la suscripción de correo está confirmada.

**Causas posibles**:
1. **Suscripción de correo no confirmada**: Aunque cree haber confirmado la suscripción, el estado en la consola SNS sigue siendo "Pendiente de confirmación", por lo que los mensajes no se están entregando
2. **Correo filtrado como spam**: El mensaje publicado fue filtrado por su proveedor de correo y se encuentra en la carpeta de spam o correo no deseado
3. **Retraso en la entrega**: Algunos proveedores de correo tienen retrasos en la entrega de correos automáticos de AWS, especialmente si tienen filtros de seguridad estrictos
4. **Mensaje publicado antes de confirmar la suscripción**: Si publicó el mensaje antes de confirmar la suscripción de correo haciendo clic en "Confirm subscription", ese mensaje no llegará (SNS solo envía a suscriptores confirmados)
5. **Límite de envío de correos alcanzado**: En cuentas AWS nuevas o en sandbox, SNS tiene límites de envío de correos que pueden haber sido alcanzados

**Solución**:
1. **Verificar estado de la suscripción de correo**: Navegue a la consola de SNS, abra su tema `sns-alerta-compra-{nombre-participante}`, y vaya a la pestaña **Suscripciones**. Confirme que la suscripción con protocolo "Correo electrónico" tiene estado "Confirmada". Si aparece como "Pendiente de confirmación", debe confirmar la suscripción primero:
   - Revise su bandeja de entrada y carpeta de spam buscando el correo de "AWS Notifications" con el asunto "AWS Notification - Subscription Confirmation"
   - Haga clic en el enlace "Confirm subscription"
   - Actualice la página de suscripciones en la consola SNS para verificar que el estado cambió a "Confirmada"
2. **Revisar carpeta de spam**: Abra la carpeta de spam o correo no deseado de su bandeja de entrada y busque correos del remitente "AWS Notifications" o "no-reply@sns.amazonaws.com". Si encuentra el mensaje allí, márquelo como "No es spam" para que futuros mensajes lleguen a su bandeja principal.
3. **Esperar y actualizar**: Si acaba de publicar el mensaje, espere hasta 5 minutos y actualice su bandeja de entrada. Algunos proveedores de correo tienen retrasos en la entrega de correos automáticos.
4. **Publicar un nuevo mensaje**: Si el mensaje original fue publicado antes de confirmar la suscripción, publique un nuevo mensaje de prueba:
   - Navegue a su tema SNS `sns-alerta-compra-{nombre-participante}`
   - Haga clic en **Publicar mensaje**
   - En el campo de cuerpo del mensaje, escriba: `¡Nuevo pedido #1052! 1 Teclado Mecánico enviado al cliente.`
   - Haga clic en **Publicar mensaje**
   - Espere 2-3 minutos y revise su bandeja de entrada y carpeta de spam
5. **Verificar la dirección de correo**: En la pestaña **Suscripciones** del tema SNS, verifique que la dirección de correo electrónico en el punto de enlace es correcta y corresponde a la bandeja que está revisando. Si hay un error tipográfico, elimine la suscripción, cree una nueva con la dirección correcta, confírmela, y publique un nuevo mensaje.
6. **Para límites de envío**: ⚠️ Si después de seguir todos los pasos anteriores aún no recibe correos, y sospecha que puede ser un límite de cuota de envío de SNS, notifique al instructor. Las cuentas AWS en sandbox tienen restricciones de envío de correos que requieren solicitud de aumento de límites.

### Error: No veo mensajes al hacer "Sondear mensajes"

**Síntoma**: Al hacer clic en el botón "Sondear mensajes" en la consola de SQS, no aparece ningún mensaje en la lista, o aparece un mensaje indicando "No se encontraron mensajes" o "0 mensajes disponibles".

**Causas posibles**:
1. **No se ha publicado ningún mensaje**: Aún no ha completado el Paso 7 del laboratorio (publicar mensaje en el tema SNS), por lo que no hay mensajes para sondear
2. **Suscripción SQS no activa**: La suscripción de la cola al tema SNS no está confirmada o tiene un problema, por lo que los mensajes publicados no están llegando a la cola
3. **Cola SQS incorrecta**: Está sondeando una cola diferente a la que suscribió al tema SNS (por ejemplo, una cola de otro participante o una cola creada anteriormente)
4. **Mensajes ya procesados**: Los mensajes fueron sondeados y visualizados anteriormente, y ya fueron eliminados de la cola o están en período de tiempo de visibilidad (temporalmente ocultos)
5. **Tiempo de sondeo expirado**: Hizo clic en "Sondear mensajes" pero no esperó suficiente tiempo para que se complete la operación de sondeo

**Solución**:
1. **Verificar que publicó un mensaje**: Confirme que completó el Paso 7 del laboratorio publicando un mensaje en el tema SNS. Si no lo ha hecho, navegue a su tema `sns-alerta-compra-{nombre-participante}`, haga clic en **Publicar mensaje**, escriba el texto del mensaje, y haga clic en **Publicar mensaje**.
2. **Verificar que está en la cola correcta**: En la consola de SQS, confirme que el nombre de la cola que está visualizando es `sqs-almacen-pedidos-{nombre-participante}` con su nombre de participante. Si está en una cola diferente, navegue a **Colas** en el panel izquierdo, busque su cola en la lista, y ábrala.
3. **Verificar estado de la suscripción**: Navegue a la consola de SNS, abra su tema `sns-alerta-compra-{nombre-participante}`, vaya a la pestaña **Suscripciones**, y confirme que la suscripción con protocolo "Amazon SQS" tiene estado "Confirmada" y el punto de enlace corresponde al ARN de su cola. Si no está confirmada, consulte la sección "La suscripción SQS no aparece como Confirmada" de esta guía.
4. **Publicar un nuevo mensaje y sondear inmediatamente**: Si los mensajes anteriores ya fueron procesados, publique un nuevo mensaje de prueba y sondee inmediatamente:
   - Navegue a su tema SNS y publique un nuevo mensaje: `¡Nuevo pedido #1053! 1 Monitor 24" enviado al cliente.`
   - Inmediatamente después, navegue a su cola SQS, haga clic en **Enviar y recibir mensajes**
   - Haga clic en **Sondear mensajes** y espere 10-15 segundos
   - Los mensajes deberían aparecer en la lista con su ID de mensaje
5. **Esperar tiempo suficiente**: Después de hacer clic en "Sondear mensajes", espere al menos 10-15 segundos sin actualizar la página. La operación de sondeo puede tardar unos segundos en completarse y mostrar resultados.
6. **Verificar configuración de la cola**: Si sospecha que los mensajes están siendo eliminados automáticamente muy rápido, verifique la configuración de la cola:
   - En la consola de SQS, abra su cola y vaya a la pestaña **Configuración**
   - Revise el "Tiempo de retención de mensajes" (debería ser 4 días por defecto)
   - Revise el "Tiempo de espera de visibilidad" (debería ser 30 segundos por defecto)
   - Si estos valores son muy bajos, los mensajes pueden desaparecer rápidamente, pero con la configuración por defecto esto no debería ser un problema

---

## Errores que Requieren Asistencia del Instructor

Algunos errores no pueden resolverse de forma independiente y requieren la intervención del instructor. Si encuentra alguno de los siguientes problemas, notifique al instructor de inmediato:

### Error de permisos IAM

**Síntoma**: Aparece un mensaje indicando que no tiene permisos para realizar una acción (por ejemplo, "You are not authorized to perform this operation", "Access Denied", "Insufficient permissions to create queue/topic", "User is not authorized to perform: sns:CreateTopic", "User is not authorized to perform: sqs:CreateQueue").

**Acción**: ⚠️ Notifique al instructor de inmediato. Este error requiere ajustes en las políticas IAM de su cuenta.

---

### Error de límites de cuota de AWS

**Síntoma**: Aparece un mensaje indicando que ha alcanzado el límite de recursos (por ejemplo, "You have reached your quota for topics", "Queue limit exceeded", "TooManyTopics", "TooManyQueues").

**Acción**: ⚠️ Notifique al instructor de inmediato. Este error requiere solicitar un aumento de cuota o liberar recursos existentes.

---

### Error: No puedo acceder al servicio SNS o SQS

**Síntoma**: Al buscar SNS o SQS en la barra de búsqueda global, el servicio no aparece o no puede acceder a él. Aparece un mensaje de error al intentar abrir la consola del servicio.

**Acción**: ⚠️ Notifique al instructor de inmediato. Esto indica un problema con los permisos de su cuenta o con el acceso a estos servicios.

---

### Error: No puedo suscribir la cola SQS al tema SNS por permisos

**Síntoma**: Al intentar crear la suscripción de la cola SQS al tema SNS, aparece un error de permisos indicando que SNS no puede enviar mensajes a la cola, o que no tiene permisos para modificar la política de la cola.

**Acción**: ⚠️ Notifique al instructor de inmediato. Este error requiere ajustes en las políticas de acceso de SQS o permisos de SNS a nivel de cuenta.

---

**Nota**: Si su problema no aparece en esta guía, consulte con el instructor o revise la documentación oficial de AWS para el servicio específico.
