# Lab 2: Networking con VPC, Subredes y Conectividad

## Indice

- [Objetivos](#objetivos)
- [Duración estimada](#duración-estimada)
- [Requisitos](#requisitos)
- [Arquitectura del laboratorio](#arquitectura-del-laboratorio)
- [Recursos compartidos](#recursos-compartidos)
- [Parte 1: Crear recursos compartidos (solo instructor)](#parte-1-crear-recursos-compartidos-solo-instructor)
- [Parte 2: Crear subredes](#parte-2-crear-subredes)
- [Parte 3: Crear tablas de enrutamiento](#parte-3-crear-tablas-de-enrutamiento)
- [Parte 4: Crear Security Group](#parte-4-crear-security-group)
- [Parte 5: Crear Network ACL personalizada](#parte-5-crear-network-acl-personalizada)
- [Parte 6: Lanzar instancias EC2 de prueba](#parte-6-lanzar-instancias-ec2-de-prueba)
- [Parte 7: Verificar conectividad](#parte-7-verificar-conectividad)
- [Parte 8: Asignar Elastic IP](#parte-8-asignar-elastic-ip)
- [Limpieza de recursos](#limpieza-de-recursos)
- [Solución de problemas](#solución-de-problemas)

## Objetivos

- Comprender la estructura de una VPC con subredes públicas y privadas
- Configurar tablas de enrutamiento para controlar el flujo de tráfico
- Implementar Grupos de seguridad y NACLs como capas de seguridad
- Verificar la conectividad a internet desde subredes públicas y privadas
- Asignar y asociar una Elastic IP a una instancia EC2

## Duración estimada

50-60 minutos

## Requisitos

- Cuenta de AWS con permisos para VPC, EC2 y networking
- Navegador para acceder a la consola de AWS

## Arquitectura del laboratorio

```
                        Internet
                           |
                    Internet Gateway  ← Recurso compartido
                           |
              ┌────────────┴────────────┐
              |        VPC              |  ← Recurso compartido
              |    10.0.0.0/16          |
              |                         |
              |  ┌─────────────────┐    |
              |  | Subred Pública  |    |
              |  | 10.0.X.0/24    |    |
              |  |   [EC2 pública] |    |
              |  └─────────────────┘    |
              |                         |
              |  ┌─────────────────┐    |
              |  | Subred Privada  |    |
              |  | 10.0.Y.0/24    |    |
              |  |   [EC2 privada] |    |
              |  └────────┬────────┘    |
              |           |             |
              |      NAT Gateway        |  ← Recurso compartido
              |                         |
              └─────────────────────────┘
```

> X e Y representan valores únicos por participante. Consulte la tabla de asignación proporcionada por el instructor.

## Recursos compartidos

Los siguientes recursos serán creados por el instructor durante el desarrollo del laboratorio. Una vez creados, serán utilizados por todos los participantes. **NO los modifique ni elimine.**

| Recurso | Nombre | Descripción |
|---------|--------|-------------|
| VPC | `vpc-workshop` | VPC principal con CIDR 10.0.0.0/16 |
| Internet Gateway | `igw-workshop` | Conecta la VPC a internet |
| NAT Gateway | `nat-workshop` | Permite salida a internet desde subredes privadas |

> Recurso compartido - NO modificar. Solo el instructor crea estos recursos.

---

## Parte 1: Crear recursos compartidos (solo instructor)

> ⚠️ **Esta sección la ejecuta ÚNICAMENTE el instructor.** Los participantes deben observar el proceso y esperar a que el instructor confirme que los recursos están listos antes de continuar con la Parte 2.

1. Verifique que está trabajando en la región correcta:
   - En la esquina superior derecha de la consola de AWS
   - Confirme que dice la región estipulada por el instructor
   - Si no es correcta, haga clic y seleccione la región indicada

2. Utilice la barra de búsqueda global (parte superior) y escriba **VPC**. Haga clic en el servicio **VPC**.

### 1.1 Crear la VPC

Una VPC (Virtual Private Cloud) es una red virtual aislada dentro de AWS donde se desplegarán todos los recursos del workshop.

1. En el panel de navegación de la izquierda, haga clic en **Sus VPCs**.

2. Haga clic en el botón naranja **Crear VPC**.

3. Configure los siguientes parámetros:
   - **Recursos a crear**: Solo la VPC
   - **Etiqueta de nombre**: `vpc-workshop`
   - **Bloque de CIDR IPv4**: Entrada manual de CIDR IPv4
   - **CIDR IPv4**: `10.0.0.0/16`
   - **Bloque de CIDR IPv6**: Ningún bloque de CIDR IPv6
   - **Tenencia**: Predeterminada

4. Haga clic en **Crear VPC**.

**✓ Verificación**: La VPC `vpc-workshop` aparece en la lista con:
- Estado **Disponible**
- Bloque CIDR IPv4 `10.0.0.0/16`

5. Seleccione la VPC `vpc-workshop`.

6. Haga clic en **Acciones → Editar la configuración de la VPC**.

7. En la sección **Configuración de DNS**, marque las casillas:
   - **Habilitar nombres de host de DNS**
   - **Habilitar resolución de DNS** (debería estar habilitada por defecto)

8. Haga clic en **Guardar**.

> Habilitar los nombres de host DNS permite que las instancias EC2 dentro de la VPC reciban nombres DNS públicos cuando se les asigna una IP pública.

### 1.2 Crear y asociar el Internet Gateway

Un Internet Gateway permite la comunicación entre los recursos de la VPC y el internet.

1. En el panel de navegación de la izquierda, haga clic en **Gateways de Internet**.

2. Haga clic en **Crear gateway de Internet**.

3. Configure los siguientes parámetros:
   - **Etiqueta de nombre**: `igw-workshop`

4. Haga clic en **Crear gateway de Internet**.

5. En la página del gateway recién creado, haga clic en **Acciones → Asociar a VPC**.

6. Seleccione `vpc-workshop` y haga clic en **Asociar gateway de Internet**.

**✓ Verificación**: El Internet Gateway `igw-workshop` muestra:
- Estado **Attached**
- Asociado a `vpc-workshop`

### 1.3 Crear subred para el NAT Gateway

El NAT Gateway requiere estar ubicado en una subred pública. El instructor creará una subred dedicada para este propósito.

1. En el panel de navegación de la izquierda, haga clic en **Subredes**.

2. Haga clic en **Crear subred**.

3. Configure los siguientes parámetros:
   - **ID de VPC**: Seleccione `vpc-workshop`
   - **Nombre de la subred**: `subnet-nat-workshop`
   - **Zona de disponibilidad**: Seleccione la primera zona disponible
   - **Bloque de CIDR IPv4 de la subred**: `10.0.0.0/24`

4. Haga clic en **Crear subred**.

5. Seleccione la subred `subnet-nat-workshop`.

6. Haga clic en **Acciones → Editar la configuración de la subred**.

7. Marque la casilla **Habilitar la asignación automática de la dirección IPv4 pública**.

8. Haga clic en **Guardar**.

### 1.4 Crear tabla de enrutamiento para la subred del NAT Gateway

1. En el panel de navegación de la izquierda, haga clic en **Tablas de enrutamiento**.

2. Haga clic en **Crear tabla de enrutamiento**.

3. Configure los siguientes parámetros:
   - **Nombre**: `rt-nat-workshop`
   - **VPC**: Seleccione `vpc-workshop`

4. Haga clic en **Crear tabla de enrutamiento**.

5. En la tabla recién creada, haga clic en la pestaña **Rutas**.

6. Haga clic en **Editar rutas → Agregar ruta**.

7. Configure la nueva ruta:
   - **Destino**: `0.0.0.0/0`
   - **Objetivo**: Internet Gateway → seleccione `igw-workshop`

8. Haga clic en **Guardar cambios**.

9. Haga clic en la pestaña **Asociaciones de subred**.

10. Haga clic en **Editar asociaciones de subred**.

11. Seleccione `subnet-nat-workshop` y haga clic en **Guardar asociaciones**.

### 1.5 Crear el NAT Gateway

Un NAT Gateway permite que las instancias en subredes privadas accedan a internet (para actualizaciones, descargas, etc.) sin ser accesibles desde internet.

1. En el panel de navegación de la izquierda, haga clic en **Gateways NAT**.

2. Haga clic en **Crear gateway NAT**.

3. Configure los siguientes parámetros:
   - **Nombre**: `nat-workshop`
   - **Subred**: Seleccione `subnet-nat-workshop`
   - **Tipo de conectividad**: Público
   - **Dirección IP elástica**: Haga clic en **Asignar IP elástica** (se asignará automáticamente)

4. Haga clic en **Crear gateway NAT**.

⏱️ **Nota**: El NAT Gateway puede tardar 2-5 minutos en cambiar a estado **Disponible**.

**✓ Verificación**: El NAT Gateway `nat-workshop` muestra:
- Estado **Disponible**
- Ubicado en `subnet-nat-workshop`
- Una Elastic IP asignada

> ⚠️ El NAT Gateway genera costos por hora y por GB de datos procesados. El instructor se encargará de eliminarlo al finalizar el workshop.

---

### Verificación por parte de los participantes

Una vez que el instructor confirme que los recursos compartidos están listos, cada participante debe verificar lo siguiente:

1. En el panel de navegación de la izquierda, haga clic en **Sus VPCs**.

2. Verifique que existe la VPC `vpc-workshop` con CIDR `10.0.0.0/16`.

3. En el panel de navegación de la izquierda, haga clic en **Gateways de Internet**.

4. Verifique que existe `igw-workshop` y que su estado es **Attached** (asociado a `vpc-workshop`).

5. En el panel de navegación de la izquierda, haga clic en **Gateways NAT**.

6. Verifique que existe `nat-workshop` y que su estado es **Disponible**.

**✓ Verificación**: Los tres recursos compartidos existen y están operativos. Si alguno no aparece, notifique al instructor antes de continuar.

---

## Parte 2: Crear subredes

Cada participante creará dos subredes dentro de la VPC compartida: una pública y una privada.

> El instructor le asignará un rango CIDR único. Reemplace `X` e `Y` con los valores que le correspondan.

### 2.1 Crear subred pública

1. En el panel de navegación de la izquierda, haga clic en **Subredes**.

2. Haga clic en el botón naranja **Crear subred**.

3. Configure los siguientes parámetros:
   - **ID de VPC**: Seleccione `vpc-workshop`
   - **Nombre de la subred**: `subnet-publica-{nombre-participante}`
   - **Zona de disponibilidad**: Seleccione la primera zona disponible (ej: us-east-1a)
   - **Bloque de CIDR IPv4 de la subred**: `10.0.X.0/24` (use el valor asignado por el instructor)

4. Haga clic en **Crear subred**.

5. Seleccione la subred recién creada `subnet-publica-{nombre-participante}`.

6. Haga clic en **Acciones → Editar la configuración de la subred**.

7. Marque la casilla **Habilitar la asignación automática de la dirección IPv4 pública**.

8. Haga clic en **Guardar**.

**✓ Verificación**: La subred pública aparece en la lista con:
- Estado **Disponible**
- CIDR `10.0.X.0/24`
- Asignación automática de IP pública habilitada

### 2.2 Crear subred privada

1. Haga clic en **Crear subred** nuevamente.

2. Configure los siguientes parámetros:
   - **ID de VPC**: Seleccione `vpc-workshop`
   - **Nombre de la subred**: `subnet-privada-{nombre-participante}`
   - **Zona de disponibilidad**: Seleccione la misma zona que la subred pública
   - **Bloque de CIDR IPv4 de la subred**: `10.0.Y.0/24` (use el valor asignado por el instructor)

3. Haga clic en **Crear subred**.

**✓ Verificación**: La subred privada aparece en la lista con:
- Estado **Disponible**
- CIDR `10.0.Y.0/24`
- Asignación automática de IP pública **deshabilitada** (por defecto)

---

## Parte 3: Crear tablas de enrutamiento

Creará dos tablas de enrutamiento: una para la subred pública (con ruta al Internet Gateway) y otra para la subred privada (con ruta al NAT Gateway).

### 3.1 Crear tabla de enrutamiento pública

1. En el panel de navegación de la izquierda, haga clic en **Tablas de enrutamiento**.

2. Haga clic en **Crear tabla de enrutamiento**.

3. Configure los siguientes parámetros:
   - **Nombre**: `rt-publica-{nombre-participante}`
   - **VPC**: Seleccione `vpc-workshop`

4. Haga clic en **Crear tabla de enrutamiento**.

5. En la tabla recién creada, haga clic en la pestaña **Rutas**.

6. Haga clic en **Editar rutas → Agregar ruta**.

7. Configure la nueva ruta:
   - **Destino**: `0.0.0.0/0`
   - **Objetivo**: Internet Gateway → seleccione `igw-workshop`

8. Haga clic en **Guardar cambios**.

9. Haga clic en la pestaña **Asociaciones de subred**.

10. Haga clic en **Editar asociaciones de subred**.

11. Seleccione `subnet-publica-{nombre-participante}` y haga clic en **Guardar asociaciones**.

**✓ Verificación**: La tabla de enrutamiento pública muestra:
- Ruta `10.0.0.0/16` → local
- Ruta `0.0.0.0/0` → `igw-workshop`
- Asociada a `subnet-publica-{nombre-participante}`

### 3.2 Crear tabla de enrutamiento privada

1. Haga clic en **Crear tabla de enrutamiento**.

2. Configure los siguientes parámetros:
   - **Nombre**: `rt-privada-{nombre-participante}`
   - **VPC**: Seleccione `vpc-workshop`

3. Haga clic en **Crear tabla de enrutamiento**.

4. En la tabla recién creada, haga clic en la pestaña **Rutas**.

5. Haga clic en **Editar rutas → Agregar ruta**.

6. Configure la nueva ruta:
   - **Destino**: `0.0.0.0/0`
   - **Objetivo**: NAT Gateway → seleccione `nat-workshop`

7. Haga clic en **Guardar cambios**.

8. Haga clic en la pestaña **Asociaciones de subred**.

9. Haga clic en **Editar asociaciones de subred**.

10. Seleccione `subnet-privada-{nombre-participante}` y haga clic en **Guardar asociaciones**.

**✓ Verificación**: La tabla de enrutamiento privada muestra:
- Ruta `10.0.0.0/16` → local
- Ruta `0.0.0.0/0` → `nat-workshop`
- Asociada a `subnet-privada-{nombre-participante}`

---

## Parte 4: Crear Security Group

Creará un Security Group que permita tráfico SSH y HTTP para las instancias EC2, y tráfico ICMP para pruebas de conectividad.

1. En el panel de navegación de la izquierda, haga clic en **Grupos de seguridad**.

2. Haga clic en **Crear grupo de seguridad**.

3. Configure los siguientes parámetros:
   - **Nombre del grupo de seguridad**: `sg-lab2-{nombre-participante}`
   - **Descripción**: `Security Group para Lab 2 VPC Networking`
   - **VPC**: Seleccione `vpc-workshop`

4. En **Reglas de entrada**, agregue las siguientes reglas haciendo clic en **Agregar regla** para cada una:

   | Tipo | Puerto | Origen | Descripción |
   |------|--------|--------|-------------|
   | SSH | 22 | Mi IP | Acceso SSH desde mi IP |
   | HTTP | 80 | 0.0.0.0/0 | Acceso web desde cualquier lugar |
   | Todo el tráfico ICMP - IPv4 | Todos | 10.0.0.0/16 | Ping dentro de la VPC |

5. Haga clic en **Crear grupo de seguridad**.

**✓ Verificación**: El Security Group `sg-lab2-{nombre-participante}` muestra:
- 3 reglas de entrada configuradas
- Reglas de salida: todo el tráfico permitido (por defecto)

> Un Security Group actúa como un firewall virtual a nivel de instancia. Es stateful, lo que significa que si permite tráfico de entrada, la respuesta de salida se permite automáticamente.

---

## Parte 5: Crear Network ACL personalizada

Las NACLs (Network Access Control Lists) son una capa adicional de seguridad a nivel de subred. A diferencia de los Security Groups, las NACLs son stateless y requieren reglas explícitas tanto de entrada como de salida.

### 5.1 Crear NACL para la subred pública

1. En el panel de navegación de la izquierda, haga clic en **ACL de red**.

2. Haga clic en **Crear ACL de red**.

3. Configure los siguientes parámetros:
   - **Nombre**: `nacl-publica-{nombre-participante}`
   - **VPC**: Seleccione `vpc-workshop`

4. Haga clic en **Crear ACL de red**.

> Por defecto, una NACL nueva deniega todo el tráfico. Debe agregar reglas explícitas para permitir el tráfico deseado.

5. Seleccione la NACL recién creada y haga clic en la pestaña **Reglas de entrada**.

6. Haga clic en **Editar reglas de entrada** y agregue las siguientes reglas:

   | Regla # | Tipo | Protocolo | Rango de puertos | Origen | Permitir/Denegar |
   |---------|------|-----------|------------------|--------|------------------|
   | 100 | HTTP (80) | TCP | 80 | 0.0.0.0/0 | Permitir |
   | 110 | SSH (22) | TCP | 22 | 0.0.0.0/0 | Permitir |
   | 120 | Regla TCP personalizada | TCP | 1024-65535 | 0.0.0.0/0 | Permitir |
   | 130 | Todo el ICMP - IPv4 | ICMP | Todos | 10.0.0.0/16 | Permitir |

7. Haga clic en **Guardar cambios**.

8. Haga clic en la pestaña **Reglas de salida**.

9. Haga clic en **Editar reglas de salida** y agregue las siguientes reglas:

   | Regla # | Tipo | Protocolo | Rango de puertos | Destino | Permitir/Denegar |
   |---------|------|-----------|------------------|---------|------------------|
   | 100 | HTTP (80) | TCP | 80 | 0.0.0.0/0 | Permitir |
   | 110 | HTTPS (443) | TCP | 443 | 0.0.0.0/0 | Permitir |
   | 120 | Regla TCP personalizada | TCP | 1024-65535 | 0.0.0.0/0 | Permitir |
   | 130 | Todo el ICMP - IPv4 | ICMP | Todos | 10.0.0.0/16 | Permitir |

10. Haga clic en **Guardar cambios**.

11. Haga clic en la pestaña **Asociaciones de subred**.

12. Haga clic en **Editar asociaciones de subred**.

13. Seleccione `subnet-publica-{nombre-participante}` y haga clic en **Guardar cambios**.

**✓ Verificación**: La NACL `nacl-publica-{nombre-participante}` muestra:
- 4 reglas de entrada (más la regla de denegación por defecto *)
- 4 reglas de salida (más la regla de denegación por defecto *)
- Asociada a `subnet-publica-{nombre-participante}`

> La regla 120 (puertos efímeros 1024-65535) es necesaria porque las NACLs son stateless. Cuando un cliente se conecta al puerto 80, la respuesta sale por un puerto efímero aleatorio. Sin esta regla, las respuestas serían bloqueadas.

---

## Parte 6: Lanzar instancias EC2 de prueba

Lanzará dos instancias EC2: una en la subred pública y otra en la subred privada, para verificar la conectividad.

### 6.1 Lanzar instancia en subred pública

1. Utilice la barra de búsqueda global y escriba **EC2**. Haga clic en el servicio **EC2**.

2. Haga clic en el botón naranja **Lanzar instancia**.

3. Configure los siguientes parámetros:
   - **Nombre**: `ec2-publica-{nombre-participante}`
   - **AMI**: Amazon Linux 2023
   - **Tipo de instancia**: t2.micro
   - **Par de claves**: Seleccione o cree un par de claves

4. En **Configuraciones de red**, haga clic en **Editar**:
   - **VPC**: Seleccione `vpc-workshop`
   - **Subred**: Seleccione `subnet-publica-{nombre-participante}`
   - **Asignar automáticamente la IP pública**: Habilitar
   - **Firewall (grupos de seguridad)**: Seleccionar un grupo de seguridad existente → `sg-lab2-{nombre-participante}`

5. Haga clic en **Lanzar instancia**.

### 6.2 Lanzar instancia en subred privada

1. Haga clic en **Lanzar instancia** nuevamente.

2. Configure los siguientes parámetros:
   - **Nombre**: `ec2-privada-{nombre-participante}`
   - **AMI**: Amazon Linux 2023
   - **Tipo de instancia**: t2.micro
   - **Par de claves**: Seleccione el mismo par de claves

3. En **Configuraciones de red**, haga clic en **Editar**:
   - **VPC**: Seleccione `vpc-workshop`
   - **Subred**: Seleccione `subnet-privada-{nombre-participante}`
   - **Asignar automáticamente la IP pública**: Deshabilitar
   - **Firewall (grupos de seguridad)**: Seleccionar un grupo de seguridad existente → `sg-lab2-{nombre-participante}`

4. Haga clic en **Lanzar instancia**.

⏱️ **Nota**: Espere 1-2 minutos a que ambas instancias estén en estado **En ejecución**.

**✓ Verificación**: En la lista de instancias, confirme que:
- `ec2-publica-{nombre-participante}` tiene estado **En ejecución** y una IP pública asignada
- `ec2-privada-{nombre-participante}` tiene estado **En ejecución** y **no** tiene IP pública

---

## Parte 7: Verificar conectividad

### 7.1 Conectarse a la instancia pública

1. Seleccione la instancia `ec2-publica-{nombre-participante}`.

2. Haga clic en **Conectar**.

3. Seleccione la pestaña **EC2 Instance Connect** y haga clic en **Conectar**.

4. En la terminal, ejecute el siguiente comando para verificar la conectividad a internet:

   ```bash
   ping -c 4 google.com
   ```

**✓ Verificación**: Debe recibir respuestas exitosas del ping, confirmando que la subred pública tiene acceso a internet a través del Internet Gateway.

### 7.2 Verificar conectividad entre subredes

1. Desde la terminal de la instancia pública, haga ping a la IP privada de la instancia privada:

   ```bash
   ping -c 4 <IP-PRIVADA-DE-EC2-PRIVADA>
   ```

   > Puede encontrar la IP privada de la instancia en la consola de EC2, en la columna **IPv4 privada**.

**✓ Verificación**: Debe recibir respuestas exitosas del ping, confirmando la comunicación entre subredes dentro de la VPC.

### 7.3 Verificar salida a internet desde subred privada (a través de NAT Gateway)

Para verificar que la instancia privada puede acceder a internet a través del NAT Gateway, usaremos la instancia pública como bastión (jump host).

1. Desde su computadora local, copie su clave privada (.pem) a la instancia pública:

   ```bash
   scp -i su-clave.pem su-clave.pem ec2-user@<IP-PUBLICA-EC2>:/home/ec2-user/
   ```

2. Conéctese por SSH a la instancia pública:

   ```bash
   ssh -i su-clave.pem ec2-user@<IP-PUBLICA-EC2>
   ```

3. Desde la instancia pública, conéctese a la instancia privada:

   ```bash
   chmod 400 su-clave.pem
   ssh -i su-clave.pem ec2-user@<IP-PRIVADA-EC2>
   ```

4. Desde la instancia privada, verifique la salida a internet:

   ```bash
   ping -c 4 google.com
   ```

**✓ Verificación**: Debe recibir respuestas exitosas del ping desde la instancia privada, confirmando que el NAT Gateway permite tráfico de salida a internet.

> La instancia privada puede iniciar conexiones hacia internet (a través del NAT Gateway), pero no puede recibir conexiones entrantes desde internet. Esta es la diferencia clave entre una subred pública y una privada.

---

## Parte 8: Asignar Elastic IP

Una Elastic IP es una dirección IPv4 estática que puede asociar a una instancia EC2. A diferencia de la IP pública automática, una Elastic IP persiste aunque la instancia se detenga y reinicie.

1. Utilice la barra de búsqueda global y escriba **EC2**. Haga clic en el servicio **EC2**.

2. En el panel de navegación de la izquierda, en la sección **Red y seguridad**, haga clic en **Direcciones IP elásticas**.

3. Haga clic en **Asignar la dirección IP elástica**.

4. Configure los siguientes parámetros:
   - **Grupo de borde de red**: Dejar por defecto
   - **Etiquetas**: Agregue una etiqueta con Clave `Name` y Valor `eip-{nombre-participante}`

5. Haga clic en **Asignar**.

6. Seleccione la Elastic IP recién creada.

7. Haga clic en **Acciones → Asociar la dirección IP elástica**.

8. Configure la asociación:
   - **Tipo de recurso**: Instancia
   - **Instancia**: Seleccione `ec2-publica-{nombre-participante}`

9. Haga clic en **Asociar**.

**✓ Verificación**: En la lista de instancias EC2:
- `ec2-publica-{nombre-participante}` ahora muestra la Elastic IP como su dirección IPv4 pública
- La IP pública anterior fue reemplazada por la Elastic IP

> Anote la Elastic IP asignada. Esta dirección no cambiará aunque detenga y reinicie la instancia, a diferencia de la IP pública automática.

---

## Limpieza de recursos

Para evitar costos innecesarios, elimine los recursos en el siguiente orden:

### 1. Liberar Elastic IP
1. Ir a **EC2 → Direcciones IP elásticas**.
2. Seleccione `eip-{nombre-participante}`.
3. **Acciones → Desasociar la dirección IP elástica** → Confirmar.
4. **Acciones → Liberar la dirección IP elástica** → Confirmar.

> ⚠️ Las Elastic IPs no asociadas a una instancia en ejecución generan costos. Siempre libérelas si no las necesita.

### 2. Terminar instancias EC2
1. Ir a **EC2 → Instancias**.
2. Seleccione `ec2-publica-{nombre-participante}` y `ec2-privada-{nombre-participante}`.
3. **Estado de la instancia → Terminar instancia** → Confirmar.

### 3. Eliminar Security Group
1. Espere a que las instancias estén en estado **Terminada**.
2. Ir a **VPC → Grupos de seguridad**.
3. Seleccione `sg-lab2-{nombre-participante}`.
4. **Acciones → Eliminar grupos de seguridad** → Confirmar.

### 4. Eliminar NACL
1. Ir a **VPC → ACL de red**.
2. Seleccione `nacl-publica-{nombre-participante}`.
3. **Acciones → Eliminar** → Confirmar.

### 5. Eliminar tablas de enrutamiento
1. Ir a **VPC → Tablas de enrutamiento**.
2. Seleccione `rt-publica-{nombre-participante}`.
3. **Acciones → Eliminar tabla de enrutamiento** → Confirmar.
4. Repita para `rt-privada-{nombre-participante}`.

### 6. Eliminar subredes
1. Ir a **VPC → Subredes**.
2. Seleccione `subnet-publica-{nombre-participante}`.
3. **Acciones → Eliminar subred** → Confirmar.
4. Repita para `subnet-privada-{nombre-participante}`.

> ⚠️ **NO elimine** la VPC `vpc-workshop`, el Internet Gateway `igw-workshop` ni el NAT Gateway `nat-workshop`. Son recursos compartidos del instructor.

---

## Solución de problemas

Si encuentra dificultades durante este laboratorio, revise los siguientes errores comunes:

### El ping a internet falla desde la instancia pública

**Causas posibles:**
1. La tabla de enrutamiento pública no tiene la ruta `0.0.0.0/0` → Internet Gateway
2. La NACL está bloqueando el tráfico ICMP
3. El Security Group no permite tráfico ICMP de salida (verifique las reglas de salida)

**Solución:** Verifique la tabla de enrutamiento asociada a la subred pública y las reglas de la NACL.

### No hay comunicación entre subredes

**Causas posibles:**
1. El Security Group no permite tráfico ICMP desde el CIDR de la VPC (10.0.0.0/16)
2. La NACL no permite tráfico ICMP entre subredes

**Solución:** Verifique que la regla ICMP en el Security Group tiene como origen `10.0.0.0/16`.

### La instancia privada no tiene salida a internet

**Causas posibles:**
1. La tabla de enrutamiento privada no tiene la ruta `0.0.0.0/0` → NAT Gateway
2. El NAT Gateway no está operativo

**Solución:** Verifique la tabla de enrutamiento asociada a la subred privada y el estado del NAT Gateway.

### Error al crear subred: CIDR en conflicto

**Causa:** Otro participante ya está usando ese rango CIDR.

**Solución:** Consulte con el instructor para obtener un rango CIDR diferente.

**Errores que requieren asistencia del instructor:**
- Errores de permisos IAM
- Errores de límites de cuota de AWS
- El NAT Gateway o Internet Gateway no aparecen en la consola

> ⚠️ Si recibe un error de permisos, notifique al instructor de inmediato. No intente solucionar este error por su cuenta.