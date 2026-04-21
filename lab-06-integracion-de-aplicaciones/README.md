# 📬 Laboratorio 6: Desacoplamiento con Amazon SNS y SQS

## Índice

- [Objetivos de aprendizaje](#objetivos-de-aprendizaje)
- [Tiempo estimado](#tiempo-estimado)
- [Prerrequisitos](#prerrequisitos)
- [Escenario de negocio](#escenario-de-negocio)
- [Paso 1: Verificar región AWS](#paso-1-verificar-región-aws)
- [Paso 2: Crear la cola SQS](#paso-2-crear-la-cola-sqs)
- [Paso 3: Crear el tema SNS](#paso-3-crear-el-tema-sns)
- [Paso 4: Suscribir la cola SQS al tema](#paso-4-suscribir-la-cola-sqs-al-tema)
- [Paso 5: Suscribir correo electrónico al tema](#paso-5-suscribir-correo-electrónico-al-tema)
- [Paso 6: Confirmar suscripción de correo](#paso-6-confirmar-suscripción-de-correo)
- [Paso 7: Publicar mensaje de prueba](#paso-7-publicar-mensaje-de-prueba)
- [Paso 8: Verificar recepción en correo](#paso-8-verificar-recepción-en-correo)
- [Paso 9: Verificar recepción en cola SQS](#paso-9-verificar-recepción-en-cola-sqs)
- [Paso 10: Analizar formato JSON del mensaje](#paso-10-analizar-formato-json-del-mensaje)
- [Solución de problemas](#solución-de-problemas)
- [Limpieza de recursos](#limpieza-de-recursos)

## Objetivos de aprendizaje

Al completar este laboratorio, podrás:

- Comprender el concepto de desacoplamiento en arquitecturas de aplicaciones y sus beneficios
- Crear e integrar Amazon SNS y Amazon SQS para implementar comunicación asíncrona entre componentes
- Implementar el patrón de mensajería Fanout para distribuir mensajes a múltiples suscriptores simultáneamente
- Verificar la entrega de mensajes en diferentes destinos y analizar el formato de encapsulamiento JSON

## Tiempo estimado

40 minutos

## Prerrequisitos

- Acceso a una cuenta AWS compartida proporcionada por el instructor
- Navegador web moderno (Chrome, Firefox, Edge o Safari)
- Acceso a una cuenta de correo electrónico personal para recibir notificaciones

## Escenario de negocio

Imagina que trabajas para una tienda de e-commerce que vende productos electrónicos. Cada vez que un cliente completa una compra, tu sistema necesita realizar dos acciones simultáneamente:

1. **Notificar al cliente**: Enviar un correo electrónico de confirmación al comprador con los detalles de su pedido
2. **Registrar en el almacén**: Agregar el pedido a una cola de trabajo para que el personal del almacén prepare el envío

En una arquitectura tradicional acoplada, tu aplicación tendría que llamar directamente a ambos sistemas (servicio de correo y sistema de almacén). Si uno de estos sistemas está caído o lento, toda la operación de compra se vería afectada.

Con una arquitectura desacoplada usando Amazon SNS y Amazon SQS, tu aplicación simplemente publica un mensaje en un "megáfono central" (tema SNS). Este megáfono se encarga automáticamente de distribuir el mensaje a todos los sistemas interesados (correo electrónico y cola del almacén) sin que tu aplicación necesite conocer los detalles de cada destino. Esto se conoce como el patrón Fanout.

En este laboratorio, implementarás esta arquitectura desacoplada y verificarás que un único mensaje publicado llega simultáneamente a múltiples destinos.

## Paso 1: Verificar región AWS

Antes de comenzar a crear recursos, es fundamental confirmar que estás trabajando en la región correcta de AWS.

1. Verifique que está trabajando en la región correcta:
   - En la esquina superior derecha de la consola de AWS
   - Confirme que dice la región estipulada por el instructor
   - Si no es correcta, haga clic y seleccione la región indicada

⚠️ **Importante - Entorno compartido**: Este laboratorio se realiza en una cuenta AWS compartida con otros participantes. Para evitar conflictos y facilitar la identificación de sus recursos:

- Todos los recursos que cree deben incluir su nombre al final
- Utilizaremos el formato `{nombre-participante}` en las instrucciones
- **Ejemplo**: Si su nombre es "carlos", cuando vea `sqs-almacen-pedidos-{nombre-participante}`, debe escribir `sqs-almacen-pedidos-carlos`
- **Nunca modifique o elimine recursos que no tengan su nombre**

## Paso 2: Crear la cola SQS

En este paso crearás una cola de Amazon SQS que actuará como la "sala de espera" para los pedidos del almacén. Esta cola almacenará temporalmente los mensajes hasta que los trabajadores del almacén estén listos para procesarlos.

1. En la barra de búsqueda global de la consola de AWS (parte superior), escriba **SQS** y haga clic en el servicio **Simple Queue Service**

2. En la página de Amazon SQS, haga clic en el botón naranja **Crear cola**

3. Configure los siguientes parámetros:
   - **Tipo**: Seleccione **Estándar**
   - **Nombre**: `sqs-almacen-pedidos-{nombre-participante}`
   - Deje todas las demás configuraciones con sus valores predeterminados

4. Desplácese hasta el final de la página y haga clic en el botón naranja **Crear cola**

**✓ Verificación**: En la lista de colas, confirme que:
- Su cola aparece con el nombre `sqs-almacen-pedidos-{nombre-participante}`
- El estado de la cola es **Activa** (puede tardar unos segundos en aparecer)

💡 **Consejo del instructor**: La cola SQS funciona como una bandeja de entrada segura. Aunque el sistema del almacén esté ocupado procesando otros pedidos o temporalmente no disponible, los nuevos pedidos no se perderán porque quedan almacenados en la cola esperando ser procesados. Esto garantiza que ningún pedido se pierda incluso durante picos de tráfico.

## Paso 3: Crear el tema SNS

En este paso crearás un tema de Amazon SNS que funcionará como el "megáfono central" de tu arquitectura. Este tema será el punto de publicación donde anunciarás las nuevas compras, y se encargará automáticamente de distribuir el mensaje a todos los suscriptores interesados.

1. Abra una nueva pestaña en su navegador y navegue a la consola de AWS

2. En la barra de búsqueda global de la consola de AWS (parte superior), escriba **SNS** y haga clic en el servicio **Simple Notification Service**

3. En el panel de navegación de la izquierda, haga clic en **Temas**

4. Haga clic en el botón naranja **Crear tema**

5. Configure los siguientes parámetros:
   - **Tipo**: Seleccione **Estándar**
   - **Nombre**: `sns-alerta-compra-{nombre-participante}`
   - Deje todas las demás configuraciones con sus valores predeterminados

6. Desplácese hasta el final de la página y haga clic en el botón naranja **Crear tema**

**✓ Verificación**: En la página de detalles del tema, confirme que:
- El estado del tema es **Activo**
- Se muestra el ARN (Amazon Resource Name) del tema en el formato `arn:aws:sns:region:account-id:sns-alerta-compra-{nombre-participante}`
- El nombre del tema coincide con `sns-alerta-compra-{nombre-participante}`

## Paso 4: Suscribir la cola SQS al tema

En este paso conectarás la cola SQS del almacén con el tema SNS. Esta suscripción permite que cada vez que se publique un mensaje en el tema SNS, automáticamente se envíe una copia a la cola SQS del almacén.

1. Permanezca en la página de detalles del tema SNS que acaba de crear

2. Haga clic en la pestaña **Suscripciones** (ubicada debajo del nombre del tema)

3. Haga clic en el botón naranja **Crear suscripción**

4. Configure los siguientes parámetros:
   - **ARN del tema**: Este campo debe estar prellenado con el ARN de su tema `sns-alerta-compra-{nombre-participante}`
   - **Protocolo**: En el menú desplegable, seleccione **Amazon SQS**
   - **Punto de enlace**: Haga clic en el campo y seleccione el ARN de su cola `sqs-almacen-pedidos-{nombre-participante}` de la lista desplegable
   - Deje todas las demás configuraciones con sus valores predeterminados

5. Desplácese hasta el final de la página y haga clic en el botón naranja **Crear suscripción**

**✓ Verificación**: En la pestaña **Suscripciones** del tema, confirme que:
- Aparece una nueva suscripción con el protocolo **Amazon SQS**
- El estado de la suscripción es **Confirmada** (esto ocurre automáticamente para suscripciones SQS)
- El punto de enlace muestra el ARN de su cola `sqs-almacen-pedidos-{nombre-participante}`

## Paso 5: Suscribir correo electrónico al tema

En este paso crearás una segunda suscripción al tema SNS, esta vez usando el protocolo de correo electrónico. Esto permitirá que cada vez que se publique un mensaje en el tema, también se envíe una copia a su correo personal, simulando la notificación al cliente.

1. Regrese a la página de detalles de su tema SNS `sns-alerta-compra-{nombre-participante}`
   - Si cerró la pestaña, navegue a **SNS** > **Temas** y haga clic en su tema

2. Asegúrese de estar en la pestaña **Suscripciones**

3. Haga clic nuevamente en el botón naranja **Crear suscripción**

4. Configure los siguientes parámetros:
   - **ARN del tema**: Este campo debe estar prellenado con el ARN de su tema `sns-alerta-compra-{nombre-participante}`
   - **Protocolo**: En el menú desplegable, seleccione **Correo electrónico**
   - **Punto de enlace**: Escriba su dirección de correo electrónico personal (ejemplo: `su.correo@ejemplo.com`)
   - Deje todas las demás configuraciones con sus valores predeterminados

5. Desplácese hasta el final de la página y haga clic en el botón naranja **Crear suscripción**

**✓ Verificación**: En la pestaña **Suscripciones** del tema, confirme que:
- Aparecen ahora **dos suscripciones**: una con protocolo **Amazon SQS** (estado: Confirmada) y otra con protocolo **Correo electrónico**
- La suscripción de correo electrónico muestra el estado **Confirmación pendiente**
- El punto de enlace de la suscripción de correo muestra su dirección de correo electrónico

## Paso 6: Confirmar suscripción de correo

⚠️ **CRÍTICO**: Antes de continuar con el siguiente paso, debe confirmar su suscripción de correo electrónico. Si no completa este paso, no recibirá los mensajes publicados en el tema SNS.

En este paso confirmarás tu suscripción de correo electrónico haciendo clic en el enlace de confirmación que AWS envió a tu bandeja de entrada. Este es un paso de seguridad para verificar que el propietario del correo electrónico realmente desea recibir notificaciones.

1. Abra su aplicación de correo electrónico (Gmail, Outlook, Yahoo, etc.)

2. Busque en su bandeja de entrada un correo con el asunto **"AWS Notification - Subscription Confirmation"**
   - **Remitente**: `no-reply@sns.amazonaws.com`
   - Si no ve el correo en la bandeja de entrada, revise la carpeta de **Spam** o **Correo no deseado**
   - El correo puede tardar 1-2 minutos en llegar

3. Abra el correo electrónico de confirmación

4. Dentro del correo, localice el enlace que dice **"Confirm subscription"**

5. Haga clic en el enlace **"Confirm subscription"**
   - Se abrirá una nueva pestaña del navegador mostrando una página de AWS con el mensaje "Subscription confirmed!"

6. Regrese a la consola de AWS, a la pestaña **Suscripciones** de su tema SNS

7. Haga clic en el botón de actualización (icono circular con flechas) ubicado en la esquina superior derecha de la tabla de suscripciones

**✓ Verificación**: En la pestaña **Suscripciones** del tema, confirme que:
- Ambas suscripciones (Amazon SQS y Correo electrónico) muestran ahora el estado **Confirmada**
- Ya no aparece el estado "Confirmación pendiente" en ninguna suscripción
- El contador de suscripciones en la parte superior muestra **2 suscripciones**

## Paso 7: Publicar mensaje de prueba

Ahora que ambas suscripciones están confirmadas, es momento de probar la arquitectura desacoplada publicando un mensaje en el tema SNS. Este mensaje se distribuirá automáticamente a ambos destinos (correo electrónico y cola SQS) gracias al patrón Fanout.

1. Regrese a la página de detalles de su tema SNS `sns-alerta-compra-{nombre-participante}`
   - Si está en la pestaña **Suscripciones**, haga clic en el nombre del tema en la parte superior para volver a la página principal del tema

2. En la esquina superior derecha, haga clic en el botón naranja **Publicar mensaje**

3. En la sección **Detalles del mensaje**, configure lo siguiente:
   - **Asunto**: Deje este campo vacío (opcional para este laboratorio)
   - **Cuerpo del mensaje**: En el cuadro de texto grande, escriba exactamente el siguiente texto:
     ```
     ¡Nuevo pedido #1050! 1 Laptop Gamer enviada al cliente.
     ```

4. Desplácese hasta el final de la página y haga clic en el botón naranja **Publicar mensaje**

5. Verá un mensaje de confirmación verde en la parte superior que dice **"Successfully published message"** con un ID de mensaje único

**✓ Verificación**: Confirme que:
- Aparece el mensaje de éxito **"Successfully published message"** en la parte superior de la página
- Se muestra un **ID de mensaje** único (una cadena alfanumérica larga)
- La página lo redirige automáticamente de vuelta a la página de detalles del tema

💡 **¿Qué acaba de suceder?**: Al publicar este mensaje en el tema SNS, Amazon SNS automáticamente envió una copia del mensaje a cada uno de los suscriptores confirmados. En este caso, el mensaje fue enviado simultáneamente a:
- Su correo electrónico personal (suscripción de correo electrónico)
- Su cola SQS del almacén (suscripción Amazon SQS)

En los siguientes pasos verificaremos que el mensaje llegó correctamente a ambos destinos.

## Paso 8: Verificar recepción en correo

En este paso confirmarás que el mensaje publicado en el tema SNS fue entregado exitosamente a tu correo electrónico.

1. Abra su aplicación de correo electrónico (Gmail, Outlook, Yahoo, etc.)

2. Busque en su bandeja de entrada un nuevo correo con el asunto **"AWS Notification - Message"**
   - **Remitente**: `no-reply@sns.amazonaws.com`
   - Si no ve el correo en la bandeja de entrada, revise la carpeta de **Spam** o **Correo no deseado**
   - El correo puede tardar 1-2 minutos en llegar

3. Abra el correo electrónico

4. Verifique que el cuerpo del mensaje contiene el texto que publicó en formato de texto plano:
   ```
   ¡Nuevo pedido #1050! 1 Laptop Gamer enviada al cliente.
   ```

**✓ Verificación**: Confirme que:
- Recibió el correo electrónico de AWS Notifications
- El mensaje aparece en formato de texto plano (sin encapsulamiento JSON)
- El contenido del mensaje coincide exactamente con el texto que publicó en el paso anterior

## Paso 9: Verificar recepción en cola SQS

En este paso confirmarás que el mensaje publicado en el tema SNS también fue entregado exitosamente a la cola SQS del almacén. A diferencia del correo electrónico, el mensaje en SQS estará encapsulado en un formato JSON proporcionado por SNS.

1. Regrese a la consola de AWS o abra una nueva pestaña

2. En la barra de búsqueda global de la consola de AWS (parte superior), escriba **SQS** y haga clic en el servicio **Simple Queue Service**

3. En la lista de colas, haga clic en el nombre de su cola `sqs-almacen-pedidos-{nombre-participante}`

4. En la página de detalles de la cola, haga clic en el botón **Enviar y recibir mensajes** ubicado en la esquina superior derecha

5. En la sección **Recibir mensajes**, haga clic en el botón **Sondear mensajes**
   - El sistema comenzará a buscar mensajes disponibles en la cola
   - Después de unos segundos, debería aparecer al menos un mensaje en la tabla de resultados

6. En la tabla de mensajes, localice su mensaje y haga clic en el **ID del mensaje** (la cadena alfanumérica en la primera columna)
   - Esto abrirá un panel lateral con los detalles completos del mensaje

7. En el panel de detalles del mensaje, observe la sección **Cuerpo**
   - Verá que el mensaje está en formato JSON
   - Este JSON es el encapsulamiento que SNS agrega automáticamente cuando envía mensajes a SQS

**✓ Verificación**: Confirme que:
- Aparece al menos un mensaje en la tabla después de hacer clic en **Sondear mensajes**
- Al hacer clic en el ID del mensaje, se abre un panel lateral con los detalles
- El cuerpo del mensaje muestra un documento JSON (no texto plano como en el correo)
- Puede ver su mensaje original dentro de la estructura JSON

## Paso 10: Analizar formato JSON del mensaje

En este paso final, analizarás la estructura del mensaje que recibió la cola SQS y comprenderás por qué aparece en formato JSON en lugar de texto plano como en el correo electrónico.

### ¿Por qué el mensaje está en formato JSON?

Cuando Amazon SNS envía un mensaje a una cola SQS, automáticamente encapsula el contenido original dentro de un documento JSON. Este encapsulamiento proporciona metadatos adicionales útiles para el procesamiento del mensaje, como:

- El tipo de notificación
- El ID único del mensaje
- El ARN del tema SNS que publicó el mensaje
- La marca de tiempo de cuando se publicó
- El mensaje original que usted escribió

Esta estructura JSON permite que los sistemas que consumen mensajes de la cola SQS puedan identificar de dónde proviene el mensaje y procesarlo adecuadamente.

### Estructura del JSON Payload

El documento JSON que ve en el cuerpo del mensaje tiene una estructura similar a esta:

```json
{
  "Type": "Notification",
  "MessageId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "TopicArn": "arn:aws:sns:region:account-id:sns-alerta-compra-{nombre-participante}",
  "Message": "¡Nuevo pedido #1050! 1 Laptop Gamer enviada al cliente.",
  "Timestamp": "2024-01-01T00:00:00.000Z",
  "SignatureVersion": "1",
  "Signature": "...",
  "SigningCertURL": "...",
  "UnsubscribeURL": "..."
}
```

### Localizar su mensaje original

1. En el panel de detalles del mensaje que abrió en el Paso 9, observe el documento JSON en la sección **Cuerpo**

2. Busque la clave llamada **`"Message":`** dentro del JSON

3. El valor de esta clave contiene su texto original exacto:
   ```
   "Message": "¡Nuevo pedido #1050! 1 Laptop Gamer enviada al cliente."
   ```

4. Compare este texto con el que recibió en su correo electrónico en el Paso 8
   - En el correo: texto plano directo
   - En SQS: encapsulado dentro de la clave `"Message":` del JSON

**✓ Verificación**: Confirme que:
- Puede identificar la clave `"Message":` dentro del documento JSON
- El valor de `"Message":` contiene exactamente el texto que publicó: `"¡Nuevo pedido #1050! 1 Laptop Gamer enviada al cliente."`
- Puede ver otras claves como `"Type"`, `"MessageId"`, `"TopicArn"`, y `"Timestamp"`

### ¡Felicitaciones!

🎉 **¡Excelente trabajo!** Ha implementado exitosamente una arquitectura desacoplada usando el patrón Fanout con Amazon SNS y Amazon SQS.

**Lo que ha logrado:**

- Creó una cola SQS que actúa como buffer seguro para mensajes del almacén
- Creó un tema SNS que funciona como punto central de publicación
- Configuró múltiples suscriptores (correo electrónico y cola SQS) al mismo tema
- Publicó un único mensaje que se distribuyó automáticamente a ambos destinos simultáneamente
- Verificó que el patrón Fanout funciona correctamente: un mensaje publicado llegó a múltiples suscriptores sin que el publicador necesite conocer los detalles de cada destino

**Beneficios de esta arquitectura:**

- **Desacoplamiento**: El sistema que publica mensajes no necesita conocer quiénes son los suscriptores ni cómo procesarán el mensaje
- **Escalabilidad**: Puede agregar nuevos suscriptores (por ejemplo, un servicio de SMS, una función Lambda, otra cola SQS) sin modificar el código del publicador
- **Resiliencia**: Si un suscriptor falla temporalmente, los demás siguen recibiendo mensajes. La cola SQS retiene mensajes hasta que puedan ser procesados
- **Flexibilidad**: Cada suscriptor puede procesar el mensaje de manera diferente según sus necesidades

Esta arquitectura es fundamental en aplicaciones modernas de AWS y se utiliza ampliamente en sistemas de e-commerce, procesamiento de eventos, notificaciones en tiempo real, y pipelines de datos.


## Solución de problemas

Si encuentra dificultades durante este laboratorio, consulte la [Guía de Solución de Problemas](TROUBLESHOOTING.md) que contiene soluciones a errores comunes.

**Errores que requieren asistencia del instructor:**
- ⚠️ Errores de permisos IAM
- ⚠️ Errores de límites de cuota de AWS

## Limpieza de recursos

⚠️ **Importante**: Al finalizar este laboratorio, puede eliminar los recursos creados para evitar cargos innecesarios.

Consulte la [Guía de Limpieza de Recursos](LIMPIEZA.md) para instrucciones detalladas sobre cómo eliminar correctamente todos los recursos en el orden adecuado.

**Nota**: Es fundamental seguir el orden de eliminación especificado en la guía para evitar errores de dependencias entre recursos.
