# Limpieza de Recursos - Laboratorio 1 (Opcional)

## ¿Cuándo realizar esta limpieza?

Realice esta limpieza únicamente si desea eliminar todos los recursos para evitar costos innecesarios

## Recursos a eliminar

Este laboratorio creó los siguientes recursos:
1. Instancia EC2: `ec2-webserver-{nombre-participante}`
2. Grupo de seguridad: `ec2-sg-webserver-{nombre-participante}`

## Pasos de eliminación

### 1. Terminar la instancia EC2

1. En la consola de AWS, utilice la barra de búsqueda global (parte superior) y escriba **EC2**, luego haga clic en el servicio EC2.

2. En el panel de navegación de la izquierda, haga clic en **Instancias**.

3. Seleccione la instancia `ec2-webserver-{nombre-participante}` haciendo clic en la casilla de verificación a la izquierda del nombre.

4. Haga clic en el menú desplegable **Estado de la instancia** en la parte superior.

5. Seleccione **Terminar instancia**.

6. En el cuadro de diálogo de confirmación, haga clic en **Terminar**.

⏱️ **Nota**: La instancia tardará unos minutos en cambiar al estado **Terminada**. Espere a que el estado cambie antes de continuar con el siguiente paso.

⚠️ **Consecuencia**: Una vez terminada, la instancia EC2 **no se puede recuperar**. Todos los datos almacenados en la instancia se perderán permanentemente.

### 2. Eliminar el Grupo de seguridad

1. En el panel de navegación de la izquierda de la consola EC2, haga clic en **Grupos de seguridad** (dentro de la sección **Red y seguridad**).

2. Seleccione el grupo de seguridad `ec2-sg-webserver-{nombre-participante}` haciendo clic en la casilla de verificación a la izquierda del nombre.

3. Haga clic en el menú desplegable **Acciones** en la parte superior.

4. Seleccione **Eliminar grupos de seguridad**.

5. En el cuadro de diálogo de confirmación, haga clic en **Eliminar**.

⚠️ **Consecuencia**: El Grupo de seguridad eliminado **no se puede recuperar**. Si necesita recrearlo, deberá configurar nuevamente todas las reglas de entrada y salida.

## Advertencias importantes

⚠️ **NO elimine recursos compartidos del instructor**:
- Si ve recursos sin su sufijo `{nombre-participante}`, son recursos compartidos
- Estos recursos son utilizados por todos los participantes del programa
- Eliminar recursos compartidos afectará a otros participantes y al funcionamiento del programa

## Verificación de limpieza

Después de completar los pasos anteriores, verifique que:
- La instancia `ec2-webserver-{nombre-participante}` aparece con estado **Terminada** en la lista de instancias
- El grupo de seguridad `ec2-sg-webserver-{nombre-participante}` ya no aparece en la lista de grupos de seguridad

## ¿Necesita ayuda?

Si encuentra problemas durante la limpieza de recursos, consulte la [Guía de Solución de Problemas](TROUBLESHOOTING.md) o notifique al instructor.
