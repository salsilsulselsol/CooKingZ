// File: cookingz-backend/server.js
const express = require('express');
const app = express();
const cors = require('cors');
const morgan = require('morgan'); 

// Import semua rute dan middleware yang dibutuhkan
const recipeRoutes = require('./routes/recipeRoutes');
const userRoutes = require('./routes/userRoutes');
const favoriteRoutes = require('./routes/favoriteRoutes');
const registerRoutes = require('./routes/registerRoutes');
const loginRoutes = require('./routes/loginRoutes');
const forgotPasswordRoutes = require('./routes/forgotPasswordRoutes'); 
const categoryRoutes = require('./routes/categoryRoutes');
const discoveryRoutes = require('./routes/discoveryRoutes'); 
const utilityRoutes = require('./routes/utilityRoutes'); // Untuk jadwal makan dll.
const reviewRoutes = require('./routes/reviewRoutes');
// const authenticateToken = require('./middleware/authMiddleware'); // Import jika akan digunakan di app.use global

// PENTING: Pastikan ini adalah import yang benar untuk notificationRoutes Anda
const notificationRoutes = require('./routes/notificationRoutes'); 

const path = require('path');
const db = require('./db'); // Ini sudah benar, koneksi database ada di root './db.js'

// Middleware umum
app.use(cors());
app.use(express.json()); // Untuk parsing JSON body
app.use(morgan('dev')); // Untuk logging request ke konsol

// Setel direktori 'uploads' sebagai folder statis yang dapat diakses publik.
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// =========================================================================
// PASANG RUTE-RUTE APLIKASI ANDA (Urutan penting untuk rute yang tumpang tindih)
// =========================================================================

// Rute autentikasi dan pendaftaran
app.use('/register', registerRoutes);
app.use('/login', loginRoutes);
app.use('/forgot-password', forgotPasswordRoutes); 

// Rute utama aplikasi
app.use('/recipes', recipeRoutes);
app.use('/users', userRoutes);
app.use('/recipes', favoriteRoutes); // HATI-HATI: Jika ini untuk rute '/recipes/favorites', pertimbangkan untuk membuatnya lebih spesifik
app.use('/categories', categoryRoutes);
app.use('/reviews', reviewRoutes);

// Rute untuk halaman beranda dan pencarian (misal /home dan /home/search)
app.use('/home', discoveryRoutes); 

// Rute untuk utilities (jadwal makan)
// PERHATIAN: Jika Anda ingin middleware autentikasi diterapkan ke semua rute di /api/utilities,
// letakkan authenticateToken di sini. Jika tidak, authenticateToken harus ada di rute individual.
// Contoh: app.use('/api/utilities', authenticateToken, utilityRoutes);
app.use('/api/utilities', utilityRoutes); 

// Rute untuk notifikasi
// Ini adalah tempat untuk notificationRoutes. Karena prefix-nya sama dengan utilityRoutes,
// pastikan rute di dalamnya tidak sama dengan rute di utilityRoutes.
app.use('/api/utilities', notificationRoutes); // Ini akan membuat endpoint menjadi /api/utilities/notifications/:userId

// =========================================================================
// PENANGANAN ERROR DAN 404 (Harus di bagian paling bawah)
// =========================================================================

// Middleware penanganan 404 generik. Ini akan tertrigger jika TIDAK ADA rute di atas yang match.
app.use((req, res, next) => {
    res.status(404).send('Backend: Rute tidak ditemukan.');
});

// Middleware penanganan error global. Ini akan tertrigger jika ada error di middleware/rute manapun.
app.use((err, req, res, next) => {
    console.error('GLOBAL ERROR HANDLER:', err.stack); // Log stack trace error untuk debugging
    res.status(500).json({ // Mengubah .send menjadi .json agar Flutter bisa parse
        status: 'error',
        message: 'Backend: Terjadi Error Internal Server. Detail ada di log server.',
        error: err.message // Mengirim pesan error ke klien (hati-hati di produksi)
    });
});


// Port server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server berjalan di port ${PORT}`);
});