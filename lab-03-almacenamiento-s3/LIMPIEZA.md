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

En este laboratorio solo creó un recurso:

1. Bucket S3 con sitio web estático

---

## Pasos de Eliminación

### 1. Vaciar el Bucket S3

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

### 2. Eliminar el Bucket S3

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

- ✓ No aparece el bucket `s3-sitio-web-{nombre-participante}` en la lista de buckets S3
- ✓ La URL del sitio web estático ya no es accesible

---

## Consecuencias de la Eliminación

Al eliminar el bucket S3:

- **Sitio web inaccesible**: La URL del sitio web estático dejará de funcionar inmediatamente
- **Datos irrecuperables**: Todos los archivos (HTML, CSS, imágenes) se eliminarán permanentemente
- **Nombre del bucket liberado**: El nombre del bucket quedará disponible para otros usuarios de AWS después de un tiempo
- **Sin costos adicionales**: Dejará de incurrir en costos de almacenamiento S3 asociados a este bucket

---

## Costos Asociados

Los siguientes recursos generan costos mientras están activos:

- **Almacenamiento S3**: Costo por GB almacenado por mes
- **Solicitudes S3**: Costo por solicitudes GET/PUT (muy bajo para sitios web pequeños)
- **Transferencia de datos**: Costo por GB transferido fuera de AWS (primeros GB gratuitos)

Al eliminar el bucket siguiendo esta guía, dejará de incurrir en costos asociados a este laboratorio.

> **Nota**: Los costos de S3 para un sitio web estático pequeño son mínimos (generalmente menos de $1 USD por mes), pero es buena práctica eliminar recursos que no se utilizan.
