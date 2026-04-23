# Guía de Solución de Problemas - Laboratorio 3

Esta guía contiene soluciones a errores comunes que pueden ocurrir durante la ejecución del Laboratorio 3: Sitio Web Estático en S3.

## Errores Comunes

### Error: El nombre del bucket ya existe o no está disponible

**Síntoma**: Al intentar crear el bucket, aparece un error indicando "Bucket name already exists" o "Bucket name is not available".

**Causas posibles**:
1. El nombre del bucket ya está en uso por otra cuenta de AWS (los nombres de bucket son únicos globalmente)
2. Ya creó un bucket con ese nombre anteriormente
3. El nombre del bucket no cumple con las reglas de nomenclatura de S3

**Solución**:
1. Modifique el nombre del bucket agregando números o caracteres adicionales:
   - Ejemplo: `s3-sitio-web-{nombre-participante}-01`
   - Ejemplo: `s3-sitio-web-{nombre-participante}-2024`
2. Verifique que el nombre cumple con las reglas de S3:
   - Solo letras minúsculas, números y guiones
   - Entre 3 y 63 caracteres
   - No puede comenzar ni terminar con guión
   - No puede contener espacios ni caracteres especiales
3. Si ya creó el bucket anteriormente, búsquelo en la lista de buckets y utilícelo
4. Asegúrese de usar su nombre de participante correcto en el placeholder

---

### Error: No puedo desactivar el bloqueo de acceso público

**Síntoma**: Al intentar desactivar "Bloquear todo el acceso público", la opción está deshabilitada o aparece un error.

**Causas posibles**:
1. Hay una política de cuenta que impide desactivar el bloqueo de acceso público
2. No tiene permisos suficientes para modificar la configuración de acceso público
3. La configuración está bloqueada a nivel de cuenta por el administrador

**Solución**:
1. Asegúrese de desmarcar la casilla "Bloquear todo el acceso público" durante la creación del bucket
2. Marque la casilla de confirmación que indica que comprende que el bucket será público
3. Si la opción está deshabilitada, notifique al instructor inmediatamente
4. Si ya creó el bucket con bloqueo activado:
   - Seleccione el bucket en la lista
   - Haga clic en la pestaña **Permisos**
   - En la sección **Bloquear acceso público (configuración del bucket)**, haga clic en **Editar**
   - Desactive todas las opciones y guarde los cambios

---

### Error: El sitio web muestra "403 Forbidden" al acceder

**Síntoma**: Al abrir la URL del sitio web estático, aparece un error "403 Forbidden" o "Access Denied".

**Causas posibles**:
1. La política de bucket no está configurada correctamente
2. La política de bucket no se aplicó o tiene errores de sintaxis
3. El bloqueo de acceso público sigue activado
4. El nombre del bucket en la política no coincide con el nombre real del bucket

**Solución**:
1. Verifique la política de bucket:
   - Vaya a la pestaña **Permisos** del bucket
   - En la sección **Política de bucket**, verifique que la política está presente
   - Confirme que el nombre del bucket en la política coincide exactamente con su bucket
   - Busque la línea `"Resource": "arn:aws:s3:::s3-sitio-web-{nombre-participante}/*"`
   - Asegúrese de que el nombre del bucket es correcto y termina con `/*`
2. Verifique el bloqueo de acceso público:
   - En la pestaña **Permisos**, sección **Bloquear acceso público**
   - Confirme que todas las opciones están desactivadas (Off)
   - Si están activadas, haga clic en **Editar** y desactívelas
3. Vuelva a aplicar la política de bucket:
   - Copie nuevamente el contenido de `bucket-policy.json`
   - Reemplace `mi-bucket` con el nombre correcto de su bucket
   - Guarde los cambios
4. Espere 1-2 minutos y vuelva a intentar acceder al sitio web

---

### Error: El sitio web muestra "404 Not Found"

**Síntoma**: Al acceder a la URL del sitio web, aparece un error "404 Not Found" o una página en blanco.

**Causas posibles**:
1. El archivo `index.html` no está en la raíz del bucket
2. El hosting de sitios web estáticos no está habilitado
3. El documento de índice está configurado incorrectamente
4. Los archivos no se cargaron correctamente al bucket

**Solución**:
1. Verifique que los archivos están en la ubicación correcta:
   - En la vista de objetos del bucket, confirme que `index.html` está en la raíz (no dentro de una carpeta)
   - Si está dentro de una carpeta, muévalo a la raíz del bucket
2. Verifique la configuración de hosting:
   - Vaya a la pestaña **Propiedades**
   - Desplácese a **Alojamiento de sitios web estáticos**
   - Confirme que está **Habilitado**
   - Verifique que el **Documento de índice** dice exactamente `index.html`
3. Si los archivos están en una carpeta incorrecta:
   - Elimine los objetos del bucket
   - Vuelva a cargar los archivos asegurándose de que `index.html` quede en la raíz
4. Use la URL correcta del sitio web:
   - Use la **URL de punto de enlace del sitio web de bucket** (no la URL de objeto de S3)
   - La URL correcta tiene el formato: `http://s3-sitio-web-{nombre-participante}.s3-website-{region}.amazonaws.com`

---

### Error: Los estilos CSS y las imágenes no se cargan

**Síntoma**: El sitio web se muestra pero sin estilos CSS, las imágenes no aparecen, o los scripts no funcionan.

**Causas posibles**:
1. Las carpetas `assets`, `js` y `css` no se cargaron correctamente
2. La estructura de carpetas no se mantuvo al cargar los archivos
3. Los archivos se cargaron dentro de una carpeta adicional
4. Las rutas en el HTML no coinciden con la estructura de carpetas en S3

**Solución**:
1. Verifique la estructura de carpetas en el bucket:
   - En la vista de objetos, confirme que ve las carpetas `assets/`, `js/`, `css/`
   - Haga clic en cada carpeta y verifique que contienen los archivos correspondientes
2. Si la estructura es incorrecta:
   - Elimine todos los objetos del bucket
   - Vuelva a cargar usando el archivo `website.zip` y la opción **Extraer**
   - O cargue los archivos y carpetas manualmente asegurándose de mantener la estructura
3. Verifique que no hay carpetas anidadas innecesarias:
   - La estructura debe ser: `index.html`, `assets/`, `js/`, `css/` en la raíz
   - NO debe ser: `sitio-web-s3/index.html`, `sitio-web-s3/assets/`, etc.
4. Si usó el método de carga manual:
   - Asegúrese de seleccionar tanto archivos como carpetas al cargar
   - Use "Agregar carpetas" para mantener la estructura de directorios

---

### Error: No puedo encontrar la URL del sitio web

**Síntoma**: No sé cuál es la URL para acceder al sitio web estático.

**Causas posibles**:
1. El hosting de sitios web estáticos no está habilitado
2. No está buscando en la ubicación correcta de la consola

**Solución**:
1. Vaya a la pestaña **Propiedades** de su bucket
2. Desplácese hacia abajo hasta la sección **Alojamiento de sitios web estáticos**
3. Si está habilitado, verá una **URL de punto de enlace del sitio web de bucket**
4. La URL tiene el formato: `http://nombre-bucket.s3-website-region.amazonaws.com`
5. Copie esta URL completa y péguela en su navegador
6. Si no ve la URL, verifique que el hosting está **Habilitado** (Paso 4 del laboratorio)

---

### Error: La política de bucket muestra errores de sintaxis JSON

**Síntoma**: Al intentar guardar la política de bucket, aparece un error indicando "Invalid JSON" o "Policy has invalid syntax".

**Causas posibles**:
1. Hay errores de formato en el JSON (comas faltantes, llaves mal cerradas)
2. Se copió incorrectamente el contenido del archivo `bucket-policy.json`
3. Se modificó accidentalmente la estructura del JSON
4. El nombre del bucket tiene caracteres especiales que no se escaparon correctamente

**Solución**:
1. Vuelva a copiar el contenido completo del archivo `bucket-policy.json`
2. Pegue el contenido en un editor de texto primero para verificar el formato
3. Asegúrese de reemplazar SOLO el texto `mi-bucket` con el nombre de su bucket
4. Verifique que:
   - Todas las llaves `{` tienen su correspondiente `}`
   - Todas las comillas están cerradas correctamente
   - No hay comas adicionales al final de las listas
5. Use un validador JSON en línea para verificar la sintaxis antes de pegar en la consola
6. Asegúrese de que el nombre del bucket no contiene caracteres especiales

---

### Error: El archivo website.zip no se extrae correctamente

**Síntoma**: Después de cargar y extraer `website.zip`, los archivos no aparecen en la estructura esperada.

**Causas posibles**:
1. La opción de extracción no está disponible en su región
2. El archivo zip tiene una estructura de carpetas anidadas
3. No se completó la extracción correctamente

**Solución**:
1. Si la opción **Extraer** no está disponible:
   - Use el método alternativo de carga manual
   - Descomprima `website.zip` en su computadora local
   - Cargue los archivos y carpetas directamente al bucket
2. Después de extraer, verifique la estructura:
   - Debe ver `index.html`, `about.html`, `contacto.html` en la raíz
   - Debe ver las carpetas `assets/`, `js/`, `css/` en la raíz
3. Si la estructura es incorrecta:
   - Elimine todos los objetos
   - Use el método de carga manual desde la carpeta `sitio-web-s3/` descomprimida
4. Asegúrese de seleccionar "Agregar archivos" Y "Agregar carpetas" al cargar manualmente

---

### Error: El bucket se creó pero no aparece en la lista

**Síntoma**: Después de crear el bucket, no aparece en la lista de buckets de S3.

**Causas posibles**:
1. Está viendo la región AWS incorrecta
2. El bucket se creó en una región diferente
3. Hay un filtro de búsqueda activo que oculta el bucket
4. Error temporal en la consola de AWS

**Solución**:
1. Verifique la región AWS:
   - En la esquina superior derecha de la consola
   - Confirme que está en la región correcta estipulada por el instructor
   - Los buckets S3 son específicos de región
2. Verifique que no hay filtros activos:
   - En la barra de búsqueda de buckets, asegúrese de que está vacía
   - Haga clic en el ícono de filtro y elimine cualquier filtro activo
3. Actualice la página del navegador (F5)
4. Si el bucket no aparece después de 2 minutos:
   - Intente crear el bucket nuevamente
   - Si aparece un error de "nombre ya existe", significa que el bucket sí se creó
   - Cambie a la región correcta para verlo

---

### Error: No puedo eliminar el bucket

**Síntoma**: Al intentar eliminar el bucket, aparece un error indicando que el bucket no está vacío o no se puede eliminar.

**Causas posibles**:
1. El bucket contiene objetos y debe vaciarse primero
2. El bucket tiene versionado habilitado y contiene versiones de objetos
3. Hay una política de retención o bloqueo de objetos activa

**Solución**:
1. Vacíe el bucket antes de eliminarlo:
   - Seleccione el bucket en la lista
   - Haga clic en el botón **Vaciar**
   - Escriba "eliminar permanentemente" en el campo de confirmación
   - Haga clic en **Vaciar**
2. Espere a que se complete el vaciado (puede tardar unos minutos si hay muchos objetos)
3. Una vez vacío, intente eliminar el bucket nuevamente:
   - Seleccione el bucket
   - Haga clic en **Eliminar**
   - Escriba el nombre del bucket para confirmar
   - Haga clic en **Eliminar bucket**
4. Si el error persiste, verifique que no hay políticas de retención activas en la pestaña **Propiedades**

---

### Error: Las páginas secundarias (about.html, contacto.html) muestran 404

**Síntoma**: La página principal (`index.html`) funciona correctamente, pero al hacer clic en los enlaces a otras páginas aparece un error 404.

**Causas posibles**:
1. Los archivos `about.html` y `contacto.html` no se cargaron al bucket
2. Los archivos están en una ubicación incorrecta dentro del bucket
3. Los nombres de archivo no coinciden exactamente (mayúsculas/minúsculas)
4. Las rutas en los enlaces HTML son incorrectas

**Solución**:
1. Verifique que los archivos existen en el bucket:
   - En la vista de objetos del bucket, busque `about.html` y `contacto.html`
   - Deben estar en la raíz del bucket, al mismo nivel que `index.html`
2. Verifique los nombres de archivo:
   - S3 es sensible a mayúsculas y minúsculas
   - Asegúrese de que los nombres son exactamente `about.html` y `contacto.html` (todo en minúsculas)
3. Si los archivos no están presentes:
   - Vuelva a cargar los archivos desde la carpeta `sitio-web-s3/` o desde `website.zip`
4. Pruebe acceder directamente a las páginas:
   - `http://su-bucket.s3-website-region.amazonaws.com/about.html`
   - `http://su-bucket.s3-website-region.amazonaws.com/contacto.html`

---

### Error: La distribución de CloudFront muestra "Access Denied" al acceder

**Síntoma**: Al abrir la URL de CloudFront, aparece un error XML con el mensaje "Access Denied".

**Causas posibles**:
1. La política del bucket S3 no fue actualizada correctamente por CloudFront
2. El Origin Access Control (OAC) no se configuró correctamente
3. La distribución aún está en proceso de despliegue

**Solución**:
1. Verifique que la distribución terminó de desplegarse:
   - En la consola de CloudFront, confirme que la columna **Última modificación** muestra una fecha (no "Implementando")
2. Verifique la política del bucket S3:
   - Vaya a S3, seleccione su bucket, pestaña **Permisos**
   - En **Política de bucket**, confirme que existe una declaración que permite acceso desde CloudFront
   - La política debe contener una condición `"AWS:SourceArn"` que referencia su distribución
3. Si la política no se actualizó automáticamente:
   - En la consola de CloudFront, seleccione su distribución
   - Vaya a la pestaña **Orígenes**, seleccione el origen S3 y haga clic en **Editar**
   - Confirme que **Origin Access Control** está seleccionado
   - Haga clic en **Copiar política** y aplíquela manualmente en la política del bucket S3
4. Espere 2-3 minutos y vuelva a intentar

---

### Error: CloudFront muestra una página en blanco o "NoSuchKey"

**Síntoma**: Al acceder a la URL raíz de CloudFront (sin especificar un archivo), aparece un error "NoSuchKey" o una página en blanco.

**Causas posibles**:
1. No se configuró un objeto raíz predeterminado en la distribución
2. El archivo `index.html` no existe en la raíz del bucket

**Solución**:
1. Configure el objeto raíz predeterminado:
   - En la consola de CloudFront, seleccione su distribución
   - Haga clic en la pestaña **General**, luego en **Editar configuración**
   - En **Objeto raíz predeterminado**, escriba `index.html`
   - Haga clic en **Guardar cambios**
2. Espere a que la distribución termine de desplegarse
3. Verifique que `index.html` existe en la raíz de su bucket S3

---

### Error: Los cambios en S3 no se reflejan en CloudFront

**Síntoma**: Después de actualizar archivos en el bucket S3, la URL de CloudFront sigue mostrando la versión anterior.

**Causas posibles**:
1. CloudFront tiene los archivos en caché en las ubicaciones de borde
2. El tiempo de vida (TTL) del caché no ha expirado

**Solución**:
1. Cree una invalidación de caché:
   - En la consola de CloudFront, seleccione su distribución
   - Haga clic en la pestaña **Invalidaciones**
   - Haga clic en **Crear invalidación**
   - En **Rutas de objetos**, escriba `/*` para invalidar todos los archivos
   - Haga clic en **Crear invalidación**
2. Espere 1-2 minutos a que la invalidación se complete
3. Actualice la página en su navegador (Ctrl+F5 para forzar recarga sin caché)

---

### Error: La distribución de CloudFront tarda mucho en desplegarse

**Síntoma**: La columna **Última modificación** muestra "Implementando" por más de 10 minutos.

**Causas posibles**:
1. CloudFront está propagando la configuración a todas las ubicaciones de borde globales
2. Hay alta demanda en el servicio

**Solución**:
1. El despliegue de una distribución nueva puede tardar entre 3 y 15 minutos
2. No es necesario esperar para continuar con otros pasos del laboratorio
3. Actualice la página de la consola periódicamente para verificar el estado
4. Si después de 15 minutos sigue en "Implementando", notifique al instructor

---

## Errores que Requieren Asistencia del Instructor

Si encuentra alguno de los siguientes errores, **notifique al instructor inmediatamente**. No intente solucionar estos errores por su cuenta:

### Error de permisos IAM

**Síntoma**: Aparece un mensaje indicando que no tiene permisos para realizar una acción en S3 (por ejemplo, "You are not authorized to perform this operation", "Access Denied to create bucket", "Insufficient permissions to modify bucket policy").

**Acción**: ⚠️ Notifique al instructor de inmediato. Este error requiere ajustes en las políticas IAM de su cuenta.

---

### Error de límites de cuota de AWS

**Síntoma**: Aparece un mensaje indicando que ha alcanzado el límite de buckets S3 (por ejemplo, "You have exceeded your bucket limit", "TooManyBuckets").

**Acción**: ⚠️ Notifique al instructor de inmediato. Este error requiere eliminar buckets existentes o solicitar un aumento de cuota.

---

### Error: No puedo desactivar el bloqueo de acceso público a nivel de cuenta

**Síntoma**: El bloqueo de acceso público está deshabilitado a nivel de bucket pero los objetos siguen siendo inaccesibles, o aparece un mensaje sobre configuración de cuenta.

**Acción**: ⚠️ Notifique al instructor de inmediato. Puede haber una política de control de servicio (SCP) o configuración de cuenta que impide el acceso público.

---

### Error: La región no soporta hosting de sitios web estáticos

**Síntoma**: La opción de "Alojamiento de sitios web estáticos" no aparece en la pestaña de Propiedades del bucket.

**Acción**: ⚠️ Notifique al instructor de inmediato. Esto puede indicar que está en una región que no soporta esta característica o que hay un problema con la consola.

---

### Error: No puedo ver el servicio S3 en la consola

**Síntoma**: Al buscar S3 en la barra de búsqueda global, el servicio no aparece o no puede acceder a él.

**Acción**: ⚠️ Notifique al instructor de inmediato. Esto indica un problema con los permisos de su cuenta o con el acceso al servicio S3.
