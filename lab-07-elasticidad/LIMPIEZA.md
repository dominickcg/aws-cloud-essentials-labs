# Limpieza de Recursos - Laboratorio 7: TechShop HA

Esta guía le ayudará a eliminar todos los recursos creados durante el laboratorio de TechShop HA. La ventaja de usar Infraestructura como Código (IaC) con CloudFormation es que al eliminar la pila se eliminan automáticamente los ~25 recursos creados por la plantilla del participante en el orden correcto de dependencias.

---

## Paso 1: Vaciar el bucket S3

Antes de eliminar la pila de CloudFormation, es necesario vaciar el bucket S3. CloudFormation no puede eliminar un bucket que contiene objetos, por lo que la eliminación de la pila fallará si omite este paso.

1. Utilice la barra de búsqueda global (parte superior) y escriba **S3**. Haga clic en el servicio **S3**.

2. En la lista de buckets, localice y haga clic en el bucket con el nombre `techshop-ha-{nombre-participante}-assets`.

3. Seleccione todos los objetos del bucket:
   - Haga clic en la casilla de verificación en la parte superior de la lista para seleccionar todos los objetos
   - Esto incluye las imágenes de productos y cualquier otro archivo subido durante el despliegue

4. Haga clic en el botón **Eliminar**.

5. En la página de confirmación:
   - Escriba **eliminar permanentemente** en el campo de confirmación
   - Haga clic en el botón **Eliminar objetos**

6. Espere a que se complete la eliminación y haga clic en **Cerrar**.

**✓ Verificación**: El bucket `techshop-ha-{nombre-participante}-assets` aparece vacío (0 objetos).

> ⚠️ **Importante**: Si omite este paso, la eliminación de la pila de CloudFormation fallará con el error `DELETE_FAILED` en el recurso del bucket S3. En ese caso, vacíe el bucket manualmente y vuelva a intentar la eliminación de la pila.

---

## Paso 2: Eliminar la pila de CloudFormation

Una vez vaciado el bucket S3, puede proceder a eliminar la pila completa. CloudFormation se encargará de eliminar todos los recursos restantes (~25 recursos) en el orden correcto.

1. Utilice la barra de búsqueda global (parte superior) y escriba **CloudFormation**. Haga clic en el servicio **CloudFormation**.

2. En el panel de navegación de la izquierda, haga clic en **Pilas**.

3. Localice y seleccione la pila `techshop-ha-{nombre-participante}` haciendo clic en el nombre de la pila.

4. En la esquina superior derecha, haga clic en el botón **Eliminar**.

5. En el cuadro de diálogo de confirmación, haga clic en **Eliminar** para confirmar la eliminación.

6. Monitoree el progreso de la eliminación:
   - Seleccione la pestaña **Eventos** de la pila
   - Observe cómo CloudFormation elimina los recursos en orden inverso a su creación
   - Refresque la vista periódicamente haciendo clic en el icono de actualización

⏱️ **Nota**: El proceso de eliminación puede tardar entre 10 y 15 minutos. La base de datos RDS Multi-AZ es el recurso que más tiempo requiere, ya que debe eliminar la réplica síncrona en la segunda zona de disponibilidad antes de eliminar la instancia principal.

---

## Paso 3: Verificar eliminación completa

1. Permanezca en la consola de CloudFormation y espere a que el estado de la pila cambie a `DELETE_COMPLETE`.
   - Si la pila desaparece de la lista, significa que la eliminación se completó correctamente (las pilas con estado `DELETE_COMPLETE` solo son visibles si activa el filtro **Eliminadas** en la lista de pilas)

2. Verifique que la pila ya no aparece en la lista de pilas activas:
   - En la lista de pilas, confirme que `techshop-ha-{nombre-participante}` no aparece
   - Si desea confirmar el estado final, haga clic en el filtro de estado y seleccione **Eliminadas** para ver la pila con estado `DELETE_COMPLETE`

3. Tiempo estimado de eliminación: 10-15 minutos
   - Los Security Groups, IAM Roles y recursos de red se eliminan en segundos
   - El EFS FileSystem y los Mount Targets tardan 1-2 minutos
   - La distribución CloudFront tarda 2-5 minutos en deshabilitarse y eliminarse
   - La instancia RDS Multi-AZ es la que más tarda: 5-10 minutos

**✓ Verificación**: Confirme que todos los recursos han sido eliminados:
- La pila `techshop-ha-{nombre-participante}` muestra estado `DELETE_COMPLETE` o ya no aparece en la lista
- No quedan instancias EC2 del Auto Scaling Group en la consola de EC2
- La base de datos RDS ya no aparece en la consola de RDS
- El bucket S3 ya no aparece en la consola de S3
- La distribución CloudFront ya no aparece en la consola de CloudFront

---

## Advertencias Importantes

⚠️ **NO elimine la infraestructura del instructor**. Los siguientes recursos son compartidos por todos los participantes y NO deben eliminarse bajo ninguna circunstancia:
- **VPC** y sus subredes (públicas y privadas)
- **Internet Gateway**
- **NAT Gateway**
- **Tablas de enrutamiento** (públicas y privadas)

Estos recursos fueron desplegados por el instructor mediante la plantilla `TechShop-Instructor-Infra.yaml` y son utilizados por todos los participantes. Eliminarlos afectará el trabajo de los demás participantes.

⚠️ **Verifique el nombre de la pila**: Antes de hacer clic en "Eliminar", confirme que el nombre de la pila contiene su nombre de participante (`techshop-ha-{nombre-participante}`). No elimine pilas de otros participantes.

⚠️ **Pérdida permanente de datos**: Al eliminar la pila, se eliminan permanentemente todos los datos almacenados en la base de datos RDS, los archivos del sistema EFS y los objetos del bucket S3. Esta acción no se puede deshacer.

---

## Solución de Problemas Durante la Limpieza

### La pila queda en estado DELETE_FAILED

**Causa más común**: El bucket S3 no fue vaciado antes de iniciar la eliminación.

**Solución**:
1. Revise la pestaña **Eventos** para identificar qué recurso causó el fallo
2. Si el error es en el bucket S3, vaya a la consola de S3, vacíe el bucket manualmente y vuelva a intentar la eliminación de la pila
3. Si el problema persiste con otro recurso, notifique al instructor

### La eliminación tarda más de 20 minutos

**Solución**:
1. Revise la pestaña **Eventos** para ver qué recurso se está eliminando actualmente
2. La base de datos RDS Multi-AZ puede tardar hasta 15 minutos en eliminarse
3. Si el proceso parece detenido en un recurso específico por más de 30 minutos, notifique al instructor

---

## ¿Necesita ayuda?

Si encuentra problemas durante la limpieza de recursos, consulte la [Guía de Solución de Problemas](TROUBLESHOOTING.md) o notifique al instructor.
