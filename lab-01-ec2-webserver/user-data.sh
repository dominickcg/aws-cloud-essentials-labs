#!/bin/bash
# Actualizar paquetes
yum update -y

# Instalar, iniciar y habilitar servidor web Apache
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Obtener token para IMDSv2
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Obtener IP privada y pública usando el token
PRIVATE_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/public-ipv4)

# Crear página web simple
cat << EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Mi Página en EC2</title>
</head>
<body style="font-family: Arial; text-align: center; margin-top: 50px;">
    <h1>¡Hola desde Amazon EC2! 🚀</h1>
    <p>Esta página fue desplegada automáticamente con User Data.</p>
    <p>La IP privada de esta instancia es: <b>$PRIVATE_IP</b></p>
    <p>La IP pública de esta instancia es: <b>$PUBLIC_IP</b></p>
</body>
</html>
EOF