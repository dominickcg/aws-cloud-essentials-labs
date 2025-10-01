# Lab 4: Arquitectura Segura con WAF, CloudFront y ALB

## Objetivos
- Implementar una arquitectura web realista con múltiples capas
- Configurar protección global con WAF y CloudFront
- Verificar protección contra ataques web comunes

## Duración estimada
- **Básico:** 30–35 minutos
- **Con sección avanzada:** 45–60 minutos

## Requisitos
- Lab 3 completado y funcionando
- Cuenta de AWS con permisos para EC2, ELB, CloudFront, WAF y RDS
- Navegador web para acceder a la aplicación

## Pasos

### 1. Crear Application Load Balancer con CloudFront y WAF

#### 1.1 Crear Target Group
1. Ir a **EC2 → Equilibrio de carga → Grupos de destino**.
2. **Crear un grupo de destino**:
   - **Tipo de destino:** Instancias
   - **Nombre del grupo de destino:** `tg-lab4-<tu-nombre>`
   - **Protocolo:** HTTP
   - **Puerto:** 80
   - **VPC:** Seleccionar la VPC por defecto
   - **Versión del protocolo:** HTTP1
3. **Configuración de health check:**
   - **Protocolo de comprobación de estado:** HTTP
   - **Ruta de comprobación de estado:** `/` (página principal)
4. **Siguiente → Registrar destinos**:
   - Seleccionar tu instancia EC2 del Lab 3
   - **Puerto:** 80
   - **Incluir como pendiente a continuación**
5. **Crear un grupo de destino**

#### 1.2 Crear Application Load Balancer con integración CloudFront
1. Ir a **EC2 → Equilibrio de carga → Balanceadores de carga**.
2. **Crear balanceador de carga → Balanceador de carga de aplicaciones**:
   - **Nombre:** `alb-lab4-<tu-nombre>`
   - **Esquema:** Expuesto a Internet
   - **Tipo de dirección IP:** IPv4
3. **Mapeo de red:**
   - **VPC:** VPC por defecto
   - **Zonas de disponibilidad:** Seleccionar las 3 AZs
4. **Security groups:**
   - Crear nuevo security group: `alb-lab4-<tu-nombre>-sg`
   - **Reglas de entrada:**
     - HTTP (80) desde cualquier lugar
5. **Agentes de escucha y direccionamiento:**
   - **Protocolo:** HTTP
   - **Puerto:** 80
   - **Acción predeterminada:** Reenviar a los grupos de destino
   - **Grupo de destino:** `tg-lab4-<tu-nombre>`
6. **Optimizar con integraciones de servicios → Amazon CloudFront + Firewall de aplicaciones web (WAF) de AWS**
   - **Aplique protecciones de seguridad y aceleración en la capa de aplicación, frente al equilibrador de carga**
   - **Agregue un grupo de seguridad a su equilibrador de carga para asegurarse de que su agente de escucha HTTP permita el tráfico entrante que se origina en CloudFront.**
7. **Crear balanceador de carga**

### 2. Verificar acceso en arquitectura básica

1. **Esperar que el ALB esté en estado "Active"** (2-3 minutos).
2. **Acceso a través de ALB:**
   - Usar el DNS del ALB
   - Verificar que funciona
3. **Acceso a través de CloudFront:**
   - Esperar que el estado sea "Deployed" (5-10 minutos)
   - Usar el dominio de CloudFront (ejemplo: `d1234567890.cloudfront.net`)
   - Verificar que funciona

### 3. Verificar protección WAF básica

#### 3.1 Revisar configuración WAF
1. Ir a **WAF & Shield → Web ACLs**.
2. Encontrar el Web ACL creado automáticamente (nombre similar a `CloudFront-[ID]`).
3. **Reglas:** Ver las reglas de protección automáticamente configuradas.

#### 3.2 Probar protección contra XSS
1. **Abrir el dominio de CloudFront** en el navegador.
2. **Intentar un ataque XSS simple** agregando el siguiente parámetro a la URL:
   ```
   https://d1234567890.cloudfront.net/?test=<script>alert('XSS')</script>
   ```
3. **Resultado esperado:** Error 403 Forbidden o página de bloqueo de WAF
4. **Verificar el bloqueo:**
   - Ir a **WAF & Shield → Web ACLs → [tu-web-acl] → Métricas**
   - Observar que el contador de "Blocked requests" ha aumentado

---

## 🔒 Sección Avanzada (Opcional)

> **💡 Para curiosos:** ¿Quieres profundizar en seguridad por capas y principio de mínimo privilegio? 
> 
> **👉 [Continúa con la Sección Avanzada](AVANZADO.md)** (+15-20 minutos)
>
> La sección avanzada cubre:
> - Configuración de Security Groups para flujo seguro
> - Implementación del principio de mínimo privilegio
> - Verificación de acceso restringido por capas

---

## Limpieza de recursos

Para evitar costos innecesarios:

1. **Eliminar distribución CloudFront:**
   - **CloudFront → Distribuciones → [tu-distribución] → Deshabilitar**
   - Esperar que se deshabilite, luego **Eliminar**
   - El Web ACL se eliminará automáticamente

2. **Eliminar Application Load Balancer:**
   - **EC2 → Equilibrio de carga → Balanceadores de carga → [tu-alb] → Acciones → Eliminar**

3. **Eliminar Target Group:**
   - **EC2 → Equilibrio de carga → Grupos de destino → [tu-tg] → Acciones → Eliminar**

4. **Eliminar Security Group del ALB:**
   - **EC2 → Security Groups → alb-lab4-<tu-nombre>-sg → Acciones → Eliminar**

5. **Recursos del Lab 3** (si no los necesitas):
   - Instancia RDS
   - Instancia EC2
   - Security Groups