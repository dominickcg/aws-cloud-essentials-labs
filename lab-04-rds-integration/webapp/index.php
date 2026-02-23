    <?php
    require_once 'config.php';

    // Procesar formulario si se envió
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
                $errores[] = 'Email no es válido';
            }
            
            // Validar teléfono (opcional)
            $telefono = trim($_POST['telefono']);
            if (!empty($telefono) && (!preg_match('/^[0-9+\-\s\(\)]{7,20}$/', $telefono))) {
                $errores[] = 'Teléfono debe contener solo números, +, -, espacios y paréntesis (7-20 caracteres)';
            }
            
            if (empty($errores)) {
                try {
                    $pdo = conectarDB();
                    $stmt = $pdo->prepare("INSERT INTO formulario (nombre, apellido, email, telefono) VALUES (?, ?, ?, ?)");
                    $stmt->execute([$nombre, $apellido, $email, $telefono]);
                    $mensaje = '<div class="alert success">Datos guardados exitosamente</div>';
                } catch (PDOException $e) {
                    if ($e->getCode() == 23000) {
                        $mensaje = '<div class="alert error">Error: El email ya está registrado</div>';
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
        <title>Lab 3 - Página Web Dinámica</title>
        <link rel="stylesheet" href="styles.css">
    </head>
    <body>
        <div class="container">
            <header>
                <h1>Lab 3: Página Web Dinámica</h1>
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
                                   title="Ingresa un email válido">
                        </div>
                        
                        <div class="form-group">
                            <label for="telefono">Teléfono:</label>
                            <input type="tel" id="telefono" name="telefono" 
                                   pattern="[0-9+\-\s\(\)]{7,20}" 
                                   title="Solo números, +, -, espacios y paréntesis, entre 7 y 20 caracteres"
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
                        <div class="alert info">No hay registros aún. Registra los primeros datos.</div>
                    <?php else: ?>
                        <table>
                            <thead>
                                <tr>
                                    <th>Nombre</th>
                                    <th>Apellido</th>
                                    <th>Email</th>
                                    <th>Teléfono</th>
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