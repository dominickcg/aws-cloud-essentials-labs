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

### 4. Verificar
1. Copia la URL del bucket.
2. Abre la URL en el navegador.
3. Verifica que todas las páginas (`index.html`, `about.html`, `contacto.html`) funcionen y que los estilos y scripts carguen correctamente.