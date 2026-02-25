<?php
require_once 'config.php';
$fb = new FirebaseService();

// Stats
$allWords = $fb->getDocuments('words');
$allUsers = $fb->getDocuments('users');
$wordCount = count($allWords);
$userCount = count($allUsers);

// Recent items
$recentWords = array_slice($allWords, 0, 5);
?>

<!DOCTYPE html>
<html lang="tr">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Almanca App - Admin Dashboard</title>

    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <!-- Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        :root {
            /* AppColors Matching Palette */
            --primary-bg: #e2e8f0;
            /* Darker Blue-Gray for Contrast */
            --sidebar-bg: #0F2027;
            /* AppColors.gradientDark */
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
            color: #2C5364;
        }

        /* Sidebar */
        .sidebar {
            width: var(--sidebar-width);
            height: 100vh;
            position: fixed;
            left: 0;
            top: 0;
            background: var(--sidebar-gradient);
            color: white;
            transition: all 0.3s ease;
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

        /* Main Content */
        .main-content {
            margin-left: var(--sidebar-width);
            padding: 2rem 3rem;
        }

        /* Stats Cards */
        .stat-card {
            background: var(--glass-bg);
            border-radius: var(--card-radius);
            padding: 1.5rem;
            border: none;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
            transition: transform 0.3s;
            position: relative;
            overflow: hidden;
        }

        .stat-card:hover {
            transform: translateY(-5px);
        }

        .stat-icon {
            width: 60px;
            height: 60px;
            border-radius: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            margin-bottom: 1rem;
        }

        .stat-card.primary .stat-icon {
            background: rgba(44, 83, 100, 0.1);
            color: #2C5364;
        }

        .stat-card.success .stat-icon {
            background: rgba(76, 175, 80, 0.1);
            color: #4CAF50;
        }

        /* Table */
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

        .badge-level {
            padding: 8px 16px;
            border-radius: 50px;
            font-weight: 600;
            font-size: 0.85rem;
        }

        @media (max-width: 991px) {
            .sidebar {
                transform: translateX(-100%);
            }

            .main-content {
                margin-left: 0;
                padding: 1.5rem;
            }
        }
    </style>
</head>

<body>

    <!-- Sidebar -->
    <nav class="sidebar">
        <div class="sidebar-brand">
            <div class="bg-white text-dark rounded-circle p-2 d-flex align-items-center justify-content-center"
                style="width:40px;height:40px;">
                <i class="fas fa-cube"></i>
            </div>
            <span>Almanca App</span>
        </div>

        <div class="nav flex-column">
            <a href="index.php" class="nav-link active">
                <i class="fas fa-home"></i> <span>Dashboard</span>
            </a>
            <a href="words.php" class="nav-link">
                <i class="fas fa-book-open"></i> <span>Kelime Yönetimi</span>
            </a>
            <a href="users.php" class="nav-link">
                <i class="fas fa-users"></i> <span>Kullanıcılar</span>
            </a>
            <a href="#" class="nav-link mt-5">
                <i class="fas fa-sign-out-alt"></i> <span>Çıkış Yap</span>
            </a>
        </div>
    </nav>

    <!-- Main Content -->
    <main class="main-content">

        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-5">
            <div>
                <h2 class="fw-bold mb-1">Hoş Geldiniz 👋</h2>
                <p class="text-muted mb-0">Uygulama istatistikleri ve yönetimi</p>
            </div>

            <div class="d-flex gap-3">
                <button class="btn btn-white bg-white shadow-sm p-2 rounded-circle border-0">
                    <i class="fas fa-bell text-muted"></i>
                </button>
                <div class="d-flex align-items-center gap-3 bg-white px-3 py-2 rounded-pill shadow-sm">
                    <div class="bg-light rounded-circle p-1">
                        <img src="https://ui-avatars.com/api/?name=Admin&background=random" class="rounded-circle"
                            width="32" height="32">
                    </div>
                    <span class="fw-bold pe-2">Admin</span>
                </div>
            </div>
        </div>

        <!-- Stats Row -->
        <div class="row g-4 mb-5">
            <div class="col-md-6 col-lg-4">
                <div class="stat-card primary">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="stat-icon">
                                <i class="fas fa-language"></i>
                            </div>
                            <h6 class="text-muted mb-1">Toplam Kelime</h6>
                            <h2 class="fw-bold mb-0"><?php echo $wordCount; ?></h2>
                        </div>
                        <span class="badge bg-soft-primary text-primary bg-opacity-10">+12%</span>
                    </div>
                </div>
            </div>

            <div class="col-md-6 col-lg-4">
                <div class="stat-card success">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="stat-icon">
                                <i class="fas fa-users"></i>
                            </div>
                            <h6 class="text-muted mb-1">Toplam Kullanıcı</h6>
                            <h2 class="fw-bold mb-0"><?php echo $userCount; ?></h2>
                        </div>
                        <span class="badge bg-soft-success text-success bg-opacity-10">+5%</span>
                    </div>
                </div>
            </div>

            <div class="col-md-6 col-lg-4">
                <div class="stat-card" style="background: var(--primary-gradient); color: white;">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="stat-icon" style="background: rgba(255,255,255,0.2); color: white;">
                                <i class="fas fa-star"></i>
                            </div>
                            <h6 class="text-white-50 mb-1">Premium Üyelik</h6>
                            <h2 class="fw-bold mb-0 text-white">PRO</h2>
                        </div>
                    </div>
                    <div class="mt-3 text-white-50 small">
                        Admin paneli aktif
                    </div>
                </div>
            </div>
        </div>

        <!-- Recent Tables -->
        <div class="content-card">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h5 class="fw-bold mb-0">Son Eklenen Kelimeler</h5>
                <a href="words.php" class="btn btn-primary btn-sm rounded-pill px-3">Tümünü Gör</a>
            </div>

            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead>
                        <tr>
                            <th>Seviye</th>
                            <th>Almanca</th>
                            <th>Türkçe</th>
                            <th>Durum</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php if (empty($recentWords)): ?>
                            <tr>
                                <td colspan="4" class="text-center py-4 text-muted">Henüz veri yok</td>
                            </tr>
                        <?php else: ?>
                            <?php foreach ($recentWords as $w):
                                $badgeColor = match ($w['level'] ?? '') {
                                    'A1' => '#22c55e',
                                    'A2' => '#3b82f6',
                                    'B1' => '#f59e0b',
                                    'B2' => '#ef4444',
                                    default => '#6366f1'
                                };
                                ?>
                                <tr>
                                    <td>
                                        <span class="badge-level"
                                            style="background: <?php echo $badgeColor; ?>20; color: <?php echo $badgeColor; ?>">
                                            <?php echo $w['level'] ?? '-'; ?>
                                        </span>
                                    </td>
                                    <td class="fw-bold text-dark"><?php echo $w['german'] ?? '-'; ?></td>
                                    <td class="text-muted"><?php echo $w['turkish'] ?? '-'; ?></td>
                                    <td><span class="badge bg-light text-dark rounded-pill"><i
                                                class="fas fa-check-circle text-success me-1"></i> Aktif</span></td>
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