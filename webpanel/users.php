<?php
require_once 'config.php';
checkAuth();
$fb = new FirebaseService();

// Fetch Users
$allUsers = $fb->getDocuments('users');

// Sort by Score Descending
usort($allUsers, function ($a, $b) {
    return ($b['score'] ?? 0) - ($a['score'] ?? 0);
});
?>

<!DOCTYPE html>
<html lang="tr">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kullanıcılar - Almanca App</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        :root {
            /* AppColors Matching Palette */
            --primary-bg: #e2e8f0; /* Darker Blue-Gray for Contrast */
            --sidebar-bg: #0F2027; /* AppColors.gradientDark */
            --sidebar-gradient: linear-gradient(180deg, #0F2027 0%, #203A43 50%, #2C5364 100%);
            --sidebar-width: 280px;
            --card-radius: 20px;
            --primary-color: #203A43;
            --accent-color: #2C5364;
            --success-color: #4CAF50;
            --primary-gradient: linear-gradient(135deg, #203A43 0%, #2C5364 100%);
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
            box-shadow: 4px 0 15px rgba(15, 32, 39, 0.3);
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
        }

        .nav-link:hover,
        .nav-link.active {
            color: white;
            background: rgba(255, 255, 255, 0.1);
            transform: translateX(5px);
        }

        .nav-link.active {
            background: rgba(255, 255, 255, 0.15);
            border-left: 4px solid #4CAF50;
            /* AppColors.correct */
            box-shadow: none;
        }

        .nav-link i {
            width: 20px;
            text-align: center;
        }

        .main-content {
            margin-left: var(--sidebar-width);
            padding: 2rem 3rem;
        }

        .content-card {
            background: var(--glass-bg);
            border-radius: var(--card-radius);
            padding: 2rem;
            border: none;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
        }

        .table thead th {
            border-bottom: 2px solid #f0f0f0;
            color: #888;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 0.85rem;
            padding-bottom: 1rem;
        }

        .table tbody td {
            padding: 1.2rem 0.5rem;
            color: #444;
            font-weight: 500;
            border-bottom: 1px solid #f8f8f8;
        }

        .rank-badge {
            width: 32px;
            height: 32px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            color: white;
        }
    </style>
</head>

<body>

    <nav class="sidebar">
        <div class="sidebar-brand">
            <div class="bg-white text-dark rounded-circle p-2 d-flex align-items-center justify-content-center"
                style="width:40px;height:40px;">
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
            <a href="users.php" class="nav-link active">
                <i class="fas fa-users"></i> <span>Kullanıcılar</span>
            </a>
            <a href="settings.php" class="nav-link">
                <i class="fas fa-cog"></i> <span>Ayarlar</span>
            </a>
            <a href="logout.php" class="nav-link mt-5">
                <i class="fas fa-sign-out-alt"></i> <span>Çıkış Yap</span>
            </a>
        </div>
    </nav>

    <main class="main-content">

        <div class="d-flex justify-content-between align-items-center mb-5">
            <div>
                <h2 class="fw-bold mb-1">Kullanıcılar</h2>
                <p class="text-muted mb-0">Toplam <?php echo count($allUsers); ?> kayıtlı üye</p>
            </div>
        </div>

        <div class="content-card">
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead>
                        <tr>
                            <th style="width: 50px;">#</th>
                            <th>Kullanıcı</th>
                            <th>Email</th>
                            <th>Puan</th>
                            <th>Kayıt</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php if (empty($allUsers)): ?>
                            <tr>
                                <td colspan="5" class="text-center py-5 text-muted">Kullanıcı bulunamadı</td>
                            </tr>
                        <?php else: ?>
                            <?php
                            $rank = 1;
                            foreach ($allUsers as $u):
                                $rankColor = '#cbd5e1'; // Default gray
                                if ($rank == 1)
                                    $rankColor = '#fbbf24'; // Gold
                                if ($rank == 2)
                                    $rankColor = '#94a3b8'; // Silver
                                if ($rank == 3)
                                    $rankColor = '#b45309'; // Bronze
                                ?>
                                <tr>
                                    <td>
                                        <div class="rank-badge" style="background: <?php echo $rankColor; ?>">
                                            <?php echo $rank++; ?>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="d-flex align-items-center gap-3">
                                            <div class="bg-light rounded-circle p-1">
                                                <img src="https://ui-avatars.com/api/?name=<?php echo urlencode($u['name'] ?? 'User'); ?>&background=random"
                                                    class="rounded-circle" width="36" height="36">
                                            </div>
                                            <span class="fw-bold text-dark"><?php echo $u['name'] ?? 'İsimsiz'; ?></span>
                                        </div>
                                    </td>
                                    <td class="text-secondary"><?php echo $u['email'] ?? '-'; ?></td>
                                    <td>
                                        <span
                                            class="badge bg-soft-warning text-warning bg-opacity-10 fs-6 px-3 py-2 border border-warning border-opacity-25">
                                            <i class="fas fa-star me-1"></i> <?php echo $u['score'] ?? 0; ?>
                                        </span>
                                    </td>
                                    <td class="text-muted small">
                                        <?php echo isset($u['createdAt']) ? date('d.m.Y', strtotime($u['createdAt'])) : '-'; ?>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>

    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>

</html>