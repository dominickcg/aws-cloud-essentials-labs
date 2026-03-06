# 🧹 Limpieza de Recursos - Laboratorio 5 (Opcional)

> ⚠️ **Nota importante**: Esta limpieza es opcional. Solo realícela si no continuará con laboratorios posteriores del programa AWS Cloud Essentials.

## ¿Cuándo realizar esta limpieza?

Realice esta limpieza únicamente si:
- Ha completado el Laboratorio 5 y no planea continuar con los laboratorios siguientes
- Desea eliminar los recursos de seguridad creados para mantener su cuenta AWS limpia
- El instructor ha indicado que puede proceder con la limpieza

⚠️ **No realice esta limpieza si planea continuar con otros laboratorios**, ya que algunos recursos pueden ser reutilizados.

---

## Recursos a Eliminar

Los recursos deben eliminarse en el siguiente orden para respetar las dependencias:

1. Deshabilitar Amazon GuardDuty
2. Eliminar usuario IAM
3. Eliminar grupo IAM

> 💡 **Nota sobre CloudTrail**: AWS CloudTrail Event History es un servicio habilitado por defecto en todas las cuentas AWS y **no requiere limpieza**. El historial de eventos se mantiene automáticamente durante 90 días sin costo adicional.

---

## Advertencias Importantes

⚠️ **NO elimine recursos compartidos del instructor**:
- Si ve usuarios o grupos IAM sin su sufijo `{nombre-participante}`, son recursos compartidos
- Estos recursos son utilizados por todos los participantes del programa o por el instructor
- Eliminar recursos compartidos afectará a otros participantes y al funcionamiento del programa
- **Solo elimine recursos que contengan su nombre de participante en el nombre**

⚠️ **Datos irrecuperables**:
- Los usuarios IAM eliminados no se pueden recuperar
- Los grupos IAM eliminados no se pueden recuperar
- Si necesita recrearlos, deberá configurar nuevamente todos los permisos y políticas

---

## Pasos de Eliminación

### Paso 1: Deshabilitar Amazon GuardDuty

1. En la barra de búsqueda global (parte superior de la consola), escriba **GuardDuty**
2. Haga clic en el servicio **GuardDuty** para abrirlo
3. En el panel de navegación de la izquierda, haga clic en **Configuración**
4. Desplácese hacia abajo hasta la sección **Suspender o deshabilitar GuardDuty**
5. Haga clic en el botón **Deshabilitar**
6. En el cuadro de diálogo de confirmación, escriba **deshabilitar** en el campo de texto
7. Haga clic en el botón **Deshabilitar GuardDuty**

**✓ Verificación**: Debería ver un mensaje de confirmación indicando que GuardDuty ha sido deshabilitado en la región actual.

> 💡 **Nota**: GuardDuty es un servicio regional. Si habilitó GuardDuty en múltiples regiones, deberá repetir este proceso en cada región.

---

### Paso 2: Eliminar Usuario IAM

1. En la barra de búsqueda global (parte superior de la consola), escriba **IAM**
2. Haga clic en el servicio **IAM** para abrirlo
3. En el panel de navegación de la izquierda, haga clic en **Usuarios**
4. En la lista de usuarios, localice el usuario **usuario-estudiante-{nombre-participante}**
   - Ejemplo: Si su nombre es Juan, busque `usuario-estudiante-juan`
5. Marque la casilla de verificación junto al nombre del usuario
6. En la parte superior de la lista, haga clic en el botón **Eliminar**
7. En el cuadro de diálogo de confirmación:
   - Lea la advertencia sobre la eliminación permanente
   - En el campo de texto, escriba el nombre completo del usuario: **usuario-estudiante-{nombre-participante}**
   - Ejemplo: `usuario-estudiante-juan`
8. Haga clic en el botón **Eliminar usuario**

**✓ Verificación**: El usuario ya no aparece en la lista de usuarios de IAM.

⚠️ **Advertencia**: Asegúrese de eliminar SOLO el usuario con su nombre de participante. No elimine usuarios de otros participantes ni usuarios compartidos del instructor.

---

### Paso 3: Eliminar Grupo IAM

1. En el panel de navegación de la izquierda de IAM, haga clic en **Grupos de usuarios**
2. En la lista de grupos, localice el grupo **grupo-cloudpractitioner-lectura-{nombre-participante}**
   - Ejemplo: Si su nombre es Juan, busque `grupo-cloudpractitioner-lectura-juan`
3. Marque la casilla de verificación junto al nombre del grupo
4. En la parte superior de la lista, haga clic en el botón **Eliminar**
5. En el cuadro de diálogo de confirmación:
   - Lea la advertencia sobre la eliminación permanente
   - En el campo de texto, escriba el nombre completo del grupo: **grupo-cloudpractitioner-lectura-{nombre-participante}**
   - Ejemplo: `grupo-cloudpractitioner-lectura-juan`
6. Haga clic en el botón **Eliminar grupo**

**✓ Verificación**: El grupo ya no aparece en la lista de grupos de usuarios de IAM.

⚠️ **Advertencia**: Asegúrese de eliminar SOLO el grupo con su nombre de participante. No elimine grupos de otros participantes ni grupos compartidos del instructor.

---

## Limpieza Completada

¡Ha completado exitosamente la limpieza de recursos del Laboratorio 5!

Los recursos eliminados fueron:
- ✅ Amazon GuardDuty deshabilitado
- ✅ Usuario IAM `usuario-estudiante-{nombre-participante}` eliminado
- ✅ Grupo IAM `grupo-cloudpractitioner-lectura-{nombre-participante}` eliminado

**Recursos que NO requieren limpieza**:
- AWS CloudTrail Event History (servicio por defecto, sin costo)

Si tiene preguntas o encuentra algún problema durante la limpieza, consulte al instructor.

