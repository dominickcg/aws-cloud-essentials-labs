# ☁️ AWS Cloud Essentials

## Descripción General

Bienvenido al programa **AWS Cloud Essentials**, una serie de laboratorios prácticos diseñados para desarrollar habilidades fundamentales en Amazon Web Services (AWS).

Este programa está orientado a personal de TI que busca comprender los servicios principales de AWS y aplicar mejores prácticas en la construcción de infraestructura en la nube.

A través de siete laboratorios progresivos, aprenderá a crear y configurar recursos esenciales de AWS, desde servidores web hasta arquitecturas de alta disponibilidad, pasando por redes virtuales, almacenamiento, bases de datos, seguridad y desacoplamiento. 

Cada laboratorio está diseñado para ejecutarse en un entorno compartido, donde múltiples participantes trabajan simultáneamente siguiendo convenciones de nombres que garantizan la organización y evitan conflictos.

## Objetivos de Aprendizaje Generales

Al completar este programa, usted será capaz de:

- Desplegar y configurar instancias EC2 con servidores web funcionales
- Diseñar y construir arquitecturas de red con VPC, subredes públicas y privadas, y controles de acceso
- Implementar sitios web estáticos utilizando Amazon S3 con políticas de acceso público
- Integrar aplicaciones web con bases de datos relacionales usando Amazon RDS
- Gestionar identidades y accesos con IAM
- Auditar acciones de usuarios con CloudTrail
- Implementar arquitecturas desacopladas con Amazon SNS y SQS
- Desplegar una arquitectura en alta disponibilidad con CloudFormation
- Aplicar mejores prácticas de seguridad mediante Grupos de seguridad, Network ACLs y AWS WAF
- Gestionar recursos en la consola de AWS siguiendo convenciones de nombres en entornos compartidos

## Prerrequisitos del Programa

Antes de comenzar con los laboratorios, asegúrese de cumplir con los siguientes requisitos:

- **Cuenta de AWS**: Acceso a una cuenta de AWS con permisos para crear recursos
- **Conocimientos básicos**: Familiaridad con conceptos de redes (direcciones IP, subredes, puertos) y servidores
- **Navegador web**: Navegador moderno actualizado para acceder a la consola de AWS
- **Región**: Confirme con el instructor la región de AWS asignada para el programa
- **Nombre de participante**: Identifique su nombre de participante único que utilizará como sufijo en todos los recursos

## Laboratorios

| Laboratorio | Título | Descripción | Tiempo Estimado |
|-------------|--------|-------------|-----------------|
| [Lab 01](./lab-01-computo-ec2/) | Servidor Web en EC2 | Lance una instancia EC2 y configure un servidor web Apache con contenido personalizado usando User Data | 30-45 min |
| [Lab 02](./lab-02-redes-vpc/) | Networking con VPC | Construya una arquitectura de red con VPC, subredes públicas y privadas, tablas de enrutamiento, Security Groups y NACLs | 50-60 min |
| [Lab 03](./lab-03-almacenamiento-s3/) | Sitio Web Estático en S3 | Implemente un sitio web estático en Amazon S3 con hosting web y políticas de acceso público | 30-40 min |
| [Lab 04](./lab-04-base-de-datos-rds/) | Página Web Dinámica con RDS | Integre una aplicación web PHP con una base de datos MySQL en Amazon RDS | 50-65 min |
| [Lab 05](./lab-05-seguridad-gobernanza/) | Seguridad, Identidad y Gobernanza | Gestione identidades con IAM, detecte amenazas con GuardDuty y audite actividad con CloudTrail | 60 min |
| [Lab 06](./lab-06-integracion-de-aplicaciones/) | Desacoplamiento con SNS y SQS | Implemente el patrón Fanout con Amazon SNS y SQS para comunicación asíncrona entre componentes | 40 min |
| [Lab 07](./lab-07-elasticidad/) | Elasticidad | Despliegue una arquitectura de misión crítica con CloudFormation, ALB, Auto Scaling, RDS Multi-AZ y WAF | 90 min |

## Convenciones de Nombres

En todos los laboratorios, utilizará el placeholder `{nombre-participante}` al crear recursos AWS. Reemplace este placeholder con su nombre de participante asignado para identificar sus recursos en el entorno compartido.

**Ejemplo**: Si su nombre de participante es `carlos`, un recurso llamado `ec2-webserver-{nombre-participante}` se creará como `ec2-webserver-carlos`.

## Recursos Compartidos

Algunos recursos AWS son compartidos entre todos los participantes y están marcados explícitamente en los laboratorios con la nota "Recurso compartido - NO modificar". Nunca modifique o elimine recursos que no incluyan su nombre de participante como sufijo.

## Soporte

Cada laboratorio incluye:
- Instrucciones paso a paso con verificaciones visuales
- Documento de solución de problemas (`TROUBLESHOOTING.md`) con errores comunes
- Guía de limpieza opcional (`LIMPIEZA.md`) para eliminar recursos al finalizar

Si encuentra errores relacionados con permisos IAM o límites de cuota de AWS, notifique al instructor de inmediato.

## Recursos Adicionales

- [Documentación oficial de AWS](https://docs.aws.amazon.com/)
- [AWS Skill Builder](https://skillbuilder.aws/)
- [Certificaciones AWS](https://aws.amazon.com/certification/)

## Contribuciones

Las contribuciones son bienvenidas. Si encuentra errores o tiene sugerencias de mejora, abra un issue o envíe un pull request.

## Licencia

Este proyecto está licenciado bajo la Licencia MIT. Copyright © 2026 AMBER CLOUD GLOBAL LLC.
