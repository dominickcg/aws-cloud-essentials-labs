# Lab 3: Página Web Dinámica con RDS

## Objetivos

- Crear una instancia RDS for MySQL
- Conectar EC2 con RDS para almacenar datos
- Implementar una página web que guarde y muestre información

## Duración estimada

40–50 minutos

## Requisitos

- Cuenta de AWS con permisos para EC2 y RDS
- Navegador web para acceder a la aplicación

## Pasos

### 1. Descargar el script de configuración

1. Descargar el archivo [`user-data.sh`](user-data.sh) a tu computadora local.

### 2. Crear los Security Groups

1. Ir a **EC2**.
2. En el menú lateral izquierdo, en la sección **Red y seguridad**, hacer clic en **Security Groups**.
3. Hacer clic en **Crear grupo de seguridad**.
4. **Configurar Security Group para EC2:**
   - **Nombre:** `ec2-lab3-tunombre-sg`
   - **Descripción:** Security Group para EC2 Lab 3
   - **VPC:** Dejar por defecto
   - **Reglas de entrada → Agregar regla**
     - **Tipo:** SSH (22). **Origen:** Mi IP.
     - **Tipo:** HTTP (80). **Origen:** Anywhere-IPv4 (0.0.0.0/0).
   - Hacer clic en **Crear grupo de seguridad**
5. Vuelve al menú de Security Groups. Luego, hacer clic en **Crear grupo de seguridad** nuevamente.
6. **Configurar Security Group para RDS:**
   - **Nombre:** `database-lab3-tunombre-sg`
   - **Descripción:** Security Group para RDS Lab 3
   - **VPC:** Dejar por defecto
   - **Reglas de entrada → Agregar regla**
     - **Tipo:** MySQL/Aurora (3306). **Origen:** Personalizado → `ec2-lab3-tunombre-sg`
   - Hacer clic en **Crear grupo de seguridad**

### 3. Crear la instancia RDS for MySQL

1. Ir a **RDS**.
2. Hacer clic en **Crear una base de datos**.
3. Configurar:
   - **Tipo de motor:** MySQL
   - **Plantillas:** Capa gratuita
   - **Identificador de instancias de bases de datos:** `database-lab3-tunombre`
   - **Nombre de usuario maestro:** `admin`
   - **Administración de credenciales:** Autoadministrado
   - **Contraseña maestra:** `Lab123456**`
   - **Confirmar la contraseña maestra:** `Lab123456**`
   - **Clase de instancia:** db.t3.micro
   - **Tipo de almacenamiento:** SSD de uso general (gp3)
   - **Almacenamiento asignado:** 20 GiB
4. En **Conectividad:**
   - **Recurso de computación:** No se conecte a un recurso informático EC2
   - **Acceso público:** No
   - **Grupo de seguridad de VPC (firewall):** Elegir existente → `database-lab3-tunombre-sg`. Quitar `default`
5. Hacer clic en **Crear base de datos** (tardará unos minutos).

### 4. Crear la instancia EC2

1. Ir a **EC2**.
2. Hacer clic en **Lanzar instancia**.
3. Configurar:
   - **Nombre:** `ec2-lab3-tunombre`
   - **AMI:** Amazon Linux 2023
   - **Tipo de instancia:** t2.micro
   - **Par de claves:** crear o seleccionar uno existente
4. **Firewall (grupos de seguridad):** Seleccionar un grupo de seguridad existente → `ec2-lab3-tunombre-sg`
5. En **Detalles avanzados → Datos de usuario**, cargar el archivo [`user-data.sh`](user-data.sh).
6. **ANTES de lanzar la instancia**: Ir a **RDS → Bases de datos**, seleccionar tu instancia `database-lab3-tunombre` y copiar el **Punto de enlace**.
7. Volviendo a la configuración de la instancia EC2, en el campo **Datos de usuario**, editar el script cargado y reemplazar `[RDS-ENDPOINT]` con el endpoint copiado.
8. Hacer clic en **Lanzar instancia** y esperar unos minutos a que se configure automáticamente.

### 5. Verificar el despliegue automático

El script de user-data se encargará automáticamente de:

- Instalar Apache, PHP y MySQL client
- Detectar el endpoint de RDS automáticamente
- Configurar la aplicación web con la conexión correcta
- Crear la base de datos y tablas necesarias
- Iniciar el servidor web

**Nota:** El proceso completo puede tomar entre 5-10 minutos. La aplicación estará lista automáticamente.

### 6. Probar la aplicación

1. Abrir la IP pública de tu EC2 en el navegador.
2. Completar el formulario con datos de prueba.
3. Hacer clic en "Ver Registros" para verificar que se guardaron correctamente en RDS.

## Limpieza de recursos

Para evitar costos innecesarios, elimina los recursos en este orden:

### 1. Eliminar instancia EC2

1. Ir a **EC2**.
2. Hacer clic en **Instancias**.
3. Seleccionar tu instancia `ec2-lab3-tunombre`.
4. Hacer clic en **Estado de la instancia → Terminar instancia**.
5. Confirmar la terminación.

### 2. Eliminar instancia RDS

1. Ir a **RDS**.
2. Hacer clic en **Bases de datos**.
3. Seleccionar tu instancia `database-lab3-tunombre`.
4. Hacer clic en **Acciones → Eliminar**.
5. Desmarcar "Crear snapshot final".
6. Escribir "delete me" para confirmar.
7. Hacer clic en **Eliminar**.

### 3. Eliminar Security Groups

1. Ir a **EC2**.
2. En el menú lateral, hacer clic en **Red y seguridad → Security Groups**.
3. Seleccionar y eliminar en este orden:
   - `database-lab3-tunombre-sg`
   - `ec2-lab3-tunombre-sg`
4. Hacer clic en **Acciones → Eliminar grupo de seguridad** para cada uno.

> **⚠️ Importante:**
>
> - Al eliminar RDS sin snapshot, perderás todos los datos permanentemente
> - Los Security Groups solo se pueden eliminar después de que no estén en uso por ningún recurso
