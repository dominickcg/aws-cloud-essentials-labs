# 🧹 Limpieza de Recursos - Laboratorio 2 (Opcional)

> ⚠️ **Nota importante**: Esta limpieza es opcional. Solo realícela si no continuará con laboratorios posteriores del programa AWS Cloud Essentials.

## ¿Cuándo realizar esta limpieza?

Realice esta limpieza únicamente si:
- Ha completado el Laboratorio 2 y no planea continuar con los laboratorios siguientes
- Desea eliminar los recursos para evitar costos innecesarios en su cuenta AWS
- El instructor ha indicado que puede proceder con la limpieza

⚠️ **No realice esta limpieza si planea continuar con otros laboratorios**, ya que algunos recursos pueden ser reutilizados.

---

## Recursos a Eliminar

Los recursos deben eliminarse en el siguiente orden para respetar las dependencias:

1. Instancias EC2 (pública y privada)
2. Elastic IP
3. Network ACL personalizada
4. Tablas de enrutamiento (pública y privada)
5. Subredes (pública y privada)
6. Security Group

⚠️ **CRÍTICO - NO elimine los siguientes recursos compartidos:**
- **VPC** (`vpc-lab2`) - Recurso compartido del instructor
- **NAT Gateway** (`nat-lab2`) - Recurso compartido del instructor
- **Internet Gateway** (`igw-lab2`) - Recurso compartido del instructor
- **Subred del NAT** (`subnet-nat-lab2`) - Recurso compartida del instructor
- **Tabla de enrutamiento del NAT** (`rt-nat-lab2`) - Recurso compartido del instructor

> El instructor se encargará de eliminar los recursos compartidos al finalizar el laboratorio.

---

## Pasos de Eliminación

### 1. Eliminar Instancias EC2

1. Utilice la barra de búsqueda global (parte superior) y escriba **EC2**. Haga clic en el servicio **EC2**.

2. En el panel de navegación de la izquierda, haga clic en **Instancias**.

3. Seleccione la instancia `ec2-publica-{nombre-participante}`.

4. Haga clic en **Estado de la instancia → Terminar instancia**.

5. Confirme haciendo clic en **Terminar**.

6. Repita los pasos 3-5 para la instancia `ec2-privada-{nombre-participante}`.

⏱️ **Nota**: Las instancias pueden tardar 1-2 minutos en terminar completamente.

**✓ Verificación**: Ambas instancias muestran el estado **Terminated** (terminada).

> ⚠️ Las instancias terminadas no se pueden recuperar. Asegúrese de no necesitar estos recursos antes de eliminarlos.

---

### 2. Liberar Elastic IP

> ⚠️ **Importante**: Las Elastic IPs no asociadas generan costos. Debe liberarlas después de eliminar las instancias.

1. En el panel de navegación de la izquierda, en la sección **Red y seguridad**, haga clic en **Direcciones IP elásticas**.

2. Seleccione la Elastic IP `eip-{nombre-participante}`.

3. Haga clic en **Acciones → Liberar direcciones IP elásticas**.

4. Confirme escribiendo **Liberar** en el cuadro de texto y haga clic en **Liberar**.

**✓ Verificación**: La Elastic IP ya no aparece en la lista.

> ⚠️ Una vez liberada, la dirección IP elástica no se puede recuperar.

---

### 3. Eliminar Network ACL Personalizada

1. Utilice la barra de búsqueda global y escriba **VPC**. Haga clic en el servicio **VPC**.

2. En el panel de navegación de la izquierda, haga clic en **ACL de red**.

3. Seleccione la NACL `nacl-publica-{nombre-participante}`.

4. Antes de eliminar, debe desasociarla de la subred:
   - Haga clic en la pestaña **Asociaciones de subred**
   - Haga clic en **Editar asociaciones de subred**
   - Deseleccione `subnet-publica-{nombre-participante}`
   - Haga clic en **Guardar cambios**

5. Ahora haga clic en **Acciones → Eliminar ACL de red**.

6. Confirme escribiendo **delete** en el cuadro de texto y haga clic en **Eliminar**.

**✓ Verificación**: La NACL `nacl-publica-{nombre-participante}` ya no aparece en la lista.

---

### 4. Eliminar Tablas de Enrutamiento

#### 4.1 Eliminar tabla de enrutamiento pública

1. En el panel de navegación de la izquierda, haga clic en **Tablas de enrutamiento**.

2. Seleccione la tabla `rt-publica-{nombre-participante}`.

3. Haga clic en **Acciones → Eliminar tabla de enrutamiento**.

4. Confirme escribiendo **delete** en el cuadro de texto y haga clic en **Eliminar**.

#### 4.2 Eliminar tabla de enrutamiento privada

1. Seleccione la tabla `rt-privada-{nombre-participante}`.

2. Haga clic en **Acciones → Eliminar tabla de enrutamiento**.

3. Confirme escribiendo **delete** en el cuadro de texto y haga clic en **Eliminar**.

**✓ Verificación**: Las tablas de enrutamiento `rt-publica-{nombre-participante}` y `rt-privada-{nombre-participante}` ya no aparecen en la lista.

> ⚠️ **NO elimine** la tabla de enrutamiento `rt-nat-lab2` - es un recurso compartido del instructor.

---

### 5. Eliminar Subredes

#### 5.1 Eliminar subred pública

1. En el panel de navegación de la izquierda, haga clic en **Subredes**.

2. Seleccione la subred `subnet-publica-{nombre-participante}`.

3. Haga clic en **Acciones → Eliminar subred**.

4. Confirme escribiendo **delete** en el cuadro de texto y haga clic en **Eliminar**.

#### 5.2 Eliminar subred privada

1. Seleccione la subred `subnet-privada-{nombre-participante}`.

2. Haga clic en **Acciones → Eliminar subred**.

3. Confirme escribiendo **delete** en el cuadro de texto y haga clic en **Eliminar**.

**✓ Verificación**: Las subredes `subnet-publica-{nombre-participante}` y `subnet-privada-{nombre-participante}` ya no aparecen en la lista.

> ⚠️ **NO elimine** la subred `subnet-nat-lab2` - es un recurso compartido del instructor.

---

### 6. Eliminar Security Group

1. En el panel de navegación de la izquierda, haga clic en **Grupos de seguridad**.

2. Seleccione el Security Group `sg-lab2-{nombre-participante}`.

3. Haga clic en **Acciones → Eliminar grupos de seguridad**.

4. Confirme haciendo clic en **Eliminar**.

**✓ Verificación**: El Security Group `sg-lab2-{nombre-participante}` ya no aparece en la lista.

---

## Verificación Final

Después de completar todos los pasos, verifique que:

- ✓ No aparecen instancias EC2 con su nombre de participante (excepto las terminadas)
- ✓ No hay Elastic IPs asignadas con su nombre de participante
- ✓ No hay NACLs personalizadas con su nombre de participante
- ✓ No hay tablas de enrutamiento con su nombre de participante
- ✓ No hay subredes con su nombre de participante
- ✓ No hay Security Groups con su nombre de participante

**Los siguientes recursos compartidos DEBEN permanecer intactos:**
- ✓ VPC `vpc-lab2` existe
- ✓ Internet Gateway `igw-lab2` existe
- ✓ NAT Gateway `nat-lab2` existe
- ✓ Subred `subnet-nat-lab2` existe
- ✓ Tabla de enrutamiento `rt-nat-lab2` existe

---

## Recursos Compartidos - Responsabilidad del Instructor

El instructor eliminará los siguientes recursos compartidos al finalizar el laboratorio:

1. NAT Gateway (`nat-lab2`)
2. Elastic IP asociada al NAT Gateway
3. Tabla de enrutamiento del NAT (`rt-nat-lab2`)
4. Subred del NAT (`subnet-nat-lab2`)
5. Internet Gateway (`igw-lab2`)
6. VPC (`vpc-lab2`)

> ⚠️ **No intente eliminar estos recursos**. Si lo hace, afectará a todos los participantes del laboratorio.

---

## Costos Asociados

Los siguientes recursos generan costos mientras están activos:

- **Instancias EC2**: Costo por hora mientras están en ejecución
- **Elastic IP no asociada**: Costo por hora si no está asociada a una instancia en ejecución
- **NAT Gateway**: Costo por hora + costo por GB de datos procesados (responsabilidad del instructor)

Al eliminar los recursos siguiendo esta guía, dejará de incurrir en costos asociados a este laboratorio.
