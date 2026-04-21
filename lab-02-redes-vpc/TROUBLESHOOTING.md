# Guía de Solución de Problemas - Laboratorio 2

Esta guía contiene soluciones a errores comunes que pueden ocurrir durante la ejecución del Laboratorio 2: Networking con VPC, Subredes y Conectividad.

## Errores Comunes

### Error: No puedo crear subredes con el CIDR asignado

**Síntoma**: Al intentar crear una subred con el bloque CIDR asignado por el instructor, aparece un error indicando que el CIDR se superpone con otra subred o no es válido.

**Causas posibles**:
1. El bloque CIDR ya está en uso por otra subred en la VPC
2. El bloque CIDR no está dentro del rango de la VPC (10.0.0.0/16)
3. El formato del CIDR es incorrecto
4. Otro participante ya utilizó ese rango CIDR

**Solución**:
1. Verifique que el CIDR esté dentro del rango de la VPC `10.0.0.0/16`
2. Confirme con el instructor que está usando el rango CIDR correcto asignado a usted
3. En el panel de navegación de VPC, haga clic en **Subredes** y verifique qué rangos CIDR ya están en uso
4. Asegúrese de usar el formato correcto: `10.0.X.0/24` donde X es su número asignado
5. Si el problema persiste, notifique al instructor para que le asigne un nuevo rango CIDR

---

### Error: La instancia en la subred pública no tiene IP pública

**Síntoma**: La instancia EC2 lanzada en la subred pública no recibe una dirección IP pública automáticamente.

**Causas posibles**:
1. La subred no tiene habilitada la asignación automática de IP pública
2. Al lanzar la instancia, la opción "Asignar automáticamente la IP pública" estaba deshabilitada
3. La configuración de red de la instancia no está correcta

**Solución**:
1. Verifique la configuración de la subred:
   - En el panel de VPC, haga clic en **Subredes**
   - Seleccione `subnet-publica-{nombre-participante}`
   - Verifique que **Asignación automática de IP pública** esté habilitada
   - Si no está habilitada, haga clic en **Acciones → Editar la configuración de la subred** y márquela
2. Si la subred está configurada correctamente pero la instancia no tiene IP pública:
   - Termine la instancia actual
   - Lance una nueva instancia asegurándose de habilitar "Asignar automáticamente la IP pública" en la configuración de red
3. Alternativamente, asigne una Elastic IP a la instancia (ver Parte 9 del laboratorio)

---

### Error: No puedo hacer ping desde la instancia pública a internet

**Síntoma**: Al ejecutar `ping google.com` desde la instancia en la subred pública, no hay respuesta o aparece "Network unreachable".

**Causas posibles**:
1. La tabla de enrutamiento de la subred pública no tiene una ruta al Internet Gateway
2. El Internet Gateway no está asociado a la VPC
3. La NACL de la subred pública está bloqueando el tráfico ICMP
4. El Security Group está bloqueando el tráfico de salida

**Solución**:
1. Verifique la tabla de enrutamiento:
   - En el panel de VPC, haga clic en **Tablas de enrutamiento**
   - Seleccione `rt-publica-{nombre-participante}`
   - En la pestaña **Rutas**, verifique que existe una ruta `0.0.0.0/0` → `igw-workshop`
   - Si no existe, agregue la ruta siguiendo las instrucciones de la Parte 4.1
2. Verifique que la tabla de enrutamiento está asociada a la subred correcta:
   - En la pestaña **Asociaciones de subred**, confirme que `subnet-publica-{nombre-participante}` está asociada
3. Verifique el Internet Gateway:
   - En el panel de VPC, haga clic en **Gateways de Internet**
   - Confirme que `igw-lab2` tiene estado **Attached** a `vpc-lab2`
4. Verifique la NACL (si creó una personalizada):
   - Asegúrese de que las reglas de salida permiten tráfico ICMP
   - Asegúrese de que las reglas de entrada permiten respuestas (puertos efímeros 1024-65535)

---

### Error: No puedo hacer ping desde la instancia privada a internet

**Síntoma**: Al ejecutar `ping google.com` desde la instancia en la subred privada, no hay respuesta o aparece "Network unreachable".

**Causas posibles**:
1. La tabla de enrutamiento de la subred privada no tiene una ruta al NAT Gateway
2. El NAT Gateway no está en estado "Disponible"
3. El NAT Gateway no tiene una Elastic IP asignada
4. La tabla de enrutamiento del NAT Gateway no tiene ruta al Internet Gateway

**Solución**:
1. Verifique la tabla de enrutamiento privada:
   - En el panel de VPC, haga clic en **Tablas de enrutamiento**
   - Seleccione `rt-privada-{nombre-participante}`
   - En la pestaña **Rutas**, verifique que existe una ruta `0.0.0.0/0` → `nat-lab2`
   - Si no existe, agregue la ruta siguiendo las instrucciones de la Parte 4.2
2. Verifique el estado del NAT Gateway:
   - En el panel de VPC, haga clic en **Gateways NAT**
   - Confirme que `nat-lab2` tiene estado **Disponible**
   - Verifique que tiene una Elastic IP asignada
   - Si el estado es "Pending", espere 2-5 minutos
3. Verifique que la tabla de enrutamiento está asociada a la subred correcta:
   - En `rt-privada-{nombre-participante}`, pestaña **Asociaciones de subred**
   - Confirme que `subnet-privada-{nombre-participante}` está asociada
4. Si el problema persiste, notifique al instructor para verificar la configuración del NAT Gateway

---

### Error: No puedo conectarme por SSH a la instancia pública

**Síntoma**: Al intentar conectar por SSH a la instancia en la subred pública, aparece un error de timeout o "Connection refused".

**Causas posibles**:
1. El Security Group no permite tráfico SSH (puerto 22)
2. La NACL está bloqueando el tráfico SSH
3. La instancia no tiene IP pública
4. Su dirección IP cambió y ya no está permitida en el Security Group
5. El par de claves no es correcto

**Solución**:
1. Verifique el Security Group:
   - En el panel de EC2, haga clic en **Grupos de seguridad**
   - Seleccione `sg-lab2-{nombre-participante}`
   - En la pestaña **Reglas de entrada**, confirme que existe una regla para SSH (puerto 22)
   - Verifique que el origen incluye su IP actual (puede usar "Mi IP" para actualizarla)
2. Verifique la NACL (si creó una personalizada):
   - En el panel de VPC, haga clic en **ACL de red**
   - Seleccione `nacl-publica-{nombre-participante}`
   - Verifique que las reglas de entrada permiten SSH (puerto 22)
   - Verifique que las reglas de salida permiten puertos efímeros (1024-65535)
3. Confirme que la instancia tiene una IP pública asignada
4. Intente usar EC2 Instance Connect desde la consola como alternativa
5. Verifique que está usando el par de claves correcto y el usuario `ec2-user`

---

### Error: No puedo hacer ping entre la instancia pública y la privada

**Síntoma**: Al intentar hacer ping desde la instancia pública a la instancia privada (o viceversa), no hay respuesta.

**Causas posibles**:
1. El Security Group no permite tráfico ICMP
2. Las NACLs están bloqueando el tráfico ICMP entre subredes
3. Las instancias están en VPCs diferentes (poco probable en este lab)
4. La IP privada utilizada es incorrecta

**Solución**:
1. Verifique el Security Group:
   - En el panel de EC2, haga clic en **Grupos de seguridad**
   - Seleccione `sg-lab2-{nombre-participante}`
   - En la pestaña **Reglas de entrada**, confirme que existe una regla para "Todo el tráfico ICMP - IPv4" con origen `10.0.0.0/16`
   - Si no existe, agregue la regla
2. Verifique las NACLs:
   - Asegúrese de que las reglas de entrada y salida permiten tráfico ICMP desde/hacia `10.0.0.0/16`
3. Confirme que está usando la IP privada correcta:
   - En la consola de EC2, seleccione la instancia destino
   - Copie la dirección que aparece en la columna **IPv4 privada**
4. Verifique que ambas instancias están en la misma VPC (`vpc-lab2`)

---

### Error: La NACL no permite el tráfico esperado

**Síntoma**: Después de configurar la NACL, el tráfico que debería estar permitido está siendo bloqueado.

**Causas posibles**:
1. Las reglas de la NACL están en el orden incorrecto (las reglas se evalúan en orden numérico)
2. Falta configurar las reglas de salida (las NACLs son stateless)
3. No se incluyeron los puertos efímeros (1024-65535) en las reglas
4. La NACL no está asociada a la subred correcta

**Solución**:
1. Verifique el orden de las reglas:
   - Las reglas se evalúan en orden numérico ascendente
   - La primera regla que coincide se aplica
   - Use números como 100, 110, 120 para dejar espacio para reglas futuras
2. Configure reglas de entrada Y salida:
   - A diferencia de los Security Groups, las NACLs requieren reglas explícitas en ambas direcciones
   - Para cada regla de entrada, considere si necesita una regla de salida correspondiente
3. Incluya puertos efímeros en las reglas:
   - Agregue una regla que permita TCP 1024-65535 tanto en entrada como en salida
   - Esto es necesario para las respuestas de conexiones iniciadas
4. Verifique la asociación de subred:
   - En la pestaña **Asociaciones de subred** de la NACL
   - Confirme que está asociada a la subred correcta
5. Si tiene dudas, puede asociar temporalmente la NACL predeterminada (que permite todo el tráfico) para verificar si el problema es la NACL

---

### Error: La tabla de enrutamiento no muestra el objetivo esperado

**Síntoma**: Al intentar agregar una ruta a la tabla de enrutamiento, el Internet Gateway o NAT Gateway no aparece en la lista de objetivos.

**Causas posibles**:
1. El Internet Gateway no está asociado a la VPC
2. El NAT Gateway no está en estado "Disponible"
3. Está intentando agregar un NAT Gateway a una tabla de enrutamiento de una VPC diferente
4. El recurso fue eliminado accidentalmente

**Solución**:
1. Verifique el Internet Gateway:
   - En el panel de VPC, haga clic en **Gateways de Internet**
   - Confirme que `igw-lab2` existe y tiene estado **Attached**
   - Si no está asociado, selecciónelo y haga clic en **Acciones → Asociar a VPC**
2. Verifique el NAT Gateway:
   - En el panel de VPC, haga clic en **Gateways NAT**
   - Confirme que `nat-lab2` existe y tiene estado **Disponible**
   - Si está en estado "Pending", espere unos minutos
   - Si está en estado "Failed", notifique al instructor
3. Verifique que la tabla de enrutamiento pertenece a la VPC correcta:
   - Seleccione la tabla de enrutamiento
   - En los detalles, confirme que la VPC es `vpc-lab2`
4. Si el recurso no aparece, notifique al instructor inmediatamente

---

### Error: No puedo asociar la Elastic IP a la instancia

**Síntoma**: Al intentar asociar una Elastic IP a la instancia EC2, aparece un error o la opción no está disponible.

**Causas posibles**:
1. La Elastic IP ya está asociada a otra instancia
2. La instancia está detenida (no en estado "En ejecución")
3. No tiene permisos para asociar Elastic IPs
4. La instancia no tiene una interfaz de red válida

**Solución**:
1. Verifique el estado de la Elastic IP:
   - En el panel de EC2, haga clic en **Direcciones IP elásticas**
   - Si la Elastic IP ya está asociada, primero desasóciela
   - Seleccione la Elastic IP y haga clic en **Acciones → Desasociar la dirección IP elástica**
2. Verifique el estado de la instancia:
   - La instancia debe estar en estado **En ejecución**
   - Si está detenida, iníciela antes de asociar la Elastic IP
3. Intente asociar nuevamente siguiendo las instrucciones de la Parte 9
4. Si el error persiste, notifique al instructor

---

### Error: Después de asociar la Elastic IP, perdí la conexión SSH

**Síntoma**: Después de asociar una Elastic IP a la instancia pública, la conexión SSH existente se pierde y no puedo reconectar.

**Causas posibles**:
1. Está intentando conectar usando la IP pública anterior (que ya no es válida)
2. El Security Group tiene configurada su IP anterior y necesita actualizarse
3. La sesión SSH anterior quedó abierta con la IP antigua

**Solución**:
1. Use la nueva Elastic IP para conectarse:
   - Copie la nueva dirección IP elástica de la consola de EC2
   - Use esta IP en su comando SSH: `ssh -i su-clave.pem ec2-user@<ELASTIC-IP>`
2. Actualice el Security Group si es necesario:
   - Si configuró "Mi IP" en el Security Group, actualice la regla con su IP actual
3. Cierre cualquier sesión SSH anterior y abra una nueva conexión
4. Si usa EC2 Instance Connect, actualice la página y conéctese nuevamente

---

### Error: No puedo conectarme a la instancia privada desde la instancia pública

**Síntoma**: Al intentar hacer SSH desde la instancia pública a la instancia privada, aparece "Permission denied" o "Connection refused".

**Causas posibles**:
1. La clave privada no está en la instancia pública
2. Los permisos de la clave privada son incorrectos
3. El Security Group no permite SSH desde la subred pública
4. Está usando la IP incorrecta (pública en lugar de privada)

**Solución**:
1. Copie la clave privada a la instancia pública:
   ```bash
   scp -i su-clave.pem su-clave.pem ec2-user@<IP-PUBLICA>:/home/ec2-user/
   ```
2. Desde la instancia pública, ajuste los permisos de la clave:
   ```bash
   chmod 400 su-clave.pem
   ```
3. Verifique el Security Group:
   - Confirme que permite SSH (puerto 22) desde `10.0.0.0/16` o desde la IP de la subred pública
4. Use la IP privada de la instancia privada (no la pública):
   ```bash
   ssh -i su-clave.pem ec2-user@<IP-PRIVADA>
   ```
5. Verifique que ambas instancias usan el mismo par de claves

---

## Errores que Requieren Asistencia del Instructor

Si encuentra alguno de los siguientes errores, **notifique al instructor inmediatamente**. No intente solucionar estos errores por su cuenta:

### Error de permisos IAM

**Síntoma**: Aparece un mensaje indicando que no tiene permisos para realizar una acción en VPC, EC2 o recursos de red (por ejemplo, "You are not authorized to perform this operation").

**Acción**: ⚠️ Notifique al instructor de inmediato. Este error requiere ajustes en las políticas IAM de su cuenta.

---

### Error de límites de cuota de AWS

**Síntoma**: Aparece un mensaje indicando que ha alcanzado el límite de recursos (por ejemplo, "VPC limit exceeded", "Elastic IP address limit exceeded", "Subnet limit exceeded").

**Acción**: ⚠️ Notifique al instructor de inmediato. Este error requiere solicitar un aumento de cuota o liberar recursos existentes.

---

### Error: No puedo ver los recursos compartidos (VPC, Internet Gateway, NAT Gateway)

**Síntoma**: Los recursos compartidos creados por el instructor (`vpc-lab2`, `igw-lab2`, `nat-lab2`) no aparecen en su consola.

**Acción**: ⚠️ Notifique al instructor de inmediato. Esto puede indicar que está en la región incorrecta o que hay un problema con los permisos de su cuenta.

---

### Error: El NAT Gateway está en estado "Failed"

**Síntoma**: El NAT Gateway `nat-lab2` muestra estado **Failed** en lugar de **Disponible**.

**Acción**: ⚠️ Notifique al instructor de inmediato. El NAT Gateway necesita ser recreado por el instructor.

---

### Error: "InsufficientInstanceCapacity" al lanzar instancias

**Síntoma**: Aparece un mensaje indicando "InsufficientInstanceCapacity" al intentar lanzar las instancias EC2.

**Acción**: ⚠️ Notifique al instructor de inmediato. Este error indica que AWS no tiene capacidad disponible para el tipo de instancia en esa zona de disponibilidad. El instructor puede sugerir usar una zona de disponibilidad diferente o un tipo de instancia alternativo.

---

### Error: No puedo eliminar recursos compartidos accidentalmente

**Síntoma**: Eliminó accidentalmente un recurso compartido (VPC, Internet Gateway, NAT Gateway) o no puede completar el laboratorio porque un recurso compartido fue eliminado.

**Acción**: ⚠️ Notifique al instructor de inmediato. Los recursos compartidos deben ser recreados por el instructor para que todos los participantes puedan continuar.
