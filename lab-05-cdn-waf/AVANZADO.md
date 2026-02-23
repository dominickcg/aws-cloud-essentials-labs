# Lab 4 - Sección Avanzada: Security Groups y Flujo Seguro

> **💡 Para curiosos:** Esta sección es opcional y está dirigida a estudiantes con más experiencia técnica.

## Requisitos previos
- Haber completado la sección básica del Lab 4
- ALB, CloudFront y WAF funcionando correctamente
- Conocimiento básico de Security Groups

## Duración adicional
+15-20 minutos

## Objetivo
Implementar el principio de mínimo privilegio configurando Security Groups para que solo permitan el tráfico necesario en cada capa de la arquitectura.

## Pasos

### 1. Configurar Security Groups para flujo seguro

Para implementar el principio de mínimo privilegio, vamos a configurar los Security Groups para que solo permitan el tráfico necesario en cada capa.

#### 1.1 Configurar Security Group del ALB
1. Ir a **EC2 → Security Groups**.
2. Buscar y seleccionar `alb-lab4-<tu-nombre>-sg`.
3. **Reglas de entrada → Editar reglas de entrada**:
   - **Eliminar** la regla HTTP (80) desde cualquier lugar (0.0.0.0/0)
   - **Agregar regla**:
     - **Tipo:** HTTP
     - **Puerto:** 80
     - **Origen:** Managed prefix list → `com.amazonaws.global.cloudfront.origin-facing`
     - **Descripción:** CloudFront traffic only
4. **Guardar reglas**

#### 1.2 Configurar Security Group de EC2
1. Buscar y seleccionar el Security Group de tu instancia EC2 del Lab 3.
2. **Reglas de entrada → Editar reglas de entrada**:
   - **Eliminar** la regla HTTP (80) desde cualquier lugar (0.0.0.0/0)
   - **Agregar regla**:
     - **Tipo:** HTTP
     - **Puerto:** 80
     - **Origen:** Security Group → `alb-lab4-<tu-nombre>-sg`
     - **Descripción:** ALB traffic only
   - **Mantener** la regla SSH (22) desde tu IP para administración
3. **Guardar reglas**

#### 1.3 Configurar Security Group de RDS
1. Buscar y seleccionar el Security Group de tu instancia RDS del Lab 3.
2. **Reglas de entrada → Editar reglas de entrada**:
   - **Eliminar** cualquier regla MySQL/Aurora (3306) desde Security Groups de EC2 genéricos
   - **Agregar regla**:
     - **Tipo:** MySQL/Aurora
     - **Puerto:** 3306
     - **Origen:** Security Group → [Security Group de tu EC2]
     - **Descripción:** EC2 traffic only
3. **Guardar reglas**

### 2. Verificar flujo de tráfico seguro

#### 2.1 Probar acceso restringido
1. **Acceso directo a EC2 (debe fallar):**
   - Intentar abrir la IP pública de EC2 en el navegador
   - **Resultado esperado:** Timeout o error de conexión

2. **Acceso directo a ALB (debe fallar):**
   - Intentar abrir el DNS del ALB en el navegador
   - **Resultado esperado:** Error 403 Forbidden

3. **Acceso a través de CloudFront (debe funcionar):**
   - Usar el dominio de CloudFront
   - **Resultado esperado:** La aplicación funciona correctamente

#### 2.2 Verificar conectividad de base de datos
1. **Conectarse por SSH a la instancia EC2** (usando tu IP permitida).
2. **Probar conexión a RDS:**
   ```bash
   mysql -h [RDS-ENDPOINT] -u admin -p
   ```
   - **Resultado esperado:** Conexión exitosa

## Resultado final

### Flujo de tráfico implementado:
```
Usuario → WAF → CloudFront → ALB → EC2 → RDS
```

### Beneficios de seguridad:
- ✅ **Principio de mínimo privilegio:** Cada capa solo acepta tráfico de la anterior
- ✅ **Sin acceso directo:** No se puede bypasear CloudFront o ALB
- ✅ **Base de datos protegida:** Solo EC2 puede acceder a RDS

## Nota sobre seguridad de credenciales

> **⚠️ Problema:** Nuestra aplicación aún tiene credenciales de base de datos hardcodeadas en el código PHP. Esto es una mala práctica de seguridad.

> **💡 Soluciones en producción:**
> - **AWS Secrets Manager:** Para almacenar credenciales de forma segura
> - **IAM Database Authentication:** Para autenticación sin passwords
> - **Variables de entorno:** Para separar configuración del código

## Limpieza adicional

1. Si completaste esta sección avanzada, no olvides **limpiar los Security Groups** modificados cuando elimines los recursos.

2. **O eliminar todo** siguiendo las instrucciones del README principal.