# 🪣 Laboratorio 3: Sitio Web Estático en S3

## Índice
- [Objetivos de aprendizaje](#objetivos-de-aprendizaje)
- [Tiempo estimado](#tiempo-estimado)
- [Prerrequisitos](#prerrequisitos)
- [Paso 1: Verificar región AWS](#paso-1-verificar-region-aws)
- [Paso 2: Crear el bucket S3](#paso-2-crear-el-bucket-s3)
- [Paso 3: Subir los archivos de la página](#paso-3-subir-los-archivos-de-la-pagina)
- [Paso 4: Configurar hosting web estático](#paso-4-configurar-hosting-web-estatico)
- [Paso 5: Configurar política de acceso público](#paso-5-configurar-politica-de-acceso-publico)
- [Paso 6: Verificar el sitio web](#paso-6-verificar-el-sitio-web)
- [Solución de problemas](#solucion-de-problemas)
- [Limpieza de recursos](#limpieza-de-recursos)

## Objetivos de aprendizaje
- Crear y configurar un bucket S3 para hosting de sitios web estáticos
- Subir contenido web a S3 y configurar permisos de acceso público
- Habilitar y configurar el alojamiento de sitios web estáticos en S3
- Aplicar políticas de bucket para permitir acceso público al contenido web

## Tiempo estimado
30-40 minutos

## Prerrequisitos
- Cuenta de AWS con permisos para Amazon S3
- Navegador web para acceder al sitio publicado
- Archivos del sitio web disponibles en la carpeta `sitio-web-s3/` de este laboratorio

## Paso 1: Verificar región AWS

1. Verifique que está trabajando en la región correcta:
   - En la esquina superior derecha de la consola de AWS
   - Confirme que dice la región estipulada por el instructor
   - Si no es correcta, haga clic y seleccione la región indicada

## Paso 2: Crear el bucket S3

1. En la barra de búsqueda global (parte superior), escriba **S3** y seleccione el servicio
2. Haga clic en el botón naranja **Crear bucket**
3. Configure los siguientes parámetros:
   - **Nombre del bucket**: `s3-sitio-web-{nombre-participante}` (debe ser único a nivel global)
   - **Región de AWS**: Mantenga la región actual
   - **Bloquear todo el acceso público**: Desactive esta opción (desmarque la casilla)
   - Marque la casilla de confirmación que indica que comprende que el bucket será público
4. Deje las demás configuraciones con sus valores predeterminados
5. Haga clic en el botón naranja **Crear bucket** al final de la página

**✓ Verificación**: En la lista de buckets, confirme que:
- Su bucket `s3-sitio-web-{nombre-participante}` aparece en la lista
- La columna **Acceso** muestra "Objetos pueden ser públicos"

⚠️ **Advertencia de seguridad**: Desactivar el bloqueo de acceso público permite que el contenido del bucket sea accesible desde internet. Solo realice esta configuración para buckets destinados a hosting web público y nunca para datos sensibles o privados.

## Paso 3: Subir los archivos de la página

1. **Preparar los archivos localmente**:
   - Descargue el archivo [`website.zip`](website.zip) ubicado en esta carpeta del laboratorio a su computadora
   - Descomprima el archivo `website.zip` en su computadora local
   - Verifique que la carpeta descomprimida contiene: `index.html`, `about.html`, `contacto.html` y las carpetas `assets`, `js`, `css`

2. **Subir los archivos al bucket S3**:
   - En la lista de buckets, haga clic en el nombre de su bucket `s3-sitio-web-{nombre-participante}`
   - Haga clic en el botón naranja **Cargar**
   - Haga clic en **Agregar archivos** y **Agregar carpetas**
   - Seleccione todos los archivos y carpetas de la carpeta descomprimida `sitio-web-s3/`
   - Asegúrese de incluir: `index.html`, `about.html`, `contacto.html` y las carpetas `assets`, `js`, `css`
   - Mantenga las configuraciones predeterminadas
   - Haga clic en el botón naranja **Cargar** al final de la página
   - Espere a que la carga se complete y haga clic en **Cerrar**

> **Nota**: La consola de S3 no soporta la extracción automática de archivos ZIP. Debe descomprimir el archivo `website.zip` en su computadora local antes de subir los archivos al bucket.

**✓ Verificación**: En la vista de objetos del bucket, confirme que:
- Puede ver los archivos `index.html`, `about.html`, `contacto.html`
- Puede ver las carpetas `assets`, `js`, `css`
- El estado de carga indica "Correcto" para todos los objetos

## Paso 4: Configurar hosting web estático

1. En la página de su bucket, haga clic en la pestaña **Propiedades**
2. Desplácese hacia abajo hasta la sección **Alojamiento de sitios web estáticos**
3. Haga clic en el botón **Editar**
4. Configure los siguientes parámetros:
   - **Alojamiento de sitios web estáticos**: Seleccione **Habilitar**
   - **Tipo de alojamiento**: Seleccione **Alojar un sitio web estático**
   - **Documento de índice**: `index.html`
   - **Documento de error**: `404.html`
5. Haga clic en el botón naranja **Guardar cambios**

**✓ Verificación**: En la sección **Alojamiento de sitios web estáticos**, confirme que:
- El estado muestra **Habilitado**
- Aparece una **URL de punto de enlace del sitio web de bucket** (anótela para usarla más adelante)

## Paso 5: Configurar política de acceso público

1. En la página de su bucket, haga clic en la pestaña **Permisos**
2. Desplácese hasta la sección **Política de bucket**
3. Haga clic en el botón **Editar**
4. Copie el contenido del archivo [`bucket-policy.json`](bucket-policy.json) ubicado en esta carpeta
5. Pegue el contenido en el editor de políticas
6. Reemplace el texto `mi-bucket` con el nombre de su bucket: `s3-sitio-web-{nombre-participante}`
7. Haga clic en el botón naranja **Guardar cambios**

**✓ Verificación**: En la sección **Política de bucket**, confirme que:
- La política aparece en el editor
- No hay mensajes de error
- El banner superior indica que la política se guardó correctamente

> **¿Por qué es necesaria esta política?** Esta política permite que cualquier persona acceda a los archivos de su sitio web mediante el protocolo HTTP. Sin ella, los visitantes recibirían errores de acceso denegado al intentar ver el sitio.

⚠️ **Importante**: Solo utilice esta configuración para contenido público destinado a ser compartido abiertamente. Nunca aplique políticas de acceso público a buckets que contengan información sensible o privada.

## Paso 6: Verificar el sitio web

1. Regrese a la pestaña **Propiedades** de su bucket
2. Desplácese hasta la sección **Alojamiento de sitios web estáticos**
3. Copie la **URL de punto de enlace del sitio web de bucket**
4. Abra una nueva pestaña en su navegador web
5. Pegue la URL y presione Enter
6. Verifique que el sitio web se carga correctamente:
   - La página principal (`index.html`) se muestra con estilos aplicados
   - Los enlaces de navegación funcionan correctamente
   - Las páginas `about.html` y `contacto.html` son accesibles
   - Las imágenes y recursos de las carpetas `assets`, `js` y `css` se cargan correctamente

**✓ Verificación**: Confirme que:
- El sitio web es accesible desde la URL pública de S3
- Todas las páginas se muestran correctamente con sus estilos
- Los enlaces de navegación entre páginas funcionan
- Las imágenes y recursos multimedia se cargan sin errores

## Solución de problemas

Si encuentra dificultades durante este laboratorio, consulte la [Guía de Solución de Problemas](TROUBLESHOOTING.md) que contiene soluciones a errores comunes.

**Errores que requieren asistencia del instructor:**
- Errores de permisos IAM al crear o configurar buckets
- Errores de límites de cuota de AWS

## Limpieza de recursos

Para instrucciones detalladas sobre cómo eliminar los recursos creados en este laboratorio, consulte el documento [LIMPIEZA.md](LIMPIEZA.md).

**Nota**: La limpieza de recursos es opcional. Solo realícela si no continuará con laboratorios posteriores o si desea evitar costos de almacenamiento.