// cookingz-backend/server.js
const express = require('express');
const app = express();
const cors = require('cors');
const morgan = require('morgan'); 

// Import semua rute dan middleware yang dibutuhkan
const recipeRoutes = require('./routes/recipeRoutes');
const userRoutes = require('./routes/userRoutes');
const favoriteRoutes = require('./routes/favoriteRoutes');
const registerRoutes = require('./routes/registerRoutes');
const loginRoutes = require('./routes/loginRoutes'); // Jika Anda menggunakan login
const forgotPasswordRoutes = require('./routes/forgotPasswordRoutes'); // <<< ADD THIS (TAMBAHKAN INI)
const categoryRoutes = require('./routes/categoryRoutes');
const discoveryRoutes = require('./routes/discoveryRoutes'); // Untuk /home dan /search
const utilityRoutes = require('./routes/utilityRoutes'); // <<< TAMBAHKAN INI untuk jadwal & notifikasi
const authenticateToken = require('./middleware/authMiddleware'); // Pastikan ini ada

const path = require('path');
const db = require('./db');

// Middleware umum
app.use(cors());
app.use(express.json());
app.use(morgan('dev')); 

// Setel direktori 'uploads' sebagai folder statis yang dapat diakses publik.
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Pasang rute-rute aplikasi Anda
app.use('/register', registerRoutes);
app.use('/login', loginRoutes); // Jika Anda menggunakan login
app.use('/forgot-password', forgotPasswordRoutes); // <<< TAMBAHKAN INI untuk forgot password
app.use('/recipes', recipeRoutes);
app.use('/users', userRoutes);
app.use('/recipes', favoriteRoutes); // Pastikan ini rute yang Anda maksud, biasanya /favorites
app.use('/categories', categoryRoutes);

// Pasang discoveryRoutes di '/home' dengan middleware autentikasi opsional
app.use('/home', (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (token) {
        authenticateToken(req, res, next);
    } else {
        next(); // Lanjutkan tanpa autentikasi jika tidak ada token
    }
}, discoveryRoutes);

// Pasang utilityRoutes di '/api/utilities' dan lindungi dengan authenticateToken
// Ini berarti setiap permintaan ke /api/utilities/* akan melalui autentikasi JWT.
app.use('/api/utilities', authenticateToken, utilityRoutes); // <<< TAMBAHKAN INI
app.use('/forgot-password', forgotPasswordRoutes); // <<< ADD THIS (TAMBAHKAN INI)


// Middleware penanganan 404 generik. Ini akan tertrigger jika TIDAK ADA rute di atas yang match.
app.use((req, res, next) => {
    res.status(404).send('Backend: Rute tidak ditemukan.');
});

// Middleware penanganan error global. Ini akan tertrigger jika ada error di middleware/rute manapun.
app.use((err, req, res, next) => {
    console.error('GLOBAL ERROR HANDLER:', err.stack);
    res.status(500).json({ // Mengubah .send menjadi .json agar Flutter bisa parse
        status: 'error',
        message: 'Backend: Terjadi Error Internal Server. Detail ada di log server.',
        error: err.message
    });
});

// Port server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server berjalan di port ${PORT}`);
});