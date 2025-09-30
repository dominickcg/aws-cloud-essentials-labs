#!/bin/bash
# User Data script para Lab 3 - Pagina Web Dinamica con RDS

# Actualizar paquetes
yum update -y

# Instalar Apache, PHP y MySQL client
yum install -y httpd php php-mysqlnd mariadb105
systemctl start httpd
systemctl enable httpd

cd /var/www/html

# Crear config.php
cat << 'EOF' > config.php
<?php
// Configuracion de la base de datos RDS
define('DB_HOST', '[RDS-ENDPOINT]'); // Reemplazar con el endpoint real de RDS
define('DB_NAME', 'lab3_rds');
define('DB_USER', 'admin');
define('DB_PASS', 'Lab123456*'); // Usar la contrasena configurada en RDS

// Configurar zona horaria GMT-5
date_default_timezone_set('America/Lima');

// Funcion para conectar a la base de datos
function conectarDB() {
    try {
        $pdo = new PDO(
            "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8",
            DB_USER,
            DB_PASS,
            [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
            ]
        );
        // Configurar zona horaria para esta conexion
        $pdo->exec("SET time_zone = '-05:00'");
        $pdo->exec("SET SESSION time_zone = '-05:00'");
        return $pdo;
    } catch (PDOException $e) {
        die("Error de conexion: " . $e->getMessage());
    }
}
?>
EOF

# Crear index.php
cat << 'EOF' > index.php
<?php
require_once 'config.php';

// Procesar formulario si se envio
$mensaje = '';
if ($_POST && isset($_POST['accion'])) {
    if ($_POST['accion'] == 'registrar') {
        // Validaciones del servidor
        $errores = [];
        
        // Validar nombre
        $nombre = trim($_POST['nombre']);
        if (empty($nombre) || !preg_match('/^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]{2,50}$/', $nombre)) {
            $errores[] = 'Nombre debe contener solo letras y espacios (2-50 caracteres)';
        }
        
        // Validar apellido
        $apellido = trim($_POST['apellido']);
        if (empty($apellido) || !preg_match('/^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]{2,50}$/', $apellido)) {
            $errores[] = 'Apellido debe contener solo letras y espacios (2-50 caracteres)';
        }
        
        // Validar email
        $email = trim($_POST['email']);
        if (empty($email) || !filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($email) > 150) {
            $errores[] = 'Email no es valido';
        }
        
        // Validar telefono (opcional)
        $telefono = trim($_POST['telefono']);
        if (!empty($telefono) && (!preg_match('/^[0-9+\-\s\(\)]{7,20}$/', $telefono))) {
            $errores[] = 'Telefono debe contener solo numeros, +, -, espacios y parentesis (7-20 caracteres)';
        }
        
        if (empty($errores)) {
            try {
                $pdo = conectarDB();
                $stmt = $pdo->prepare("INSERT INTO formulario (nombre, apellido, email, telefono) VALUES (?, ?, ?, ?)");
                $stmt->execute([$nombre, $apellido, $email, $telefono]);
                $mensaje = '<div class="alert success">Datos guardados exitosamente</div>';
            } catch (PDOException $e) {
                if ($e->getCode() == 23000) {
                    $mensaje = '<div class="alert error">Error: El email ya esta registrado</div>';
                } else {
                    $mensaje = '<div class="alert error">Error: ' . $e->getMessage() . '</div>';
                }
            }
        } else {
            $mensaje = '<div class="alert error">Errores encontrados:<br>• ' . implode('<br>• ', $errores) . '</div>';
        }
    }
}

// Obtener registros si se solicita
$mostrar_registros = isset($_POST['accion']) && $_POST['accion'] == 'ver_registros';
$registros = [];
if ($mostrar_registros) {
    try {
        $pdo = conectarDB();
        $stmt = $pdo->query("SELECT * FROM formulario ORDER BY fecha_registro DESC");
        $registros = $stmt->fetchAll();
    } catch (PDOException $e) {
        $mensaje = '<div class="alert error">Error al obtener registros: ' . $e->getMessage() . '</div>';
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lab 3 - P&aacute;gina Web Din&aacute;mica</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>Lab 3: P&aacute;gina Web Din&aacute;mica</h1>
            <p>Conectando EC2 con RDS MySQL</p>
        </header>

        <main>
            <?php echo $mensaje; ?>
            
            <div class="form-container">
                <h2>Formulario de Registro</h2>
                <form method="POST" action="">
                    <input type="hidden" name="accion" value="registrar">
                    
                    <div class="form-group">
                        <label for="nombre">Nombre:</label>
                        <input type="text" id="nombre" name="nombre" required 
                               pattern="[A-Za-zÁÉÍÓÚáéíóúÑñ\s]{2,50}" 
                               title="Solo letras y espacios, entre 2 y 50 caracteres"
                               maxlength="50">
                    </div>
                    
                    <div class="form-group">
                        <label for="apellido">Apellido:</label>
                        <input type="text" id="apellido" name="apellido" required 
                               pattern="[A-Za-zÁÉÍÓÚáéíóúÑñ\s]{2,50}" 
                               title="Solo letras y espacios, entre 2 y 50 caracteres"
                               maxlength="50">
                    </div>
                    
                    <div class="form-group">
                        <label for="email">Email:</label>
                        <input type="email" id="email" name="email" required 
                               maxlength="150"
                               title="Ingresa un email valido">
                    </div>
                    
                    <div class="form-group">
                        <label for="telefono">Tel&eacute;fono:</label>
                        <input type="tel" id="telefono" name="telefono" 
                               pattern="[0-9+\-\s\(\)]{7,20}" 
                               title="Solo numeros, +, -, espacios y parentesis, entre 7 y 20 caracteres"
                               maxlength="20"
                               placeholder="+51 999 123 456">
                    </div>
                    
                    <button type="submit" class="btn-primary">Registrar Datos</button>
                </form>
                
                <div class="button-container">
                    <form method="POST" action="" style="display: inline;">
                        <input type="hidden" name="accion" value="ver_registros">
                        <button type="submit" class="btn-secondary">Ver Todos los Registros</button>
                    </form>
                </div>
            </div>

            <?php if ($mostrar_registros): ?>
            <div class="table-container">
                <h2>Registros Almacenados (<?php echo count($registros); ?>)</h2>
                
                <?php if (empty($registros)): ?>
                    <div class="alert info">No hay registros aun. Registra los primeros datos.</div>
                <?php else: ?>
                    <table>
                        <thead>
                            <tr>
                                <th>Nombre</th>
                                <th>Apellido</th>
                                <th>Email</th>
                                <th>Tel&eacute;fono</th>
                                <th>Fecha</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($registros as $registro): ?>
                            <tr>
                                <td><?php echo htmlspecialchars($registro['nombre']); ?></td>
                                <td><?php echo htmlspecialchars($registro['apellido']); ?></td>
                                <td><?php echo htmlspecialchars($registro['email']); ?></td>
                                <td><?php echo htmlspecialchars($registro['telefono'] ?: 'N/A'); ?></td>
                                <td><?php echo date('d/m/Y H:i', strtotime($registro['fecha_registro'])); ?></td>
                            </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                <?php endif; ?>
            </div>
            <?php endif; ?>
        </main>

        <footer>
            <p>&copy; 2025 - AWS Cloud Essentials Lab 3</p>
        </footer>
    </div>
</body>
</html>
EOF

# Crear styles.css
cat << 'EOF' > styles.css
/* Estilos simples para Lab 3 */

body {
    font-family: Arial, sans-serif;
    margin: 0;
    padding: 20px;
    background: #f5f5f5;
}

.container {
    max-width: 800px;
    margin: 0 auto;
    background: white;
    padding: 30px;
    border-radius: 10px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

header {
    text-align: center;
    background: #007bff;
    color: white;
    padding: 20px;
    border-radius: 8px;
    margin-bottom: 30px;
}

.form-container, .table-container {
    background: #f8f9fa;
    padding: 20px;
    border-radius: 8px;
    margin-bottom: 20px;
}

.form-group {
    margin-bottom: 15px;
}

.form-group label {
    display: block;
    margin-bottom: 5px;
    font-weight: bold;
}

.form-group input, textarea {
    width: 100%;
    padding: 10px;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 16px;
}

.btn-primary, .btn-secondary {
    padding: 10px 20px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 16px;
    margin: 5px;
}

.btn-primary {
    background: #007bff;
    color: white;
}

.btn-secondary {
    background: #28a745;
    color: white;
}

.button-container {
    text-align: center;
    margin-top: 20px;
    padding-top: 20px;
    border-top: 1px solid #ddd;
}

table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 15px;
}

table th, table td {
    padding: 10px;
    text-align: left;
    border-bottom: 1px solid #ddd;
}

table th {
    background: #007bff;
    color: white;
}

.alert {
    padding: 15px;
    border-radius: 4px;
    margin-bottom: 20px;
}

.alert.success {
    background: #d4edda;
    color: #155724;
}

.alert.error {
    background: #f8d7da;
    color: #721c24;
}

.alert.info {
    background: #d1ecf1;
    color: #0c5460;
}

footer {
    text-align: center;
    margin-top: 30px;
    padding-top: 20px;
    border-top: 1px solid #ddd;
    color: #666;
}
EOF

# Crear database-setup.sql
cat << 'EOF' > database-setup.sql
-- Script para configurar la base de datos del Lab 3

CREATE DATABASE IF NOT EXISTS lab3_rds;
USE lab3_rds;

SET time_zone = '-05:00';

CREATE TABLE IF NOT EXISTS formulario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    fecha_registro DATETIME DEFAULT (NOW())
);

DESCRIBE formulario;
EOF

# Establecer permisos correctos
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html