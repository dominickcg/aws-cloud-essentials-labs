# Guía de Solución de Problemas - Laboratorio 5: Seguridad, Identidad y Gobernanza

Este documento proporciona soluciones a errores comunes que pueden ocurrir durante la ejecución del Laboratorio 5. Los problemas están organizados por módulo para facilitar su consulta.

## Índice

- [Módulo IAM](#módulo-iam)
- [Módulo GuardDuty](#módulo-guardduty)
- [Módulo CloudTrail](#módulo-cloudtrail)
- [Errores que Requieren Asistencia del Instructor](#errores-que-requieren-asistencia-del-instructor)

---

## Módulo IAM

### Error: No puedo iniciar sesión con el usuario IAM creado

**Síntoma**: Al intentar iniciar sesión con el usuario IAM creado (usuario-estudiante-{nombre-participante}) utilizando la Console Sign-in URL, aparece un mensaje de error indicando "Nombre de usuario o contraseña incorrectos" o "Usuario no encontrado".

**Causas posibles**:
1. Está utilizando la URL incorrecta para iniciar sesión (URL de cuenta raíz en lugar de la Console Sign-in URL específica de IAM)
2. El nombre de usuario ingresado no coincide exactamente con el nombre del usuario IAM creado
3. La contraseña ingresada es incorrecta
4. El usuario IAM no tiene habilitado el acceso a la consola de administración de AWS
5. Está intentando iniciar sesión en la región incorrecta (aunque IAM es global, la URL puede variar)

**Solución**:
1. Verifique que está utilizando la Console Sign-in URL correcta que copió del Dashboard de IAM en el Paso 2. Esta URL tiene el formato: `https://[ID-cuenta].signin.aws.amazon.com/console`
2. Confirme que el nombre de usuario ingresado es exactamente `usuario-estudiante-{nombre-participante}` (reemplace {nombre-participante} con su nombre real)
3. Verifique que la contraseña ingresada es la misma que configuró durante la creación del usuario
4. Regrese a la consola de IAM con su usuario principal y verifique que el usuario IAM tiene habilitado "Acceso a la consola" en la pestaña "Credenciales de seguridad"
5. Si el problema persiste, intente restablecer la contraseña del usuario IAM:
   - En la consola de IAM, navegue a **Usuarios**
   - Seleccione el usuario `usuario-estudiante-{nombre-participante}`
   - Haga clic en la pestaña **Credenciales de seguridad**
   - En la sección "Contraseña de la consola", haga clic en **Administrar**
   - Configure una nueva contraseña personalizada

---

### Error: No veo la Console Sign-in URL en el dashboard de IAM

**Síntoma**: Al acceder al Dashboard de IAM, no aparece la sección que muestra la Console Sign-in URL (URL de inicio de sesión de la consola) necesaria para que los usuarios IAM inicien sesión.

**Causas posibles**:
1. Está visualizando una sección diferente del servicio IAM (por ejemplo, Usuarios, Grupos, Políticas) en lugar del Dashboard principal
2. La interfaz de la consola de AWS ha cambiado y la URL se encuentra en una ubicación diferente
3. El navegador no está mostrando correctamente la página debido a problemas de caché o extensiones
4. Está utilizando una cuenta AWS que no tiene configurado un alias de cuenta (la URL aparece pero con el ID numérico de la cuenta)

**Solución**:
1. Asegúrese de estar en el Dashboard principal de IAM:
   - En el panel de navegación izquierdo, haga clic en **Dashboard** (debe ser la primera opción)
   - Verifique que el título de la página dice "Dashboard de IAM" o "IAM Dashboard"
2. Busque la sección llamada "URL de inicio de sesión de usuarios de IAM de AWS" o "AWS Account" en la parte superior del Dashboard
3. La URL tiene el formato: `https://[ID-cuenta-o-alias].signin.aws.amazon.com/console`
4. Si no ve la URL claramente, intente:
   - Actualizar la página del navegador (F5 o Ctrl+R)
   - Limpiar la caché del navegador y volver a cargar la página
   - Desactivar temporalmente extensiones del navegador que puedan interferir
   - Utilizar una ventana de incógnito para acceder a la consola
5. Como alternativa, puede construir manualmente la URL de inicio de sesión:
   - Navegue a **Dashboard de IAM**
   - Copie el **ID de cuenta de AWS** (número de 12 dígitos visible en la parte superior derecha de la consola)
   - Construya la URL: `https://[ID-cuenta].signin.aws.amazon.com/console`
   - Reemplace [ID-cuenta] con el número de 12 dígitos copiado

---

### Error: El usuario puede crear recursos cuando no debería

**Síntoma**: Durante la prueba negativa del Paso 5, al intentar lanzar una instancia EC2 con el usuario IAM `usuario-estudiante-{nombre-participante}`, la operación se completa exitosamente en lugar de mostrar un mensaje de "Acceso denegado". El usuario puede crear recursos cuando solo debería tener permisos de lectura.

**Causas posibles**:
1. El usuario IAM no fue añadido correctamente al grupo `grupo-lectura-{nombre-participante}` que tiene la política ViewOnlyAccess
2. Se adjuntó una política adicional con permisos de escritura directamente al usuario IAM (en lugar de solo a través del grupo)
3. Se seleccionó una política incorrecta al crear el grupo (por ejemplo, PowerUserAccess o AdministratorAccess en lugar de ViewOnlyAccess)
4. El grupo tiene múltiples políticas adjuntas y una de ellas otorga permisos de escritura
5. Existe una política basada en recursos o una política de sesión que está otorgando permisos adicionales

**Solución**:
1. Verifique la membresía del grupo:
   - En la consola de IAM, navegue a **Usuarios**
   - Seleccione el usuario `usuario-estudiante-{nombre-participante}`
   - Haga clic en la pestaña **Grupos**
   - Confirme que el usuario pertenece al grupo `grupo-lectura-{nombre-participante}`
   - Si no aparece el grupo, haga clic en **Añadir usuario a grupos** y seleccione el grupo correcto
2. Verifique las políticas del usuario:
   - En la misma página del usuario, haga clic en la pestaña **Permisos**
   - Revise la sección "Políticas de permisos"
   - Confirme que NO hay políticas adjuntas directamente al usuario (solo debe heredar permisos del grupo)
   - Si hay políticas adicionales, haga clic en **X** para eliminarlas
3. Verifique las políticas del grupo:
   - En la consola de IAM, navegue a **Grupos de usuarios**
   - Seleccione el grupo `grupo-lectura-{nombre-participante}`
   - Haga clic en la pestaña **Permisos**
   - Confirme que la ÚNICA política adjunta es **ViewOnlyAccess** (política administrada por AWS)
   - Si hay otras políticas, elimínelas haciendo clic en **Desasociar**
4. Si la política del grupo es incorrecta:
   - Desasocie la política incorrecta del grupo
   - Haga clic en **Adjuntar políticas**
   - Busque y seleccione **ViewOnlyAccess**
   - Haga clic en **Adjuntar política**
5. Después de realizar correcciones, cierre la sesión del usuario IAM y vuelva a iniciar sesión para que los cambios de permisos surtan efecto
6. Repita la prueba negativa intentando lanzar una instancia EC2 - ahora debería recibir un mensaje de "Acceso denegado"

---

## Módulo GuardDuty

### Error: No aparecen hallazgos de muestra en GuardDuty

**Síntoma**: Después de hacer clic en "Generar hallazgos de muestra" en la sección de Configuración de GuardDuty, al navegar a la sección "Hallazgos" no aparece ninguna alerta simulada en la lista, o la lista aparece vacía.

**Causas posibles**:
1. Los hallazgos de muestra tardan unos segundos en generarse y aparecer en la interfaz
2. Está visualizando la sección incorrecta de GuardDuty (por ejemplo, "Resumen" en lugar de "Hallazgos")
3. Hay filtros activos en la vista de hallazgos que están ocultando los hallazgos de muestra
4. GuardDuty no se habilitó correctamente en el paso anterior
5. Está visualizando GuardDuty en una región diferente a la que habilitó el servicio (GuardDuty es regional)
6. El navegador no está actualizando la página correctamente debido a problemas de caché

**Solución**:
1. Espere entre 30 segundos y 1 minuto después de generar los hallazgos de muestra, luego actualice la página del navegador (F5 o Ctrl+R)
2. Verifique que está en la sección correcta:
   - En el panel de navegación izquierdo de GuardDuty, haga clic en **Hallazgos** (no "Resumen" ni "Configuración")
   - El título de la página debe decir "Hallazgos" o "Findings"
3. Revise si hay filtros activos:
   - En la parte superior de la lista de hallazgos, busque la barra de filtros
   - Si ve filtros aplicados (por ejemplo, por severidad, tipo o estado), haga clic en **Borrar filtros** o en la **X** junto a cada filtro
   - Asegúrese de que el filtro de estado incluye "Archivado: No" para ver hallazgos activos
4. Confirme que GuardDuty está habilitado:
   - En el panel de navegación izquierdo, haga clic en **Configuración**
   - Verifique que el estado del servicio es "Habilitado" o "Enabled"
   - Si aparece como "Suspendido" o "Deshabilitado", haga clic en **Habilitar GuardDuty** nuevamente
5. Verifique la región correcta:
   - En la esquina superior derecha de la consola de AWS, confirme que está en la misma región donde habilitó GuardDuty
   - Si está en una región diferente, cambie a la región correcta utilizando el selector de regiones
6. Intente generar los hallazgos de muestra nuevamente:
   - Navegue a **Configuración** en el panel izquierdo
   - Desplácese hasta la sección "Hallazgos de muestra"
   - Haga clic en **Generar hallazgos de muestra** nuevamente
   - Espere el mensaje de confirmación verde
   - Regrese a **Hallazgos** y actualice la página
7. Si después de estos pasos los hallazgos aún no aparecen, intente:
   - Cerrar sesión y volver a iniciar sesión en la consola de AWS
   - Utilizar una ventana de incógnito del navegador
   - Limpiar la caché del navegador y volver a intentar

---

## Módulo CloudTrail

### Error: No veo mis eventos en CloudTrail

**Síntoma**: Al acceder al Historial de eventos de CloudTrail y aplicar filtros para buscar eventos específicos (por ejemplo, eventos del usuario IAM creado o eventos administrativos), no aparece ningún resultado en la lista de eventos, o la lista está vacía.

**Causas posibles**:
1. Los filtros aplicados son demasiado restrictivos o contienen errores tipográficos en el nombre de usuario o recurso
2. Los eventos aún no se han registrado en CloudTrail (puede haber un retraso de hasta 15 minutos)
3. El rango de tiempo seleccionado no incluye el período en que se realizaron las acciones
4. El nombre del recurso o usuario ingresado en el filtro no coincide exactamente con el nombre real (CloudTrail es sensible a mayúsculas/minúsculas)
5. Está buscando eventos en la región incorrecta (algunos eventos son globales, otros son regionales)
6. Los eventos que busca son eventos de datos (Data Events) en lugar de eventos de administración (Management Events), y el Event History solo muestra eventos de administración por defecto

**Solución**:
1. Verifique que los filtros están configurados correctamente:
   - Haga clic en el botón **Borrar filtros** para eliminar todos los filtros activos
   - Confirme que puede ver eventos en la lista sin filtros aplicados
   - Vuelva a aplicar los filtros uno por uno para identificar cuál está causando el problema
2. Verifique el nombre exacto del recurso o usuario:
   - Para filtrar por usuario IAM, asegúrese de escribir exactamente `usuario-estudiante-{nombre-participante}` (reemplace {nombre-participante} con su nombre real)
   - CloudTrail es sensible a mayúsculas y minúsculas, verifique que el nombre está escrito correctamente
   - No incluya espacios adicionales al inicio o final del nombre
3. Ajuste el rango de tiempo:
   - En la parte superior del Historial de eventos, verifique el selector de rango de tiempo
   - Amplíe el rango a las últimas 24 horas o más si es necesario
   - Confirme que el rango incluye el momento en que realizó las acciones del laboratorio
4. Verifique la región correcta:
   - Eventos de IAM son globales y aparecen en la región us-east-1 (Norte de Virginia)
   - Si está buscando eventos de IAM, cambie a la región us-east-1 en el selector de región (esquina superior derecha)
   - Para eventos de otros servicios regionales (como EC2), asegúrese de estar en la región donde realizó las acciones
5. Utilice el atributo de filtro correcto:
   - Para buscar eventos por usuario: seleccione **Nombre de usuario** como atributo de filtro
   - Para buscar eventos por recurso: seleccione **Nombre del recurso** como atributo de filtro
   - Para buscar eventos por tipo de acción: seleccione **Nombre del evento** como atributo de filtro
6. Si busca eventos administrativos específicos (CreateUser, CreateGroup, AttachGroupPolicy):
   - Use el filtro **Nombre del evento** en lugar de **Nombre de usuario**
   - Escriba el nombre exacto del evento (por ejemplo, `CreateUser`)
   - Tenga en cuenta que estos eventos pueden tardar hasta 15 minutos en aparecer (ver error siguiente)

---

### Error: Eventos de CloudTrail tardan en aparecer

**Síntoma**: Después de realizar acciones en la consola de AWS (como crear usuarios IAM, grupos, o iniciar sesión con un usuario IAM), los eventos correspondientes no aparecen inmediatamente en el Historial de eventos de CloudTrail. Al buscar eventos recientes, la lista está vacía o no muestra las acciones que acaba de realizar.

**Causas posibles**:
1. CloudTrail tiene un retraso normal de procesamiento de eventos que puede ser de hasta 15 minutos
2. Los eventos están siendo procesados y aún no se han indexado en el Historial de eventos
3. La página del Historial de eventos no se ha actualizado para mostrar los eventos más recientes
4. El navegador está mostrando una versión en caché de la página

**Solución**:
1. **Espere el tiempo de propagación normal**:
   - CloudTrail puede tardar hasta **15 minutos** en procesar y mostrar eventos en el Historial de eventos
   - Este retraso es normal y esperado, especialmente para eventos administrativos como CreateUser, CreateGroup, y AttachGroupPolicy
   - No es un error del laboratorio ni de su configuración
2. **Actualice la página periódicamente**:
   - Haga clic en el botón de actualización del navegador (F5 o Ctrl+R) cada 2-3 minutos
   - O haga clic en el botón **Actualizar** dentro de la interfaz de CloudTrail si está disponible
3. **Continúe con otras partes del laboratorio**:
   - Mientras espera que aparezcan los eventos administrativos del Paso 11, puede:
     - Revisar los eventos de inicio de sesión (ConsoleLogin) del Paso 10, que suelen aparecer más rápido
     - Repasar los conceptos aprendidos en los módulos anteriores
     - Leer la sección de Conceptos Clave al final del README
4. **Verifique que está buscando en el momento correcto**:
   - Anote la hora exacta en que realizó las acciones (crear usuario, crear grupo)
   - En el Historial de eventos, ajuste el rango de tiempo para incluir ese período específico
   - Amplíe el rango de tiempo a las últimas 1-2 horas para asegurarse de capturar los eventos
5. **Limpie la caché del navegador si es necesario**:
   - Si después de 15-20 minutos los eventos aún no aparecen, intente:
     - Abrir una ventana de incógnito y acceder nuevamente a CloudTrail
     - Limpiar la caché del navegador y recargar la página
6. **Verifique la región correcta para eventos de IAM**:
   - Los eventos de IAM son globales pero se registran en la región **us-east-1 (Norte de Virginia)**
   - Cambie a la región us-east-1 en el selector de región (esquina superior derecha)
   - Busque los eventos administrativos en esa región

⏱️ **Nota importante**: El retraso de hasta 15 minutos en la aparición de eventos es un comportamiento normal de CloudTrail y no indica un problema. Si después de 20 minutos los eventos aún no aparecen, revise los filtros aplicados y la región seleccionada según las soluciones del error anterior "No veo mis eventos en CloudTrail".

---

## Errores que Requieren Asistencia del Instructor

Algunos errores están fuera del alcance de este laboratorio y requieren la intervención del instructor. Si encuentra alguno de los siguientes problemas, notifique al instructor de inmediato:

⚠️ **Errores de permisos IAM**: Si recibe mensajes de error indicando que su usuario principal no tiene permisos para crear usuarios, grupos o políticas en IAM, esto indica un problema de configuración de la cuenta que solo el instructor puede resolver.

⚠️ **Errores de límites de cuota de AWS**: Si recibe mensajes sobre límites de servicio alcanzados (por ejemplo, número máximo de usuarios IAM), notifique al instructor para que ajuste las cuotas de la cuenta.

⚠️ **Errores de habilitación de GuardDuty**: Si GuardDuty no se puede habilitar debido a restricciones de la cuenta o conflictos con configuraciones existentes, el instructor debe revisar la configuración de la cuenta.

⚠️ **Problemas de acceso a la consola AWS**: Si no puede acceder a la consola de AWS o experimenta problemas de autenticación con su usuario principal, contacte al instructor de inmediato.

---

**Nota**: Si su problema no aparece en esta guía, consulte con el instructor o revise la documentación oficial de AWS para el servicio específico.
