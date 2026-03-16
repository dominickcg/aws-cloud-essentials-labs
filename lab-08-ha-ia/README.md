# 🏛️ Laboratorio 8: Portal del Ciudadano para Consulta de Expedientes Constitucionales - Arquitectura en Alta Disponibilidad

## Índice
- [Objetivos de aprendizaje](#objetivos-de-aprendizaje)
- [Tiempo estimado](#tiempo-estimado)
- [Prerrequisitos](#prerrequisitos)
- [Escenario de negocio](#escenario-de-negocio)
- [Arquitectura de la solución](#arquitectura-de-la-solución)
- [Fase 1: Despliegue con CloudFormation (25 min)](#fase-1-despliegue-con-cloudformation-25-min)
  - [Paso 1: Verificar región AWS](#paso-1-verificar-región-aws)
  - [Paso 2: Lanzar la pila de CloudFormation](#paso-2-lanzar-la-pila-de-cloudformation)
  - [Paso 3: Monitorear eventos de la pila y confirmar suscripción de correo](#paso-3-monitorear-eventos-de-la-pila-y-confirmar-suscripción-de-correo)
- [Fase 2: Alta Disponibilidad y Seguridad (30 min)](#fase-2-alta-disponibilidad-y-seguridad-30-min)
  - [Paso 4: Acceder al portal del TC](#paso-4-acceder-al-portal-del-tc)
  - [Paso 5: Inspeccionar AWS WAF](#paso-5-inspeccionar-aws-waf)
  - [Paso 6: Simular fallo de servidor](#paso-6-simular-fallo-de-servidor)
  - [Paso 7: Inspeccionar RDS Multi-AZ y Secrets Manager](#paso-7-inspeccionar-rds-multi-az-y-secrets-manager)
  - [Paso 8: Inspeccionar roles IAM](#paso-8-inspeccionar-roles-iam)
- [Fase 3: Arquitectura Orientada a Eventos (15 min)](#fase-3-arquitectura-orientada-a-eventos-15-min)
  - [Paso 9: Publicar mensaje en SNS](#paso-9-publicar-mensaje-en-sns)
  - [Paso 10: Inspeccionar cola SQS y concepto de buffer](#paso-10-inspeccionar-cola-sqs-y-concepto-de-buffer)
  - [Paso 11: Verificar Lambda y CloudWatch](#paso-11-verificar-lambda-y-cloudwatch)
- [Fase 4: IA para el Ciudadano (20 min)](#fase-4-ia-para-el-ciudadano-20-min)
  - [Paso 12: Chatbot con Amazon Bedrock](#paso-12-chatbot-con-amazon-bedrock)
  - [Paso 13: Síntesis de voz con Amazon Polly](#paso-13-síntesis-de-voz-con-amazon-polly)
- [Solución de problemas](#solución-de-problemas)
- [Limpieza de recursos](#limpieza-de-recursos)

## Objetivos de aprendizaje

Al completar este laboratorio, usted será capaz de:

- Desplegar infraestructura completa de misión crítica mediante Infraestructura como Código (IaC) con AWS CloudFormation
- Validar alta disponibilidad y auto scaling terminando instancias EC2 y observando la recuperación automática
- Inspeccionar seguridad perimetral con AWS WAF y gestión de credenciales con AWS Secrets Manager
- Comprender el principio de mínimo privilegio mediante roles IAM
- Comprender arquitecturas orientadas a eventos con Amazon SNS, Amazon SQS y AWS Lambda para procesamiento desacoplado
- Interactuar con servicios de Inteligencia Artificial Generativa mediante Amazon Bedrock para asistencia ciudadana
- Implementar accesibilidad mediante síntesis de voz con Amazon Polly para ciudadanos con discapacidad visual
- Inspeccionar tolerancia a fallos con Amazon RDS Multi-AZ para protección de datos críticos

## Tiempo estimado

90 minutos

## Prerrequisitos

Para completar este laboratorio, usted necesita:

- Acceso a una cuenta AWS compartida proporcionada por el instructor
- Navegador web moderno (Chrome, Firefox, Edge o Safari)
- Acceso a su correo electrónico personal para confirmar suscripciones de Amazon SNS
- Archivo `TC-Portal-HA-Lab.yaml` descargado localmente en su computadora

## Escenario de negocio

El Tribunal Constitucional (TC) enfrenta un desafío crítico: cada vez que se publica un fallo controversial sobre temas sensibles como habeas corpus, amparo o inconstitucionalidad de leyes, el portal web experimenta saturación masiva de tráfico. Miles de ciudadanos, abogados, periodistas y académicos intentan acceder simultáneamente a los expedientes, causando caídas del sistema y negando el acceso a la justicia constitucional.

Esta situación es inaceptable en un estado democrático de derecho. El acceso a la información judicial es un derecho fundamental que no puede depender de la capacidad de un solo servidor. Además, el TC debe garantizar que todos los ciudadanos, incluyendo personas con discapacidad visual, puedan consultar las resoluciones de manera accesible.

Su misión es desplegar y validar una arquitectura de "Misión Crítica" que garantice:

- **Alta Disponibilidad**: El portal permanece en línea incluso si un servidor completo falla
- **Escalabilidad Automática**: El sistema se adapta automáticamente a picos masivos de tráfico
- **Seguridad Perimetral**: AWS WAF protege el portal contra ataques web comunes y AWS Secrets Manager gestiona las credenciales de la base de datos de forma segura
- **Procesamiento Desacoplado**: Los expedientes se procesan de manera asíncrona sin colapsar la infraestructura
- **Asistencia Inteligente**: Un chatbot de IA ayuda a los ciudadanos a comprender términos legales complejos
- **Accesibilidad Universal**: Síntesis de voz permite a personas con discapacidad visual escuchar las resoluciones

## Arquitectura de la solución

La arquitectura que desplegará en este laboratorio integra múltiples servicios de AWS para crear un sistema resiliente y escalable:

### Componentes de Alta Disponibilidad y Seguridad

```
┌──────────────┐
│              │
│  Ciudadano   │──────HTTP/HTTPS──┐
│              │                  │
└──────────────┘                  ▼
                          ┌─────────────────────┐
                          │  AWS WAF             │
                          │  Web ACL             │
                          │  (Filtro de tráfico) │
                          └─────────────────────┘
                                  │
                                  ▼ tráfico filtrado
                          ┌─────────────────────┐
                          │ Application Load     │
                          │ Balancer (ALB)       │
                          │ Multi-AZ             │
                          └─────────────────────┘
                            │                 │
                ┌───────────┘                 └───────────┐
                ▼                                         ▼
┌─────────────────────────────────┐   ┌─────────────────────────────────┐
│  Zona de Disponibilidad A       │   │  Zona de Disponibilidad B       │
│                                 │   │                                 │
│  ┌──────────────────────┐      │   │  ┌──────────────────────┐      │
│  │  EC2 Instance        │      │   │  │  EC2 Instance        │      │
│  │  Portal TC           │      │   │  │  Portal TC           │      │
│  └──────────────────────┘      │   │  └──────────────────────┘      │
│           │                     │   │           │                     │
│  ┌──────────────────────┐      │   │  ┌──────────────────────┐      │
│  │  RDS Primary         │      │   │  │  RDS Standby         │      │
│  │  MySQL               │◄─────┼───┼──│  MySQL Replica       │      │
│  └──────────────────────┘      │   │  └──────────────────────┘      │
│           ▲                     │   │  (Replicación Síncrona)        │
└───────────┼─────────────────────┘   └─────────────────────────────────┘
            │
┌───────────┴─────────────────────┐
│  AWS Secrets Manager            │
│  Credenciales auto-generadas    │
│  para la base de datos RDS      │
└─────────────────────────────────┘

        ┌────────────────────────────────────┐
        │  Auto Scaling Group                │
        │  Min: 2 | Max: 4 | Desired: 2     │
        │  Gestiona instancias EC2           │
        └────────────────────────────────────┘
```

### Componentes de Arquitectura Orientada a Eventos

```
┌──────────────────┐         ┌──────────────────┐         ┌──────────────────┐
│  Amazon SNS      │────────▶│  Amazon SQS      │────────▶│  AWS Lambda      │
│  Topic           │         │  Queue           │         │  Procesador      │
│  Alertas         │         │  Buffer          │         │  Expedientes     │
└──────────────────┘         └──────────────────┘         └──────────────────┘
        │                                                           │
        │                                                           │
        ▼                                                           ▼
┌──────────────────┐                                     ┌──────────────────┐
│  Correo Email    │                                     │  CloudWatch Logs │
│  del Participante│                                     │  Registros       │
└──────────────────┘                                     └──────────────────┘
```

### Componentes de Inteligencia Artificial

```
┌──────────────────┐                    ┌──────────────────────────────┐
│  EC2 Portal TC   │───API Call────────▶│  Amazon Bedrock              │
│  Aplicación Web  │                    │  Asistente Constitucional    │
└──────────────────┘                    │  (Modelo de IA Generativa)   │
        │                               └──────────────────────────────┘
        │
        │
        │───API Call────────▶┌──────────────────────────────┐
                             │  Amazon Polly                │
                             │  Síntesis de Voz             │
                             │  (Texto a Audio Neural)      │
                             └──────────────────────────────┘
```

### Concepto de Infraestructura como Código (IaC)

En este laboratorio, utilizará AWS CloudFormation para desplegar toda esta arquitectura compleja en cuestión de minutos, sin realizar configuraciones manuales. CloudFormation lee una plantilla (archivo YAML) que describe todos los recursos necesarios, calcula automáticamente las dependencias entre ellos, y los aprovisiona en el orden correcto.

Esto significa que en lugar de hacer clic manualmente para crear la VPC, luego las subnets, luego los security groups, luego las instancias EC2, luego el balanceador de carga, etc., simplemente cargará un archivo y CloudFormation hará todo el trabajo pesado por usted. Esta es la esencia de la Infraestructura como Código: definir su infraestructura en un archivo versionable y reproducible.

---

## Fase 1: Despliegue con CloudFormation (25 min)

### Paso 1: Verificar región AWS

1. Verifique que está trabajando en la región correcta:
   - En la esquina superior derecha de la consola de AWS
   - Confirme que dice la región estipulada por el instructor
   - Si no es correcta, haga clic y seleccione la región indicada

**¿Qué es Infraestructura como Código (IaC)?**

En este laboratorio, utilizará un enfoque revolucionario para desplegar infraestructura: en lugar de hacer clic manualmente en la consola para crear cada recurso (VPC, subnets, balanceador de carga, instancias EC2, base de datos, etc.), cargará un archivo de plantilla que describe toda la arquitectura.

AWS CloudFormation leerá esta plantilla, calculará automáticamente las dependencias entre los recursos, y los aprovisionará en el orden correcto. En cuestión de minutos, tendrá una arquitectura completa de misión crítica funcionando, sin configurar manualmente ni un solo recurso.

Esta es la esencia de la Infraestructura como Código: definir su infraestructura en un archivo versionable, reproducible y auditable. Si necesita crear el mismo entorno 10 veces, simplemente ejecuta la plantilla 10 veces. Si necesita eliminar todo, elimina la pila y CloudFormation se encarga de limpiar todos los recursos.

**Arquitectura que desplegará:**

Revise los diagramas de arquitectura presentados en la sección [Arquitectura de la solución](#arquitectura-de-la-solución) al inicio de este documento. Observe cómo los componentes se distribuyen en múltiples zonas de disponibilidad para garantizar alta disponibilidad, cómo AWS WAF filtra el tráfico antes de llegar al Application Load Balancer, cómo AWS Secrets Manager gestiona las credenciales de la base de datos, y cómo los servicios de eventos e IA se integran para crear un sistema resiliente y moderno.

### Paso 2: Lanzar la pila de CloudFormation

Ahora desplegará toda la infraestructura del Portal del Tribunal Constitucional utilizando AWS CloudFormation. Este proceso automatizado creará más de 20 recursos de AWS en cuestión de minutos.

1. En la barra de búsqueda global de la consola de AWS (parte superior), escriba `CloudFormation` y haga clic en el servicio **AWS CloudFormation** que aparece en los resultados.

2. En la consola de CloudFormation, haga clic en el botón naranja **Crear pila** ubicado en la esquina superior derecha.

3. En el menú desplegable que aparece, seleccione la opción **Con recursos nuevos (estándar)**.

4. En la pantalla "Crear pila", en la sección "Especificar plantilla":
   - Seleccione la opción **Cargar un archivo de plantilla**
   - Haga clic en el botón **Elegir archivo**
   - Navegue hasta la ubicación donde descargó el archivo `TC-Portal-HA-Lab.yaml` en su computadora
   - Seleccione el archivo y haga clic en **Abrir**
   - Haga clic en el botón **Siguiente** en la parte inferior de la pantalla

5. En la pantalla "Especificar detalles de la pila", configure los siguientes parámetros:
   - **Nombre de la pila**: `[Iniciales]-TC-Portal`
     - Reemplace `[Iniciales]` con sus iniciales personales (por ejemplo, si su nombre es Juan Pérez, use `JP-TC-Portal`)
     - Este nombre identifica sus recursos en el entorno compartido
   - **EmailAlerts**: Ingrese su dirección de correo electrónico personal
     - Esta dirección recibirá las notificaciones de alertas del sistema
     - Asegúrese de usar un correo al que tenga acceso inmediato
   - Haga clic en **Siguiente**

6. En la pantalla "Configurar opciones de la pila":
   - Deje todos los valores por defecto sin modificar
   - Desplácese hasta el final de la página
   - Haga clic en **Siguiente**

7. En la pantalla "Revisar y crear":
   - Revise el resumen de la configuración de su pila
   - Desplácese hasta el final de la página
   - En la sección "Capacidades", marque la casilla que dice:
     - ☑ **Reconozco que AWS CloudFormation podría crear recursos de IAM con nombres personalizados**
   - Esta confirmación es necesaria porque la plantilla crea roles y políticas de IAM para Lambda y EC2
   - Haga clic en el botón naranja **Enviar** para iniciar el despliegue

⏱️ **Nota**: CloudFormation comenzará a crear los recursos inmediatamente. El proceso completo tomará aproximadamente 15-20 minutos, principalmente debido a la base de datos RDS Multi-AZ que requiere aprovisionamiento en dos centros de datos.

**✓ Verificación**: Confirme que:
- La pila aparece en la lista de pilas de CloudFormation
- El estado de la pila muestra **CREATE_IN_PROGRESS** (en color azul)
- El nombre de su pila es `[Iniciales]-TC-Portal` con sus iniciales correctas

### Paso 3: Monitorear eventos de la pila y confirmar suscripción de correo

Ahora que CloudFormation está creando su infraestructura, observará en tiempo real cómo los recursos se aprovisionan en un orden lógico y confirmará su suscripción al sistema de alertas.

1. Permanezca en la consola de CloudFormation y asegúrese de que su pila `[Iniciales]-TC-Portal` esté seleccionada.

2. Haga clic en la pestaña **Eventos** ubicada en la parte inferior de la pantalla.

3. Haga clic en el botón de actualización (icono circular con flechas) ubicado en la esquina superior derecha de la tabla de eventos para ver los eventos más recientes.

4. Observe la columna **Estado** de los eventos:
   - Los recursos en proceso de creación muestran el estado **CREATE_IN_PROGRESS** (en color azul)
   - Los recursos completados muestran el estado **CREATE_COMPLETE** (en color verde)
   - Refresque periódicamente para ver cómo los recursos avanzan de `CREATE_IN_PROGRESS` a `CREATE_COMPLETE`

**💡 Tip del instructor - Orden lógico de creación:**

Observe cómo CloudFormation crea los recursos en un orden específico:
1. Primero crea la **VPC** (red virtual)
2. Luego crea las **Subnets** (subredes dentro de la VPC)
3. Después crea los **Security Groups** (grupos de seguridad que dependen de la VPC)
4. Finalmente crea las **instancias EC2** (que necesitan las subnets y security groups)

CloudFormation determina automáticamente este orden leyendo las dependencias en el código de la plantilla. Usted no tuvo que especificar manualmente "primero crea esto, luego aquello" — el sistema lo calculó por sí mismo.

⏱️ **Importante - Tiempo de espera para RDS Multi-AZ**: La base de datos Amazon RDS configurada en modo Multi-AZ tomará aproximadamente **10 a 15 minutos** en completar su creación. Esto se debe a que AWS debe aprovisionar servidores físicos en dos centros de datos diferentes y configurar la replicación síncrona entre ellos para garantizar la tolerancia a fallos.

**Mientras espera que la pila se complete:**

5. Abra su cliente de correo electrónico (en una nueva pestaña del navegador o aplicación de correo).

6. Busque en su bandeja de entrada un correo con el asunto **"AWS Notification - Subscription Confirmation"**.

7. Si no encuentra el correo en la bandeja de entrada principal, **revise su carpeta de Spam o Correo no deseado** — los correos de confirmación de AWS a veces son filtrados por los sistemas de correo.

8. Abra el correo de confirmación y localice el enlace que dice **"Confirm subscription"** (Confirmar suscripción).

9. Haga clic en el enlace **"Confirm subscription"** — esto abrirá una página web de AWS confirmando que su suscripción al tema SNS ha sido activada exitosamente.

⚠️ **Advertencia crítica**: Si no confirma su suscripción de correo electrónico, **NO recibirá las alertas de tráfico** cuando el sistema detecte picos de actividad en el portal del Tribunal Constitucional. La confirmación es obligatoria para que Amazon SNS pueda enviarle notificaciones.

**✓ Verificación**: Confirme que:
- Los eventos de CloudFormation muestran múltiples recursos con estado **CREATE_COMPLETE**
- Puede observar el orden lógico de creación (VPC → Subnets → Security Groups → EC2)
- Ha recibido y confirmado el correo de suscripción de AWS (la página de confirmación muestra "Subscription confirmed!")
- La pila continúa en estado **CREATE_IN_PROGRESS** mientras se completan los recursos restantes (especialmente RDS)

---

## Fase 2: Alta Disponibilidad y Seguridad (30 min)

### Paso 4: Acceder al portal del TC

Una vez que CloudFormation haya completado el despliegue de toda la infraestructura, accederá al Portal del Tribunal Constitucional a través de la URL del Application Load Balancer para confirmar que el sistema está funcionando correctamente.

1. En la consola de CloudFormation, asegúrese de que su pila `[Iniciales]-TC-Portal` esté seleccionada.

2. Verifique que el estado de la pila en la parte superior muestre **CREATE_COMPLETE** (en color verde).
   - Si el estado aún muestra **CREATE_IN_PROGRESS**, espere unos minutos más y refresque la página
   - La creación completa puede tomar hasta 20 minutos debido a la base de datos RDS Multi-AZ

3. Una vez que la pila esté en estado **CREATE_COMPLETE**, haga clic en la pestaña **Salidas** ubicada en la parte inferior de la pantalla.

4. En la tabla de salidas, localice la fila con la clave **PortalURL**.

5. Haga clic en el enlace de la URL que aparece en la columna **Valor** — este es el nombre DNS del Application Load Balancer.
   - La URL tendrá un formato similar a: `http://[Iniciales]-TC-Portal-alb-1234567890.us-east-1.elb.amazonaws.com`
   - El enlace abrirá el portal en una nueva pestaña de su navegador

6. Espere unos segundos mientras el navegador carga la página del Portal del Tribunal Constitucional.

7. Valide visualmente que la página principal del portal se carga correctamente:
   - Debe ver el encabezado con el título "Portal del Ciudadano - Tribunal Constitucional"
   - Debe ver la interfaz del portal con opciones de navegación
   - Debe ver enlaces a las secciones "Asistente Constitucional" y "Resoluciones"

**✓ Verificación**: Confirme que:
- La pila de CloudFormation muestra el estado **CREATE_COMPLETE**
- La pestaña **Salidas** contiene la clave **PortalURL** con una URL válida
- El portal del Tribunal Constitucional se carga correctamente en su navegador
- La interfaz del portal muestra el branding institucional y las opciones de navegación

**💡 Tip del instructor**: El Application Load Balancer que acaba de utilizar está distribuyendo automáticamente el tráfico entre dos instancias EC2 ubicadas en diferentes zonas de disponibilidad. Aunque usted solo ve una URL, detrás de escena hay dos servidores web trabajando en paralelo para garantizar alta disponibilidad. Además, antes de que el tráfico llegue al ALB, AWS WAF inspecciona cada solicitud HTTP para bloquear ataques web comunes. En el siguiente paso, inspeccionará esta capa de seguridad perimetral.

### Paso 5: Inspeccionar AWS WAF

Ahora inspeccionará la capa de seguridad perimetral del Portal del Tribunal Constitucional. AWS WAF (Web Application Firewall) actúa como un escudo que filtra todo el tráfico HTTP antes de que llegue al Application Load Balancer, bloqueando automáticamente patrones de ataque comunes.

1. En la barra de búsqueda global de la consola de AWS (parte superior), escriba `WAF` y haga clic en el servicio **AWS WAF** que aparece en los resultados.

2. En el panel de navegación de la izquierda, haga clic en **Web ACLs**.

3. En la lista de Web ACLs, localice y seleccione la Web ACL creada por su pila de CloudFormation:
   - El nombre de la Web ACL incluirá su pila de CloudFormation (por ejemplo, `[Iniciales]-TC-Portal-waf-acl`)
   - Haga clic en el nombre de la Web ACL para abrir sus detalles

4. En la página de detalles de la Web ACL, haga clic en la pestaña **Reglas**.

5. En la lista de reglas, identifique el grupo de reglas administrado **AWSManagedRulesCommonRuleSet**:
   - Este es un conjunto de reglas mantenido y actualizado por expertos de seguridad de AWS
   - Protege contra las vulnerabilidades más comunes del OWASP Top 10, incluyendo inyección SQL, cross-site scripting (XSS) y otros patrones de ataque web

6. Navegue a la pestaña **Recursos de AWS asociados**.

7. En la lista de recursos asociados, confirme que la Web ACL está asociada al Application Load Balancer de su pila de CloudFormation.

**💡 Tip del instructor - Seguridad perimetral automática:**

AWS WAF actúa como un escudo de seguridad que inspecciona cada solicitud HTTP antes de que llegue al portal del Tribunal Constitucional. Cada vez que un ciudadano, abogado o periodista accede al portal, WAF analiza la solicitud buscando patrones de ataque conocidos y bloquea automáticamente las solicitudes maliciosas sin que el equipo de desarrollo tenga que escribir código de seguridad personalizado.

El grupo de reglas administrado **AWSManagedRulesCommonRuleSet** es mantenido y actualizado continuamente por expertos de seguridad de AWS. Esto significa que cuando se descubren nuevas vulnerabilidades o técnicas de ataque, AWS actualiza las reglas automáticamente para proteger su portal sin que usted tenga que hacer nada.

**✓ Verificación**: Confirme que:
- Localizó correctamente la Web ACL de AWS WAF creada por su pila de CloudFormation
- La pestaña **Reglas** muestra el grupo de reglas administrado **AWSManagedRulesCommonRuleSet**
- La pestaña **Recursos de AWS asociados** confirma que la Web ACL está asociada al Application Load Balancer

### Paso 6: Simular fallo de servidor

Ahora realizará una prueba crítica de alta disponibilidad: terminará deliberadamente una de las instancias EC2 del portal para simular un fallo de servidor y observará cómo el Application Load Balancer mantiene el sitio en línea mientras el Auto Scaling Group recupera automáticamente la capacidad.

1. En la barra de búsqueda global de la consola de AWS (parte superior), escriba `EC2` y haga clic en el servicio **EC2** que aparece en los resultados.

2. En el panel de navegación de la izquierda, haga clic en **Instancias**.

3. En la lista de instancias, identifique las dos instancias EC2 del Portal del Tribunal Constitucional:
   - Ambas instancias tendrán nombres que incluyen su pila de CloudFormation (por ejemplo, `[Iniciales]-TC-Portal-...`)
   - Observe la columna **Zona de disponibilidad** — confirme que las dos instancias están en zonas de disponibilidad diferentes
   - Por ejemplo, una instancia puede estar en `us-east-1a` y la otra en `us-east-1b`
   - Esta distribución Multi-AZ es clave para la alta disponibilidad

4. Seleccione **solo una** de las dos instancias haciendo clic en la casilla de verificación a la izquierda del nombre de la instancia.

5. Con la instancia seleccionada, haga clic en el menú desplegable **Estado de la instancia** ubicado en la parte superior de la pantalla.

6. En el menú que aparece, seleccione **Terminar instancia**.

7. En el cuadro de diálogo de confirmación que aparece, haga clic en el botón **Terminar** para confirmar la acción.
   - La instancia comenzará el proceso de terminación inmediatamente
   - El estado de la instancia cambiará a **Shutting down** (Apagándose) y luego a **Terminated** (Terminada)

8. **Inmediatamente** después de terminar la instancia, regrese a la pestaña de su navegador donde tiene abierto el Portal del Tribunal Constitucional.

9. Refresque la página del portal múltiples veces (presione F5 o haga clic en el botón de actualizar del navegador).

10. Observe que **el portal continúa funcionando normalmente** — la página se carga sin errores.

**💡 Explicación técnica**: El portal sigue funcionando porque el Application Load Balancer detectó automáticamente que una de las instancias dejó de responder a las verificaciones de salud (health checks). En cuestión de segundos, el ALB dejó de enviar tráfico a la instancia terminada y comenzó a dirigir el 100% de las solicitudes a la instancia sobreviviente en la otra zona de disponibilidad. Los ciudadanos que acceden al portal no experimentan ninguna interrupción del servicio.

11. Regrese a la consola de EC2 con la lista de instancias.

12. Espere aproximadamente **3 a 5 minutos** ⏱️ y refresque periódicamente la vista de instancias haciendo clic en el botón de actualización (icono circular con flechas) en la esquina superior derecha.

13. Observe cómo el Auto Scaling Group detecta que la capacidad deseada (2 instancias) no se está cumpliendo y **lanza automáticamente una nueva instancia** para reemplazar la que terminó.

14. Observe la nueva instancia en la lista:
   - Inicialmente aparecerá con el estado **Pending** (Pendiente) mientras se aprovisiona
   - Después de 1-2 minutos, el estado cambiará a **Running** (En ejecución)
   - Finalmente, las verificaciones de salud del ALB confirmarán que la instancia está lista para recibir tráfico

**✓ Verificación**: Confirme que:
- Identificó correctamente las dos instancias EC2 en diferentes zonas de disponibilidad
- Terminó exitosamente una de las instancias (estado **Terminated**)
- El portal del TC continuó funcionando sin interrupciones después de terminar la instancia
- El Auto Scaling Group lanzó automáticamente una nueva instancia de reemplazo
- La nueva instancia transicionó de **Pending** a **Running**
- Ahora tiene nuevamente dos instancias en estado **Running** en diferentes zonas de disponibilidad

**💡 Tip del instructor**: Lo que acaba de presenciar es el corazón de la alta disponibilidad en AWS. El sistema tiene múltiples capas de resiliencia:
1. **Application Load Balancer**: Detecta fallos en segundos y redirige el tráfico automáticamente
2. **Multi-AZ**: Las instancias están en centros de datos físicamente separados — si un centro de datos completo falla, el otro continúa operando
3. **Auto Scaling Group**: Monitorea constantemente la capacidad y reemplaza instancias fallidas sin intervención humana

Esta arquitectura garantiza que el Portal del Tribunal Constitucional permanezca accesible 24/7, incluso durante fallos de hardware, mantenimiento de infraestructura o picos masivos de tráfico.

### Paso 7: Inspeccionar RDS Multi-AZ y Secrets Manager

Ahora inspeccionará la configuración de la base de datos relacional del Portal del Tribunal Constitucional para comprender cómo el diseño Multi-AZ protege los datos críticos contra fallos masivos de infraestructura, y cómo AWS Secrets Manager gestiona las credenciales de la base de datos de forma segura y automatizada.

1. En la barra de búsqueda global de la consola de AWS (parte superior), escriba `RDS` y haga clic en el servicio **Amazon RDS** que aparece en los resultados.

2. En el panel de navegación de la izquierda, haga clic en **Bases de datos**.

3. En la lista de bases de datos, localice y seleccione la instancia de base de datos creada para el Portal del Tribunal Constitucional:
   - El nombre de la base de datos incluirá su pila de CloudFormation (por ejemplo, `[Iniciales]-TC-Portal-db-...`)
   - Haga clic en el nombre de la base de datos para abrir sus detalles

4. En la página de detalles de la base de datos, haga clic en la pestaña **Configuración** ubicada en la parte superior.

5. Desplácese por la sección de configuración hasta localizar el campo **Multi-AZ**.

6. Confirme que el valor del campo **Multi-AZ** es **Sí**.

**💡 Tip del instructor - Tolerancia a fallos de datos críticos:**

Lo que acaba de confirmar es una de las configuraciones más importantes para sistemas de misión crítica. La base de datos RDS Multi-AZ mantiene una réplica síncrona de todos los datos del Tribunal Constitucional en un centro de datos físicamente separado.

Esto significa que si el centro de datos primario de AWS sufre un corte de energía masivo, un desastre natural o cualquier fallo catastrófico de infraestructura, **el Tribunal Constitucional no pierde ni un solo expediente**. La réplica síncrona en la otra instalación física contiene una copia exacta y actualizada de todos los datos.

**Failover automático sin intervención humana:**

Si la base de datos primaria falla, AWS detecta automáticamente el problema y redirige todo el tráfico de base de datos a la réplica en la otra zona de disponibilidad. Este proceso de failover toma típicamente entre 60 y 120 segundos y ocurre sin que los administradores del sistema tengan que hacer nada manualmente.

Durante esos 1-2 minutos, las aplicaciones pueden experimentar errores de conexión temporales, pero una vez completado el failover, el portal del TC continúa operando normalmente con la réplica promovida como nueva base de datos primaria.

**Diferencia con el Auto Scaling de EC2:**

Observe la diferencia con lo que vio en el Paso 6:
- **EC2 con Auto Scaling**: Cuando terminó una instancia, el ASG lanzó una nueva instancia vacía y la configuró desde cero (3-5 minutos)
- **RDS Multi-AZ**: La réplica ya está ejecutándose, sincronizada y lista — solo necesita ser promovida (1-2 minutos)

Esta es la razón por la cual RDS Multi-AZ es crítico para bases de datos: no puede permitirse perder datos ni esperar varios minutos para reconstruir un servidor de base de datos desde cero cuando cada segundo cuenta para el acceso ciudadano a la justicia.

**Inspeccionar AWS Secrets Manager:**

Ahora verificará cómo se gestionan las credenciales de la base de datos de forma segura mediante AWS Secrets Manager.

7. En la barra de búsqueda global de la consola de AWS (parte superior), escriba `Secrets Manager` y haga clic en el servicio **AWS Secrets Manager** que aparece en los resultados.

8. En la lista de secretos, localice el secreto creado por su pila de CloudFormation:
   - El nombre del secreto incluirá su pila de CloudFormation (por ejemplo, `[Iniciales]-TC-Portal-rds-secret`)
   - Haga clic en el nombre del secreto para abrir sus detalles

9. En la página de detalles del secreto, desplácese hasta la sección **Valor del secreto**.

10. Haga clic en el botón **Recuperar valor del secreto** para ver las credenciales auto-generadas.

11. Observe que la contraseña es una cadena compleja auto-generada:
    - La contraseña contiene una combinación de letras mayúsculas, minúsculas, números y caracteres especiales
    - Esta contraseña fue generada automáticamente durante el despliegue de CloudFormation
    - En ningún momento esta contraseña fue escrita manualmente ni fue visible en la plantilla de CloudFormation

**💡 Tip del instructor - Gestión segura de credenciales:**

AWS Secrets Manager resuelve un problema crítico de seguridad en la gestión de credenciales. Tradicionalmente, las contraseñas de bases de datos se almacenaban en archivos de configuración, variables de entorno o incluso directamente en el código fuente — prácticas que representan un riesgo de seguridad significativo.

Con Secrets Manager integrado en la arquitectura del Tribunal Constitucional:
- La contraseña de la base de datos se **genera automáticamente** durante el despliegue, sin intervención humana
- La contraseña se **almacena cifrada** en AWS Secrets Manager, no en texto plano
- La contraseña puede **rotarse periódicamente** sin modificar el código de la aplicación ni la plantilla de CloudFormation

**💡 Explicación técnica - Referencia dinámica en CloudFormation:**

La plantilla de Infraestructura como Código utiliza la referencia dinámica `resolve:secretsmanager` de CloudFormation para inyectar la contraseña en la base de datos RDS en tiempo de despliegue. Esto significa que el valor real de la contraseña nunca aparece en la plantilla YAML — CloudFormation resuelve la referencia automáticamente al momento de crear los recursos.

**✓ Verificación**: Confirme que:
- Localizó correctamente la instancia de base de datos RDS del Portal del TC
- La pestaña **Configuración** muestra el campo **Multi-AZ** con valor **Sí**
- Comprende que existe una réplica síncrona en otra zona de disponibilidad
- Comprende que el failover automático ocurre sin intervención manual en caso de fallo
- Localizó el secreto en AWS Secrets Manager creado por la pila de CloudFormation
- Pudo recuperar el valor del secreto y observar la contraseña auto-generada
- Comprende que la contraseña nunca fue visible en la plantilla de CloudFormation

### Paso 8: Inspeccionar roles IAM

Ahora inspeccionará los roles de IAM (Identity and Access Management) creados por la pila de CloudFormation para comprender cómo se aplica el principio de mínimo privilegio en la arquitectura del Portal del Tribunal Constitucional. Cada servicio recibe únicamente los permisos que necesita para realizar su función específica.

1. En la barra de búsqueda global de la consola de AWS (parte superior), escriba `IAM` y haga clic en el servicio **IAM** que aparece en los resultados.

2. En el panel de navegación de la izquierda, haga clic en **Roles**.

3. En la barra de búsqueda de roles, escriba el nombre de su pila de CloudFormation (por ejemplo, `[Iniciales]-TC-Portal`) para filtrar los roles creados por su pila.

4. Identifique los dos roles principales creados por la pila:
   - Un rol para las **instancias EC2** (por ejemplo, `[Iniciales]-TC-Portal-EC2InstanceRole-...`)
   - Un rol para la **función Lambda** (por ejemplo, `[Iniciales]-TC-Portal-LambdaExecutionRole-...`)

**Inspeccionar el rol de EC2:**

5. Haga clic en el nombre del rol de EC2 para abrir sus detalles.

6. En la sección **Políticas de permisos**, revise las políticas adjuntas al rol y observe los permisos otorgados:
   - Permisos para **invocación de Amazon Bedrock** (`bedrock:InvokeModel`) — permite a las instancias EC2 enviar preguntas al modelo de IA generativa para el chatbot constitucional
   - Permisos para **síntesis de voz con Amazon Polly** (`polly:SynthesizeSpeech`) — permite a las instancias EC2 convertir texto de resoluciones a audio para ciudadanos con discapacidad visual

7. Regrese a la lista de roles haciendo clic en **Roles** en la ruta de navegación superior.

**Inspeccionar el rol de Lambda:**

8. Haga clic en el nombre del rol de Lambda para abrir sus detalles.

9. En la sección **Políticas de permisos**, revise las políticas adjuntas al rol y observe los permisos otorgados:
   - Permisos para **consumo de mensajes de Amazon SQS** (`sqs:ReceiveMessage`, `sqs:DeleteMessage`, `sqs:GetQueueAttributes`) — permite a la función Lambda leer y procesar mensajes de la cola de expedientes
   - Permisos para **escritura en CloudWatch Logs** (`logs:CreateLogGroup`, `logs:CreateLogStream`, `logs:PutLogEvents`) — permite a la función Lambda registrar su actividad para monitoreo y auditoría

**💡 Tip del instructor - Principio de mínimo privilegio:**

Lo que acaba de observar es la aplicación del principio de mínimo privilegio, una de las mejores prácticas fundamentales de seguridad en AWS. Cada servicio recibe **solo los permisos que necesita** para realizar su función específica, y nada más:

- Las instancias EC2 pueden invocar Bedrock y Polly, pero **no pueden** leer mensajes de SQS ni escribir en CloudWatch Logs directamente
- La función Lambda puede consumir mensajes de SQS y escribir logs, pero **no puede** invocar Bedrock ni Polly

Esta separación de permisos reduce el "radio de impacto" (blast radius) si algún componente es comprometido. Si un atacante logra acceder a una instancia EC2, solo podría interactuar con Bedrock y Polly — no tendría acceso a la cola de mensajes ni a otros servicios críticos.

**💡 Explicación técnica - Instance Profile:**

Las instancias EC2 acceden a Amazon Bedrock y Amazon Polly a través del rol IAM adjunto mediante un **instance profile**. Esto elimina completamente la necesidad de almacenar claves de acceso (API keys) en los servidores. Las credenciales temporales se rotan automáticamente por AWS, proporcionando un nivel de seguridad significativamente superior al uso de claves estáticas.

**✓ Verificación**: Confirme que:
- Localizó correctamente los roles IAM creados por su pila de CloudFormation
- El rol de EC2 tiene permisos para Amazon Bedrock (invocación de modelos) y Amazon Polly (síntesis de voz)
- El rol de Lambda tiene permisos para Amazon SQS (consumo de mensajes) y CloudWatch Logs (escritura de registros)
- Comprende que cada servicio recibe solo los permisos necesarios para su función específica (principio de mínimo privilegio)
- Comprende que las instancias EC2 usan un instance profile en lugar de claves API estáticas

---

## Fase 3: Arquitectura Orientada a Eventos (15 min)

### Paso 9: Publicar mensaje en SNS

Ahora iniciará el flujo de eventos automatizado del Portal del Tribunal Constitucional publicando un mensaje que simula la emisión de un nuevo fallo judicial. Este mensaje viajará automáticamente a través de la arquitectura orientada a eventos (SNS → SQS → Lambda) sin intervención manual.

1. En la barra de búsqueda global de la consola de AWS (parte superior), escriba `SNS` y haga clic en el servicio **Amazon SNS** que aparece en los resultados.

2. En el panel de navegación de la izquierda, haga clic en **Temas**.

3. En la lista de temas, localice y seleccione el tema SNS creado por su pila de CloudFormation:
   - El nombre del tema incluirá su pila de CloudFormation (por ejemplo, `[Iniciales]-TC-Portal-alertas`)
   - Haga clic en el nombre del tema para abrir sus detalles

4. En la página de detalles del tema, haga clic en el botón naranja **Publicar mensaje** ubicado en la esquina superior derecha.

5. En la pantalla "Publicar mensaje al tema", desplácese hasta la sección **Cuerpo del mensaje**.

6. En el campo de texto del cuerpo del mensaje, escriba exactamente el siguiente texto:

```
Se ha emitido la resolución del Expediente N° 001-2026 sobre Habeas Corpus
```

7. Deje todos los demás campos con sus valores por defecto (no es necesario especificar asunto ni atributos adicionales).

8. Desplácese hasta el final de la página y haga clic en el botón naranja **Publicar mensaje**.

9. Observe la notificación de confirmación que aparece en la parte superior de la pantalla indicando que el mensaje fue publicado exitosamente.

**✓ Verificación**: Confirme que:
- Localizó correctamente el tema SNS de su pila de CloudFormation
- Publicó el mensaje con el texto exacto especificado
- Recibió la confirmación de que el mensaje fue publicado exitosamente

**💡 Tip del instructor - Arquitectura desacoplada:**

Lo que acaba de hacer es publicar un mensaje en un canal de comunicación (tema SNS) sin preocuparse por quién lo recibirá ni cómo se procesará. Esta es la esencia de las arquitecturas orientadas a eventos: los componentes del sistema están desacoplados.

En este momento, el mensaje que publicó está siendo entregado automáticamente a dos destinos:
1. **Su correo electrónico**: Recibirá una notificación por correo con el texto del mensaje (revise su bandeja de entrada)
2. **La cola SQS**: El mensaje se almacenó automáticamente en la cola de procesamiento de expedientes

Ninguno de estos destinos requirió que usted configurara manualmente la entrega — las suscripciones ya estaban definidas en la plantilla de CloudFormation. En el siguiente paso, inspeccionará cómo el mensaje llegó a la cola SQS.

### Paso 10: Inspeccionar cola SQS y concepto de buffer

Ahora inspeccionará la cola de mensajes de Amazon SQS para comprender cómo actúa como un amortiguador (buffer) que protege la infraestructura del Tribunal Constitucional contra picos masivos de procesamiento.

1. En la barra de búsqueda global de la consola de AWS (parte superior), escriba `SQS` y haga clic en el servicio **Amazon SQS** que aparece en los resultados.

2. En la lista de colas, localice la cola de procesamiento creada por su pila de CloudFormation:
   - El nombre de la cola incluirá su pila de CloudFormation (por ejemplo, `[Iniciales]-TC-Portal-expedientes`)
   - Haga clic en el nombre de la cola para abrir sus detalles

3. En la página de detalles de la cola, observe la sección **Mensajes disponibles** en la parte superior:
   - Si el mensaje aún está en la cola, verá el contador de mensajes disponibles
   - Si el mensaje ya fue procesado por Lambda, el contador puede estar en 0

**💡 Explicación técnica - Suscripción automática:**

La plantilla de CloudFormation que desplegó ya configuró automáticamente la suscripción de esta cola SQS al tema SNS. Esto significa que cuando publicó el mensaje en el Paso 9, Amazon SNS lo entregó instantáneamente a la cola SQS sin que usted tuviera que configurar manualmente esta integración.

Esta es otra ventaja de la Infraestructura como Código: las relaciones entre servicios se definen una vez en la plantilla y se replican automáticamente cada vez que se despliega.

**💡 Tip del instructor - Concepto de buffer para protección contra picos:**

Imagine el siguiente escenario crítico: el Tribunal Constitucional emite un fallo histórico sobre un tema controversial y publica simultáneamente **1,000 expedientes** relacionados con el caso. Si el sistema intentara procesar todos esos expedientes inmediatamente enviándolos directamente al servidor web o a la base de datos, la infraestructura colapsaría bajo la carga masiva.

Aquí es donde Amazon SQS actúa como un amortiguador inteligente:

1. **Recepción segura**: La cola SQS recibe y almacena de manera segura los 1,000 mensajes en cuestión de segundos, sin importar cuán rápido lleguen.

2. **Procesamiento controlado**: La función Lambda (que verá en el siguiente paso) consume los mensajes de la cola a su propio ritmo, procesando quizás 10 o 20 expedientes por minuto según la capacidad disponible.

3. **Sin pérdida de datos**: Ningún expediente se pierde. Todos los mensajes permanecen en la cola hasta que son procesados exitosamente. Si el procesamiento falla, el mensaje regresa automáticamente a la cola para reintentarse.

4. **Escalabilidad independiente**: El sistema puede procesar los 1,000 expedientes en 1 hora o en 10 horas, dependiendo de la capacidad configurada, pero lo importante es que el sistema nunca colapsa y nunca pierde datos.

**Contraste con arquitectura sin buffer:**

Sin SQS, si 1,000 solicitudes llegaran simultáneamente al servidor web, ocurriría lo siguiente:
- El servidor intentaría procesar todas las solicitudes al mismo tiempo
- La memoria y CPU se saturarían
- Las conexiones de base de datos se agotarían
- El sistema colapsaría y rechazaría solicitudes
- Los ciudadanos verían errores 500 o timeouts
- Algunos expedientes podrían perderse

Con SQS como buffer, el sistema absorbe el pico de tráfico sin inmutarse y procesa los expedientes de manera ordenada y confiable.

**✓ Verificación**: Confirme que:
- Localizó correctamente la cola SQS de su pila de CloudFormation
- Comprende que la cola fue suscrita automáticamente al tema SNS por la plantilla de IaC
- Comprende el concepto de buffer: SQS retiene mensajes y permite procesamiento al ritmo del sistema
- Comprende cómo SQS protege contra colapsos durante picos masivos de tráfico (ejemplo de 1,000 expedientes)

### Paso 11: Verificar Lambda y CloudWatch

Ahora verificará que la función de cómputo sin servidor consumió automáticamente el mensaje de la cola SQS revisando los registros del sistema en CloudWatch Logs. Esto confirmará que el flujo de eventos se completó exitosamente de principio a fin.

1. En la barra de búsqueda global de la consola de AWS (parte superior), escriba `Lambda` y haga clic en el servicio **AWS Lambda** que aparece en los resultados.

2. En la lista de funciones, localice y haga clic en la función Lambda creada por su pila de CloudFormation:
   - El nombre de la función incluirá su pila de CloudFormation y será similar a `[Iniciales]-TC-Portal-ProcesadorExpedientes`
   - Haga clic en el nombre de la función para abrir sus detalles

3. En la página de detalles de la función Lambda, haga clic en la pestaña **Monitor** ubicada en la parte superior.

4. En la sección de monitoreo, haga clic en el botón **Ver registros en CloudWatch** ubicado en la esquina superior derecha.
   - Esto abrirá la consola de Amazon CloudWatch Logs en una nueva pestaña o ventana

5. En la consola de CloudWatch Logs, verá una lista de **flujos de registro** (log streams) para la función Lambda.

6. Haga clic en el flujo de registro más reciente de la lista:
   - Los flujos de registro están ordenados por fecha y hora
   - El más reciente aparecerá en la parte superior
   - El nombre del flujo incluirá una marca de tiempo

7. En el flujo de registro, desplácese por los eventos de registro y busque el texto del mensaje que publicó en el Paso 9.

8. Localice y valide la presencia del texto exacto:
   ```
   Se ha emitido la resolución del Expediente N° 001-2026 sobre Habeas Corpus
   ```

9. Observe también otros detalles en los registros:
   - Información sobre el evento SQS que activó la función
   - Detalles del procesamiento del mensaje
   - Confirmación de que el mensaje fue procesado exitosamente

**💡 Explicación técnica - Procesamiento sin servidor:**

Lo que acaba de confirmar es el funcionamiento completo de una arquitectura orientada a eventos sin servidor:

1. **Usted publicó un mensaje** en Amazon SNS (Paso 9)
2. **SNS entregó el mensaje** automáticamente a la cola SQS (Paso 10)
3. **SQS activó la función Lambda** automáticamente cuando detectó el nuevo mensaje
4. **Lambda extrajo el mensaje** de la cola, ejecutó su código de procesamiento, y registró la actividad en CloudWatch Logs
5. **Todo esto ocurrió sin intervención humana** — ningún administrador tuvo que hacer clic en nada ni ejecutar ningún script manualmente

**Ventajas del procesamiento sin servidor:**

- **Sin servidores que gestionar**: No hay instancias EC2 que aprovisionar, parchear o monitorear para el procesamiento de expedientes
- **Escalabilidad automática**: Si llegan 1,000 mensajes, Lambda puede procesar múltiples mensajes en paralelo automáticamente
- **Pago por uso**: Solo paga por el tiempo de ejecución real de la función (milisegundos), no por servidores inactivos esperando trabajo
- **Alta disponibilidad integrada**: Lambda se ejecuta automáticamente en múltiples zonas de disponibilidad sin configuración adicional

**✓ Verificación**: Confirme que:
- Localizó correctamente la función Lambda `ProcesadorExpedientes` de su pila
- Navegó exitosamente a CloudWatch Logs desde la pestaña **Monitor**
- Abrió el flujo de registro más reciente
- Encontró el texto exacto del mensaje publicado en el Paso 9 dentro de los registros
- Comprende que Lambda detectó, extrajo y procesó el mensaje automáticamente sin intervención humana

**💡 Tip del instructor - Arquitectura completa de eventos:**

Ha completado la validación de una arquitectura orientada a eventos de principio a fin:

```
SNS Topic → SQS Queue → Lambda Function → CloudWatch Logs
(Paso 9)    (Paso 10)    (Paso 11)         (Paso 11)
```

Esta arquitectura es fundamental para sistemas modernos de misión crítica porque:
- **Desacopla componentes**: Cada servicio puede evolucionar independientemente
- **Absorbe picos de tráfico**: SQS actúa como buffer durante cargas masivas
- **Garantiza procesamiento**: Los mensajes no se pierden y se reintentan automáticamente en caso de fallo
- **Escala automáticamente**: Lambda procesa más mensajes en paralelo cuando la demanda aumenta
- **Proporciona observabilidad**: CloudWatch Logs registra toda la actividad para auditoría y debugging

El Tribunal Constitucional ahora puede publicar miles de expedientes simultáneamente con la confianza de que todos serán procesados de manera ordenada, confiable y auditable.

---

## Fase 4: IA para el Ciudadano (20 min)

### Paso 12: Chatbot con Amazon Bedrock

Ahora interactuará con el asistente constitucional impulsado por Inteligencia Artificial Generativa para comprobar cómo Amazon Bedrock puede traducir términos jurídicos complejos a un lenguaje sencillo que cualquier ciudadano pueda comprender.

1. Regrese a la pestaña de su navegador donde tiene abierto el Portal del Tribunal Constitucional.
   - Si cerró la pestaña, puede volver a abrir el portal usando la URL del Application Load Balancer que obtuvo en el Paso 4 (pestaña **Salidas** de CloudFormation)

2. En la página principal del portal, localice y haga clic en el enlace o botón de navegación que dice **"Asistente Constitucional"** o **"Chatbot"**.
   - Esto lo llevará a la interfaz del asistente de IA

3. En la interfaz del chatbot, localice el campo de texto donde puede escribir su pregunta.

4. Escriba exactamente la siguiente pregunta en el campo de texto:
   ```
   ¿Qué es un recurso de agravio constitucional?
   ```

5. Haga clic en el botón **Enviar** o presione la tecla **Enter** para enviar la pregunta al asistente.

6. Observe que aparece el mensaje **"Procesando su consulta con Amazon Bedrock..."** mientras el sistema procesa su pregunta.

⏱️ **Nota**: La respuesta de Amazon Bedrock puede tardar entre 3 y 10 segundos, ya que el modelo de IA generativa está procesando su consulta en tiempo real. Este tiempo es normal y depende de la complejidad de la pregunta.

   - Durante este tiempo, la aplicación web está realizando una llamada API a Amazon Bedrock
   - Bedrock invoca un modelo de lenguaje fundacional (foundation model)
   - El modelo procesa su pregunta y genera una respuesta en lenguaje natural

7. Observe la respuesta que aparece en el área de chat del asistente.

8. Valide que el asistente responde con una explicación clara y en lenguaje natural que sea fácil de comprender para un ciudadano sin formación legal.
   - La respuesta debe explicar el concepto de "recurso de agravio constitucional" en términos sencillos
   - La respuesta debe ser coherente, relevante y contextualizada al ámbito constitucional
   - Si aparece el mensaje "Lo sentimos, no se pudo procesar su consulta. Verifique que el modelo de Amazon Bedrock esté habilitado en su cuenta.", consulte la sección de [Solución de problemas](#solución-de-problemas)

**💡 Tip del instructor - Flujo técnico de Amazon Bedrock:**

Lo que acaba de experimentar involucra varios pasos técnicos que ocurren en tiempo real:

1. **Frontend captura la pregunta**: El JavaScript de la aplicación web (chatbot.js) captura el texto que escribió
2. **Llamada al backend**: La aplicación envía una solicitud HTTP al backend API ejecutándose en las instancias EC2
3. **Backend invoca Bedrock**: El backend hace una llamada a la API `InvokeModel` de Amazon Bedrock, pasando su pregunta como prompt
4. **Modelo fundacional procesa**: Bedrock ejecuta un modelo de IA generativa (como Claude, Titan u otro) que analiza su pregunta y genera una respuesta contextualizada
5. **Respuesta regresa al frontend**: La respuesta generada viaja de vuelta a través del backend hacia el navegador
6. **Visualización en tiempo real**: El JavaScript muestra la respuesta en la interfaz del chat

Todo este flujo ocurre en cuestión de segundos, proporcionando una experiencia interactiva fluida para el ciudadano.

**Ventajas de Amazon Bedrock para el Tribunal Constitucional:**

- **Sin entrenar modelos**: No es necesario que el TC entrene sus propios modelos de IA desde cero — puede usar modelos fundacionales pre-entrenados
- **Lenguaje natural**: Los ciudadanos pueden hacer preguntas en español coloquial y recibir respuestas comprensibles
- **Escalabilidad**: Bedrock escala automáticamente para atender miles de consultas simultáneas durante fallos de alto perfil
- **Actualización continua**: Los modelos fundacionales se actualizan regularmente con nuevos conocimientos sin intervención del TC
- **Democratización del acceso**: Ciudadanos sin conocimientos legales pueden comprender conceptos constitucionales complejos

**✓ Verificación**: Confirme que:
- Navegó exitosamente a la sección **Asistente Constitucional** o **Chatbot** del portal
- Escribió la pregunta exacta especificada sobre el recurso de agravio constitucional
- El asistente respondió con una explicación clara y en lenguaje natural
- La respuesta es relevante, coherente y fácil de comprender para un ciudadano sin formación legal
- Comprende que la aplicación web hizo una llamada API a Amazon Bedrock para generar la respuesta

**💡 Tip del instructor - Impacto social:**

Lo que acaba de probar tiene un impacto profundo en la democratización del acceso a la justicia. Históricamente, los documentos legales y constitucionales han sido inaccesibles para ciudadanos comunes debido al lenguaje técnico y la complejidad jurídica.

Con un asistente de IA integrado en el portal del Tribunal Constitucional:
- Un ciudadano puede preguntar "¿Qué es un habeas corpus?" y recibir una explicación simple
- Un estudiante puede consultar "¿Cuándo puedo presentar un amparo?" sin necesidad de contratar un abogado
- Un periodista puede entender rápidamente las implicaciones de un fallo constitucional complejo

Esta tecnología no reemplaza el asesoramiento legal profesional, pero reduce significativamente la barrera de entrada para que cualquier persona pueda comprender sus derechos constitucionales fundamentales.

### Paso 13: Síntesis de voz con Amazon Polly

Ahora comprobará cómo el Portal del Tribunal Constitucional cumple con las regulaciones de inclusión y accesibilidad para ciudadanos con discapacidad visual mediante la síntesis de voz con Amazon Polly.

1. En el Portal del Tribunal Constitucional, localice y haga clic en el enlace o botón de navegación que dice **"Resoluciones"** o **"Últimos Fallos"**.
   - Esto lo llevará a la sección donde se publican las resoluciones judiciales

2. En la sección de resoluciones, localice una resolución de ejemplo precargada que contiene un bloque de texto con el resumen de una sentencia.
   - El texto puede ser un resumen de un fallo sobre habeas corpus, amparo u otro tema constitucional

3. Junto al bloque de texto de la resolución, localice el botón o icono que dice **"Escuchar Resumen"** o muestra un icono de reproducción (▶).

4. Haga clic en el botón **"Escuchar Resumen"**.
   - Observe que el texto del botón cambia a **"Generando audio con Amazon Polly..."** mientras se procesa la solicitud

5. Espere unos segundos mientras el sistema genera el audio.

⏱️ **Nota**: La generación de audio con Amazon Polly puede tardar entre 2 y 5 segundos dependiendo de la longitud del texto.

   - Durante este tiempo, la aplicación web está enviando el texto al backend
   - El backend hace una llamada a la API `SynthesizeSpeech` de Amazon Polly
   - Polly convierte el texto en audio MP3 con una voz neural en español

6. Observe que el navegador comienza a reproducir automáticamente un archivo de audio MP3.

7. Escuche el audio y valide que:
   - La voz es natural y fluida (no robótica)
   - La pronunciación en español es correcta
   - La entonación y el ritmo son apropiados para la lectura de un documento legal
   - El audio corresponde al texto visible en la pantalla

8. Si lo desea, puede pausar, reproducir nuevamente o ajustar el volumen usando los controles del reproductor de audio del navegador.

**💡 Tip del instructor - Cumplimiento de regulaciones de inclusión:**

Lo que acaba de experimentar es el cumplimiento de las regulaciones de accesibilidad e inclusión para personas con discapacidad visual. Muchos países tienen leyes que requieren que los portales gubernamentales proporcionen alternativas de audio para contenido textual.

Con Amazon Polly integrado en el Portal del Tribunal Constitucional:
- **Ciudadanos con discapacidad visual** pueden escuchar las resoluciones judiciales en lugar de depender de lectores de pantalla genéricos
- **Ciudadanos con dislexia** pueden beneficiarse de la lectura en voz alta para mejorar la comprensión
- **Ciudadanos con bajo nivel de alfabetización** pueden acceder a la información judicial de manera más efectiva
- **Ciudadanos en movimiento** pueden escuchar las resoluciones mientras realizan otras actividades

**Ventajas de Amazon Polly:**

- **Voces neurales realistas**: Polly utiliza tecnología de síntesis de voz neural que suena natural y humana, no robótica
- **Múltiples idiomas y voces**: Soporte para español latinoamericano, español de España, y múltiples voces masculinas y femeninas
- **Conversión en tiempo real**: El texto se convierte a audio en cuestión de segundos, sin necesidad de pre-grabar archivos
- **Sin entrenar modelos**: No es necesario entrenar modelos de Machine Learning — Polly es un servicio completamente gestionado
- **Escalabilidad**: Puede generar miles de audios simultáneamente durante picos de tráfico
- **Costo eficiente**: Pago por carácter convertido, sin costos de infraestructura de servidores de audio

**Flujo técnico de Amazon Polly:**

1. **Usuario hace clic en "Escuchar Resumen"**: El JavaScript captura el texto de la resolución
2. **Llamada al backend**: La aplicación envía el texto al backend API en EC2
3. **Backend invoca Polly**: El backend hace una llamada a `SynthesizeSpeech` con el texto y parámetros de voz (idioma: español, voz neural)
4. **Polly genera audio**: Amazon Polly convierte el texto en un stream de audio MP3
5. **Audio regresa al navegador**: El backend envía el audio al frontend
6. **Reproducción automática**: El navegador reproduce el audio usando el elemento `<audio>` de HTML5

**✓ Verificación**: Confirme que:
- Navegó exitosamente a la sección **Resoluciones** o **Últimos Fallos**
- Localizó una resolución de ejemplo con texto precargado
- Hizo clic en el botón **"Escuchar Resumen"** o icono de reproducción
- El navegador reprodujo un archivo de audio MP3 con voz neural en español
- La voz es natural, fluida y la pronunciación es correcta
- El audio corresponde al texto visible en la pantalla
- Comprende que Amazon Polly convirtió el texto a voz en tiempo real sin entrenar modelos ML

**💡 Tip del instructor - Impacto en accesibilidad:**

El Tribunal Constitucional ahora cumple con las regulaciones de inclusión para ciudadanos con discapacidad visual. Esto no es solo un requisito legal — es un imperativo ético en una democracia moderna.

Antes de esta integración, una persona con discapacidad visual dependía de:
- Lectores de pantalla genéricos que pueden tener dificultades con terminología legal
- Asistencia de terceros para leer documentos judiciales (comprometiendo privacidad)
- Versiones en Braille que tardan semanas en producirse y distribuirse

Con Amazon Polly integrado:
- **Acceso inmediato**: Las resoluciones están disponibles en audio en el mismo momento que se publican
- **Independencia**: Los ciudadanos pueden acceder a la información sin depender de terceros
- **Privacidad**: No es necesario compartir información personal con asistentes humanos
- **Igualdad de acceso**: Todos los ciudadanos, independientemente de su capacidad visual, tienen acceso simultáneo a la justicia constitucional

Esta es la verdadera promesa de la tecnología en el sector público: no solo eficiencia operativa, sino inclusión y democratización del acceso a derechos fundamentales.

---

## Solución de problemas

Si encuentra dificultades durante este laboratorio, consulte la [Guía de Solución de Problemas](TROUBLESHOOTING.md) que contiene soluciones a errores comunes.

**Errores que requieren asistencia del instructor:**
- Errores de permisos IAM
- Errores de límites de cuota de AWS
- Errores de acceso a modelos de Amazon Bedrock

## Limpieza de recursos

Al finalizar el laboratorio, consulte la [Guía de Limpieza de Recursos](LIMPIEZA.md) para eliminar todos los recursos creados y evitar cargos no deseados.

⚠️ **Importante**: La eliminación de la pila de CloudFormation eliminará automáticamente todos los recursos, incluyendo la base de datos RDS con todos los datos almacenados, la Web ACL de WAF y el secreto de Secrets Manager.
