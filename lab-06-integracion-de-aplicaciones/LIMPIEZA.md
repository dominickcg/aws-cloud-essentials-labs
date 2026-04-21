# 🧹 Limpieza de Recursos - Laboratorio 6

⚠️ **Nota importante**: Esta limpieza es opcional. Solo realícela si desea eliminar los recursos creados durante el laboratorio para evitar cargos innecesarios en su cuenta AWS.

Si planea continuar trabajando con estos recursos o realizar el laboratorio nuevamente, puede mantenerlos activos. Los recursos de Amazon SNS y Amazon SQS tienen costos mínimos cuando no están en uso activo.

---

## Recursos a Eliminar (en orden)

Es fundamental seguir el orden de eliminación especificado a continuación para evitar errores de dependencias entre recursos. Las suscripciones deben eliminarse primero, ya que dependen del tema SNS. Luego se elimina el tema SNS, y finalmente la cola SQS.

**Recursos creados en este laboratorio:**
- 2 suscripciones al tema SNS (Amazon SQS + Correo electrónico)
- 1 tema SNS: `sns-alerta-compra-{nombre-participante}`
- 1 cola SQS: `sqs-almacen-pedidos-{nombre-participante}`

⚠️ **CRÍTICO - Entorno compartido**: Solo elimine recursos que tengan su nombre de participante en el sufijo. **Nunca elimine recursos de otros participantes o recursos compartidos proporcionados por el instructor.**

---

### 1. Eliminar Suscripciones del Tema SNS

Las suscripciones deben eliminarse primero, ya que dependen del tema SNS.

1. En la consola de AWS, utilice la barra de búsqueda global (parte superior) y escriba **SNS**
2. Haga clic en **Simple Notification Service** para abrir la consola de SNS
3. En el panel de navegación de la izquierda, haga clic en **Temas**
4. En la lista de temas, haga clic en el nombre de su tema: `sns-alerta-compra-{nombre-participante}`
5. En la página del tema, haga clic en la pestaña **Suscripciones**
6. Seleccione la casilla de verificación junto a la suscripción de **Amazon SQS** (protocolo: Amazon SQS)
7. Haga clic en el botón **Eliminar** en la parte superior
8. En el cuadro de diálogo de confirmación, escriba **eliminar** y haga clic en **Eliminar**
9. Repita los pasos 6-8 para eliminar la suscripción de **Correo electrónico** (protocolo: Email)

**✓ Verificación**: En la pestaña **Suscripciones** del tema SNS, confirme que:
- Ya no aparecen las dos suscripciones que creó (Amazon SQS y Correo electrónico)
- La lista de suscripciones está vacía o solo muestra suscripciones de otros participantes


---

### 2. Eliminar el Tema SNS

Una vez eliminadas las suscripciones, puede proceder a eliminar el tema SNS.

1. En la consola de SNS, en el panel de navegación de la izquierda, haga clic en **Temas**
2. En la lista de temas, seleccione la casilla de verificación junto a su tema: `sns-alerta-compra-{nombre-participante}`
3. Haga clic en el botón **Eliminar** en la parte superior
4. En el cuadro de diálogo de confirmación, escriba **eliminar** en el campo de texto
5. Haga clic en el botón **Eliminar** para confirmar la eliminación

**✓ Verificación**: En la lista de temas de SNS, confirme que:
- Su tema `sns-alerta-compra-{nombre-participante}` ya no aparece en la lista
- Solo permanecen los temas de otros participantes o temas compartidos del instructor


---

### 3. Eliminar la Cola SQS

Finalmente, puede eliminar la cola SQS que creó al inicio del laboratorio.

1. En la consola de AWS, utilice la barra de búsqueda global (parte superior) y escriba **SQS**
2. Haga clic en **Simple Queue Service** para abrir la consola de SQS
3. En el panel de navegación de la izquierda, haga clic en **Colas**
4. En la lista de colas, seleccione la casilla de verificación junto a su cola: `sqs-almacen-pedidos-{nombre-participante}`
   
   ⚠️ **ADVERTENCIA**: Verifique cuidadosamente que está seleccionando SOLO la cola con su nombre de participante. **No seleccione ni elimine colas de otros participantes.**

5. Haga clic en el botón **Eliminar** en la parte superior
6. En el cuadro de diálogo de confirmación, escriba **eliminar** en el campo de texto
7. Haga clic en el botón **Eliminar** para confirmar la eliminación

**✓ Verificación**: En la lista de colas de SQS, confirme que:
- Su cola `sqs-almacen-pedidos-{nombre-participante}` ya no aparece en la lista
- Solo permanecen las colas de otros participantes o colas compartidas del instructor

---

## Confirmación Final

Ha completado exitosamente la limpieza de todos los recursos del Laboratorio 6. Los siguientes recursos han sido eliminados:

- ✓ 2 suscripciones al tema SNS (Amazon SQS + Correo electrónico)
- ✓ 1 tema SNS: `sns-alerta-compra-{nombre-participante}`
- ✓ 1 cola SQS: `sqs-almacen-pedidos-{nombre-participante}`

Su cuenta AWS ya no tiene recursos activos de este laboratorio y no generará cargos relacionados con estos servicios.

