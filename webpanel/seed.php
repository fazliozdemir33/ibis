<?php
require_once 'config.php';
$fb = new FirebaseService();

echo "<h1>Veritabanı Sıfırlanıyor...</h1>";

// 1. Mevcut tüm kelimeleri çek
$allWords = $fb->getDocuments('words');
echo "Bulunan kelime sayısı: " . count($allWords) . "<br>";

// 2. Hepsini sil
foreach ($allWords as $word) {
    if (isset($word['id'])) {
        $fb->deleteDocument('words', $word['id']);
        echo "Silindi: " . ($word['german'] ?? 'Bilinmeyen') . "<br>";
    }
}

// 3. Varsayılan kelimeleri ekle
$defaults = [
    ['level' => 'A1', 'german' => 'der Apfel', 'turkish' => 'Elma'],
    ['level' => 'A2', 'german' => 'die Reise', 'turkish' => 'Seyahat'],
    ['level' => 'B1', 'german' => 'die Erfahrung', 'turkish' => 'Deneyim'],
    ['level' => 'B2', 'german' => 'die Wissenschaft', 'turkish' => 'Bilim'],
];

echo "<hr><h3>Yeni Kelimeler Ekleniyor...</h3>";

foreach ($defaults as $w) {
    $fb->addDocument('words', [
        'german' => $w['german'],
        'turkish' => $w['turkish'],
        'level' => $w['level'],
        'createdAt' => date('Y-m-d\TH:i:s\Z')
    ]);
    echo "Eklendi: [{$w['level']}] {$w['german']} - {$w['turkish']}<br>";
}

echo "<hr><h2 style='color:green'>İşlem Tamamlandı!</h2>";
echo "<a href='words.php'>Kelime Paneline Dön</a>";
?>