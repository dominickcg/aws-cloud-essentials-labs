# Lab 3: Página Web Dinámica con RDS

## Objetivos
- Crear una instancia RDS for MySQL sencilla
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

### 2. Crear la instancia EC2
1. Ir a **EC2 → Lanzar instancia**.
2. Configurar:
   - **Nombre:** `ec2-lab3-<tu-nombre>`
   - **AMI:** Amazon Linux 2023
   - **Tipo de instancia:** t2.micro
   - **Par de claves:** crear o seleccionar uno existente
3. **Security Group:**
   - **Nombre:** `ec2-lab3-<tu-nombre>-sg`
   - SSH (22) desde tu IP
   - HTTP (80) desde cualquier lugar (0.0.0.0/0)
4. En **Detalles avanzados → Datos de usuario**, cargar el archivo `user-data.sh` descargado
5. Lanzar la instancia y esperar unos minutos a que se configure automáticamente.

### 3. Crear la instancia RDS MySQL
1. Ir a **RDS → Crear una base de datos**.
2. Configurar:
   - **Motor:** MySQL
   - **Plantillas:** Capa gratuita
   - **Identificador:** `database-lab3-<tu-nombre>`
   - **Usuario:** `admin`
   - **Administración de credenciales:** Autoadministrado
   - **Contraseña maestra:** `Lab123456*`
   - **Clase de instancia:** db.t3.micro
3. En **Conectividad:**
   - **Acceso público:** No
   - **Security Group:** Crear nuevo con nombre `database-lab3-<tu-nombre>-sg`
4. Crear la base de datos (tardará unos minutos).

### 4. Configurar acceso desde EC2
1. Ve a **EC2 → Red y seguridad → Security Groups**.
2. Busca el Security Group de RDS `database-lab3-<tu-nombre>-sg`.
3. **Reglas de entrada → Editar reglas de entrada → Agregar regla**
   - **Tipo:** MySQL/Aurora (3306)
   - **Origen:** Security Group de tu EC2
4. Guardar reglas.

### 5. Configurar la aplicación web
1. Conectarse por SSH a la instancia EC2
2. Cambiar al directorio de la aplicación web:
   ```bash
   cd /var/www/html
   ```
3. Editar el archivo de configuración:
   ```bash
   sudo nano config.php
   ```
   - Reemplazar `[RDS-ENDPOINT]` con el endpoint real de tu RDS
   - Presionar `Ctrl+O` para guardar
   - Presionar `Enter` para confirmar el nombre del archivo
   - Presionar `Ctrl+X` para salir de nano
4. Crear la base de datos ejecutando:
   ```bash
   mysql -h [RDS-ENDPOINT] -u admin -p < database-setup.sql
   ```

### 6. Probar la aplicación
1. Abrir la IP pública de tu EC2 en el navegador.
2. Completar el formulario con datos de prueba.
3. Hacer clic en "Ver Registros" para verificar que se guardaron.

## Limpieza de recursos

Para evitar costos innecesarios:

1. **Eliminar instancia RDS:**
   - Ve a **RDS → Bases de datos**
   - Selecciona tu instancia → **Acciones → Eliminar**
   - Desmarcar "Crear snapshot final"
   - Confirmar eliminación

2. **Eliminar Security Groups:**
   - Ve a **EC2 → Security Groups**
   - Elimina `database-lab3-<tu-nombre>-sg`
   - Elimina `ec2-lab3-<tu-nombre>-sg` (si no lo necesitas para otros labs)

3. **Mantener EC2** para otros labs (o eliminar si no la necesitas)

> **💡 Tip:** RDS genera costos por hora. Elimínala inmediatamente después del lab.

> **⚠️ Importante:** Al eliminar RDS sin snapshot, perderás todos los datos permanentemente.