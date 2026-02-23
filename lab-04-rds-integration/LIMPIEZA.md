# 🧹 Limpieza de Recursos - Laboratorio 4 (Opcional)

> ⚠️ **Nota importante**: Esta limpieza es opcional. Solo realícela si no continuará con laboratorios posteriores del programa AWS Cloud Essentials.

## ¿Cuándo realizar esta limpieza?

Realice esta limpieza únicamente si:
- Ha completado el Laboratorio 4 y no planea continuar con los laboratorios siguientes
- Desea eliminar los recursos para evitar costos innecesarios en su cuenta AWS
- El instructor ha indicado que puede proceder con la limpieza

⚠️ **No realice esta limpieza si planea continuar con otros laboratorios**, ya que algunos recursos pueden ser reutilizados.

---

## Recursos a Eliminar

Los recursos deben eliminarse en el siguiente orden para respetar las dependencias:

1. Instancia EC2
2. Instancia RDS (Base de datos)
3. Grupos de seguridad (EC2 y RDS)

---

## Pasos de Eliminación

### 1. Terminar la Instancia EC2

1. Utilice la barra de búsqueda global (parte superior) y escriba **EC2**. Haga clic en el servicio **EC2**.

2. En el panel de navegación de la izquierda, haga clic en **Instancias**.

3. Seleccione la instancia `ec2-webapp-{nombre-participante}` haciendo clic en la casilla de verificación a la izquierda del nombre.

4. Haga clic en el menú desplegable **Estado de la instancia** en la parte superior.

5. Seleccione **Terminar instancia**.

6. En el cuadro de diálogo de confirmación, haga clic en **Terminar**.

⏱️ **Nota**: La instancia tardará 1-2 minutos en cambiar al estado **Terminada**.

**✓ Verificación**: La instancia `ec2-webapp-{nombre-participante}` muestra el estado **Terminated** (terminada).

> ⚠️ **Consecuencia**: Una vez terminada, la instancia EC2 **no se puede recuperar**. Todos los datos almacenados en la instancia se perderán permanentemente.

---

### 2. Eliminar la Instancia RDS

> ⚠️ **CRÍTICO**: La eliminación de la base de datos RDS es **permanente e irreversible**. Todos los datos almacenados en la base de datos se perderán para siempre.

1. Utilice la barra de búsqueda global (parte superior) y escriba **RDS**. Haga clic en el servicio **RDS**.

2. En el panel de navegación de la izquierda, haga clic en **Bases de datos**.

3. Seleccione la base de datos `database-lab4-{nombre-participante}` haciendo clic en el nombre.

4. Haga clic en el menú desplegable **Acciones** en la parte superior derecha.

5. Seleccione **Eliminar**.

6. En la página de confirmación:
   - **Crear instantánea final**: Desmarque la casilla (no es necesaria para este laboratorio)
   - **Conservar copias de seguridad automatizadas**: Desmarque la casilla
   - **Reconozco que al eliminar esta instancia...**: Marque la casilla para confirmar
   - Escriba **delete me** en el cuadro de texto de confirmación
   - Haga clic en el botón naranja **Eliminar**

⏱️ **Nota**: La eliminación de la base de datos RDS puede tardar **5-10 minutos** en completarse. El estado cambiará de **Eliminando** a desaparecer de la lista.

**✓ Verificación**: La base de datos `database-lab4-{nombre-participante}` ya no aparece en la lista de bases de datos.

> ⚠️ **Advertencia**: Los datos de la base de datos **no se pueden recuperar** después de la eliminación. Asegúrese de tener copias de seguridad si necesita conservar algún dato.

---

### 3. Eliminar Grupos de seguridad

> ⚠️ **Importante**: Los Grupos de seguridad solo se pueden eliminar después de que todos los recursos asociados (EC2 y RDS) hayan sido terminados completamente.

#### 3.1 Eliminar Grupo de seguridad de EC2

1. Utilice la barra de búsqueda global (parte superior) y escriba **EC2**. Haga clic en el servicio **EC2**.

2. En el panel de navegación de la izquierda, en la sección **Red y seguridad**, haga clic en **Grupos de seguridad**.

3. Seleccione el grupo de seguridad `ec2-sg-lab4-{nombre-participante}` haciendo clic en la casilla de verificación a la izquierda del nombre.

4. Haga clic en el menú desplegable **Acciones** en la parte superior.

5. Seleccione **Eliminar grupos de seguridad**.

6. En el cuadro de diálogo de confirmación, haga clic en **Eliminar**.

**✓ Verificación**: El grupo de seguridad `ec2-sg-lab4-{nombre-participante}` ya no aparece en la lista.

#### 3.2 Eliminar Security Group de RDS

1. En la misma página de grupos de seguridad, seleccione el grupo de seguridad `rds-sg-lab4-{nombre-participante}` haciendo clic en la casilla de verificación a la izquierda del nombre.

2. Haga clic en el menú desplegable **Acciones** en la parte superior.

3. Seleccione **Eliminar grupos de seguridad**.

4. En el cuadro de diálogo de confirmación, haga clic en **Eliminar**.

**✓ Verificación**: El grupo de seguridad `rds-sg-lab4-{nombre-participante}` ya no aparece en la lista.

> ⚠️ **Consecuencia**: Los Grupos de seguridad eliminados **no se pueden recuperar**. Si necesita recrearlos, deberá configurar nuevamente todas las reglas de entrada y salida.

---

## Verificación Final

Después de completar todos los pasos, verifique que:

- ✓ La instancia EC2 `ec2-webapp-{nombre-participante}` aparece con estado **Terminada** o ya no aparece en la lista
- ✓ La base de datos RDS `database-lab4-{nombre-participante}` ya no aparece en la lista de bases de datos
- ✓ El grupo de seguridad `ec2-sg-lab4-{nombre-participante}` ya no aparece en la lista de grupos de seguridad
- ✓ El grupo de seguridad `rds-sg-lab4-{nombre-participante}` ya no aparece en la lista de grupos de seguridad

---

## Advertencias Importantes

⚠️ **NO elimine recursos compartidos del instructor**:
- Si ve recursos sin su sufijo `{nombre-participante}`, son recursos compartidos
- Estos recursos son utilizados por todos los participantes del programa
- Eliminar recursos compartidos afectará a otros participantes y al funcionamiento del programa

⚠️ **Datos irrecuperables**:
- Los datos almacenados en la base de datos RDS se eliminarán permanentemente
- Los datos almacenados en la instancia EC2 se eliminarán permanentemente
- No hay forma de recuperar estos datos después de la eliminación
- Asegúrese de tener copias de seguridad si necesita conservar algún dato

---

## Costos Asociados

Los siguientes recursos generan costos mientras están activos:

- **Instancia EC2**: Costo por hora mientras está en ejecución
- **Instancia RDS**: Costo por hora mientras está disponible (incluso si no se usa)
- **Almacenamiento RDS**: Costo por GB almacenado por mes
- **Copias de seguridad RDS**: Costo por GB de copias de seguridad almacenadas

Al eliminar los recursos siguiendo esta guía, dejará de incurrir en costos asociados a este laboratorio.

> 💡 **Nota**: Las instancias RDS generan costos significativos incluso cuando no están en uso. Es importante eliminarlas si no las necesita.

---

## ¿Necesita ayuda?

Si encuentra problemas durante la limpieza de recursos, consulte la [Guía de Solución de Problemas](TROUBLESHOOTING.md) o notifique al instructor.

**Errores comunes durante la limpieza:**
- **No se puede eliminar Grupo de seguridad**: Asegúrese de que la instancia EC2 y la base de datos RDS estén completamente terminadas antes de intentar eliminar los Grupos de seguridad
- **Error al eliminar RDS**: Verifique que marcó todas las casillas de confirmación y escribió correctamente "delete me"
