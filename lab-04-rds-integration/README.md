# 🗄️ Laboratorio 4: Página Web Dinámica con RDS

## Índice

- [Objetivos de aprendizaje](#objetivos-de-aprendizaje)
- [Tiempo estimado](#tiempo-estimado)
- [Prerrequisitos](#prerrequisitos)
- [Paso 1: Verificar región AWS](#paso-1-verificar-region-aws)
- [Paso 2: Crear los Grupos de seguridad](#paso-2-crear-los-grupos-de-seguridad)
- [Paso 3: Crear la instancia RDS for MySQL](#paso-3-crear-la-instancia-rds-for-mysql)
- [Paso 4: Configurar recursos mientras espera RDS](#paso-4-configurar-recursos-mientras-espera-rds)
- [Paso 5: Crear la instancia EC2](#paso-5-crear-la-instancia-ec2)
- [Paso 6: Probar la aplicación](#paso-6-probar-la-aplicacion)
- [Solución de problemas](#solucion-de-problemas)
- [Limpieza de recursos](#limpieza-de-recursos)

## Objetivos de aprendizaje

- Crear y configurar una instancia RDS for MySQL en AWS
- Implementar conectividad segura entre EC2 y RDS mediante Grupos de seguridad
- Desplegar una aplicación web dinámica que interactúa con una base de datos
- Comprender el tiempo de aprovisionamiento de servicios administrados como RDS

## Tiempo estimado

50-65 minutos (incluye 10-15 minutos de aprovisionamiento de RDS)

## Prerrequisitos

- Cuenta de AWS con permisos para EC2 y RDS
- Navegador web para acceder a la aplicación
- Haber completado el Laboratorio 1 (se reutilizará el par de claves creado)

⚠️ **Nota sobre Free Tier**: Este laboratorio está diseñado para usar recursos dentro del Free Tier de AWS (db.t3.micro con 20 GB de almacenamiento). Verifique que su cuenta tenga Free Tier activo y no haya excedido los límites mensuales para evitar cargos inesperados.

## Paso 1: Verificar región AWS

1. Verifique que está trabajando en la región correcta:
   - En la esquina superior derecha de la consola de AWS
   - Confirme que dice la región estipulada por el instructor
   - Si no es correcta, haga clic y seleccione la región indicada

## Paso 2: Crear los Grupos de seguridad

1. Utilice la barra de búsqueda global (parte superior) y escriba **EC2**, luego haga clic en el servicio
2. En el panel de navegación de la izquierda, en la sección **Red y seguridad**, haga clic en **Grupos de seguridad**
3. Haga clic en el botón naranja **Crear grupo de seguridad**
4. Configure el Security Group para EC2:
   - **Nombre del grupo de seguridad**: `ec2-sg-lab4-{nombre-participante}`
   - **Descripción**: `Security Group para EC2 Lab 4`
   - **VPC**: Deje la VPC por defecto
   - En la sección **Reglas de entrada**, haga clic en **Agregar regla**:
     - **Tipo**: SSH
     - **Origen**: Mi IP
   - Haga clic en **Agregar regla** nuevamente:
     - **Tipo**: HTTP
     - **Origen**: Anywhere-IPv4 (0.0.0.0/0)
   - Haga clic en el botón naranja **Crear grupo de seguridad**

**✓ Verificación**: En la lista de grupos de seguridad, confirme que:
- El grupo `ec2-sg-lab4-{nombre-participante}` aparece en la lista
- Tiene 2 reglas de entrada (SSH y HTTP)

5. En el panel de navegación de la izquierda, haga clic en **Grupos de seguridad** nuevamente
6. Haga clic en el botón naranja **Crear grupo de seguridad**
7. Configure el Security Group para RDS:
   - **Nombre del grupo de seguridad**: `rds-sg-lab4-{nombre-participante}`
   - **Descripción**: `Security Group para RDS Lab 4`
   - **VPC**: Deje la VPC por defecto
   - En la sección **Reglas de entrada**, haga clic en **Agregar regla**:
     - **Tipo**: MYSQL/Aurora
     - **Origen**: Personalizado
     - En el campo de búsqueda, escriba y seleccione `ec2-sg-lab4-{nombre-participante}`
   - Haga clic en el botón naranja **Crear grupo de seguridad**

**✓ Verificación**: En la lista de grupos de seguridad, confirme que:
- El grupo `rds-sg-lab4-{nombre-participante}` aparece en la lista
- Tiene 1 regla de entrada (MYSQL/Aurora) con origen del Security Group de EC2

## Paso 3: Crear la instancia RDS for MySQL

1. Utilice la barra de búsqueda global (parte superior) y escriba **RDS**, luego haga clic en el servicio
2. Haga clic en el botón naranja **Crear base de datos**
3. Configure los siguientes parámetros:
   - **Método de creación de base de datos**: Creación estándar
   - **Opciones del motor**: MySQL
   - **Versión del motor**: Deje la versión por defecto
   - **Plantillas**: Capa gratuita
   - **Identificador de instancias de bases de datos**: `database-lab4-{nombre-participante}`
   - **Nombre de usuario maestro**: `admin`
   - **Administración de credenciales**: Autoadministrado
   - **Contraseña maestra**: `Lab123456**`
   - **Confirmar la contraseña maestra**: `Lab123456**`
4. En la sección **Configuración de la instancia**:
   - **Clase de instancia de base de datos**: db.t3.micro
5. En la sección **Almacenamiento**:
   - **Tipo de almacenamiento**: SSD de uso general (gp3) - Recomendado por AWS
   - **Almacenamiento asignado**: 20 GiB
6. En la sección **Conectividad**:
   - **Recurso de computación**: No se conecte a un recurso informático EC2
   - **Acceso público**: No
   - **Grupo de seguridad de VPC (firewall)**: Haga clic en **Elegir existente**
   - Seleccione `rds-sg-lab4-{nombre-participante}`
   - Quite el grupo `default` haciendo clic en la X
7. Desplácese hasta el final y haga clic en el botón naranja **Crear base de datos**

⏱️ **Nota**: La base de datos RDS puede tardar 10-15 minutos en estar disponible.

**✓ Verificación**: En la lista de bases de datos, confirme que:
- La base de datos `database-lab4-{nombre-participante}` aparece en la lista
- El estado inicial es **Creando** (color naranja)

## Paso 4: Configurar recursos mientras espera RDS

**Mientras espera** que la base de datos RDS esté disponible, puede realizar las siguientes tareas:

1. Descargue el archivo [`user-data.sh`](user-data.sh) ubicado en esta carpeta a su computadora local
2. Revise el contenido del script para familiarizarse con la configuración automática
3. Prepare el par de claves que utilizará para la instancia EC2 (del Laboratorio 1)

⚠️ **Importante**: NO proceda al Paso 5 hasta que el estado de la base de datos RDS sea **Disponible** (color verde). Puede verificar el estado en **RDS → Bases de datos**.

## Paso 5: Crear la instancia EC2

**Antes de comenzar**: Verifique que la base de datos RDS tiene estado **Disponible** en la consola de RDS.

1. En la consola de RDS, haga clic en **Bases de datos** en el panel de navegación izquierdo
2. Haga clic en el identificador de su base de datos `database-lab4-{nombre-participante}`
3. En la sección **Conectividad y seguridad**, copie el valor del **Punto de enlace** (ejemplo: `database-lab4-nombre.xxxxx.us-east-1.rds.amazonaws.com`)
4. Utilice la barra de búsqueda global (parte superior) y escriba **EC2**, luego haga clic en el servicio
5. Haga clic en el botón naranja **Lanzar instancia**
6. Configure los siguientes parámetros:
   - **Nombre**: `ec2-webapp-{nombre-participante}`
   - **Imágenes de aplicaciones y sistemas operativos (Amazon Machine Image)**: Amazon Linux 2023
   - **Tipo de instancia**: t2.micro
   - **Par de claves**: Seleccione el par de claves que creó en el Laboratorio 1
7. En la sección **Configuración de red**:
   - Haga clic en **Editar**
   - **Firewall (grupos de seguridad)**: Seleccionar grupo de seguridad existente
   - Seleccione `ec2-sg-lab4-{nombre-participante}`
8. En la sección **Detalles avanzados**:
   - Desplácese hasta el final hasta encontrar **Datos de usuario**
   - Copie el contenido del archivo [`user-data.sh`](user-data.sh) ubicado en esta carpeta
   - Pegue el contenido en el campo de texto
   - **IMPORTANTE**: Reemplace `[RDS-ENDPOINT]` con el punto de enlace que copió en el paso 3
9. Haga clic en el botón naranja **Lanzar instancia**

**✓ Verificación**: En la lista de instancias, confirme que:
- La instancia `ec2-webapp-{nombre-participante}` aparece en la lista
- El estado de la instancia es **En ejecución** (verde)
- La columna **Comprobaciones de estado** muestra "2/2 comprobaciones aprobadas" (esto puede tardar 2-3 minutos)

⏱️ **Nota**: El script de datos de usuario puede tardar 5-10 minutos en completar la instalación y configuración de la aplicación web.

## Paso 6: Probar la aplicación

1. En la consola de EC2, seleccione su instancia `ec2-webapp-{nombre-participante}`
2. Copie la **Dirección IPv4 pública** que aparece en la sección de detalles
3. Abra una nueva pestaña en su navegador web
4. Pegue la dirección IP en la barra de direcciones y presione Enter
5. Debería ver el formulario de la aplicación web
6. Complete el formulario con datos de prueba:
   - Ingrese un nombre
   - Ingrese un correo electrónico
   - Haga clic en **Enviar**
7. Haga clic en el botón **Ver Registros** para verificar que los datos se guardaron correctamente en la base de datos RDS

**✓ Verificación**: Confirme que:
- La página web se carga correctamente
- Puede enviar datos mediante el formulario
- Los datos aparecen en la sección "Ver Registros"
- Los datos persisten al recargar la página

## Solución de problemas

Si encuentra dificultades durante este laboratorio, consulte la [Guía de Solución de Problemas](TROUBLESHOOTING.md) que contiene soluciones a errores comunes.

**Errores que requieren asistencia del instructor:**
- Errores de permisos IAM
- Errores de límites de cuota de AWS

## Limpieza de recursos

Para eliminar los recursos creados en este laboratorio, consulte la [Guía de Limpieza de Recursos](LIMPIEZA.md).

⚠️ **Nota**: La limpieza es opcional. Solo realícela si no continuará con laboratorios posteriores o si desea evitar costos innecesarios.
