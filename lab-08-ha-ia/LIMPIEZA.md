# Limpieza de Recursos - Laboratorio 8

Esta guía le ayudará a eliminar todos los recursos creados durante el laboratorio del Portal del Ciudadano del Tribunal Constitucional.

---

## Método Principal: Eliminar la Pila de CloudFormation

La ventaja de usar Infraestructura como Código (IaC) con CloudFormation es que todos los recursos se pueden eliminar con una sola acción. CloudFormation eliminará automáticamente todos los recursos en el orden correcto.

### Pasos para Eliminar la Pila

1. Navegue a la consola de **AWS CloudFormation**:
   - Utilice la barra de búsqueda global en la parte superior
   - Escriba "CloudFormation" y seleccione el servicio

2. En el panel de navegación izquierdo, haga clic en **Pilas**

3. Localice su pila con el nombre `[Iniciales]-TC-Portal`

4. Seleccione la pila haciendo clic en el nombre

5. En la esquina superior derecha, haga clic en el botón **Eliminar**

6. En el cuadro de diálogo de confirmación, haga clic en **Eliminar pila**

⚠️ **Advertencia Importante**: Al eliminar la pila de CloudFormation, se eliminarán PERMANENTEMENTE todos los recursos, incluyendo:
- Todas las instancias EC2 del Auto Scaling Group
- El Application Load Balancer
- La Web ACL de AWS WAF y sus reglas asociadas
- La base de datos RDS Multi-AZ (incluyendo todos los datos almacenados)
- El secreto de AWS Secrets Manager con las credenciales de la base de datos
- Los temas SNS y colas SQS
- La función Lambda
- Todos los Security Groups, subnets y la VPC
- Los roles y políticas IAM creados

Esta acción NO se puede deshacer. Asegúrese de que no necesita conservar ningún dato antes de proceder.

⏱️ **Nota sobre el Tiempo de Eliminación**: El proceso de eliminación puede tardar entre 10 y 15 minutos en completarse, especialmente debido a la base de datos RDS Multi-AZ que requiere tiempo para eliminar las réplicas en ambas zonas de disponibilidad.

---

## Verificación de Limpieza

Después de iniciar la eliminación, siga estos pasos para confirmar que todos los recursos fueron eliminados correctamente:

### 1. Verificar el Estado de la Pila

1. Permanezca en la consola de CloudFormation
2. Seleccione la pestaña **Eventos** de su pila
3. Observe cómo CloudFormation elimina los recursos en orden inverso a su creación
4. Refresque la vista periódicamente hasta que el estado de la pila cambie a `DELETE_COMPLETE`

**✓ Verificación**: Confirme que el estado final de la pila es `DELETE_COMPLETE` (puede tardar 10-15 minutos)

### 2. Verificar que No Quedan Instancias EC2 Huérfanas

1. Navegue a la consola de **Amazon EC2**
2. En el panel izquierdo, haga clic en **Instancias**
3. Verifique que no aparecen instancias con el nombre de su pila `[Iniciales]-TC-Portal`

**✓ Verificación**: No deben aparecer instancias relacionadas con su laboratorio. Si aparecen instancias en estado **Terminando**, espere a que completen la terminación.

### 3. Verificar que la Base de Datos RDS fue Eliminada

1. Navegue a la consola de **Amazon RDS**
2. En el panel izquierdo, haga clic en **Bases de datos**
3. Verifique que no aparece la base de datos `[Iniciales]-TC-Portal-db`

**✓ Verificación**: La base de datos no debe aparecer en la lista. Si aparece en estado **Eliminando**, espere a que complete la eliminación.

---

## Advertencias Importantes

⚠️ **NO Elimine Recursos de Otros Participantes**: Antes de eliminar cualquier recurso, verifique siempre que el nombre contiene sus iniciales. Eliminar recursos de otros participantes interrumpirá su trabajo y causará problemas en el entorno compartido.

⚠️ **Verifique el Nombre de la Pila**: Asegúrese de seleccionar la pila correcta antes de hacer clic en "Eliminar". El nombre debe ser `[Iniciales]-TC-Portal` donde `[Iniciales]` son sus iniciales personales.

⚠️ **Pérdida Permanente de Datos**: Una vez eliminada la pila, NO es posible recuperar:
- Los datos almacenados en la base de datos RDS
- Los logs de CloudWatch
- Las configuraciones personalizadas realizadas durante el laboratorio

---

## Recursos que NO Deben Eliminarse

Los siguientes recursos NO fueron creados por su pila y NO deben eliminarse:

- Recursos compartidos del instructor (si existen)
- Recursos de otros participantes (identificables por diferentes iniciales en el nombre)
- Recursos de laboratorios anteriores que aún necesite

---

## Solución de Problemas Durante la Limpieza

### Error: La pila queda en estado DELETE_FAILED

**Síntoma**: La eliminación de la pila falla y queda en estado `DELETE_FAILED`.

**Causas posibles**:
1. Algún recurso fue modificado o eliminado manualmente fuera de CloudFormation
2. Existen dependencias externas que impiden la eliminación

**Solución**:
1. Revise la pestaña **Eventos** para identificar qué recurso causó el fallo
2. Si es posible, elimine manualmente el recurso problemático desde su consola respectiva
3. Intente eliminar la pila nuevamente
4. Si el problema persiste, notifique al instructor

### La eliminación tarda más de 20 minutos

**Síntoma**: Han pasado más de 20 minutos y la pila sigue en estado `DELETE_IN_PROGRESS`.

**Solución**:
1. Esto puede ser normal para bases de datos RDS Multi-AZ grandes
2. Revise la pestaña **Eventos** para ver qué recurso se está eliminando actualmente
3. Si el proceso parece detenido en un recurso específico por más de 30 minutos, notifique al instructor

---

## Confirmación Final

Una vez completada la limpieza, confirme que:

- ✓ La pila de CloudFormation está en estado `DELETE_COMPLETE` o ya no aparece en la lista
- ✓ No quedan instancias EC2 relacionadas con el laboratorio
- ✓ La base de datos RDS fue eliminada
- ✓ No aparecen cargos inesperados en la facturación de AWS relacionados con este laboratorio

Si tiene dudas sobre algún recurso o cargo, consulte con el instructor antes de finalizar.
