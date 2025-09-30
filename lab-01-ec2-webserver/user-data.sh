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
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mi Página en EC2</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; background: #f5f5f5; }
        .container { max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .ip-info { background: #e8f4fd; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .timestamp { color: #666; font-size: 0.9em; }
    </style>
</head>
<body>
    <div class="container">
        <h1>¡Hola desde Amazon EC2! 🚀</h1>
        <p>Esta página fue desplegada automáticamente con User Data.</p>
        <div class="ip-info">
            <p><strong>IP Privada:</strong> $PRIVATE_IP</p>
            <p><strong>IP Pública:</strong> $PUBLIC_IP</p>
        </div>
        <p class="timestamp">Desplegado el: $(date)</p>
        <p><em>Lab 1 - AWS Cloud Essentials</em></p>
    </div>
</body>
</html>
EOF