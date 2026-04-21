# 🔒 Laboratorio 5: Seguridad, Identidad y Gobernanza en AWS

## Índice

- [Objetivos de aprendizaje](#objetivos-de-aprendizaje)
- [Tiempo estimado](#tiempo-estimado)
- [Prerrequisitos](#prerrequisitos)
- [Paso 1: Verificar región AWS](#paso-1-verificar-región-aws)
- [Paso 2: Acceder al Dashboard de IAM](#paso-2-acceder-al-dashboard-de-iam)
- [Paso 3: Crear grupo de usuarios](#paso-3-crear-grupo-de-usuarios)
- [Paso 4: Crear usuario IAM](#paso-4-crear-usuario-iam)
- [Paso 5: Simulación de acceso](#paso-5-simulación-de-acceso)
- [Paso 6: Habilitar GuardDuty](#paso-6-habilitar-guardduty)
- [Paso 7: Generar hallazgos de muestra](#paso-7-generar-hallazgos-de-muestra)
- [Paso 8: Analizar hallazgos](#paso-8-analizar-hallazgos)
- [Paso 9: Acceder a CloudTrail](#paso-9-acceder-a-cloudtrail)
- [Paso 10: Auditar accesos del usuario](#paso-10-auditar-accesos-del-usuario)
- [Paso 11: Auditar acciones administrativas](#paso-11-auditar-acciones-administrativas)
- [Conceptos clave](#conceptos-clave)
- [Solución de problemas](#solución-de-problemas)
- [Limpieza de recursos](#limpieza-de-recursos)

## Objetivos de aprendizaje

Al completar este laboratorio, usted será capaz de:

- Gestionar identidades y accesos en AWS utilizando IAM, aplicando el principio de menor privilegio mediante políticas administradas
- Detectar amenazas de seguridad en tiempo real utilizando Amazon GuardDuty sin necesidad de instalar agentes
- Auditar y rastrear actividad de usuarios y recursos en su cuenta AWS mediante AWS CloudTrail
- Comprender la diferencia entre autenticación (quién eres) y autorización (qué puedes hacer) en el contexto de seguridad en la nube

## Tiempo estimado

60 minutos

## Prerrequisitos

Para completar este laboratorio, necesita:

- Acceso a una cuenta AWS compartida con permisos de administrador
- Navegador web moderno (Chrome, Firefox, Edge o Safari)
- Bloc de notas o editor de texto para guardar información temporal

⚠️ **Importante**: Este laboratorio se ejecuta en un entorno de cuenta AWS compartida. Múltiples participantes trabajarán simultáneamente en la misma cuenta. Para evitar conflictos y facilitar la identificación de sus recursos, **DEBE** usar el placeholder `{nombre-participante}` en todos los nombres de recursos que cree.

**Ejemplos de nombres correctos**:
- `grupo-cloudpractitioner-lectura-juan`
- `usuario-estudiante-maria`
- `grupo-cloudpractitioner-lectura-carlos`

**Nunca modifique o elimine recursos que no incluyan su nombre de participante.**

## Paso 1: Verificar región AWS

Antes de comenzar con el laboratorio, es fundamental verificar que está trabajando en la región correcta de AWS.

1. Verifique que está trabajando en la región correcta:
   - En la esquina superior derecha de la consola de AWS
   - Confirme que dice la región estipulada por el instructor
   - Si no es correcta, haga clic y seleccione la región indicada

⚠️ **Advertencia Crítica - Entorno Compartido**

Este laboratorio se ejecuta en una cuenta AWS compartida donde múltiples participantes trabajan simultáneamente. Para evitar conflictos y facilitar la identificación de sus recursos:

- **DEBE** usar el placeholder `{nombre-participante}` en todos los nombres de recursos que cree
- Reemplace `{nombre-participante}` con su nombre real en minúsculas
- Siga siempre el patrón: `{tipo}-{descripcion}-{nombre-participante}`

**Ejemplos de nombres correctos siguiendo el patrón**:
- `grupo-cloudpractitioner-lectura-juan` (tipo: grupo, descripción: cloudpractitioner-lectura, participante: juan)
- `usuario-estudiante-maria` (tipo: usuario, descripción: estudiante, participante: maria)
- `grupo-cloudpractitioner-lectura-carlos` (tipo: grupo, descripción: cloudpractitioner-lectura, participante: carlos)
- `usuario-estudiante-ana` (tipo: usuario, descripción: estudiante, participante: ana)

**Nunca modifique o elimine recursos que no incluyan su nombre de participante.**

**✓ Verificación**: Confirme que:
- La región mostrada en la esquina superior derecha coincide con la indicada por el instructor
- Comprende la importancia de usar `{nombre-participante}` en todos los recursos que creará

## Paso 2: Acceder al Dashboard de IAM

En este paso, accederá al servicio AWS IAM (Identity and Access Management) y copiará la URL de inicio de sesión de la consola, que necesitará más adelante para probar el acceso con el usuario IAM que creará.

1. Asegúrese de estar iniciado sesión con su usuario principal que tiene permisos de administrador

2. En la barra de búsqueda global (parte superior de la consola), escriba **IAM**

3. En los resultados, haga clic en **IAM** para abrir el servicio

4. Será redirigido al Dashboard de IAM (panel principal del servicio)

5. En el Dashboard de IAM, localice la sección **AWS Account** (Cuenta de AWS) en el panel derecho

6. Dentro de esta sección, encontrará el campo **Console sign-in URL** (URL de inicio de sesión de la consola)

7. Haga clic en el icono de copiar junto a la URL, o seleccione la URL completa y cópiela

8. Pegue esta URL en un bloc de notas o editor de texto para usarla más adelante

> **Nota**: Esta URL de inicio de sesión es específica de su cuenta AWS y será necesaria en el Paso 5 cuando pruebe el acceso con el usuario IAM que creará. La URL tiene un formato similar a: `https://123456789012.signin.aws.amazon.com/console`

**✓ Verificación**: Confirme que:
- Está en el Dashboard de IAM (el título de la página dice "IAM Dashboard")
- Ha copiado y guardado la Console Sign-in URL en un lugar accesible
- La URL copiada comienza con `https://` y contiene `signin.aws.amazon.com`

## Paso 3: Crear grupo de usuarios

En este paso, creará un grupo de usuarios en IAM y le asignará una política administrada de AWS que otorga permisos de solo lectura. Los grupos de usuarios facilitan la gestión de permisos al permitirle asignar políticas a un grupo en lugar de a usuarios individuales.

1. En el panel de navegación de la izquierda del Dashboard de IAM, haga clic en **Grupos de usuarios**

2. Haga clic en el botón naranja **Crear grupo** (ubicado en la parte superior derecha)

3. En la página "Crear grupo de usuarios", configure el nombre del grupo:
   - **Nombre del grupo de usuarios**: `grupo-cloudpractitioner-lectura-{nombre-participante}`
   
   ⚠️ **Advertencia**: Es obligatorio seguir el patrón de nombre `grupo-cloudpractitioner-lectura-{nombre-participante}` donde reemplaza `{nombre-participante}` con su nombre real en minúsculas. Por ejemplo: `grupo-cloudpractitioner-lectura-juan`

4. Desplácese hacia abajo hasta la sección **Adjuntar políticas de permisos**

5. En el cuadro de búsqueda de políticas, escriba: **ViewOnlyAccess**

6. En los resultados de búsqueda, marque la casilla junto a la política **ViewOnlyAccess**

7. (Opcional) Para explorar qué permisos otorga esta política:
   - Haga clic en el símbolo **+** o en el nombre de la política **ViewOnlyAccess** para expandir los detalles
   - Haga clic en el enlace **JSON** para visualizar el documento de política completo
   - Observe que la política contiene múltiples declaraciones con `"Effect": "Allow"` y acciones que terminan en `Describe*`, `Get*`, `List*`, que son operaciones de solo lectura

8. Haga clic en el botón naranja **Crear grupo** (ubicado en la parte inferior de la página)

> **Nota educativa - Principio de menor privilegio**: La política ViewOnlyAccess implementa el principio de menor privilegio al otorgar únicamente permisos de lectura. Este principio de seguridad establece que los usuarios deben tener solo los permisos mínimos necesarios para realizar sus tareas. En este caso, el grupo puede ver recursos pero no modificarlos ni eliminarlos.

> **Nota educativa - Políticas administradas vs. personalizadas**: 
> - **Políticas administradas por AWS** (como ViewOnlyAccess): Son creadas y mantenidas por AWS. Se actualizan automáticamente cuando AWS agrega nuevos servicios o funcionalidades. Son ideales para casos de uso comunes.
> - **Políticas personalizadas**: Son creadas por usted para necesidades específicas de su organización. Ofrecen control granular pero requieren mantenimiento manual cuando cambian los requisitos.

**✓ Verificación**: Confirme que:
- El grupo de usuarios aparece en la lista de "Grupos de usuarios" con el nombre `grupo-cloudpractitioner-lectura-{nombre-participante}` (con su nombre real)
- En la columna "Políticas", el grupo muestra "1" política adjunta
- Al hacer clic en el nombre del grupo, puede ver que la política **ViewOnlyAccess** está asociada en la pestaña "Permisos"

## Paso 4: Crear usuario IAM

En este paso, creará un usuario de IAM con acceso a la consola de AWS y lo asignará al grupo que creó anteriormente. Este usuario tendrá los permisos de solo lectura heredados del grupo, aplicando el principio de menor privilegio.

1. En el panel de navegación de la izquierda del Dashboard de IAM, haga clic en **Usuarios**

2. Haga clic en el botón naranja **Crear usuario** (ubicado en la parte superior derecha)

3. En la página "Especificar detalles del usuario", configure el nombre del usuario:
   - **Nombre de usuario**: `usuario-estudiante-{nombre-participante}`
   
   ⚠️ **Advertencia**: Es obligatorio seguir el patrón de nombre `usuario-estudiante-{nombre-participante}` donde reemplaza `{nombre-participante}` con su nombre real en minúsculas. Por ejemplo: `usuario-estudiante-juan`

4. En la sección "Proporcionar acceso de usuario a la Consola de administración de AWS - opcional", marque la casilla para habilitar el acceso a la consola

5. Seleccione la opción **Quiero crear un usuario de IAM**

6. En la sección de configuración de contraseña:
   - Seleccione **Contraseña personalizada**
   - Ingrese una contraseña segura temporal que pueda recordar (por ejemplo: `LabSeguridad2024!`)
   - **DESMARQUE** la casilla "Los usuarios deben crear una nueva contraseña en el siguiente inicio de sesión"

> **Nota**: Desmarcamos la opción de cambio obligatorio de contraseña para ahorrar tiempo durante el laboratorio y simplificar la prueba de acceso. En un entorno de producción real, esta opción debería permanecer marcada para garantizar que cada usuario establezca su propia contraseña segura en el primer inicio de sesión.

7. Haga clic en el botón naranja **Siguiente** (ubicado en la parte inferior derecha)

8. En la página "Establecer permisos", seleccione la opción **Añadir usuario a grupo**

9. En la lista de grupos disponibles, marque la casilla junto al grupo `grupo-cloudpractitioner-lectura-{nombre-participante}` que creó en el paso anterior

10. Haga clic en el botón naranja **Siguiente** (ubicado en la parte inferior derecha)

11. En la página "Revisar y crear", revise la configuración del usuario:
    - Verifique que el nombre del usuario es correcto
    - Confirme que el acceso a la consola está habilitado
    - Verifique que el usuario está asignado al grupo correcto

12. Haga clic en el botón naranja **Crear usuario** (ubicado en la parte inferior derecha)

13. En la página de confirmación, verá un mensaje de éxito indicando que el usuario fue creado exitosamente

> **Nota educativa - Herencia de permisos**: Al añadir el usuario al grupo `grupo-cloudpractitioner-lectura-{nombre-participante}`, el usuario hereda automáticamente todos los permisos de las políticas adjuntas al grupo. En este caso, hereda los permisos de solo lectura de la política ViewOnlyAccess. Esta es una práctica recomendada en IAM: gestionar permisos a nivel de grupo en lugar de asignarlos individualmente a cada usuario, lo que facilita la administración y reduce errores.

**✓ Verificación**: Confirme que:
- El usuario aparece en la lista de "Usuarios" con el nombre `usuario-estudiante-{nombre-participante}` (con su nombre real)
- Al hacer clic en el nombre del usuario, puede ver en la pestaña "Permisos" que el usuario pertenece al grupo `grupo-cloudpractitioner-lectura-{nombre-participante}`
- En la pestaña "Credenciales de seguridad", el campo "Acceso a la consola" muestra "Habilitado"

## Paso 5: Simulación de acceso

En este paso, iniciará sesión con el usuario IAM que creó y realizará pruebas empíricas para validar que la política de solo lectura funciona correctamente. Realizará una prueba positiva (acceso permitido a S3) y una prueba negativa (acceso denegado a EC2) para comprender cómo IAM valida los permisos.

1. Abra una ventana de navegación privada o incógnito en su navegador:
   - **Chrome**: Presione `Ctrl+Shift+N` (Windows/Linux) o `Cmd+Shift+N` (Mac)
   - **Firefox**: Presione `Ctrl+Shift+P` (Windows/Linux) o `Cmd+Shift+P` (Mac)
   - **Edge**: Presione `Ctrl+Shift+N` (Windows/Linux) o `Cmd+Shift+N` (Mac)
   - **Safari**: Presione `Cmd+Shift+N` (Mac)

> **Nota**: Usar una ventana de incógnito evita conflictos con su sesión actual de administrador y le permite probar el acceso del usuario IAM de forma aislada.

2. En la ventana de incógnito, pegue la **Console Sign-in URL** que copió en el Paso 2

3. Presione Enter para cargar la página de inicio de sesión

4. En la página de inicio de sesión, ingrese las credenciales del usuario IAM:
   - **Nombre de usuario**: `usuario-estudiante-{nombre-participante}` (reemplace con su nombre real, por ejemplo: `usuario-estudiante-juan`)
   - **Contraseña**: La contraseña personalizada que configuró en el Paso 4

5. Haga clic en el botón **Iniciar sesión**

**✓ Verificación**: Confirme que:
- Ha iniciado sesión exitosamente en la consola de AWS
- En la esquina superior derecha, puede ver el nombre del usuario IAM (por ejemplo: `usuario-estudiante-juan`)
- No aparecen mensajes de error de autenticación

> **Nota educativa - Autenticación vs. Autorización**:
> - **Autenticación**: Es el proceso de verificar quién eres. Acabas de autenticarte proporcionando tu nombre de usuario y contraseña correctos.
> - **Autorización**: Es el proceso de verificar qué puedes hacer. Ahora probarás qué acciones te permite realizar la política ViewOnlyAccess adjunta a tu grupo.

### Prueba Positiva: Verificar acceso de lectura a S3

6. En la barra de búsqueda global (parte superior de la consola), escriba **S3**

7. En los resultados, haga clic en **S3** para abrir el servicio

8. Observe la lista de buckets de S3 en la cuenta

9. Verifique que puede ver los buckets sin recibir mensajes de error de permisos

> **Nota**: La política ViewOnlyAccess incluye permisos para acciones de lectura en S3 como `s3:ListAllMyBuckets` y `s3:GetBucketLocation`, por lo que puede visualizar la lista de buckets sin problemas.

**✓ Verificación - Prueba Positiva**: Confirme que:
- Puede ver la lista de buckets de S3 en la consola
- No aparecen mensajes de error como "Access Denied" o "No tiene permisos"
- La interfaz de S3 se carga correctamente

### Prueba Negativa: Verificar denegación de acceso de escritura a EC2

10. En la barra de búsqueda global (parte superior de la consola), escriba **EC2**

11. En los resultados, haga clic en **EC2** para abrir el servicio

12. Haga clic en el botón naranja **Lanzar instancia** (ubicado en la parte superior derecha)

13. Observe que aparece un mensaje de error indicando que no tiene permisos para realizar esta acción

> **Nota**: El mensaje de error puede variar, pero típicamente indica "You are not authorized to perform this operation" o "No está autorizado para realizar esta operación". Este es el comportamiento esperado, ya que la política ViewOnlyAccess solo otorga permisos de lectura, no de escritura o creación de recursos.

**✓ Verificación - Prueba Negativa**: Confirme que:
- Aparece un mensaje de error al intentar lanzar una instancia EC2
- El mensaje indica falta de permisos o autorización
- No puede proceder con la creación de la instancia

> **Nota educativa - Validación de permisos por políticas IAM**:
> 
> Cuando intentas realizar una acción en AWS, el servicio IAM evalúa todas las políticas adjuntas a tu identidad (usuario, grupo, rol) para determinar si la acción está permitida o denegada. El proceso de evaluación sigue estas reglas:
> 
> 1. **Denegación explícita**: Si alguna política tiene un "Deny" explícito, la acción se deniega inmediatamente
> 2. **Permiso explícito**: Si alguna política tiene un "Allow" explícito y no hay "Deny", la acción se permite
> 3. **Denegación implícita**: Si no hay ningún "Allow" explícito, la acción se deniega por defecto
> 
> En tu caso, la política ViewOnlyAccess tiene "Allow" para acciones de lectura (Get, List, Describe) pero no para acciones de escritura (Create, Delete, Modify), por lo que las acciones de escritura se deniegan implícitamente.

14. Cierre la ventana de navegación privada o incógnito

15. Regrese a su ventana de navegación normal donde tiene la sesión de administrador activa

**✓ Verificación - Comportamientos observados**: Confirme que:
- Pudo iniciar sesión exitosamente con el usuario IAM (autenticación exitosa)
- Pudo ver recursos en S3 (autorización de lectura funcionó correctamente)
- No pudo crear instancias EC2 (autorización de escritura fue denegada correctamente)
- Comprendió la diferencia entre autenticación (quién eres) y autorización (qué puedes hacer)

## Paso 6: Habilitar GuardDuty

En este paso, habilitará Amazon GuardDuty, un servicio de detección continua de amenazas que monitorea actividad maliciosa y comportamiento no autorizado en su cuenta AWS. GuardDuty analiza eventos de múltiples fuentes de datos de AWS para identificar amenazas de seguridad sin necesidad de instalar agentes ni administrar infraestructura adicional.

1. Asegúrese de estar en su sesión principal de AWS con permisos de administrador (no en la ventana de incógnito del usuario IAM)

2. En la barra de búsqueda global (parte superior de la consola), escriba **GuardDuty**

3. En los resultados, haga clic en **GuardDuty** para abrir el servicio

4. Si es la primera vez que accede a GuardDuty en esta región, verá una página de bienvenida

5. Haga clic en el botón naranja **Comenzar** o **Get Started** (ubicado en el centro de la página)

6. En la siguiente pantalla, revise la información sobre GuardDuty y los tipos de amenazas que detecta

7. Haga clic en el botón naranja **Habilitar GuardDuty** o **Enable GuardDuty** (ubicado en la parte inferior de la página)

8. GuardDuty se habilitará inmediatamente y comenzará a monitorear su cuenta

> **Nota educativa - GuardDuty como servicio regional**:
> 
> Amazon GuardDuty es un servicio regional, lo que significa que debe habilitarse de forma independiente en cada región de AWS donde desee monitorear actividad. Si trabaja con recursos en múltiples regiones (por ejemplo, us-east-1 y eu-west-1), debe habilitar GuardDuty en cada una de esas regiones por separado. Los hallazgos de GuardDuty son específicos de la región donde se detectan.
> 
> En este laboratorio, solo habilitaremos GuardDuty en la región actual especificada por el instructor.

> **Nota educativa - GuardDuty sin agentes (agentless)**:
> 
> A diferencia de soluciones tradicionales de seguridad que requieren instalar software (agentes) en cada servidor o instancia, GuardDuty es completamente sin agentes. Esto significa que:
> 
> - **No requiere instalación**: No necesita instalar ni mantener software adicional en sus instancias EC2 u otros recursos
> - **No afecta el rendimiento**: No consume recursos computacionales de sus instancias
> - **Activación inmediata**: Comienza a funcionar inmediatamente después de habilitarlo
> - **Análisis inteligente**: GuardDuty analiza automáticamente logs de VPC Flow Logs, CloudTrail y DNS para detectar amenazas usando machine learning y inteligencia de amenazas
> 
> Esta arquitectura sin agentes hace que GuardDuty sea fácil de implementar y escalar sin impacto operacional en su infraestructura.

**✓ Verificación**: Confirme que:
- Está en el Dashboard de GuardDuty (el título de la página dice "GuardDuty")
- Aparece un mensaje de confirmación indicando que GuardDuty está habilitado
- En el panel principal, puede ver secciones como "Resumen" o "Summary" y "Hallazgos" o "Findings"
- El estado del servicio muestra "Habilitado" o "Enabled"

## Paso 7: Generar hallazgos de muestra

En este paso, generará hallazgos de muestra en GuardDuty para visualizar cómo se presentan las alertas de seguridad sin necesidad de simular un ataque real. Los hallazgos de muestra le permitirán familiarizarse con la interfaz y los tipos de amenazas que GuardDuty puede detectar.

1. En el panel de navegación de la izquierda de GuardDuty, haga clic en **Configuración** o **Settings**

2. En la página de Configuración, desplácese hacia abajo hasta encontrar la sección **Hallazgos de muestra** o **Sample findings**

3. Haga clic en el botón **Generar hallazgos de muestra** o **Generate sample findings**

4. GuardDuty generará automáticamente un conjunto de hallazgos de muestra que representan diferentes tipos de amenazas

5. Espere unos segundos y observe el mensaje de confirmación verde en la parte superior de la página indicando que los hallazgos de muestra se generaron exitosamente

> **Nota**: Los hallazgos de muestra son alertas simuladas que GuardDuty crea para fines de demostración y prueba. No representan amenazas reales en su cuenta, pero muestran exactamente cómo se verían los hallazgos reales si GuardDuty detectara actividad maliciosa o sospechosa.

**✓ Verificación**: Confirme que:
- Aparece un mensaje de confirmación verde indicando que los hallazgos de muestra se generaron exitosamente
- El mensaje puede decir algo como "Sample findings generated successfully" o "Hallazgos de muestra generados exitosamente"
- No aparecen mensajes de error

## Paso 8: Analizar hallazgos

En este paso, analizará los hallazgos de muestra generados por GuardDuty para familiarizarse con la interfaz de alertas de seguridad y comprender qué tipo de información proporciona AWS cuando detecta actividad anómala o potencialmente maliciosa en su cuenta.

1. En el panel de navegación de la izquierda de GuardDuty, haga clic en **Hallazgos** o **Findings**

2. Observe la lista de hallazgos de muestra que se generaron en el paso anterior

3. En la lista de hallazgos, preste atención a las etiquetas de severidad que aparecen en cada hallazgo:
   - **Baja** (Low): Actividad sospechosa de bajo riesgo
   - **Media** (Medium): Actividad sospechosa que requiere atención
   - **Alta** (High): Actividad potencialmente maliciosa que requiere investigación inmediata

> **Nota**: Los hallazgos de muestra incluyen ejemplos de diferentes niveles de severidad para que pueda familiarizarse con cómo GuardDuty clasifica las amenazas según su impacto potencial.

### Analizar hallazgo relacionado con EC2

4. En la lista de hallazgos, busque un hallazgo relacionado con EC2, específicamente uno con el tipo **Recon:EC2/PortProbeUnprotectedPort**

5. Haga clic en el nombre del hallazgo para expandir el panel de detalles en el lado derecho de la pantalla

6. En el panel de detalles, observe la siguiente información:
   - **Severidad**: Nivel de gravedad del hallazgo (en este caso, generalmente Media)
   - **Recurso afectado**: La instancia EC2 que fue objetivo del escaneo de puertos
   - **Resumen**: Descripción breve de la amenaza detectada
   - **Detalles de la acción**: Información sobre el tipo de actividad detectada (escaneo de puertos)
   - **Dirección IP de origen**: La dirección IP desde donde se originó el escaneo

> **Nota educativa - Recon:EC2/PortProbeUnprotectedPort**:
> 
> Este tipo de hallazgo indica que GuardDuty detectó un escaneo de puertos en una instancia EC2. Un escaneo de puertos es una técnica de reconocimiento que los atacantes utilizan para identificar qué servicios están ejecutándose en un servidor y qué puertos están abiertos. Esta es típicamente la primera fase de un ataque, donde el atacante intenta mapear la superficie de ataque antes de intentar explotar vulnerabilidades.
> 
> En un escenario real, este hallazgo sugeriría que alguien está investigando su infraestructura, posiblemente como preparación para un ataque más sofisticado.

### Analizar hallazgo relacionado con IAM

7. Regrese a la lista de hallazgos haciendo clic en el botón de retroceso o cerrando el panel de detalles

8. En la lista de hallazgos, busque un hallazgo relacionado con IAM, específicamente uno con el tipo **UnauthorizedAccess:IAMUser/MaliciousIPCaller**

9. Haga clic en el nombre del hallazgo para expandir el panel de detalles

10. En el panel de detalles, observe la siguiente información:
    - **Severidad**: Nivel de gravedad del hallazgo (en este caso, generalmente Media o Alta)
    - **Recurso afectado**: El usuario IAM que realizó la llamada a la API
    - **Resumen**: Descripción de la actividad sospechosa detectada
    - **Detalles de la acción**: Tipo de llamada a la API realizada
    - **Dirección IP de origen**: La dirección IP desde donde se realizó la llamada, identificada como maliciosa

> **Nota educativa - UnauthorizedAccess:IAMUser/MaliciousIPCaller**:
> 
> Este tipo de hallazgo indica que GuardDuty detectó una llamada a la API de AWS desde una dirección IP conocida por estar asociada con actividad maliciosa. GuardDuty mantiene una base de datos de inteligencia de amenazas que incluye direcciones IP reportadas como fuentes de ataques, malware o actividad sospechosa.
> 
> En un escenario real, este hallazgo sugeriría que las credenciales de un usuario IAM podrían haber sido comprometidas y están siendo utilizadas desde una ubicación asociada con actores maliciosos. Esto requeriría acción inmediata, como rotar las credenciales del usuario y revisar los permisos.

### Comprender el panel de detalles

11. Mientras visualiza cualquiera de los hallazgos, familiarícese con las secciones del panel de detalles:
    - **Resumen**: Proporciona una descripción concisa de la amenaza detectada
    - **Recurso afectado**: Identifica el recurso específico de AWS involucrado (instancia EC2, usuario IAM, bucket S3, etc.)
    - **Acción**: Describe el tipo de actividad que desencadenó el hallazgo
    - **Actor**: Información sobre la fuente de la actividad (dirección IP, ubicación geográfica)
    - **Información adicional**: Detalles técnicos adicionales que pueden ayudar en la investigación

> **Nota educativa - Tipos de amenazas comunes detectadas por GuardDuty**:
> 
> GuardDuty puede detectar una amplia variedad de amenazas de seguridad, organizadas en categorías:
> 
> - **Reconocimiento (Recon)**: Actividad que sugiere que un atacante está investigando su infraestructura, como escaneos de puertos o enumeración de recursos
> - **Acceso no autorizado (UnauthorizedAccess)**: Intentos de acceder a recursos sin los permisos adecuados o desde ubicaciones sospechosas
> - **Compromiso de instancia (Instance Compromise)**: Comportamiento que sugiere que una instancia EC2 ha sido comprometida, como comunicación con servidores de comando y control
> - **Exfiltración de datos (Exfiltration)**: Actividad que sugiere que los datos están siendo extraídos de su cuenta de forma no autorizada
> - **Minería de criptomonedas (CryptoCurrency)**: Detección de actividad relacionada con minería de criptomonedas no autorizada
> - **Malware**: Detección de comunicación con dominios o direcciones IP asociadas con malware conocido
> 
> Cada tipo de amenaza proporciona información específica que ayuda a los equipos de seguridad a comprender la naturaleza del incidente y tomar las acciones correctivas apropiadas.

**✓ Verificación**: Confirme que:
- Puede ver la lista de hallazgos de muestra en GuardDuty
- Identificó y revisó el hallazgo **Recon:EC2/PortProbeUnprotectedPort** relacionado con EC2
- Identificó y revisó el hallazgo **UnauthorizedAccess:IAMUser/MaliciousIPCaller** relacionado con IAM
- Comprende cómo leer el panel de detalles de un hallazgo, incluyendo severidad, recurso afectado y resumen
- Comprende los tipos básicos de amenazas que GuardDuty puede detectar

## Paso 9: Acceder a CloudTrail

En este paso, accederá al servicio AWS CloudTrail y navegará hasta el historial de eventos para visualizar el registro de las llamadas a la API recientes en su cuenta AWS. CloudTrail es un servicio de gobernanza y auditoría que registra automáticamente toda la actividad de administración en su cuenta, proporcionando trazabilidad completa de las acciones realizadas por usuarios, roles y servicios.

1. Asegúrese de estar en su sesión principal de AWS con permisos de administrador

2. En la barra de búsqueda global (parte superior de la consola), escriba **CloudTrail**

3. En los resultados, haga clic en **CloudTrail** para abrir el servicio

4. Será redirigido al Dashboard de CloudTrail (panel principal del servicio)

5. Observe el menú lateral izquierdo del servicio CloudTrail

6. En el panel de navegación de la izquierda, haga clic en **Historial de eventos** o **Event history**

7. Se cargará la vista del historial de eventos, mostrando una lista de eventos de administración recientes en su cuenta

> **Nota educativa - Registro de 90 días de eventos de administración**:
> 
> AWS CloudTrail Event History registra automáticamente los últimos 90 días de eventos de administración en su cuenta de forma gratuita. Los eventos de administración incluyen operaciones de gestión de recursos como:
> 
> - Creación, modificación o eliminación de recursos (CreateUser, DeleteBucket, RunInstances)
> - Cambios en configuraciones de seguridad (AttachGroupPolicy, PutBucketPolicy)
> - Inicio de sesión en la consola (ConsoleLogin)
> - Llamadas a APIs de AWS realizadas por usuarios, roles o servicios
> 
> Este registro automático proporciona visibilidad inmediata de la actividad en su cuenta sin necesidad de configuración adicional. Para retener eventos por más de 90 días o registrar eventos de datos (como acceso a objetos S3), debe crear un trail de CloudTrail, que tiene costos asociados.

> **Nota educativa - Servicio gratuito habilitado por defecto**:
> 
> CloudTrail Event History es un servicio gratuito que está habilitado por defecto en todas las cuentas de AWS. No necesita activarlo ni configurarlo para comenzar a registrar eventos de administración. Esto significa que:
> 
> - **Sin costo**: La visualización del historial de eventos de los últimos 90 días no tiene costo
> - **Sin configuración**: No requiere configuración inicial para comenzar a registrar eventos
> - **Disponibilidad inmediata**: Puede acceder al historial de eventos en cualquier momento desde el primer día de su cuenta
> - **Auditoría básica**: Proporciona capacidades de auditoría básicas sin necesidad de crear trails adicionales
> 
> Esta funcionalidad gratuita es fundamental para la seguridad y el cumplimiento, ya que permite rastrear quién hizo qué, cuándo y desde dónde en su cuenta AWS.

**✓ Verificación**: Confirme que:
- Está en la vista "Historial de eventos" de CloudTrail (el título de la página dice "Event history" o "Historial de eventos")
- Puede ver una lista de eventos recientes con columnas como "Nombre del evento", "Nombre de usuario", "Hora del evento" y "Recurso"
- Los eventos están ordenados cronológicamente, mostrando los más recientes primero
- Comprende que este historial registra automáticamente los últimos 90 días de actividad de administración sin costo adicional

## Paso 10: Auditar accesos del usuario

En este paso, utilizará el historial de eventos de CloudTrail para auditar los intentos de acceso realizados por el usuario IAM que creó en el Paso 4. Filtrará los eventos por nombre de usuario para rastrear las acciones de inicio de sesión y los intentos de acceso no autorizados que generó durante la simulación del Paso 5.

1. Asegúrese de estar en la vista "Historial de eventos" de CloudTrail

2. Localice la barra de filtros en la parte superior de la lista de eventos

3. En la barra de filtros, haga clic en el menú desplegable que dice **Seleccionar atributo** o **Select attribute**

4. En el menú desplegable, seleccione la opción **Nombre de usuario** o **User name**

5. En la caja de búsqueda que aparece junto al atributo seleccionado, ingrese el nombre del usuario IAM que creó:
   - Escriba: `usuario-estudiante-{nombre-participante}`
   - Reemplace `{nombre-participante}` con su nombre real en minúsculas

   **Ejemplo concreto**: Si su nombre es Juan, escriba: `usuario-estudiante-juan`

6. Presione Enter o haga clic en el botón de búsqueda para aplicar el filtro

7. CloudTrail mostrará únicamente los eventos asociados con el usuario IAM especificado

### Identificar eventos de inicio de sesión

8. En la lista de eventos filtrados, busque eventos con el nombre **ConsoleLogin**

9. Estos eventos representan los intentos de inicio de sesión en la consola de AWS que realizó con el usuario IAM en el Paso 5

10. Haga clic en uno de los eventos **ConsoleLogin** para expandir los detalles

11. En el panel de detalles, observe la siguiente información:
    - **Nombre del evento**: ConsoleLogin
    - **Nombre de usuario**: El usuario IAM que inició sesión (usuario-estudiante-{nombre-participante})
    - **Hora del evento**: Fecha y hora exacta del inicio de sesión
    - **Dirección IP de origen**: La dirección IP desde donde se realizó el inicio de sesión
    - **Agente de usuario**: Información sobre el navegador utilizado
    - **Resultado**: Si el inicio de sesión fue exitoso o fallido

> **Nota**: Si el inicio de sesión fue exitoso, el campo "responseElements" mostrará "ConsoleLogin: Success". Si hubiera fallado (por ejemplo, por contraseña incorrecta), mostraría "ConsoleLogin: Failure".

### Identificar errores de acceso a EC2

12. Regrese a la lista de eventos filtrados

13. Desplácese por la lista de eventos y busque eventos relacionados con el servicio **EC2**

14. Busque específicamente eventos que muestren errores de permisos, como:
    - Eventos con nombres que incluyan "Describe", "Run" o "Launch" relacionados con EC2
    - Eventos que en la columna "Código de error" o "Error code" muestren mensajes como "AccessDenied" o "UnauthorizedOperation"

15. Haga clic en uno de estos eventos de error de EC2 para expandir los detalles

16. En el panel de detalles, observe la siguiente información:
    - **Nombre del evento**: El tipo de operación que se intentó realizar (por ejemplo, RunInstances, DescribeInstances)
    - **Código de error**: El tipo de error que ocurrió (por ejemplo, Client.UnauthorizedOperation)
    - **Mensaje de error**: Descripción del error indicando que el usuario no tiene permisos para realizar la acción
    - **Hora del evento**: Cuándo se intentó la operación
    - **Dirección IP de origen**: Desde dónde se realizó el intento

> **Nota educativa - Importancia de la auditoría de accesos**:
> 
> La auditoría de accesos mediante CloudTrail es fundamental para la seguridad y el cumplimiento en AWS por varias razones:
> 
> - **Detección de actividad sospechosa**: Permite identificar intentos de acceso no autorizados o patrones de comportamiento anómalos que podrían indicar una brecha de seguridad
> - **Investigación de incidentes**: Cuando ocurre un incidente de seguridad, CloudTrail proporciona un registro detallado de todas las acciones realizadas, permitiendo reconstruir la secuencia de eventos
> - **Cumplimiento normativo**: Muchas regulaciones (como GDPR, HIPAA, PCI-DSS) requieren mantener registros de auditoría de quién accedió a qué datos y cuándo
> - **Validación de políticas de seguridad**: Permite verificar que las políticas de IAM están funcionando correctamente al mostrar qué acciones fueron permitidas y cuáles fueron denegadas
> - **Responsabilidad y trazabilidad**: Establece un registro inmutable de las acciones de cada usuario, promoviendo la responsabilidad individual
> 
> En este laboratorio, está auditando las acciones del usuario IAM que creó para verificar que:
> 1. El usuario pudo iniciar sesión exitosamente (autenticación funcionó)
> 2. El usuario pudo ver recursos en S3 (autorización de lectura funcionó)
> 3. El usuario no pudo crear instancias EC2 (autorización de escritura fue denegada correctamente)
> 
> En un entorno de producción real, los equipos de seguridad revisan regularmente los logs de CloudTrail para detectar anomalías, investigar incidentes y garantizar el cumplimiento de las políticas de seguridad de la organización.

**✓ Verificación**: Confirme que:
- Aplicó correctamente el filtro por "Nombre de usuario" con el valor `usuario-estudiante-{nombre-participante}`
- Identificó al menos un evento **ConsoleLogin** que representa el inicio de sesión del usuario IAM
- Identificó eventos relacionados con EC2 que muestran errores de permisos (AccessDenied o UnauthorizedOperation)
- Comprende la información que proporciona cada evento (nombre del evento, usuario, hora, dirección IP, resultado)
- Comprende la importancia de la auditoría de accesos para la seguridad, cumplimiento e investigación de incidentes

## Paso 11: Auditar acciones administrativas

En este paso, filtrará los eventos de CloudTrail para encontrar las acciones de creación de usuarios y grupos que realizó al inicio del laboratorio. Esto le permitirá comprobar que AWS registra automáticamente todo cambio administrativo en su cuenta, proporcionando trazabilidad completa de las operaciones de gestión de identidades.

1. Asegúrese de estar en la vista "Historial de eventos" de CloudTrail

2. Si todavía tiene el filtro anterior aplicado (por nombre de usuario), borre el filtro:
   - Haga clic en la "X" junto al filtro activo para eliminarlo
   - O haga clic en el botón **Borrar filtros** o **Clear filters** si está disponible

3. En la barra de filtros, haga clic en el menú desplegable que dice **Seleccionar atributo** o **Select attribute**

4. En el menú desplegable, seleccione la opción **Nombre del recurso** o **Resource name**

5. En la caja de búsqueda que aparece junto al atributo seleccionado, ingrese el nombre del usuario IAM que creó:
   - Escriba: `usuario-estudiante-{nombre-participante}`
   - Reemplace `{nombre-participante}` con su nombre real en minúsculas

   **Ejemplo concreto**: Si su nombre es Juan, escriba: `usuario-estudiante-juan`

6. Presione Enter o haga clic en el botón de búsqueda para aplicar el filtro

7. CloudTrail mostrará los eventos relacionados con el recurso especificado (su usuario IAM)

### Localizar eventos de creación de recursos IAM

8. En la lista de eventos filtrados, busque eventos de API con los siguientes nombres:
   - **CreateUser**: Evento que registra la creación del usuario IAM
   - **CreateGroup**: Evento que registra la creación del grupo de usuarios
   - **AttachGroupPolicy**: Evento que registra la asignación de la política ViewOnlyAccess al grupo

⚠️ **Advertencia Crítica - Tiempo de Propagación de Eventos**

Los eventos en CloudTrail pueden tardar hasta 15 minutos en aparecer en el historial después de que se realiza la acción. Esto se debe al tiempo de procesamiento y propagación de los logs en el sistema de CloudTrail.

**Si no ve los eventos inmediatamente**:
- Espere unos minutos y actualice la página del historial de eventos
- Haga clic en el botón de actualización del navegador o presione F5
- Los eventos eventualmente aparecerán una vez que CloudTrail complete el procesamiento

> **Nota educativa - Tiempo de propagación en CloudTrail**:
> 
> AWS CloudTrail registra eventos de forma continua, pero existe un retraso entre el momento en que se realiza una acción y el momento en que el evento aparece en el historial. Este retraso típicamente es de:
> 
> - **Eventos de administración**: Generalmente aparecen en 5-15 minutos
> - **Eventos de datos**: Pueden tardar más tiempo en aparecer
> 
> Este comportamiento es normal y se debe a que CloudTrail:
> 1. Captura el evento cuando ocurre la acción
> 2. Procesa y valida el evento
> 3. Almacena el evento en el historial
> 4. Indexa el evento para que sea buscable
> 
> En un entorno de producción, los equipos de seguridad deben tener en cuenta este retraso al investigar incidentes recientes. Para alertas en tiempo real sobre actividad sospechosa, se recomienda usar Amazon EventBridge (anteriormente CloudWatch Events) en combinación con CloudTrail, o servicios como GuardDuty que analizan los logs de CloudTrail de forma continua.

### Analizar eventos administrativos

9. Una vez que los eventos aparezcan, haga clic en el evento **CreateUser** para expandir los detalles

10. En el panel de detalles, observe la siguiente información:
    - **Nombre del evento**: CreateUser
    - **Nombre de usuario**: El usuario administrador que creó el recurso (su usuario principal)
    - **Hora del evento**: Fecha y hora exacta de la creación del usuario IAM
    - **Nombre del recurso**: El nombre del usuario IAM creado (usuario-estudiante-{nombre-participante})
    - **Región**: La región donde se realizó la acción (IAM es global, pero el evento se registra en la región donde se realizó la llamada a la API)

11. Regrese a la lista de eventos y haga clic en el evento **CreateGroup** (si está visible)

12. Observe los detalles del evento de creación del grupo, incluyendo:
    - El nombre del grupo creado (grupo-cloudpractitioner-lectura-{nombre-participante})
    - Quién realizó la acción
    - Cuándo se realizó

13. Busque y haga clic en el evento **AttachGroupPolicy** (si está visible)

14. En los detalles de este evento, observe:
    - El nombre del grupo al que se adjuntó la política
    - El nombre de la política adjuntada (ViewOnlyAccess)
    - Quién realizó la acción de adjuntar la política

> **Nota**: Estos eventos demuestran que CloudTrail registra automáticamente todas las acciones administrativas en IAM, proporcionando un registro completo de:
> - Quién creó el usuario y el grupo
> - Cuándo se crearon
> - Qué políticas se adjuntaron
> - Desde qué dirección IP se realizaron las acciones
> 
> Esta trazabilidad es fundamental para auditorías de seguridad, cumplimiento normativo e investigación de incidentes. En un entorno de producción, estos logs se utilizan para:
> - Detectar creación no autorizada de usuarios o cambios en permisos
> - Investigar brechas de seguridad rastreando qué acciones se realizaron
> - Cumplir con requisitos de auditoría que exigen registros de cambios en identidades y accesos
> - Generar reportes de cumplimiento para regulaciones como SOC 2, ISO 27001, GDPR, etc.

**✓ Verificación**: Confirme que:
- Borró el filtro anterior y aplicó un nuevo filtro por "Nombre del recurso" con el valor `usuario-estudiante-{nombre-participante}`
- Identificó al menos uno de los siguientes eventos: **CreateUser**, **CreateGroup** o **AttachGroupPolicy**
- Si los eventos no aparecieron inmediatamente, esperó unos minutos y actualizó la página
- Comprende que los eventos pueden tardar hasta 15 minutos en aparecer debido al tiempo de propagación en CloudTrail
- Comprende que CloudTrail registra automáticamente todas las acciones administrativas, proporcionando trazabilidad completa para auditorías y cumplimiento

## Conceptos clave

En este laboratorio, ha explorado tres pilares fundamentales de la seguridad en AWS. A continuación, se resumen los conceptos clave que debe retener de cada módulo:

### IAM y Principio de Menor Privilegio

AWS Identity and Access Management (IAM) es el servicio que controla quién puede acceder a sus recursos de AWS y qué acciones pueden realizar. Los conceptos fundamentales que aprendió incluyen:

- **Principio de menor privilegio**: Los usuarios deben tener únicamente los permisos mínimos necesarios para realizar sus tareas. En este laboratorio, aplicó este principio al asignar la política ViewOnlyAccess, que otorga permisos de solo lectura sin permitir modificaciones o eliminaciones de recursos.

- **Gestión de permisos mediante grupos**: En lugar de asignar políticas directamente a usuarios individuales, es una práctica recomendada crear grupos de usuarios y asignar políticas a los grupos. Los usuarios heredan automáticamente los permisos del grupo, facilitando la administración y reduciendo errores.

- **Diferencia entre autenticación y autorización**: La autenticación verifica quién eres (mediante usuario y contraseña), mientras que la autorización determina qué puedes hacer (mediante políticas de IAM). Ambos conceptos trabajan juntos para proporcionar seguridad integral.

- **Políticas administradas vs. personalizadas**: AWS proporciona políticas administradas (como ViewOnlyAccess) que se actualizan automáticamente cuando se agregan nuevos servicios. Las políticas personalizadas ofrecen control granular pero requieren mantenimiento manual.

### GuardDuty y Detección de Amenazas

Amazon GuardDuty es un servicio de detección continua de amenazas que monitorea actividad maliciosa y comportamiento no autorizado en su cuenta AWS. Los conceptos clave incluyen:

- **Detección sin agentes (agentless)**: GuardDuty no requiere instalar software adicional en sus instancias o recursos. Analiza automáticamente logs de VPC Flow Logs, CloudTrail y DNS para detectar amenazas usando machine learning e inteligencia de amenazas.

- **Servicio regional**: GuardDuty debe habilitarse de forma independiente en cada región de AWS donde desee monitorear actividad. Los hallazgos son específicos de la región donde se detectan.

- **Clasificación por severidad**: GuardDuty clasifica las amenazas en tres niveles de severidad (Baja, Media, Alta) según su impacto potencial, permitiendo priorizar la respuesta a incidentes.

- **Tipos de amenazas detectadas**: GuardDuty identifica múltiples categorías de amenazas, incluyendo reconocimiento (escaneos de puertos), acceso no autorizado (credenciales comprometidas), compromiso de instancias (comunicación con servidores maliciosos), exfiltración de datos y minería de criptomonedas no autorizada.

- **Inteligencia de amenazas integrada**: GuardDuty mantiene una base de datos actualizada de direcciones IP maliciosas, dominios asociados con malware y patrones de comportamiento sospechoso, permitiendo detectar amenazas conocidas automáticamente.

### CloudTrail y Auditoría

AWS CloudTrail es un servicio de gobernanza y auditoría que registra automáticamente toda la actividad de administración en su cuenta AWS. Los conceptos fundamentales incluyen:

- **Registro automático de 90 días**: CloudTrail Event History registra automáticamente los últimos 90 días de eventos de administración de forma gratuita y sin necesidad de configuración. Esto proporciona visibilidad inmediata de la actividad en su cuenta.

- **Trazabilidad completa**: CloudTrail registra quién realizó cada acción, qué acción se realizó, cuándo ocurrió, desde qué dirección IP y cuál fue el resultado (éxito o error). Esta información es fundamental para auditorías de seguridad e investigación de incidentes.

- **Eventos de administración**: CloudTrail registra operaciones de gestión de recursos como creación, modificación o eliminación de recursos, cambios en configuraciones de seguridad, inicio de sesión en la consola y llamadas a APIs de AWS.

- **Tiempo de propagación**: Los eventos pueden tardar hasta 15 minutos en aparecer en el historial después de que se realiza la acción, debido al tiempo de procesamiento y propagación de los logs en el sistema de CloudTrail.

- **Importancia para cumplimiento**: CloudTrail es esencial para cumplir con regulaciones que requieren mantener registros de auditoría (GDPR, HIPAA, PCI-DSS, SOC 2, ISO 27001). Permite demostrar quién accedió a qué datos, cuándo y desde dónde.

- **Detección de actividad sospechosa**: Al revisar regularmente los logs de CloudTrail, los equipos de seguridad pueden identificar intentos de acceso no autorizados, patrones de comportamiento anómalos y validar que las políticas de seguridad están funcionando correctamente.

### Integración de los Tres Servicios

Estos tres servicios trabajan juntos para proporcionar una estrategia de seguridad integral en AWS:

- **IAM** controla quién puede acceder y qué pueden hacer
- **GuardDuty** detecta cuando alguien intenta hacer algo malicioso
- **CloudTrail** registra todo lo que se hace para auditoría e investigación

En un entorno de producción, estos servicios se complementan para proporcionar defensa en profundidad: IAM previene accesos no autorizados, GuardDuty detecta amenazas en tiempo real, y CloudTrail proporciona el registro de auditoría necesario para investigar incidentes y cumplir con regulaciones.

## Solución de problemas

Si encuentra dificultades durante este laboratorio, consulte la [Guía de Solución de Problemas](TROUBLESHOOTING.md) que contiene soluciones a errores comunes.

## Limpieza de recursos

Para instrucciones opcionales sobre cómo eliminar los recursos creados en este laboratorio, consulte el documento [LIMPIEZA.md](LIMPIEZA.md).
