<?php
require_once 'config.php';

$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $password = $_POST['password'] ?? '';
    
    $fb = new FirebaseService();
    $settings = $fb->getAdminSettings();
    
    // Default password if not set in DB
    $correctPassword = $settings['password'] ?? 'anıl123';
    
    if ($password === $correctPassword) {
        $_SESSION['admin_logged_in'] = true;
        header('Location: index.php');
        exit;
    } else {
        $error = 'Hatalı şifre!';
    }
}
?>

<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Giriş - Almanca App</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-gradient: linear-gradient(135deg, #0F2027 0%, #203A43 50%, #2C5364 100%);
        }
        body {
            font-family: 'Outfit', sans-serif;
            background: var(--primary-gradient);
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0;
        }
        .login-card {
            background: rgba(255, 255, 255, 0.95);
            padding: 3rem;
            border-radius: 20px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.2);
            width: 100%;
            max-width: 400px;
            backdrop-filter: blur(10px);
        }
        .btn-primary {
            background: #203A43;
            border: none;
            padding: 0.8rem;
            font-weight: 600;
            border-radius: 12px;
            transition: all 0.3s;
        }
        .btn-primary:hover {
            background: #2C5364;
            transform: translateY(-2px);
        }
        .form-control {
            border-radius: 12px;
            padding: 0.8rem 1rem;
            border: 1px solid #ddd;
        }
        .form-control:focus {
            box-shadow: 0 0 0 3px rgba(32, 58, 67, 0.1);
            border-color: #203A43;
        }
    </style>
</head>
<body>
    <div class="login-card">
        <div class="text-center mb-4">
            <h2 class="fw-bold">Yönetim Paneli</h2>
            <p class="text-muted">Devam etmek için şifrenizi girin</p>
        </div>

        <?php if ($error): ?>
            <div class="alert alert-danger rounded-3 small border-0"><?php echo $error; ?></div>
        <?php endif; ?>

        <form method="POST">
            <div class="mb-4">
                <label class="form-label small fw-bold text-muted">ŞİFRE</label>
                <input type="password" name="password" class="form-control" placeholder="••••••••" required autofocus>
            </div>
            <button type="submit" class="btn btn-primary w-100 mb-3">Giriş Yap</button>
        </form>
    </div>
</body>
</html>
