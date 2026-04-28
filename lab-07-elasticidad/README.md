# 🏗️ Laboratorio 7: TechShop - Arquitectura de Alta Disponibilidad

## Índice

- [Objetivos de aprendizaje](#objetivos-de-aprendizaje)
- [Tiempo estimado](#tiempo-estimado)
- [Prerrequisitos](#prerrequisitos)
- [Escenario de negocio](#escenario-de-negocio)
- [Arquitectura de la solución](#arquitectura-de-la-solución)
- [Fase 1: Despliegue con CloudFormation (25 min)](#fase-1-despliegue-con-cloudformation-25-min)
  - [Paso 1: Verificar región y comprender Infraestructura como Código (5 min)](#paso-1-verificar-región-y-comprender-infraestructura-como-código-5-min)
  - [Paso 2: Lanzar la pila de CloudFormation (10 min)](#paso-2-lanzar-la-pila-de-cloudformation-10-min)
  - [Paso 3: Monitorear eventos de la pila (10 min)](#paso-3-monitorear-eventos-de-la-pila-10-min)
- [Fase 2: Alta Disponibilidad y Almacenamiento (25 min)](#fase-2-alta-disponibilidad-y-almacenamiento-25-min)
  - [Paso 4: Acceder a TechShop via CloudFront (5 min)](#paso-4-acceder-a-techshop-via-cloudfront-5-min)
  - [Paso 5: Inspeccionar EFS (5 min)](#paso-5-inspeccionar-efs-5-min)
  - [Paso 6: Simular fallo de servidor (10 min)](#paso-6-simular-fallo-de-servidor-10-min)
  - [Paso 7: Inspeccionar RDS Multi-AZ (5 min)](#paso-7-inspeccionar-rds-multi-az-5-min)
- [Fase 3: Distribución de Contenido y Seguridad (20 min)](#fase-3-distribución-de-contenido-y-seguridad-20-min)
  - [Paso 8: Inspeccionar CloudFront (5 min)](#paso-8-inspeccionar-cloudfront-5-min)
  - [Paso 9: Inspeccionar S3 con OAC (5 min)](#paso-9-inspeccionar-s3-con-oac-5-min)
  - [Paso 10: Inspeccionar WAF (5 min)](#paso-10-inspeccionar-waf-5-min)
  - [Paso 11: Verificar caching de CloudFront (5 min)](#paso-11-verificar-caching-de-cloudfront-5-min)
- [Fase 4: Observabilidad con CloudWatch (20 min)](#fase-4-observabilidad-con-cloudwatch-20-min)
  - [Paso 12: Inspeccionar alarmas de CloudWatch (5 min)](#paso-12-inspeccionar-alarmas-de-cloudwatch-5-min)
  - [Paso 13: Inspeccionar dashboard de CloudWatch (5 min)](#paso-13-inspeccionar-dashboard-de-cloudwatch-5-min)
  - [Paso 14: Verificar métricas de CloudFront (5 min)](#paso-14-verificar-métricas-de-cloudfront-5-min)
  - [Paso 15: Revisión final de capas de alta disponibilidad (5 min)](#paso-15-revisión-final-de-capas-de-alta-disponibilidad-5-min)
- [Solución de problemas](#solución-de-problemas)
- [Limpieza de recursos](#limpieza-de-recursos)

## Objetivos de aprendizaje

Al completar este laboratorio, usted será capaz de:

- Desplegar una arquitectura completa de alta disponibilidad mediante Infraestructura como Código (IaC) con AWS CloudFormation, aprovisionando ~25 recursos con un solo archivo
- Validar alta disponibilidad simulando fallos de servidor y observando la recuperación automática con Auto Scaling, ALB y almacenamiento compartido con EFS
- Inspeccionar la distribución de contenido con Amazon CloudFront y el acceso restringido a S3 mediante Origin Access Control (OAC)
- Comprender la seguridad perimetral con AWS WAF y su protección contra ataques web comunes en el edge
- Configurar y analizar observabilidad proactiva con alarmas y dashboards de Amazon CloudWatch

## Tiempo estimado

90 minutos

## Prerrequisitos

Para completar este laboratorio, usted necesita:

- Acceso a una cuenta AWS compartida proporcionada por el instructor
- Navegador web moderno (Chrome, Firefox, Edge o Safari)
- Infraestructura de red desplegada previamente por el instructor mediante la plantilla `TechShop-Instructor-Infra.yaml`
  - Esta plantilla crea la VPC, subredes públicas y privadas, Internet Gateway, NAT Gateway y tablas de enrutamiento
  - Recurso compartido - NO modificar
- Región **us-east-1** (N. Virginia) configurada en la consola de AWS
- Archivo `TechShop-HA-Lab.yaml` descargado localmente en su computadora (disponible en esta carpeta del repositorio)

## Escenario de negocio

TechShop es una tienda e-commerce de productos tecnológicos que ha experimentado un crecimiento acelerado en los últimos meses. Durante eventos de ventas como Black Friday y Cyber Monday, el sitio web experimenta picos de tráfico de hasta 10 veces el volumen normal, causando caídas del sistema y pérdida de ventas.

El equipo de TechShop ha identificado los siguientes problemas críticos:

- El servidor web único no soporta los picos de tráfico y se satura
- Cuando el servidor falla, toda la tienda queda fuera de línea
- La base de datos no tiene respaldo en tiempo real, arriesgando pérdida de datos de pedidos
- Los archivos compartidos entre servidores no están sincronizados
- No existe protección contra ataques web comunes
- No hay visibilidad sobre el estado de la infraestructura ni alertas proactivas

Su misión es desplegar y validar una arquitectura de alta disponibilidad que resuelva todos estos problemas, garantizando que TechShop permanezca en línea y protegida durante los picos de tráfico más exigentes.

## Arquitectura de la solución

La arquitectura que desplegará en este laboratorio distribuye la aplicación en múltiples capas de resiliencia, cada una diseñada para eliminar puntos únicos de fallo:

```
                            ┌─────────────────────┐
                            │     Usuarios /       │
                            │     Navegador        │
                            └──────────┬──────────┘
                                       │ HTTPS
                                       ▼
                            ┌─────────────────────┐
                            │     AWS WAF          │
                            │  (Seguridad en Edge) │
                            └──────────┬──────────┘
                                       │
                                       ▼
                            ┌─────────────────────┐
                            │  CloudFront (CDN)    │
                            │  2 orígenes:         │
                            │  ALB + S3 con OAC    │
                            └───┬─────────────┬───┘
                     Dinámico   │             │  Estático
                     (/* )      │             │  (/images/*, /assets/*)
                                ▼             ▼
                ┌──────────────────┐   ┌──────────────────┐
                │  Application     │   │  S3 Bucket       │
                │  Load Balancer   │   │  (OAC - acceso   │
                │  (Multi-AZ)      │   │   solo CloudFront)│
                └───────┬─────────┘   └──────────────────┘
                        │
           ┌────────────┴────────────┐
           ▼                         ▼
┌─────────────────────┐   ┌─────────────────────┐
│  us-east-1a         │   │  us-east-1b         │
│                     │   │                     │
│  EC2 Instance A     │   │  EC2 Instance B     │
│  (Auto Scaling)     │   │  (Auto Scaling)     │
│                     │   │                     │
│  EFS Mount Target A │   │  EFS Mount Target B │
│  (Subred privada)   │   │  (Subred privada)   │
│                     │   │                     │
│  RDS Primary        │   │  RDS Standby        │
│  (Subred privada)   │   │  (Réplica síncrona) │
└─────────────────────┘   └─────────────────────┘
           │                         │
           └────────────┬────────────┘
                        ▼
              ┌──────────────────┐
              │  CloudWatch      │
              │  Dashboard +     │
              │  Alarmas         │
              └──────────────────┘

Auto Scaling Group: Min 2 | Max 4 | Deseado 2
EFS: Almacenamiento compartido entre todas las instancias
RDS Multi-AZ: Replicación síncrona con failover automático
```

### Justificación de alta disponibilidad por servicio

| Servicio | Rol en la arquitectura | Justificación HA |
|----------|----------------------|------------------|
| **EC2 Auto Scaling** | Cómputo | Redundancia de servidores con escalado automático entre 2 y 4 instancias distribuidas en dos zonas de disponibilidad |
| **ALB** | Distribución de tráfico | Balanceo de carga con health checks que detectan y desvían tráfico de instancias fallidas automáticamente |
| **RDS Multi-AZ** | Base de datos | Replicación síncrona con failover automático a una réplica standby en otra zona de disponibilidad |
| **EFS** | Almacenamiento compartido | Sistema de archivos persistente accesible desde todas las instancias EC2, permitiendo que nuevas instancias sirvan contenido inmediatamente |
| **S3** | Almacenamiento de objetos | Durabilidad de 99.999999999% (11 nueves) para imágenes de productos y activos estáticos |
| **CloudFront** | CDN | Caching en ubicaciones de borde a nivel mundial, reduciendo latencia y descargando los servidores de origen |
| **WAF** | Seguridad perimetral | Firewall de aplicaciones web en el edge que bloquea tráfico malicioso antes de que alcance la infraestructura |
| **CloudWatch** | Observabilidad | Monitoreo proactivo con alarmas que permiten detección y respuesta rápida ante problemas |

---

## Fase 1: Despliegue con CloudFormation (25 min)

### Paso 1: Verificar región y comprender Infraestructura como Código (5 min)

1. Verifique que está trabajando en la región correcta:
   - En la esquina superior derecha de la consola de AWS
   - Confirme que dice **EE.UU. Este (Norte de Virginia) us-east-1**
   - Si no es correcta, haga clic en el selector de región y seleccione **US East (N. Virginia) us-east-1**

⚠️ **Importante**: La región **us-east-1** es obligatoria para este laboratorio. AWS WAF con scope `CLOUDFRONT` solo puede crearse en us-east-1 cuando se define en la misma pila de CloudFormation que la distribución CloudFront.

**Infraestructura como Código (IaC)**

En este laboratorio, utilizará AWS CloudFormation para desplegar toda la arquitectura de alta disponibilidad de TechShop en cuestión de minutos, sin crear manualmente ni un solo recurso. CloudFormation lee una plantilla (archivo YAML) que describe los ~25 recursos necesarios, calcula automáticamente las dependencias entre ellos, y los aprovisiona en el orden correcto.

En lugar de hacer clic manualmente para crear la VPC, luego las subredes, luego los grupos de seguridad, luego las instancias EC2, luego el balanceador de carga, la base de datos, el CDN, el WAF, etc., simplemente cargará un archivo y CloudFormation hará todo el trabajo. Esta es la esencia de la Infraestructura como Código: definir su infraestructura en un archivo versionable y reproducible.

**Infraestructura compartida del instructor**

Antes de iniciar, el instructor ya desplegó la infraestructura de red base mediante la plantilla `TechShop-Instructor-Infra.yaml`. Esta infraestructura incluye:

- VPC con soporte DNS habilitado
- 2 subredes públicas (us-east-1a y us-east-1b) con IP pública automática
- 2 subredes privadas (us-east-1a y us-east-1b)
- Internet Gateway para acceso público
- NAT Gateway para acceso saliente desde subredes privadas
- Tablas de enrutamiento configuradas

Recurso compartido - NO modificar

Usted seleccionará estos recursos de red como parámetros al lanzar su pila de CloudFormation en el siguiente paso.

**Arquitectura que desplegará:**

Revise el diagrama de arquitectura presentado en la sección [Arquitectura de la solución](#arquitectura-de-la-solución) al inicio de este documento. Observe cómo cada servicio contribuye a eliminar puntos únicos de fallo:

- **EC2 Auto Scaling + ALB**: Redundancia de cómputo con escalado automático entre 2 y 4 instancias distribuidas en dos zonas de disponibilidad. El ALB distribuye el tráfico y detecta instancias fallidas mediante health checks.
- **RDS Multi-AZ**: La base de datos mantiene una réplica síncrona en otra zona de disponibilidad con failover automático.
- **EFS**: Almacenamiento compartido persistente accesible desde todas las instancias, permitiendo que nuevas instancias sirvan contenido inmediatamente al arrancar.
- **CloudFront + S3 con OAC**: CDN que cachea contenido estático en ubicaciones de borde globales. S3 almacena imágenes con acceso restringido exclusivamente a través de CloudFront.
- **WAF**: Firewall de aplicaciones web que filtra tráfico malicioso en el edge antes de que alcance la infraestructura.
- **CloudWatch**: Alarmas y dashboard para monitoreo proactivo de CPU, solicitudes del ALB y conexiones de base de datos.

### Paso 2: Lanzar la pila de CloudFormation (10 min)

Ahora desplegará toda la arquitectura de alta disponibilidad de TechShop utilizando AWS CloudFormation. Este proceso automatizado creará ~25 recursos de AWS en cuestión de minutos.

1. En la barra de búsqueda global de la consola de AWS (parte superior), escriba `CloudFormation` y haga clic en el servicio **AWS CloudFormation** que aparece en los resultados.

2. En la consola de CloudFormation, haga clic en el botón naranja **Crear pila** ubicado en la esquina superior derecha.

3. En el menú desplegable que aparece, seleccione la opción **Con recursos nuevos (estándar)**.

4. En la pantalla "Crear pila", en la sección "Especificar plantilla":
   - Seleccione la opción **Cargar un archivo de plantilla**
   - Haga clic en el botón **Elegir archivo**
   - Navegue hasta la ubicación donde descargó el archivo `TechShop-HA-Lab.yaml` en su computadora
   - Seleccione el archivo y haga clic en **Abrir**
   - Haga clic en el botón **Siguiente** en la parte inferior de la pantalla

5. En la pantalla "Especificar detalles de la pila", configure los siguientes parámetros:
   - **Nombre de la pila**: `techshop-ha-{nombre-participante}`
     - Reemplace `{nombre-participante}` con su nombre (por ejemplo, `techshop-ha-carlos`)
     - Este nombre identifica sus recursos en el entorno compartido
   - **VpcId**: Seleccione la VPC creada por el instructor en el menú desplegable
     - Busque la VPC que contenga el nombre de la pila del instructor
   - **PublicSubnetAId**: Seleccione la subred pública en us-east-1a
   - **PublicSubnetBId**: Seleccione la subred pública en us-east-1b
   - **PrivateSubnetAId**: Seleccione la subred privada en us-east-1a
   - **PrivateSubnetBId**: Seleccione la subred privada en us-east-1b
   - Haga clic en **Siguiente**

⚠️ **Importante**: Asegúrese de seleccionar las subredes correctas. Las subredes públicas se utilizan para el ALB y las instancias EC2, mientras que las subredes privadas se utilizan para EFS y RDS. Si selecciona subredes incorrectas, la pila fallará durante la creación.

6. En la pantalla "Configurar opciones de la pila":
   - Deje todos los valores por defecto sin modificar
   - Desplácese hasta el final de la página
   - Haga clic en **Siguiente**

7. En la pantalla "Revisar y crear":
   - Revise el resumen de la configuración de su pila
   - Desplácese hasta el final de la página
   - En la sección "Capacidades", marque la casilla que dice:
     - **Reconozco que AWS CloudFormation podría crear recursos de IAM con nombres personalizados**
   - Esta confirmación es necesaria porque la plantilla crea un rol IAM y un perfil de instancia para que las instancias EC2 accedan a S3 y CloudWatch
   - Haga clic en el botón naranja **Enviar** para iniciar el despliegue

⚠️ **Advertencia**: Si no marca la casilla de capacidades IAM, CloudFormation rechazará la creación de la pila con el error `Requires capabilities: [CAPABILITY_NAMED_IAM]`. Si esto ocurre, simplemente regrese y marque la casilla.

**✓ Verificación**: Confirme que:
- La pila `techshop-ha-{nombre-participante}` aparece en la lista de pilas de CloudFormation
- El estado de la pila muestra **CREATE_IN_PROGRESS** (en color azul)
- El nombre de su pila sigue el formato `techshop-ha-{nombre-participante}` con su nombre correcto

⚠️ **Nota sobre seguridad en producción**: En este laboratorio, el grupo de seguridad del ALB (SG-ALB) permite tráfico HTTP/HTTPS desde cualquier origen (0.0.0.0/0). En una arquitectura de producción, se restringiría el inbound del ALB exclusivamente a los rangos de IP de CloudFront usando el AWS-managed prefix list `com.amazonaws.global.cloudfront.origin-facing`, garantizando que solo CloudFront pueda comunicarse con el ALB.

### Paso 3: Monitorear eventos de la pila (10 min)

Ahora que CloudFormation está creando su infraestructura, observará en tiempo real cómo los ~25 recursos se aprovisionan en un orden lógico determinado por sus dependencias.

1. Permanezca en la consola de CloudFormation y asegúrese de que su pila `techshop-ha-{nombre-participante}` esté seleccionada.

2. Haga clic en la pestaña **Eventos** ubicada en la parte inferior de la pantalla.

3. Haga clic en el botón de actualización (icono circular con flechas) ubicado en la esquina superior derecha de la tabla de eventos para ver los eventos más recientes.

4. Observe la columna **Estado** de los eventos:
   - Los recursos en proceso de creación muestran el estado **CREATE_IN_PROGRESS** (en color azul)
   - Los recursos completados muestran el estado **CREATE_COMPLETE** (en color verde)
   - Refresque periódicamente para ver cómo los recursos avanzan de `CREATE_IN_PROGRESS` a `CREATE_COMPLETE`

5. Observe el orden lógico de creación de los recursos. CloudFormation determina automáticamente este orden leyendo las dependencias en la plantilla:
   - **Primero**: Grupos de seguridad (SG-ALB, SG-EC2, SG-RDS, SG-EFS) — dependen solo de la VPC
   - **Segundo**: Recursos de almacenamiento (EFS FileSystem, S3 Bucket) y red (ALB, Target Group) — dependen de los grupos de seguridad y subredes
   - **Tercero**: Mount targets de EFS, RDS Multi-AZ, Launch Template — dependen de los recursos anteriores
   - **Cuarto**: Auto Scaling Group — depende del Launch Template, Target Group y mount targets de EFS
   - **Quinto**: CloudFront Distribution, WAF WebACL — dependen del ALB y S3
   - **Sexto**: CloudWatch Dashboard y Alarmas — dependen del ASG, ALB y RDS

⏱️ **Nota**: La base de datos Amazon RDS configurada en modo Multi-AZ tomará aproximadamente **15 minutos** en completar su creación. Esto se debe a que AWS debe aprovisionar servidores en dos zonas de disponibilidad diferentes y configurar la replicación síncrona entre ellos.

⏱️ **Nota**: La distribución de Amazon CloudFront tomará aproximadamente **5 minutos** en completar su propagación a las ubicaciones de borde globales.

6. Mientras espera que la pila se complete, puede hacer clic en la pestaña **Recursos** para ver la lista completa de recursos que CloudFormation está creando. Observe cómo cada recurso tiene un identificador lógico (nombre en la plantilla) y un identificador físico (ID real del recurso en AWS).

7. Espere hasta que el estado de la pila cambie a **CREATE_COMPLETE** (en color verde) en la parte superior de la pantalla. El proceso completo tomará aproximadamente 15-20 minutos.

**✓ Verificación**: Confirme que:
- La pestaña **Eventos** muestra múltiples recursos con estado **CREATE_COMPLETE**
- Puede observar el orden lógico de creación (Security Groups, Storage, Compute, CDN, Monitoring)
- La pila alcanzó el estado **CREATE_COMPLETE** (en color verde)
- La pestaña **Recursos** muestra ~25 recursos creados exitosamente

---

## Fase 2: Alta Disponibilidad y Almacenamiento (25 min)

En esta fase, verificará que la arquitectura de TechShop está realmente preparada para resistir fallos. Accederá a la aplicación, inspeccionará los componentes de almacenamiento compartido y base de datos, y simulará un fallo de servidor para comprobar la recuperación automática.

### Paso 4: Acceder a TechShop via CloudFront (5 min)

Ahora que la pila se ha creado exitosamente, accederá a la tienda TechShop a través de la URL de CloudFront proporcionada en las salidas de la pila.

1. En la consola de CloudFormation, asegúrese de que su pila `techshop-ha-{nombre-participante}` esté seleccionada.

2. Haga clic en la pestaña **Salidas** ubicada en la parte inferior de la pantalla.

3. Localice la salida con clave **CloudFrontURL**. Esta es la URL pública de su tienda TechShop, servida a través de la red de distribución de contenido de CloudFront.

4. Haga clic en el enlace de la columna **Valor** (la URL que comienza con `https://`) o cópiela y péguela en una nueva pestaña de su navegador.

5. Verifique que la página principal de TechShop se carga correctamente en su navegador. Debería ver la página de inicio con el branding de TechShop, la navegación y los productos destacados.

⏱️ **Nota**: Si la página no carga inmediatamente, espere 1-2 minutos y refresque. CloudFront puede tardar unos minutos adicionales en propagar completamente la configuración a todas las ubicaciones de borde.

**✓ Verificación**: Confirme que:
- La pestaña **Salidas** muestra la clave `CloudFrontURL` con una URL de CloudFront
- La página principal de TechShop se carga correctamente en el navegador
- La URL en la barra de direcciones corresponde al dominio de CloudFront (formato `https://dXXXXXXXXXXXXX.cloudfront.net`)

### Paso 5: Inspeccionar EFS (5 min)

Amazon Elastic File System (EFS) proporciona almacenamiento compartido persistente que todas las instancias EC2 del Auto Scaling Group montan simultáneamente. Esto garantiza que cuando Auto Scaling lanza una nueva instancia, esta tiene acceso inmediato a los archivos de la aplicación web sin necesidad de copiarlos o sincronizarlos.

1. En la barra de búsqueda global de la consola de AWS (parte superior), escriba `EFS` y haga clic en el servicio **Amazon Elastic File System** que aparece en los resultados.

2. En la lista de sistemas de archivos, localice el sistema de archivos creado por su pila. Puede identificarlo por el nombre que contiene `techshop-ha-{nombre-participante}`.

3. Haga clic en el **ID del sistema de archivos** para ver sus detalles.

4. En la página de detalles del sistema de archivos, observe las siguientes propiedades:
   - **Cifrado**: Debe mostrar **Habilitado** — los datos se cifran en reposo automáticamente
   - **Modo de rendimiento**: Debe mostrar **General Purpose** (generalPurpose) — optimizado para operaciones de baja latencia

5. Haga clic en la pestaña **Red** para inspeccionar los mount targets (puntos de montaje).

6. Verifique que existen **2 mount targets**, uno en cada zona de disponibilidad:
   - Un mount target en la subred de la zona **us-east-1a**
   - Un mount target en la subred de la zona **us-east-1b**

7. Para cada mount target, observe la columna **Grupo de seguridad**. Haga clic en el ID del grupo de seguridad para verificar que permite tráfico NFS:
   - **Regla de entrada**: TCP puerto **2049** (NFS) desde el grupo de seguridad de las instancias EC2

**Justificación de alta disponibilidad**: EFS proporciona almacenamiento compartido persistente accesible desde todas las instancias EC2 simultáneamente. Cuando Auto Scaling lanza una nueva instancia (por escalado o reemplazo de una instancia fallida), esta monta el sistema de archivos EFS y tiene acceso inmediato a todos los archivos de la aplicación web. No se requiere copia ni sincronización de datos, lo que reduce el tiempo de recuperación a segundos.

**✓ Verificación**: Confirme que:
- El sistema de archivos EFS muestra cifrado **Habilitado** y modo de rendimiento **General Purpose**
- Existen **2 mount targets** en las zonas us-east-1a y us-east-1b
- El grupo de seguridad de los mount targets permite tráfico TCP en el puerto **2049** (NFS)

### Paso 6: Simular fallo de servidor (10 min)

Esta es la prueba más importante del laboratorio. Terminará manualmente una de las instancias EC2 para simular un fallo de servidor y verificará que TechShop permanece en línea gracias a la redundancia del Auto Scaling Group y el balanceo de carga del ALB.

1. En la barra de búsqueda global de la consola de AWS (parte superior), escriba `EC2` y haga clic en el servicio **Amazon EC2** que aparece en los resultados.

2. En el panel de navegación de la izquierda, haga clic en **Instancias**.

3. Identifique las instancias EC2 que pertenecen a su Auto Scaling Group. Puede reconocerlas porque su nombre contiene `techshop-ha-{nombre-participante}`. Debería ver **2 instancias** en estado **En ejecución**.

4. Seleccione **una** de las dos instancias haciendo clic en la casilla de verificación a su izquierda.

5. Termine la instancia seleccionada:
   - Haga clic en el menú **Estado de la instancia** en la parte superior
   - Seleccione **Terminar instancia**
   - En el cuadro de confirmación, haga clic en **Terminar**

⚠️ **Importante**: Termine solo UNA instancia. La segunda instancia debe permanecer activa para mantener el servicio mientras Auto Scaling lanza el reemplazo.

6. **Inmediatamente** después de terminar la instancia, regrese a la pestaña del navegador donde tiene abierta la tienda TechShop (la URL de CloudFront) y refresque la página varias veces.

7. Observe que **el sitio permanece en línea**. El ALB detecta automáticamente que la instancia terminada ya no responde a los health checks y redirige todo el tráfico a la instancia restante.

8. Ahora verifique que Auto Scaling está lanzando una instancia de reemplazo:
   - En la barra de búsqueda global, escriba `Auto Scaling` y haga clic en **Grupos de Auto Scaling**
   - Localice el grupo de Auto Scaling de su pila (contiene `techshop-ha-{nombre-participante}`)
   - Haga clic en el nombre del grupo para ver sus detalles
   - En la pestaña **Administración de instancias**, observe que Auto Scaling está lanzando una nueva instancia para mantener la capacidad deseada de 2

⏱️ **Nota**: Auto Scaling detectará el fallo y lanzará una instancia de reemplazo en aproximadamente **3-5 minutos**. La nueva instancia montará automáticamente el sistema de archivos EFS y tendrá acceso inmediato a los archivos de la aplicación web.

9. Regrese a **EC2 > Instancias** y espere hasta que vea nuevamente **2 instancias** en estado **En ejecución**. Puede hacer clic en el botón de actualización periódicamente para ver el progreso.

**✓ Verificación**: Confirme que:
- Después de terminar una instancia, la tienda TechShop **permaneció en línea** al refrescar la página de CloudFront
- El grupo de Auto Scaling detectó la instancia faltante y lanzó una nueva instancia de reemplazo
- Después de unos minutos, la lista de instancias EC2 muestra nuevamente **2 instancias** en estado **En ejecución**

### Paso 7: Inspeccionar RDS Multi-AZ (5 min)

Amazon RDS Multi-AZ mantiene una réplica síncrona de la base de datos en una zona de disponibilidad diferente. Si la instancia primaria falla, AWS realiza un failover automático a la réplica standby sin intervención manual y sin pérdida de datos.

1. En la barra de búsqueda global de la consola de AWS (parte superior), escriba `RDS` y haga clic en el servicio **Amazon RDS** que aparece en los resultados.

2. En el panel de navegación de la izquierda, haga clic en **Bases de datos**.

3. Localice la instancia de base de datos creada por su pila. Puede identificarla porque su nombre contiene `techshop-ha-{nombre-participante}`.

4. Haga clic en el **identificador de la base de datos** para ver sus detalles.

5. En la pestaña **Configuración**, localice el campo **Implementación Multi-AZ** y confirme que muestra **Sí**.

6. Observe también los siguientes detalles de configuración:
   - **Motor**: MySQL
   - **Clase de instancia de base de datos**: db.t3.micro
   - **Almacenamiento**: 20 GiB gp2

**Justificación de alta disponibilidad**: RDS Multi-AZ mantiene una réplica síncrona de la base de datos en otra zona de disponibilidad. "Síncrona" significa que cada escritura en la base de datos primaria se replica inmediatamente a la standby antes de confirmar la transacción, garantizando cero pérdida de datos. Si la instancia primaria experimenta un fallo (hardware, red o mantenimiento), AWS realiza un failover automático a la réplica standby en aproximadamente 60-120 segundos, sin intervención manual y sin necesidad de cambiar la cadena de conexión de la aplicación.

**✓ Verificación**: Confirme que:
- La instancia de base de datos RDS muestra **Implementación Multi-AZ** con valor **Sí** en la pestaña de configuración
- El motor de base de datos es **MySQL** con clase de instancia **db.t3.micro**

---

## Fase 3: Distribución de Contenido y Seguridad (20 min)

En esta fase, inspeccionará cómo CloudFront distribuye el contenido de TechShop a nivel global, cómo S3 almacena los activos estáticos con acceso restringido mediante Origin Access Control (OAC), cómo WAF protege la aplicación contra ataques web comunes, y verificará el funcionamiento del caching en el edge.

### Paso 8: Inspeccionar CloudFront (5 min)

Amazon CloudFront es la red de distribución de contenido (CDN) que sirve como punto de entrada principal para los usuarios de TechShop. La distribución está configurada con dos orígenes: el ALB para contenido dinámico y el bucket S3 para contenido estático, cada uno con políticas de caché optimizadas para su tipo de contenido.

1. En la barra de búsqueda global de la consola de AWS (parte superior), escriba `CloudFront` y haga clic en el servicio **Amazon CloudFront** que aparece en los resultados.

2. En la lista de distribuciones, localice la distribución creada por su pila. Puede identificarla porque su comentario u origen contiene el nombre de su pila `techshop-ha-{nombre-participante}`.

3. Haga clic en el **ID de la distribución** para ver sus detalles.

4. En la pestaña **Orígenes**, verifique que existen **2 orígenes** configurados:
   - **Origen ALB (dinámico)**: El nombre de dominio del origen apunta al Application Load Balancer de su pila. Este origen sirve el contenido dinámico de la aplicación web (páginas HTML generadas por los servidores EC2).
   - **Origen S3 con OAC (estático)**: El nombre de dominio del origen apunta al bucket S3 de su pila. Este origen sirve las imágenes de productos y activos estáticos. Observe que la columna **Acceso de origen** muestra el uso de Origin Access Control (OAC), lo que significa que solo CloudFront puede acceder al bucket S3.

5. Haga clic en la pestaña **Comportamientos** para inspeccionar las reglas de enrutamiento de contenido. Verifique los siguientes comportamientos de caché:

   - **Comportamiento predeterminado** (`*`):
     - **Origen**: ALB (contenido dinámico)
     - **Política de caché**: CachingDisabled — el contenido dinámico no se almacena en caché porque puede cambiar con cada solicitud
     - **Protocolo del visor**: redirect-to-https

   - **Comportamientos para contenido estático** (`/assets/*` y `/images/*`):
     - **Origen**: S3 (contenido estático)
     - **Política de caché**: CachingOptimized — el contenido estático se almacena en caché con TTL largo porque las imágenes y activos no cambian frecuentemente
     - **Protocolo del visor**: redirect-to-https

**Justificación de alta disponibilidad**: CloudFront proporciona caching en ubicaciones de borde (edge locations) distribuidas a nivel mundial. Esto reduce la latencia para los usuarios al servir contenido desde la ubicación más cercana, y descarga los servidores de origen (ALB y EC2) al evitar que cada solicitud de contenido estático llegue hasta la infraestructura. Si un servidor de origen experimenta problemas temporales, CloudFront puede seguir sirviendo contenido estático desde su caché.

**✓ Verificación**: Confirme que:
- La distribución de CloudFront muestra **2 orígenes**: uno apuntando al ALB y otro al bucket S3 con OAC
- El comportamiento predeterminado (`*`) enruta al ALB con política **CachingDisabled**
- Los comportamientos `/assets/*` y `/images/*` enrutan al S3 con política **CachingOptimized**

### Paso 9: Inspeccionar S3 con OAC (5 min)

Amazon S3 almacena las imágenes de productos y activos estáticos de TechShop con una durabilidad de 99.999999999% (11 nueves). El acceso al bucket está completamente restringido: solo CloudFront puede leer los objetos mediante Origin Access Control (OAC), bloqueando cualquier acceso público directo.

1. En la barra de búsqueda global de la consola de AWS (parte superior), escriba `S3` y haga clic en el servicio **Amazon S3** que aparece en los resultados.

2. En la lista de buckets, localice el bucket creado por su pila. Puede identificarlo porque su nombre contiene `techshop-ha-{nombre-participante}`.

3. Haga clic en el **nombre del bucket** para ver su contenido.

4. Verifique que el bucket contiene las imágenes de productos almacenadas en la carpeta `images/`. Debería ver archivos como `producto-1.svg`, `producto-2.svg`, etc.

5. Verifique que el acceso público está completamente bloqueado:
   - Haga clic en la pestaña **Permisos**
   - En la sección **Bloquear acceso público (configuración del bucket)**, confirme que las **4 opciones** están habilitadas (todas marcadas como **Activado**)
   - Esto garantiza que ningún objeto del bucket puede ser accedido directamente desde Internet

6. **Prueba de acceso directo (Access Denied esperado)**:
   - Regrese a la pestaña **Objetos** del bucket
   - Haga clic en uno de los archivos de imagen (por ejemplo, `producto-1.svg`)
   - En la página de detalles del objeto, copie la **URL del objeto** (la URL de S3 que comienza con `https://s3.amazonaws.com/` o `https://{bucket-name}.s3.amazonaws.com/`)
   - Pegue esta URL en una nueva pestaña del navegador
   - Resultado esperado: **Access Denied** — esto confirma que el acceso directo al bucket S3 está bloqueado

7. **Prueba de acceso via CloudFront (funciona correctamente)**:
   - Regrese a la pestaña de CloudFormation con las salidas de su pila
   - Copie la URL de **CloudFrontURL** y agregue la ruta de la imagen al final (por ejemplo, `https://dXXXXXXXXXXXXX.cloudfront.net/images/producto-1.svg`)
   - Pegue esta URL en una nueva pestaña del navegador
   - Resultado esperado: **La imagen se muestra correctamente** — CloudFront tiene acceso al bucket S3 a través del OAC

**Justificación de alta disponibilidad**: Amazon S3 ofrece una durabilidad de 99.999999999% (11 nueves), lo que significa que los datos almacenados están protegidos contra pérdida con una probabilidad extremadamente alta. S3 replica automáticamente los objetos en múltiples instalaciones dentro de la región, garantizando que las imágenes de productos y activos estáticos de TechShop estén siempre disponibles incluso si una instalación de almacenamiento experimenta un fallo.

**✓ Verificación**: Confirme que:
- El bucket S3 contiene las imágenes de productos en la carpeta `images/`
- Las 4 opciones de **Bloquear acceso público** están **Activadas**
- El acceso directo via URL de S3 muestra **Access Denied**
- El acceso via URL de CloudFront muestra la imagen correctamente

### Paso 10: Inspeccionar WAF (5 min)

AWS WAF (Web Application Firewall) protege TechShop contra ataques web comunes como inyección SQL, cross-site scripting (XSS) y otros patrones de tráfico malicioso. La WebACL está configurada con scope CLOUDFRONT, lo que significa que filtra el tráfico en el edge antes de que llegue a la infraestructura de origen.

1. En la barra de búsqueda global de la consola de AWS (parte superior), escriba `WAF` y haga clic en el servicio **AWS WAF** que aparece en los resultados.

2. En la consola de WAF, verifique que la región seleccionada en la parte superior muestra **Global (CloudFront)**. Si no es así, haga clic en el selector de región y seleccione **Global (CloudFront)**.

⚠️ **Importante**: Las WebACL con scope CLOUDFRONT solo son visibles cuando se selecciona la región **Global (CloudFront)** en la consola de WAF. Si selecciona una región específica como us-east-1, no verá la WebACL.

3. En el panel de navegación de la izquierda, haga clic en **Web ACLs**.

4. Localice la WebACL creada por su pila. Puede identificarla porque su nombre contiene `techshop-ha-{nombre-participante}`.

5. Haga clic en el **nombre de la WebACL** para ver sus detalles.

6. En la pestaña **Overview**, verifique los siguientes detalles:
   - **Scope**: CLOUDFRONT — la WebACL opera a nivel global en las ubicaciones de borde de CloudFront

7. Haga clic en la pestaña **Associated AWS resources** (Recursos de AWS asociados) y verifique que la WebACL está asociada a la distribución de CloudFront de su pila.

8. Haga clic en la pestaña **Rules** (Reglas) y verifique que contiene el grupo de reglas administrado **AWSManagedRulesCommonRuleSet**. Este grupo de reglas proporciona protección contra:
   - Inyección SQL (SQLi)
   - Cross-site scripting (XSS)
   - Inclusión de archivos locales y remotos
   - Otros patrones de ataque web comunes definidos por el equipo de seguridad de AWS

**Justificación de alta disponibilidad**: WAF actúa como un firewall de aplicaciones web en el edge, filtrando y bloqueando tráfico malicioso antes de que alcance la infraestructura de TechShop. Esto protege los servidores de origen (ALB y EC2) contra ataques que podrían saturar los recursos o explotar vulnerabilidades, contribuyendo a mantener la disponibilidad del servicio incluso bajo intentos de ataque.

**✓ Verificación**: Confirme que:
- La consola de WAF muestra la región **Global (CloudFront)**
- La WebACL tiene scope **CLOUDFRONT** y está asociada a la distribución de CloudFront de su pila
- La pestaña de reglas contiene el grupo de reglas administrado **AWSManagedRulesCommonRuleSet**

### Paso 11: Verificar caching de CloudFront (5 min)

Ahora verificará en la práctica cómo funciona el caching de CloudFront. Al acceder a un recurso estático por primera vez, CloudFront lo obtiene del origen (S3) y lo almacena en la ubicación de borde más cercana. En solicitudes posteriores, CloudFront sirve el contenido directamente desde su caché sin contactar al origen, reduciendo la latencia significativamente.

1. Abra las herramientas de desarrollador de su navegador:
   - Presione la tecla **F12** en su teclado, o
   - Haga clic derecho en cualquier parte de la página y seleccione **Inspeccionar**

2. En las herramientas de desarrollador, haga clic en la pestaña **Network** (Red).

3. Asegúrese de que la grabación de red está activa (el botón de grabación debe estar en rojo).

4. En la barra de direcciones del navegador, acceda a un recurso estático a través de la URL de CloudFront. Utilice la URL de CloudFront de las salidas de su pila y agregue la ruta de una imagen, por ejemplo:
   ```
   https://dXXXXXXXXXXXXX.cloudfront.net/images/producto-1.svg
   ```
   Reemplace `dXXXXXXXXXXXXX` con el identificador de su distribución de CloudFront.

5. En la pestaña **Network** de las herramientas de desarrollador, haga clic en la solicitud del recurso (por ejemplo, `producto-1.svg`).

6. En el panel de detalles de la solicitud, haga clic en la pestaña **Headers** (Encabezados) y busque el encabezado de respuesta **X-Cache**. En esta primera solicitud, debería mostrar:
   ```
   X-Cache: Miss from cloudfront
   ```
   Esto indica que CloudFront no tenía el recurso en su caché y tuvo que obtenerlo del origen (S3).

7. Ahora **refresque la página** (presione F5 o Ctrl+R) para realizar una segunda solicitud al mismo recurso.

8. En la pestaña **Network**, haga clic nuevamente en la solicitud del recurso y verifique el encabezado **X-Cache**. Esta vez debería mostrar:
   ```
   X-Cache: Hit from cloudfront
   ```
   Esto indica que CloudFront sirvió el recurso directamente desde su caché en la ubicación de borde, sin contactar al origen S3.

**Beneficio del caching**: La diferencia entre "Miss" y "Hit" demuestra el valor del caching de CloudFront. Cuando el contenido se sirve desde la caché (Hit), la latencia se reduce drásticamente porque el recurso se entrega desde la ubicación de borde más cercana al usuario, en lugar de viajar hasta el bucket S3 en la región us-east-1. En una aplicación de producción con usuarios globales, esto puede significar la diferencia entre tiempos de carga de milisegundos versus segundos.

**✓ Verificación**: Confirme que:
- La primera solicitud al recurso estático muestra el encabezado `X-Cache: Miss from cloudfront`
- La segunda solicitud (después de refrescar) muestra el encabezado `X-Cache: Hit from cloudfront`
- El recurso estático se carga correctamente en ambas solicitudes

---

## Fase 4: Observabilidad con CloudWatch (20 min)

En esta fase, inspeccionará los mecanismos de observabilidad proactiva que permiten detectar y responder a problemas antes de que afecten a los usuarios de TechShop. Revisará las alarmas configuradas, el dashboard centralizado de métricas, las métricas de CloudFront, y realizará una revisión final de las cuatro capas de alta disponibilidad validadas durante el laboratorio.

### Paso 12: Inspeccionar alarmas de CloudWatch (5 min)

Las alarmas de CloudWatch proporcionan monitoreo proactivo al evaluar continuamente métricas clave de la infraestructura y cambiar de estado cuando se superan los umbrales definidos. La pila de TechShop incluye dos alarmas críticas: una para detectar alta utilización de CPU en las instancias EC2 y otra para detectar errores 5xx en el ALB.

1. En la barra de búsqueda global de la consola de AWS (parte superior), escriba `CloudWatch` y haga clic en el servicio **Amazon CloudWatch** que aparece en los resultados.

2. En el panel de navegación de la izquierda, haga clic en **Alarmas** y luego en **Todas las alarmas**.

3. Localice las dos alarmas creadas por su pila. Puede identificarlas porque sus nombres contienen `techshop-ha-{nombre-participante}`.

4. Identifique la **alarma de CPU alta** y haga clic en su nombre para ver los detalles. Verifique la siguiente configuración:
   - **Namespace**: AWS/EC2
   - **Métrica**: CPUUtilization
   - **Umbral**: Mayor que **80%** — se activa cuando la utilización promedio de CPU supera el 80%
   - **Período**: **300 segundos** (5 minutos) — cada punto de datos representa el promedio de 5 minutos
   - **Períodos de evaluación**: **2** — la alarma requiere que el umbral se supere durante 2 períodos consecutivos (10 minutos totales) antes de cambiar a estado ALARM, evitando falsas alarmas por picos momentáneos

5. Regrese a la lista de alarmas y haga clic en la **alarma de errores 5xx** para ver sus detalles. Verifique la siguiente configuración:
   - **Namespace**: AWS/ApplicationELB
   - **Métrica**: HTTPCode_ELB_5XX_Count
   - **Umbral**: Mayor que **10** — se activa cuando el número de errores 5xx supera 10 en un período
   - **Período**: **300 segundos** (5 minutos)
   - **Períodos de evaluación**: **1** — la alarma cambia a estado ALARM inmediatamente cuando se supera el umbral en un solo período, ya que los errores 5xx son críticos y requieren atención inmediata

6. Observe el **estado actual** de cada alarma. Los posibles estados son:
   - **OK** (verde): La métrica está dentro de los límites normales. La infraestructura funciona correctamente.
   - **ALARM** (rojo): La métrica ha superado el umbral definido durante los períodos de evaluación configurados. Requiere atención.
   - **INSUFFICIENT_DATA** (gris): CloudWatch no tiene suficientes datos para evaluar la alarma. Esto es normal para alarmas recién creadas o cuando las métricas aún no se han generado.

**Justificación de alta disponibilidad**: Las alarmas de CloudWatch proporcionan monitoreo proactivo que permite detectar problemas antes de que afecten a los usuarios. La alarma de CPU alta detecta cuando las instancias EC2 están sobrecargadas, lo que podría indicar la necesidad de escalar. La alarma de errores 5xx detecta cuando el ALB está devolviendo errores del servidor, lo que podría indicar fallos en las instancias de backend. En una arquitectura de producción, estas alarmas se conectarían a acciones automáticas (como políticas de escalado) o notificaciones SNS para alertar al equipo de operaciones.

**✓ Verificación**: Confirme que:
- Existen **2 alarmas** de CloudWatch asociadas a su pila: una para CPU alta y otra para errores 5xx
- La alarma de CPU alta tiene umbral **80%**, período **300s** y **2 períodos de evaluación**
- La alarma de errores 5xx tiene umbral **10**, período **300s** y **1 período de evaluación**
- Cada alarma muestra un estado actual (**OK**, **ALARM** o **INSUFFICIENT_DATA**)

### Paso 13: Inspeccionar dashboard de CloudWatch (5 min)

El dashboard de CloudWatch proporciona una vista centralizada de las métricas más importantes de la infraestructura de TechShop en un solo panel. Esto permite al equipo de operaciones monitorear el estado general del sistema de un vistazo, sin necesidad de navegar entre múltiples consolas de servicios.

1. En la consola de CloudWatch, en el panel de navegación de la izquierda, haga clic en **Paneles de control**.

2. Localice el dashboard creado por su pila. Puede identificarlo porque su nombre contiene `techshop-ha-{nombre-participante}`.

3. Haga clic en el **nombre del dashboard** para abrirlo.

4. Inspeccione los **4 widgets** de métricas que componen el dashboard:

   - **EC2 CPU Utilization**: Muestra la utilización promedio de CPU de las instancias EC2 del Auto Scaling Group. Una utilización consistentemente alta (por encima del 70-80%) indica que las instancias están sobrecargadas y podría ser necesario escalar horizontalmente (agregar más instancias).

   - **ALB Request Count**: Muestra el número total de solicitudes que recibe el Application Load Balancer. Este widget permite identificar patrones de tráfico, picos de demanda y tendencias de uso. Un aumento repentino podría indicar un evento de ventas o un posible ataque.

   - **ALB Target Response Time**: Muestra el tiempo promedio que tardan las instancias EC2 en responder a las solicitudes del ALB. Un aumento en el tiempo de respuesta puede indicar que las instancias están sobrecargadas, que la base de datos está lenta, o que existe un problema de rendimiento en la aplicación.

   - **RDS Database Connections**: Muestra el número de conexiones activas a la base de datos RDS MySQL. Un número alto de conexiones puede indicar que la aplicación está bajo carga pesada o que existen conexiones que no se están cerrando correctamente.

⏱️ **Nota**: Las métricas pueden tardar aproximadamente **5 minutos** en aparecer en el dashboard después de que la pila se haya creado. Si los widgets muestran "No data available" o aparecen vacíos, espere unos minutos y refresque el dashboard haciendo clic en el icono de actualización en la esquina superior derecha.

**✓ Verificación**: Confirme que:
- El dashboard de CloudWatch muestra **4 widgets** de métricas
- Los widgets corresponden a: **EC2 CPU Utilization**, **ALB Request Count**, **ALB Target Response Time** y **RDS Database Connections**
- Al menos algunos widgets muestran datos o puntos de métricas (si la pila lleva más de 5 minutos creada)

### Paso 14: Verificar métricas de CloudFront en CloudWatch (5 min)

CloudFront publica automáticamente métricas operativas en CloudWatch que permiten monitorear el rendimiento y la efectividad de la distribución de contenido. Estas métricas ayudan a entender cuánto tráfico está manejando CloudFront y qué porcentaje del contenido se está sirviendo desde la caché.

1. En la consola de CloudWatch, en el panel de navegación de la izquierda, haga clic en **Métricas** y luego en **Todas las métricas**.

2. En la parte inferior de la pantalla, en la sección de búsqueda de métricas, escriba `CloudFront` y presione Enter.

3. Haga clic en el namespace **CloudFront** que aparece en los resultados. Luego haga clic en **Per-Distribution Metrics** para ver las métricas por distribución.

4. Localice las métricas de su distribución de CloudFront e inspeccione las siguientes métricas clave:

   - **Requests** (Solicitudes totales): Muestra el número total de solicitudes HTTP/HTTPS que CloudFront ha recibido. Esta métrica indica el volumen de tráfico que la CDN está manejando, descargando los servidores de origen.

   - **BytesDownloaded**: Muestra el volumen total de datos transferidos desde CloudFront a los usuarios. Permite entender el consumo de ancho de banda de la distribución.

5. Para visualizar una métrica, seleccione la casilla de verificación junto a ella. El gráfico en la parte superior de la pantalla mostrará los datos de la métrica seleccionada.

6. Comprenda cómo estas métricas ayudan a evaluar la efectividad de la CDN:
   - Un alto número de **Requests** indica que CloudFront está manejando tráfico significativo, protegiendo los servidores de origen de la carga directa
   - La relación entre solicitudes totales y las que llegan al origen indica la **efectividad del caching**: cuantas más solicitudes se sirvan desde la caché (cache hits), menor será la carga en los servidores de origen y menor la latencia para los usuarios

**✓ Verificación**: Confirme que:
- El namespace **CloudFront** aparece en la lista de métricas de CloudWatch
- Puede ver métricas como **Requests** y **BytesDownloaded** para su distribución
- Al seleccionar una métrica, el gráfico muestra datos (si ha accedido previamente a la URL de CloudFront)

### Paso 15: Revisión final de capas de alta disponibilidad (5 min)

Ha completado la inspección de toda la arquitectura de alta disponibilidad de TechShop. En este paso final, recapitulará las cuatro capas de resiliencia que ha validado durante el laboratorio y cómo cada una contribuye a garantizar que TechShop permanezca en línea durante los picos de tráfico más exigentes.

**Las 4 capas de alta disponibilidad de TechShop:**

**Capa 1 - Redundancia de cómputo: EC2 Auto Scaling + ALB** (validada en el Paso 6)
- El Auto Scaling Group mantiene entre 2 y 4 instancias EC2 distribuidas en dos zonas de disponibilidad (us-east-1a y us-east-1b)
- El Application Load Balancer distribuye el tráfico entre las instancias saludables y detecta automáticamente instancias fallidas mediante health checks
- Cuando una instancia falla, Auto Scaling lanza automáticamente una instancia de reemplazo mientras el ALB redirige el tráfico a las instancias restantes
- Usted validó esta capa al terminar una instancia EC2 y confirmar que el sitio permaneció en línea

**Capa 2 - Protección de datos: RDS Multi-AZ + EFS** (validada en los Pasos 5 y 7)
- RDS Multi-AZ mantiene una réplica síncrona de la base de datos MySQL en otra zona de disponibilidad con failover automático en 60-120 segundos
- EFS proporciona almacenamiento compartido persistente accesible desde todas las instancias EC2, permitiendo que nuevas instancias sirvan contenido inmediatamente al arrancar
- Usted validó esta capa al inspeccionar los 2 mount targets de EFS y confirmar que RDS tiene Multi-AZ habilitado

**Capa 3 - Distribución de contenido: CloudFront + S3 + WAF** (validada en los Pasos 8-11)
- CloudFront distribuye contenido estático desde ubicaciones de borde globales, reduciendo latencia y descargando los servidores de origen
- S3 almacena imágenes de productos con durabilidad de 99.999999999% (11 nueves), accesible exclusivamente a través de CloudFront OAC
- WAF filtra tráfico malicioso en el edge antes de que alcance la infraestructura, protegiendo contra ataques web comunes
- Usted validó esta capa al inspeccionar los 2 orígenes de CloudFront, confirmar que S3 bloquea acceso directo, verificar las reglas de WAF y comprobar el caching con el encabezado X-Cache

**Capa 4 - Observabilidad: CloudWatch alarmas + dashboard** (validada en los Pasos 12-14)
- Las alarmas de CloudWatch monitorean proactivamente CPU alta y errores 5xx, permitiendo detección rápida de problemas
- El dashboard centralizado muestra métricas de CPU, solicitudes del ALB, tiempo de respuesta y conexiones de base de datos en un solo panel
- Las métricas de CloudFront permiten evaluar la efectividad de la CDN y el volumen de tráfico manejado
- Usted validó esta capa al inspeccionar las 2 alarmas, los 4 widgets del dashboard y las métricas de CloudFront

**Resumen de servicios y su contribución a la alta disponibilidad:**

| Servicio | Capa | Contribución a la Alta Disponibilidad |
|----------|------|---------------------------------------|
| **EC2 Auto Scaling** | Cómputo | Redundancia de servidores con escalado automático entre 2 y 4 instancias en 2 AZs |
| **ALB** | Cómputo | Distribución de tráfico con health checks que detectan y desvían instancias fallidas |
| **RDS Multi-AZ** | Datos | Replicación síncrona con failover automático a réplica standby en otra AZ |
| **EFS** | Datos | Almacenamiento compartido persistente accesible desde todas las instancias EC2 |
| **S3** | Contenido | Durabilidad de 11 nueves para imágenes y activos estáticos |
| **CloudFront** | Contenido | Caching en ubicaciones de borde globales, reduciendo latencia y carga en origen |
| **WAF** | Seguridad | Firewall de aplicaciones web en el edge que bloquea tráfico malicioso |
| **CloudWatch** | Observabilidad | Monitoreo proactivo con alarmas y dashboard para detección rápida de problemas |

Ha desplegado y validado exitosamente una arquitectura de alta disponibilidad completa para TechShop utilizando Infraestructura como Código con AWS CloudFormation. Esta arquitectura garantiza que TechShop puede resistir fallos de servidores, picos de tráfico de hasta 10x durante eventos como Black Friday y Cyber Monday, y ataques web comunes, mientras mantiene visibilidad completa sobre el estado de la infraestructura.

Los patrones de arquitectura que ha explorado en este laboratorio — redundancia multi-AZ, balanceo de carga con health checks, replicación de base de datos, almacenamiento compartido, distribución de contenido con CDN, seguridad perimetral con WAF y observabilidad proactiva con CloudWatch — son los mismos patrones que utilizan las aplicaciones de producción a escala global en AWS.

**✓ Verificación final**: Confirme que durante este laboratorio usted:
- Desplegó ~25 recursos de AWS con un solo archivo de CloudFormation (Fase 1)
- Validó la redundancia de cómputo simulando un fallo de servidor y confirmando la recuperación automática (Fase 2)
- Inspeccionó la distribución de contenido con CloudFront, el acceso restringido a S3 con OAC y la protección de WAF (Fase 3)
- Verificó la observabilidad proactiva con alarmas, dashboard y métricas de CloudWatch (Fase 4)

---

## Solución de problemas

Si encuentra dificultades durante este laboratorio, consulte la [Guía de Solución de Problemas](./TROUBLESHOOTING.md) que contiene soluciones a errores comunes organizados por fase.

**Errores que requieren asistencia del instructor:**

⚠️ Si recibe alguno de los siguientes errores, notifique al instructor de inmediato. No intente solucionar estos errores por su cuenta:

- Errores de permisos IAM (AccessDenied, UnauthorizedOperation)
- Errores de límites de cuota de AWS (LimitExceededException, ResourceLimitExceeded)

## Limpieza de recursos

Al finalizar el laboratorio, siga las instrucciones de la [Guía de Limpieza](./LIMPIEZA.md) para eliminar los recursos creados durante el laboratorio.

⚠️ **Importante**: NO elimine la infraestructura del instructor (VPC, subredes, Internet Gateway, NAT Gateway). Solo elimine la pila de CloudFormation que usted creó (`techshop-ha-{nombre-participante}`).
