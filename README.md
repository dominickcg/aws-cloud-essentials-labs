# ☁️ AWS Cloud Essentials

## Descripción General

Bienvenido al programa **AWS Cloud Essentials**, una serie de laboratorios prácticos diseñados para desarrollar habilidades fundamentales en Amazon Web Services (AWS). Este programa está orientado a participantes que buscan comprender los servicios principales de AWS y aplicar mejores prácticas en la construcción de infraestructura en la nube.

A través de cuatro laboratorios progresivos, aprenderá a crear y configurar recursos esenciales de AWS, desde servidores web hasta bases de datos relacionales, pasando por redes virtuales y almacenamiento de objetos. Cada laboratorio está diseñado para ejecutarse en un entorno compartido, donde múltiples participantes trabajan simultáneamente siguiendo convenciones de nombres que garantizan la organización y evitan conflictos.

## Objetivos de Aprendizaje Generales

Al completar este programa, usted será capaz de:

- Desplegar y configurar instancias EC2 con servidores web funcionales
- Diseñar y construir arquitecturas de red con VPC, subredes públicas y privadas, y controles de acceso
- Implementar sitios web estáticos utilizando Amazon S3 con políticas de acceso público
- Integrar aplicaciones web con bases de datos relacionales usando Amazon RDS
- Aplicar mejores prácticas de seguridad mediante Security Groups y Network ACLs
- Gestionar recursos en la consola de AWS siguiendo convenciones de nombres en entornos compartidos

## Prerrequisitos del Programa

Antes de comenzar con los laboratorios, asegúrese de cumplir con los siguientes requisitos:

- **Cuenta de AWS**: Acceso a una cuenta de AWS con permisos para crear recursos (EC2, VPC, S3, RDS)
- **Conocimientos básicos**: Familiaridad con conceptos de redes (direcciones IP, subredes, puertos) y servidores web
- **Navegador web**: Navegador moderno actualizado para acceder a la consola de AWS
- **Región AWS**: Confirme con el instructor la región AWS asignada para el programa
- **Nombre de participante**: Identifique su nombre de participante único que utilizará como sufijo en todos los recursos

## Laboratorios

Este programa consta de cuatro laboratorios secuenciales. Se recomienda completarlos en orden, ya que algunos laboratorios dependen de recursos creados en laboratorios anteriores.

| Laboratorio | Título | Descripción | Tiempo Estimado |
|-------------|--------|-------------|-----------------|
| [Lab 01](./lab-01-ec2-webserver/) | Servidor Web en EC2 | Aprenda a lanzar una instancia EC2 y configurar un servidor web Apache con contenido personalizado | 30-45 minutos |
| [Lab 02](./lab-02-vpc-networking/) | Networking con VPC | Construya una arquitectura de red completa con VPC, subredes públicas y privadas, y controles de acceso | 60-90 minutos |
| [Lab 03](./lab-03-s3-staticwebsite/) | Sitio Web Estático en S3 | Implemente un sitio web estático utilizando Amazon S3 con hosting web y políticas de acceso público | 30-45 minutos |
| [Lab 04](./lab-04-rds-integration/) | Página Web Dinámica con RDS | Integre una aplicación web con una base de datos MySQL en Amazon RDS | 45-60 minutos |

## Contenido Adicional

**Nota**: El directorio `lab-05-cdn-waf` contiene material avanzado sobre CloudFront y AWS WAF que actualmente se encuentra en proceso de mejora. Este contenido no forma parte del programa principal AWS Cloud Essentials.

## Convenciones de Nombres

En todos los laboratorios, utilizará el placeholder `{nombre-participante}` al crear recursos AWS. Reemplace este placeholder con su nombre de participante asignado para identificar sus recursos en el entorno compartido.

**Ejemplo**: Si su nombre de participante es `carlos`, un recurso llamado `ec2-webserver-{nombre-participante}` se creará como `ec2-webserver-carlos`.

## Recursos Compartidos

Algunos recursos AWS son compartidos entre todos los participantes y están marcados explícitamente en los laboratorios con la nota "Recurso compartido - NO modificar". Nunca modifique o elimine recursos que no incluyan su nombre de participante como sufijo.

## Soporte

Cada laboratorio incluye:
- Instrucciones paso a paso con verificaciones visuales
- Documento de solución de problemas (TROUBLESHOOTING.md) con errores comunes
- Guía de limpieza opcional (LIMPIEZA.md) para eliminar recursos al finalizar

Si encuentra errores relacionados con permisos IAM o límites de cuota de AWS, notifique al instructor de inmediato.

---

¡Comience con el [Laboratorio 1: Servidor Web en EC2](./lab-01-ec2-webserver/) y disfrute su experiencia de aprendizaje en AWS!
