# Lab 2: Publicar sitio web estático en S3

## Objetivos
- Subir una página web estática completa a un bucket S3.
- Configurar el bucket para hosting web.
- Acceder al sitio usando la URL pública de S3.

## Duración estimada
30–40 minutos

## Requisitos
- Cuenta de AWS con permisos para S3.
- Navegador para acceder al sitio web.

## Pasos

### 1. Crear el bucket S3
1. Ir a **S3 → Crear bucket**.
2. Asignar un nombre único a nivel global (por ejemplo: `lab2-web-static-<tu-nombre>`).
3. Desactivar **Bloquear todo el acceso público** para el lab.
4. Crear el bucket.

> **⚠️ Advertencia de seguridad:** Desactivar el bloqueo de acceso público permite que el contenido del bucket sea accesible desde internet. Solo hazlo para buckets destinados a hosting web público y nunca para datos sensibles o privados.

### 2. Subir los archivos de la página
1. Abre la carpeta `website/`.
2. Haz clic en **Cargar** en tu bucket S3.
3. Selecciona todos los archivos y carpetas (`assets`, `scripts`, `styles`, `index.html`, etc.).
4. Mantén las configuraciones por defecto y haz clic en **Cargar**.

### 3. Configurar hosting web estático
1. Ve a **Propiedades → Alojamiento de sitios web estáticos → Editar**.
2. Selecciona **Habilitar**.
3. Documento de índice: `index.html`.
4. Documento de error: `404.html`.
5. Guarda los cambios.

### 4. Configurar política de acceso público
1. Ve a **Permisos → Política de bucket → Editar**.
2. Copia el contenido de [`bucket-policy.json`](bucket-policy.json) y reemplaza `mi-bucket` con el nombre de tu bucket.
3. Pega la política en el editor y guarda los cambios.

> **¿Por qué es necesaria esta política?** Esta política permite que cualquier persona acceda a los archivos de tu sitio web. Sin ella, los visitantes recibirían errores de acceso denegado.

> **⚠️ Importante:** Solo usa esta configuración para contenido público. Nunca apliques políticas públicas a buckets con información sensible.

### 5. Verificar
1. Copia la URL del bucket.
2. Abre la URL en el navegador.
3. Verifica que todas las páginas (`index.html`, `about.html`, `contacto.html`) funcionen y que los estilos y scripts carguen correctamente.

## Limpieza de recursos

Para evitar costos innecesarios, elimina los recursos creados:

1. **Vaciar el bucket S3:**
   - Ve a **S3 → Buckets**
   - Selecciona tu bucket
   - **Vaciar** → Confirma escribiendo "eliminar permanentemente"

2. **Eliminar el bucket:**
   - Selecciona el bucket vacío
   - **Eliminar** → Confirma escribiendo el nombre del bucket

> **⚠️ Importante:** Una vez eliminado el bucket y sus objetos, no se pueden recuperar. Asegúrate de tener copias de seguridad si necesitas conservar el contenido.