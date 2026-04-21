# Guía de Solución de Problemas - Laboratorio 7

Esta guía contiene soluciones a los errores más comunes que pueden presentarse durante el laboratorio del Portal del Ciudadano.

---

## Fase 1: Despliegue con CloudFormation

### Error: La pila de CloudFormation falla durante la creación

**Síntoma**: El estado de la pila cambia a `CREATE_FAILED` y algunos recursos muestran errores en la pestaña **Eventos**.

**Causas posibles**:
1. El nombre de la pila contiene caracteres no permitidos (espacios, caracteres especiales)
2. Ya existe una pila con el mismo nombre en la región
3. La dirección de correo electrónico ingresada en el parámetro `EmailAlerts` tiene formato inválido

**Solución**:
1. Revise la pestaña **Eventos** de la pila para identificar el recurso que falló y el mensaje de error específico
2. Elimine la pila fallida (si quedó en estado `CREATE_FAILED`)
3. Vuelva a crear la pila verificando que:
   - El nombre sigue el formato `[Iniciales]-TC-Portal` (solo letras, números y guiones)
   - No existe otra pila con el mismo nombre
   - El correo electrónico es válido

### Error: La pila queda en estado ROLLBACK_IN_PROGRESS o ROLLBACK_COMPLETE

**Síntoma**: La pila inicia la creación pero luego revierte todos los recursos automáticamente.

**Causas posibles**:
1. No se marcó el checkbox de capacidades IAM al crear la pila
2. La cuenta no tiene permisos suficientes para crear algún recurso
3. Se alcanzó un límite de cuota de AWS (por ejemplo, máximo de VPCs o instancias EC2)

**Solución**:
1. Revise la pestaña **Eventos** y busque el primer recurso con estado `CREATE_FAILED` (el que inició el rollback)
2. Si el error menciona "Requires capabilities: [CAPABILITY_NAMED_IAM]", vuelva a crear la pila asegurándose de marcar el checkbox de capacidades IAM
3. Si el error menciona permisos o cuotas, notifique al instructor

### Error: No recibo el correo de confirmación de suscripción SNS

**Síntoma**: Después de crear la pila, no llega el correo de "AWS Notification - Subscription Confirmation".

**Causas posibles**:
1. El correo fue clasificado como spam o correo no deseado
2. La dirección de correo ingresada en el parámetro `EmailAlerts` es incorrecta
3. El proveedor de correo bloquea mensajes de AWS

**Solución**:
1. Revise la carpeta de **Spam** o **Correo no deseado** de su bandeja de entrada
2. Espere 2-3 minutos adicionales, ya que el correo puede tardar en llegar
3. Si no aparece, verifique la dirección de correo en los parámetros de la pila (pestaña **Parámetros** en CloudFormation)
4. Si la dirección es incorrecta, deberá eliminar la pila y recrearla con el correo correcto

### Error: El enlace de confirmación no funciona o expiró

**Síntoma**: Al hacer clic en "Confirm subscription" en el correo, la página muestra un error o indica que el enlace expiró.

**Causas posibles**:
1. Han pasado más de 72 horas desde que se envió el correo
2. Problemas de conectividad de red

**Solución**:
1. Si el enlace expiró, navegue a la consola de Amazon SNS, seleccione el tema de la pila, y solicite un reenvío de la confirmación
2. Intente abrir el enlace en un navegador diferente
3. Si persiste el problema, notifique al instructor


---

## Fase 2: Pruebas de Alta Disponibilidad

### Error: La URL del Application Load Balancer no carga el portal

**Síntoma**: Al hacer clic en la URL del ALB desde la pestaña **Salidas**, el navegador muestra un error de tiempo de espera o "No se puede acceder al sitio".

**Causas posibles**:
1. Las instancias EC2 aún están iniciándose y no han completado la instalación del servidor web
2. El Health Check del Target Group aún no ha marcado las instancias como saludables
3. El Security Group del ALB no permite tráfico HTTP en el puerto 80

**Solución**:
1. Espere 3-5 minutos adicionales para que las instancias completen su inicialización
2. Navegue a EC2 > Grupos de destino, seleccione el Target Group de la pila y verifique la pestaña **Destinos**
3. Confirme que al menos una instancia muestra estado **healthy** (saludable)
4. Si después de 10 minutos las instancias siguen en estado **unhealthy**, revise los Security Groups

### Error: El portal no responde después de terminar una instancia

**Síntoma**: Después de terminar una instancia EC2, el portal deja de cargar o muestra errores intermitentes.

**Causas posibles**:
1. Se terminaron ambas instancias por error
2. El ALB aún no ha detectado que la instancia está fuera de servicio
3. El navegador tiene caché de la conexión anterior

**Solución**:
1. Verifique en EC2 > Instancias que al menos una instancia sigue en estado **En ejecución**
2. Espere 30-60 segundos para que el Health Check del ALB detecte el cambio
3. Limpie la caché del navegador o intente en una ventana de incógnito
4. Si ambas instancias fueron terminadas, espere a que el Auto Scaling Group lance nuevas instancias

### Error: El Auto Scaling Group no lanza una nueva instancia de reemplazo

**Síntoma**: Después de terminar una instancia, pasan más de 10 minutos y el ASG no lanza una instancia nueva.

**Causas posibles**:
1. Se alcanzó el límite de cuota de instancias EC2 en la cuenta
2. El Launch Template tiene errores de configuración
3. No hay capacidad disponible en las zonas de disponibilidad

**Solución**:
1. Verifique en EC2 > Auto Scaling > Grupos de Auto Scaling que el grupo tiene **Capacidad deseada: 2**
2. Revise la pestaña **Actividad** del ASG para ver mensajes de error
3. Si el error menciona límites de cuota o capacidad, notifique al instructor

### Error: No encuentro la base de datos RDS en la consola

**Síntoma**: Al navegar a Amazon RDS > Bases de datos, no aparece la base de datos creada por la pila.

**Causas posibles**:
1. La base de datos aún está en proceso de creación (puede tardar 10-15 minutos)
2. Está visualizando una región diferente a donde se creó la pila
3. La creación de la base de datos falló durante el despliegue de CloudFormation

**Solución**:
1. Verifique que está en la región correcta (esquina superior derecha de la consola)
2. Revise el estado de la pila en CloudFormation - debe estar en `CREATE_COMPLETE`
3. Si la pila está completa pero no ve la base de datos, revise la pestaña **Eventos** de CloudFormation para errores relacionados con RDS
4. Espere el tiempo completo de aprovisionamiento (10-15 minutos desde el inicio de la pila)

### Errores de Seguridad (Fase 2)

### Error: La Web ACL de AWS WAF no aparece en la consola

**Síntoma**: Al navegar a AWS WAF > Web ACLs, no aparece la Web ACL creada por la pila de CloudFormation.

**Causas posibles**:
1. Está visualizando una región diferente a donde se creó la pila
2. La pila de CloudFormation aún no ha completado la creación de todos los recursos
3. El filtro de región en la consola de WAF no coincide con la región de despliegue

**Solución**:
1. Verifique que está en la región correcta (esquina superior derecha de la consola)
2. Revise el estado de la pila en CloudFormation — debe estar en `CREATE_COMPLETE`
3. En la consola de AWS WAF, asegúrese de que el selector de región muestra la región donde desplegó la pila
4. Si la pila aún está en `CREATE_IN_PROGRESS`, espere a que finalice completamente

### Error: La Web ACL no está asociada al Application Load Balancer

**Síntoma**: La pestaña **Recursos de AWS asociados** de la Web ACL está vacía o no muestra el ALB del laboratorio.

**Causas posibles**:
1. El recurso `WAFWebACLAssociation` falló durante la creación de la pila
2. La pila sufrió un rollback parcial que afectó la asociación WAF-ALB

**Solución**:
1. Navegue a CloudFormation y revise la pestaña **Eventos** de su pila
2. Busque el recurso `WAFWebACLAssociation` y verifique que su estado es `CREATE_COMPLETE`
3. Si el recurso muestra `CREATE_FAILED`, revise el mensaje de error en la columna de detalles
4. Si la pila sufrió un rollback, elimínela y vuelva a crearla

### Error: No puedo acceder al secreto en AWS Secrets Manager

**Síntoma**: Al navegar a AWS Secrets Manager, no aparece el secreto creado por la pila o se muestra un error de acceso denegado.

**Causas posibles**:
1. Está visualizando una región diferente a donde se creó la pila
2. Los permisos IAM del usuario no permiten acceder a Secrets Manager
3. La pila de CloudFormation aún no ha completado la creación del secreto

**Solución**:
1. Verifique que está en la región correcta (esquina superior derecha de la consola)
2. Revise el estado de la pila en CloudFormation — debe estar en `CREATE_COMPLETE`
3. Busque secretos que contengan el nombre de su pila (por ejemplo, `[Iniciales]-TC-Portal-rds-secret`)

⚠️ Si recibe un error de permisos de acceso, notifique al instructor de inmediato. No intente solucionar este error por su cuenta.

### Error: El botón "Recuperar valor del secreto" no muestra las credenciales

**Síntoma**: Al hacer clic en **Recuperar valor del secreto** en la consola de Secrets Manager, aparece un error de permisos o acceso denegado.

**Causas posibles**:
1. Los permisos IAM del usuario no incluyen la acción `secretsmanager:GetSecretValue`
2. Existe una política de recursos que restringe el acceso al secreto

**Solución**:

⚠️ Este es un error de permisos IAM. Notifique al instructor de inmediato. El instructor deberá verificar que su usuario tiene los permisos necesarios para leer secretos en Secrets Manager.

### Error: No encuentro los roles IAM creados por la pila

**Síntoma**: Al buscar en IAM > Roles, no aparecen los roles creados por la pila de CloudFormation.

**Causas posibles**:
1. El filtro de búsqueda no coincide con el nombre exacto de los roles
2. El prefijo del nombre de la pila es diferente al esperado
3. Los roles tienen un nombre generado automáticamente por CloudFormation

**Solución**:
1. En la consola de IAM > Roles, utilice la barra de búsqueda e ingrese parte del nombre de su pila (por ejemplo, `[Iniciales]-TC-Portal`)
2. Si no aparecen resultados, intente buscar solo por sus iniciales
3. Navegue a CloudFormation, seleccione su pila y revise la pestaña **Recursos** para ver los nombres exactos de los roles IAM creados

---

## Fase 3: Arquitectura Orientada a Eventos

### Error: No puedo encontrar el tema SNS creado por la pila

**Síntoma**: Al navegar a Amazon SNS > Temas, no aparece el tema de alertas.

**Causas posibles**:
1. Está visualizando una región diferente
2. El tema tiene un nombre diferente al esperado
3. La creación del tema falló en CloudFormation

**Solución**:
1. Verifique que está en la región correcta
2. Busque temas que contengan el nombre de su pila (por ejemplo, `[Iniciales]-TC-Portal-alertas`)
3. Si no aparece ningún tema, revise la pestaña **Recursos** de la pila en CloudFormation para confirmar que el recurso SNSTopic se creó correctamente

### Error: El mensaje no aparece en la cola SQS

**Síntoma**: Después de publicar un mensaje en SNS, al revisar la cola SQS no hay mensajes disponibles.

**Causas posibles**:
1. La función Lambda ya procesó y eliminó el mensaje de la cola
2. La suscripción entre SNS y SQS no está configurada correctamente
3. El mensaje se publicó en un tema diferente

**Solución**:
1. Esto es comportamiento normal si Lambda procesó el mensaje rápidamente (en menos de 1 minuto)
2. Verifique los logs de CloudWatch (siguiente paso) para confirmar que Lambda recibió el mensaje
3. Si desea ver mensajes en la cola, puede deshabilitar temporalmente el Event Source Mapping de Lambda

### Error: La función Lambda no procesó el mensaje

**Síntoma**: Al revisar CloudWatch Logs, no aparece el texto del mensaje publicado en SNS.

**Causas posibles**:
1. El Event Source Mapping entre SQS y Lambda está deshabilitado
2. La función Lambda tiene errores de ejecución
3. Los permisos IAM de Lambda no permiten leer de SQS

**Solución**:
1. Navegue a AWS Lambda > Funciones > ProcesadorExpedientes
2. Verifique la pestaña **Configuración** > **Desencadenadores** que el trigger de SQS está **Habilitado**
3. Revise la pestaña **Monitor** > **Métricas** para ver si hay errores de invocación
4. Si hay errores de permisos, notifique al instructor

### Error: No veo registros en CloudWatch Logs

**Síntoma**: Al hacer clic en "Ver registros en CloudWatch", no aparecen log streams o el grupo de logs está vacío.

**Causas posibles**:
1. La función Lambda nunca se ha ejecutado
2. Los permisos de CloudWatch Logs no están configurados correctamente
3. Está buscando en el grupo de logs incorrecto

**Solución**:
1. Verifique que publicó un mensaje en SNS en el paso anterior
2. Espere 1-2 minutos para que los logs aparezcan
3. Confirme que está en el grupo de logs correcto: `/aws/lambda/[Iniciales]-TC-Portal-ProcesadorExpedientes`
4. Intente publicar otro mensaje en SNS y espere a que se procese

---

## Fase 4: Servicios de IA

### Error: El chatbot muestra "Lo sentimos, no se pudo procesar su consulta"

**Síntoma**: Al enviar una pregunta en la interfaz del chatbot, aparece el mensaje "Lo sentimos, no se pudo procesar su consulta. Verifique que el modelo de Amazon Bedrock esté habilitado en su cuenta."

**Causas posibles**:
1. El modelo de Amazon Bedrock no está habilitado en la cuenta o región
2. Las instancias EC2 no tienen permisos IAM para invocar Bedrock
3. El servicio backend (tc-backend) no está ejecutándose en las instancias EC2
4. La región actual no soporta Amazon Bedrock o el modelo seleccionado

**Solución**:
1. Verifique que el modelo de Amazon Bedrock esté habilitado: navegue a la consola de Amazon Bedrock > **Acceso a modelos** y confirme que el modelo utilizado tiene acceso concedido
2. Verifique que el rol IAM de EC2 tiene permisos para `bedrock:InvokeModel` (consulte el Paso 8 del laboratorio)
3. Si el error persiste, notifique al instructor para que verifique la configuración de acceso a modelos de Bedrock

⚠️ Si recibe un error de acceso a modelos de Bedrock, notifique al instructor de inmediato. El instructor debe habilitar el acceso al modelo en la consola de Amazon Bedrock.

### Error: El chatbot no responde (sin mensaje de error)

**Síntoma**: Al enviar una pregunta, el indicador "Procesando su consulta con Amazon Bedrock..." permanece indefinidamente sin mostrar respuesta ni error. El chatbot de Bedrock no responde.

**Causas posibles**:
1. El servicio backend (tc-backend) no está ejecutándose en las instancias EC2
2. La configuración de Apache reverse proxy no está enrutando las solicitudes `/api` al backend
3. Timeout de la solicitud al backend (la respuesta de Bedrock tarda demasiado)

**Solución**:
1. Espere hasta 30 segundos, ya que algunas consultas complejas pueden tardar más en procesarse
2. Recargue la página del portal y vuelva a intentar con la pregunta sugerida
3. Si el problema persiste, notifique al instructor para que verifique que el servicio backend está activo en las instancias EC2

### Error: El audio no se genera al hacer clic en "Escuchar Resumen"

**Síntoma**: Al hacer clic en "Escuchar Resumen", el botón muestra "Generando audio con Amazon Polly..." pero luego aparece un mensaje de error o no se reproduce audio.

**Causas posibles**:
1. Amazon Polly no está disponible en la región actual
2. Las instancias EC2 no tienen permisos IAM para invocar Polly
3. El servicio backend (tc-backend) no está ejecutándose en las instancias EC2
4. El navegador bloquea la reproducción automática de audio

**Solución**:
1. Si aparece el mensaje "No se pudo generar el audio. Verifique que Amazon Polly esté disponible en su región.", confirme con el instructor que Amazon Polly está disponible en la región de despliegue
2. Verifique que el rol IAM de EC2 tiene permisos para `polly:SynthesizeSpeech` (consulte el Paso 8 del laboratorio)
3. Si el navegador bloquea la reproducción automática, haga clic en el icono de audio en la barra de direcciones del navegador y permita la reproducción de audio para este sitio
4. Intente en un navegador diferente (Chrome, Firefox)

### Error: El backend no responde (error 502/504)

**Síntoma**: Al interactuar con el chatbot o el botón de audio, el navegador muestra un error de red, o la consola del navegador muestra errores 502 Bad Gateway o 504 Gateway Timeout.

**Causas posibles**:
1. El servicio backend (tc-backend) no se inició correctamente durante el despliegue
2. Las dependencias npm (`@aws-sdk/client-bedrock-runtime`, `@aws-sdk/client-polly`, `express`) no se instalaron correctamente
3. El puerto 3001 del backend no es accesible desde Apache
4. El módulo de reverse proxy de Apache no está configurado correctamente

**Solución**:
1. Recargue la página del portal y espere 1-2 minutos antes de intentar nuevamente
2. Si el error persiste, notifique al instructor para que verifique el estado del servicio backend en las instancias EC2
3. El instructor puede conectarse a la instancia EC2 y verificar el estado del servicio con `systemctl status tc-backend`

### Error: La respuesta de Bedrock es genérica o incorrecta

**Síntoma**: El chatbot responde, pero la respuesta no es relevante a la pregunta constitucional o es muy genérica.

**Causas posibles**:
1. El prompt del sistema enviado al modelo no está optimizado para consultas constitucionales
2. El modelo seleccionado no es el más adecuado para consultas legales en español
3. La pregunta es demasiado ambigua o fuera del contexto constitucional

**Solución**:
1. Intente reformular la pregunta de manera más específica (por ejemplo, "¿Qué es un recurso de agravio constitucional y cuándo se puede presentar?")
2. Pruebe con la pregunta exacta sugerida en el laboratorio: "¿Qué es un recurso de agravio constitucional?"
3. Si las respuestas siguen siendo irrelevantes, notifique al instructor para que revise la configuración del prompt del sistema en el backend

---

## Errores que Requieren Asistencia del Instructor

Los siguientes errores NO deben intentar solucionarse por cuenta propia. Notifique al instructor de inmediato:

⚠️ **Errores de permisos IAM**
- Mensajes que indican "Access Denied", "Unauthorized", o "You are not authorized to perform this operation"
- Errores al crear roles o políticas IAM en CloudFormation

⚠️ **Errores de límites de cuota de AWS**
- Mensajes que indican "LimitExceeded", "You have exceeded the maximum number of...", o "Insufficient capacity"
- No se pueden crear más instancias EC2, VPCs, o bases de datos RDS

⚠️ **Errores de acceso a modelos de Bedrock**
- Mensajes que indican "Model access denied" o "You don't have access to the model"
- El instructor debe habilitar el acceso a modelos en la consola de Bedrock

⚠️ **Errores de configuración de cuenta**
- Problemas para acceder a servicios específicos de AWS
- Errores relacionados con Service Control Policies (SCPs) o permisos de organización
