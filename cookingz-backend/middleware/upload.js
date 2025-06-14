// cookingz-backend/middleware/upload.js
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Direktori tempat file akan disimpan.
// Ini akan membuat folder 'uploads' di root folder 'cookingz-backend'
const UPLOADS_DIR = path.join(__dirname, '../uploads');

// Pastikan direktori uploads ada. Jika tidak, buatlah.
// Menambahkan { recursive: true } untuk membuat folder induk jika tidak ada
if (!fs.existsSync(UPLOADS_DIR)) {
  console.log('Creating UPLOADS_DIR:', UPLOADS_DIR);
  fs.mkdirSync(UPLOADS_DIR, { recursive: true });
}

// Konfigurasi penyimpanan untuk Multer
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, UPLOADS_DIR); // Tentukan folder tujuan upload
  },
  filename: function (req, file, cb) {
    // Buat nama file unik: fieldname-timestamp.ext
    // Misalnya: image-1718374800000.jpeg atau video-1718374800000.mp4
    cb(null, file.fieldname + '-' + Date.now() + path.extname(file.originalname));
  }
});

// Filter file untuk membatasi jenis file yang diunggah
const fileFilter = (req, file, cb) => {
  // --- TAMBAHKAN LOG INI UNTUK DEBUGGING MIME TYPE ---
  console.log('MIME Type file yang diunggah:', file.mimetype);
  // --------------------------------------------------

  // Izinkan hanya gambar (jpeg, jpg, png, gif) dan video (mp4, mov, webm)
  const allowedMimes = [
    'image/jpeg', 'image/jpg', 'image/png', 'image/gif',
    'video/mp4', 'video/quicktime', 'video/webm' // 'video/quicktime' untuk .mov
  ];
  if (allowedMimes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    // Pesan error ini akan dikirim jika tipe file tidak didukung
    cb(new Error('Tipe file tidak didukung! Hanya gambar (JPEG, PNG, GIF) dan video (MP4, MOV, WEBM) yang diizinkan.'), false);
  }
};

// Inisialisasi multer dengan konfigurasi storage dan fileFilter
const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 1024 * 1024 * 50 // Batas ukuran file 50MB (sesuaikan jika perlu)
  }
});

module.exports = upload;