# 🧹 Limpieza de Recursos - Laboratorio 3 (Opcional)

> ⚠️ **Nota importante**: Esta limpieza es opcional. Solo realícela si no continuará con laboratorios posteriores del programa AWS Cloud Essentials.

## ¿Cuándo realizar esta limpieza?

Realice esta limpieza únicamente si:
- Ha completado el Laboratorio 3 y no planea continuar con los laboratorios siguientes
- Desea eliminar los recursos para evitar costos innecesarios en su cuenta AWS
- El instructor ha indicado que puede proceder con la limpieza

⚠️ **No realice esta limpieza si planea continuar con otros laboratorios**, ya que algunos recursos pueden ser reutilizados.

---

## Recursos a Eliminar

En este laboratorio creó los siguientes recursos:

1. Distribución de CloudFront
2. Bucket S3 con sitio web estático

> ⚠️ **Importante**: Debe eliminar la distribución de CloudFront ANTES de eliminar el bucket S3, ya que la distribución depende del bucket como origen.

---

## Pasos de Eliminación

### 1. Deshabilitar la distribución de CloudFront

> ⚠️ **CRÍTICO**: Debe deshabilitar la distribución antes de poder eliminarla. Las distribuciones activas no se pueden eliminar directamente.

1. Utilice la barra de búsqueda global (parte superior) y escriba **CloudFront**. Haga clic en el servicio **CloudFront**.

2. En la lista de distribuciones, localice la distribución `cf-sitio-web-{nombre-participante}`.

3. Seleccione la distribución marcando la casilla a la izquierda.

4. Haga clic en el botón **Deshabilitar** y confirme haciendo clic en **Deshabilitar distribución**.

⏱️ **Nota**: La deshabilitación puede tardar entre 3 y 5 minutos en propagarse a todas las ubicaciones de borde.

5. Espere hasta que la columna **Última modificación** muestre una nueva fecha y hora (ya no dice "Implementando").

**✓ Verificación**: La columna **Estado** de la distribución muestra **Deshabilitado**.

---

### 2. Eliminar la distribución de CloudFront

1. En la lista de distribuciones, seleccione la distribución deshabilitada marcando la casilla.

2. Haga clic en el botón **Eliminar** y confirme haciendo clic en **Eliminar**.

**✓ Verificación**: La distribución `cf-sitio-web-{nombre-participante}` ya no aparece en la lista de distribuciones.

> ⚠️ **Advertencia**: Si el botón **Eliminar** no está disponible, significa que CloudFront aún está propagando la deshabilitación. Espere unos minutos y vuelva a intentar.

---

### 3. Vaciar el Bucket S3

> ⚠️ **CRÍTICO**: Debe vaciar el bucket antes de poder eliminarlo. Los buckets S3 no se pueden eliminar si contienen objetos.

1. Utilice la barra de búsqueda global (parte superior) y escriba **S3**. Haga clic en el servicio **S3**.

2. En la lista de buckets, localice el bucket `s3-sitio-web-{nombre-participante}`.

3. Haga clic en el nombre del bucket para abrirlo.

4. Haga clic en el botón **Vaciar**.

5. En la página de confirmación:
   - Lea la advertencia sobre la eliminación permanente de objetos
   - Escriba **vaciar permanentemente** en el cuadro de texto
   - Haga clic en el botón **Vaciar**

⏱️ **Nota**: El vaciado puede tardar unos segundos dependiendo de la cantidad de archivos.

**✓ Verificación**: El bucket muestra **0 objetos** en la columna de objetos.

> ⚠️ **Advertencia**: Los objetos eliminados no se pueden recuperar. Asegúrese de tener copias de seguridad si necesita conservar algún archivo.

---

### 4. Eliminar el Bucket S3

1. Regrese a la lista de buckets haciendo clic en **Amazon S3** en la parte superior izquierda, o en el enlace **Buckets** del panel de navegación.

2. Seleccione el bucket `s3-sitio-web-{nombre-participante}` marcando la casilla a la izquierda del nombre (no haga clic en el nombre).

3. Haga clic en el botón **Eliminar** en la parte superior derecha.

4. En la página de confirmación:
   - Lea la advertencia sobre la eliminación permanente del bucket
   - Escriba el nombre completo del bucket: `s3-sitio-web-{nombre-participante}` en el cuadro de texto
   - Haga clic en el botón **Eliminar bucket**

**✓ Verificación**: El bucket `s3-sitio-web-{nombre-participante}` ya no aparece en la lista de buckets.

> ⚠️ **Advertencia**: Una vez eliminado, el bucket no se puede recuperar. El nombre del bucket quedará disponible para que otros usuarios de AWS lo utilicen después de un tiempo.

---

## Verificación Final

Después de completar todos los pasos, verifique que:

- ✓ No aparece la distribución `cf-sitio-web-{nombre-participante}` en la lista de distribuciones de CloudFront
- ✓ No aparece el bucket `s3-sitio-web-{nombre-participante}` en la lista de buckets S3
- ✓ La URL del sitio web estático ya no es accesible (ni por S3 ni por CloudFront)

---

## Consecuencias de la Eliminación

Al eliminar la distribución de CloudFront y el bucket S3:

- **Sitio web inaccesible**: Tanto la URL de CloudFront como la URL de S3 dejarán de funcionar inmediatamente
- **Datos irrecuperables**: Todos los archivos (HTML, CSS, imágenes) se eliminarán permanentemente
- **Nombre del bucket liberado**: El nombre del bucket quedará disponible para otros usuarios de AWS después de un tiempo
- **Sin costos adicionales**: Dejará de incurrir en costos de almacenamiento S3 y transferencia de CloudFront asociados a este laboratorio

---

## Costos Asociados

Los siguientes recursos generan costos mientras están activos:

- **Almacenamiento S3**: Costo por GB almacenado por mes
- **Solicitudes S3**: Costo por solicitudes GET/PUT (muy bajo para sitios web pequeños)
- **Transferencia de datos S3**: Costo por GB transferido fuera de AWS (primeros GB gratuitos)
- **CloudFront**: Costo por solicitudes HTTP/HTTPS y por GB transferido desde las ubicaciones de borde (incluye capa gratuita de 1 TB/mes durante el primer año)

Al eliminar la distribución y el bucket siguiendo esta guía, dejará de incurrir en costos asociados a este laboratorio.

> **Nota**: Los costos combinados de S3 y CloudFront para un sitio web estático pequeño son mínimos (generalmente menos de $1 USD por mes), pero es buena práctica eliminar recursos que no se utilizan.
