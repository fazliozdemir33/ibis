<?php
require_once 'config.php';
checkAuth();

$fb = new FirebaseService();
$successMsg = '';
$errorMsg = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'update_password') {
    $currentPassword = $_POST['current_password'];
    $newPassword = $_POST['new_password'];
    $confirmPassword = $_POST['confirm_password'];

    $settings = $fb->getAdminSettings();
    $dbPassword = $settings['password'] ?? 'anıl123';

    if ($currentPassword !== $dbPassword) {
        $errorMsg = "Mevcut şifre hatalı!";
    } elseif ($newPassword !== $confirmPassword) {
        $errorMsg = "Yeni şifreler eşleşmiyor!";
    } elseif (strlen($newPassword) < 4) {
        $errorMsg = "Yeni şifre en az 4 karakter olmalıdır!";
    } else {
        $fb->updateAdminSettings(['password' => $newPassword]);
        $successMsg = "Şifre başarıyla güncellendi!";
    }
}
?>

<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ayarlar - Almanca App</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-bg: #e2e8f0;
            --sidebar-gradient: linear-gradient(180deg, #0F2027 0%, #203A43 50%, #2C5364 100%);
            --sidebar-width: 280px;
            --card-radius: 20px;
            --glass-bg: rgba(255, 255, 255, 0.98);
        }
        body {
            font-family: 'Outfit', sans-serif;
            background-color: var(--primary-bg);
            color: #333;
        }
        .sidebar {
            width: var(--sidebar-width);
            height: 100vh;
            position: fixed;
            left: 0;
            top: 0;
            background: var(--sidebar-gradient);
            color: white;
            z-index: 1000;
            padding: 2rem 1.5rem;
        }
        .sidebar-brand {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 3rem;
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        .nav-link {
            color: rgba(255, 255, 255, 0.6);
            padding: 1rem 1.5rem;
            border-radius: 12px;
            margin-bottom: 0.5rem;
            display: flex;
            align-items: center;
            gap: 1rem;
            transition: all 0.3s;
            font-weight: 500;
            text-decoration: none;
        }
        .nav-link:hover, .nav-link.active {
            color: white;
            background: rgba(255, 255, 255, 0.1);
        }
        .nav-link.active {
            border-left: 4px solid #4CAF50;
        }
        .main-content {
            margin-left: var(--sidebar-width);
            padding: 2rem 3rem;
        }
        .content-card {
            background: var(--glass-bg);
            border-radius: var(--card-radius);
            padding: 2.5rem;
            border: none;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
            max-width: 600px;
        }
        .form-control {
            border-radius: 12px;
            padding: 0.8rem 1.2rem;
            border: 1px solid #eef2f7;
            background: #f8fafc;
        }
        .btn-primary {
            background: #203A43;
            border: none;
            padding: 0.8rem 2rem;
            border-radius: 12px;
            font-weight: 600;
        }
    </style>
</head>
<body>
    <nav class="sidebar">
        <div class="sidebar-brand">
            <div class="bg-white text-dark rounded-circle p-2 d-flex align-items-center justify-content-center" style="width:40px;height:40px;">
                <i class="fas fa-cube"></i>
            </div>
            <span>Almanca App</span>
        </div>
        <div class="nav flex-column">
            <a href="index.php" class="nav-link">
                <i class="fas fa-home"></i> <span>Dashboard</span>
            </a>
            <a href="words.php" class="nav-link">
                <i class="fas fa-book-open"></i> <span>Kelime Yönetimi</span>
            </a>
            <a href="users.php" class="nav-link">
                <i class="fas fa-users"></i> <span>Kullanıcılar</span>
            </a>
            <a href="settings.php" class="nav-link active">
                <i class="fas fa-cog"></i> <span>Ayarlar</span>
            </a>
            <a href="logout.php" class="nav-link mt-5">
                <i class="fas fa-sign-out-alt"></i> <span>Çıkış Yap</span>
            </a>
        </div>
    </nav>

    <main class="main-content">
        <div class="mb-5">
            <h2 class="fw-bold mb-1">Panel Ayarları</h2>
            <p class="text-muted">Güvenlik ve genel ayarlar</p>
        </div>

        <?php if ($successMsg): ?>
            <div class="alert alert-success border-0 shadow-sm rounded-3 mb-4">
                <i class="fas fa-check-circle me-2"></i> <?php echo $successMsg; ?>
            </div>
        <?php endif; ?>

        <?php if ($errorMsg): ?>
            <div class="alert alert-danger border-0 shadow-sm rounded-3 mb-4">
                <i class="fas fa-exclamation-circle me-2"></i> <?php echo $errorMsg; ?>
            </div>
        <?php endif; ?>

        <div class="content-card">
            <h5 class="fw-bold mb-4">Admin Şifresini Değiştir</h5>
            <form method="POST">
                <input type="hidden" name="action" value="update_password">
                <div class="mb-3">
                    <label class="form-label text-muted small fw-bold">MEVCUT ŞİFRE</label>
                    <input type="password" name="current_password" class="form-control" required>
                </div>
                <div class="mb-3">
                    <label class="form-label text-muted small fw-bold">YENİ ŞİFRE</label>
                    <input type="password" name="new_password" class="form-control" required>
                </div>
                <div class="mb-4">
                    <label class="form-label text-muted small fw-bold">YENİ ŞİFRE (TEKRAR)</label>
                    <input type="password" name="confirm_password" class="form-control" required>
                </div>
                <button type="submit" class="btn btn-primary">Şifreyi Güncelle</button>
            </form>
        </div>
    </main>
</body>
</html>
