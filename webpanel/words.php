<?php
require_once 'config.php';
$fb = new FirebaseService();

// Action Logic
$successMsg = '';
$errorMsg = '';

// TEK KELİME EKLEME
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'add_word') {
    $german = trim($_POST['german']);
    $turkish = trim($_POST['turkish']);
    $level = trim($_POST['level']);

    if ($german && $turkish) {
        $fb->addDocument('words', [
            'german' => $german,
            'turkish' => $turkish,
            'level' => $level,
            'createdAt' => date('Y-m-d\TH:i:s\Z')
        ]);
        $successMsg = "Kelime başarıyla eklendi!";
    }
}

// TOPLU KELİME EKLEME (BULK UPLOAD)
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'bulk_add') {
    $content = $_POST['bulk_content'];
    $level = $_POST['level'];
    $count = 0;

    // Satırlara böl
    $lines = preg_split('/\r\n|\r|\n/', $content);

    foreach ($lines as $line) {
        // Boş satırları atla
        if (empty(trim($line)))
            continue;

        // ":" işaretine göre ayır (Almanca : Türkçe)
        // Eğer : yoksa bu satırı atla
        if (strpos($line, ':') !== false) {
            $parts = explode(':', $line);
            if (count($parts) >= 2) {
                $german = trim($parts[0]);
                $turkish = trim($parts[1]);

                // İkisi de doluysa ekle
                if (!empty($german) && !empty($turkish)) {
                    $fb->addDocument('words', [
                        'german' => $german,
                        'turkish' => $turkish,
                        'level' => $level,
                        'createdAt' => date('Y-m-d\TH:i:s\Z')
                    ]);
                    $count++;
                }
            }
        }
    }

    if ($count > 0) {
        $successMsg = "Harika! Toplam <b>$count</b> kelime başarıyla eklendi.";
    } else {
        $errorMsg = "Hiçbir kelime eklenemedi. Formatı kontrol et: 'Almanca : Türkçe'";
    }
}

if (isset($_GET['delete'])) {
    $fb->deleteDocument('words', $_GET['delete']);
    header("Location: words.php");
    exit;
}

// Fetch Data
$allWords = $fb->getDocuments('words');

// Filter
$selectedLevel = $_GET['level'] ?? '';
if ($selectedLevel) {
    $allWords = array_filter($allWords, function ($w) use ($selectedLevel) {
        return isset($w['level']) && $w['level'] === $selectedLevel;
    });
}
?>

<!DOCTYPE html>
<html lang="tr">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kelime Yönetimi - Almanca App</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
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

        .badge-level {
            padding: 8px 16px;
            border-radius: 50px;
            font-weight: 600;
            font-size: 0.85rem;
        }

        .btn-gradient {
            background: var(--primary-gradient);
            color: white;
            border: none;
            padding: 10px 24px;
            border-radius: 12px;
            font-weight: 600;
            transition: all 0.3s;
        }

        .btn-gradient:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(99, 102, 241, 0.4);
            color: white;
        }

        .bulk-textarea {
            font-family: 'Courier New', monospace;
            font-size: 0.9rem;
            line-height: 1.6;
            background: #f8fafc;
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
            <a href="words.php" class="nav-link active">
                <i class="fas fa-book-open"></i> <span>Kelime Yönetimi</span>
            </a>
            <a href="users.php" class="nav-link">
                <i class="fas fa-users"></i> <span>Kullanıcılar</span>
            </a>
        </div>
    </nav>

    <main class="main-content">

        <div class="d-flex justify-content-between align-items-center mb-5">
            <div>
                <h2 class="fw-bold mb-1">Kelimeler</h2>
                <p class="text-muted mb-0">Toplam <?php echo count($allWords); ?> kelime kayıtlı</p>
            </div>

            <div class="d-flex gap-2">
                <button class="btn btn-dark rounded-pill px-4" data-bs-toggle="modal" data-bs-target="#bulkModal">
                    <i class="fas fa-layer-group me-2"></i> Toplu Ekle
                </button>
                <button class="btn btn-gradient rounded-pill px-4 shadow" data-bs-toggle="modal"
                    data-bs-target="#addModal">
                    <i class="fas fa-plus me-2"></i> Yeni Kelime
                </button>
            </div>
        </div>

        <?php if ($successMsg): ?>
            <div class="alert alert-success border-0 shadow-sm rounded-3 mb-4 d-flex align-items-center">
                <i class="fas fa-check-circle me-3 fs-4"></i> <?php echo $successMsg; ?>
            </div>
        <?php endif; ?>

        <?php if ($errorMsg): ?>
            <div class="alert alert-danger border-0 shadow-sm rounded-3 mb-4 d-flex align-items-center">
                <i class="fas fa-exclamation-circle me-3 fs-4"></i> <?php echo $errorMsg; ?>
            </div>
        <?php endif; ?>

        <div class="content-card mb-4">
            <div class="row align-items-center">
                <div class="col-md-3">
                    <form action="" method="GET">
                        <select name="level" class="form-select border-0 bg-light py-2 rounded-3 fw-bold"
                            onchange="this.form.submit()">
                            <option value="">Tüm Seviyeler</option>
                            <option value="A1" <?php echo $selectedLevel == 'A1' ? 'selected' : ''; ?>>A1 - Başlangıç</option>
                            <option value="A2" <?php echo $selectedLevel == 'A2' ? 'selected' : ''; ?>>A2 - Temel</option>
                            <option value="B1" <?php echo $selectedLevel == 'B1' ? 'selected' : ''; ?>>B1 - Orta</option>
                        </select>
                    </form>
                </div>
                <div class="col text-end text-muted small">
                    Almanca > Türkçe kelime seti
                </div>
            </div>
        </div>

        <div class="content-card">
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead>
                        <tr>
                            <th>Seviye</th>
                            <th>Almanca</th>
                            <th>Türkçe</th>
                            <th class="text-end">İşlemler</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php if (empty($allWords)): ?>
                            <tr>
                                <td colspan="4" class="text-center py-5 text-muted"><i
                                        class="fas fa-search mb-3 fs-2 opacity-50 d-block"></i> Kayıt bulunamadı</td>
                            </tr>
                        <?php else: ?>
                            <?php foreach ($allWords as $word):
                                $badgeColor = match ($word['level'] ?? '') {
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
                                            <?php echo $word['level'] ?? '-'; ?>
                                        </span>
                                    </td>
                                    <td class="fw-bold fs-5"><?php echo $word['german'] ?? '-'; ?></td>
                                    <td class="text-secondary"><?php echo $word['turkish'] ?? '-'; ?></td>
                                    <td class="text-end">
                                        <a href="?delete=<?php echo $word['id']; ?>"
                                            class="btn btn-light btn-sm text-danger rounded-circle p-2"
                                            onclick="return confirm('Bu kelimeyi silmek istiyor musunuz?')"
                                            style="width:36px;height:36px;">
                                            <i class="fas fa-trash-alt"></i>
                                        </a>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>

    </main>

    <!-- Add Modal -->
    <div class="modal fade" id="addModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg" style="border-radius: 20px;">
                <div class="modal-header border-0 pb-0 ps-4 pt-4">
                    <h5 class="modal-title fw-bold">Yeni Kelime</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form method="POST">
                    <input type="hidden" name="action" value="add_word">
                    <div class="modal-body p-4">
                        <div class="mb-4">
                            <label class="form-label text-muted small fw-bold text-uppercase">Zorluk Seviyesi</label>
                            <select name="level" class="form-select form-select-lg bg-light border-0 fw-bold">
                                <option value="A1">A1 - Başlangıç</option>
                                <option value="A2">A2 - Temel</option>
                                <option value="B1">B1 - Orta</option>
                            </select>
                        </div>

                        <div class="row g-3">
                            <div class="col-md-12">
                                <label class="form-label text-muted small fw-bold text-uppercase">🇩🇪 Almanca</label>
                                <input type="text" name="german"
                                    class="form-control form-control-lg bg-light border-0 fw-bold"
                                    placeholder="Örn: der Tisch" required>
                            </div>
                            <div class="col-md-12">
                                <label class="form-label text-muted small fw-bold text-uppercase">🇹🇷 Türkçe</label>
                                <input type="text" name="turkish"
                                    class="form-control form-control-lg bg-light border-0 fw-bold"
                                    placeholder="Örn: Masa" required>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer border-0 pe-4 pb-4">
                        <button type="button" class="btn btn-light rounded-pill px-4"
                            data-bs-dismiss="modal">İptal</button>
                        <button type="submit" class="btn btn-gradient rounded-pill px-4">Kaydet</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Bulk Upload Modal -->
    <div class="modal fade" id="bulkModal" tabindex="-1">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg" style="border-radius: 20px;">
                <div class="modal-header border-0 pb-0 ps-4 pt-4">
                    <div>
                        <h5 class="modal-title fw-bold"><i class="fas fa-layer-group text-primary me-2"></i>Toplu Kelime
                            Ekleme</h5>
                        <p class="text-muted small mb-0">Listeyi yapıştır, gerisini sisteme bırak.</p>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form method="POST">
                    <input type="hidden" name="action" value="bulk_add">
                    <div class="modal-body p-4">
                        <div class="mb-4">
                            <label class="form-label text-muted small fw-bold text-uppercase">Zorluk Seviyesi (Tümü
                                İçin)</label>
                            <select name="level" class="form-select bg-light border-0 fw-bold">
                                <option value="A1">A1 - Başlangıç</option>
                                <option value="A2">A2 - Temel</option>
                                <option value="B1">B1 - Orta</option>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">Kelime Listesi</label>
                            <div class="alert alert-info py-2 small">
                                Format: <b>Almanca : Türkçe</b> (Her satıra bir tane)<br>
                                Örnek:<br>
                                <em>der Apfel : Elma<br>
                                    laufen : yürümek</em>
                            </div>
                            <textarea name="bulk_content" class="form-control bulk-textarea border-0 shadow-sm"
                                rows="10" placeholder="der Apfel : Elma&#10;das Haus : Ev&#10;..." required></textarea>
                        </div>
                    </div>
                    <div class="modal-footer border-0 pe-4 pb-4">
                        <button type="button" class="btn btn-light rounded-pill px-4"
                            data-bs-dismiss="modal">İptal</button>
                        <button type="submit" class="btn btn-dark rounded-pill px-4"><i class="fas fa-save me-2"></i>
                            Listeyi Kaydet</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>

</html>