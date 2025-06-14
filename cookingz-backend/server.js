// cookingz-backend/server.js
const express = require('express');
const cors = require('cors');
const pool = require('./db'); // Pastikan db.js sudah berjalan dan terkoneksi
const registerRoutes = require('./routes/registerRoutes');
const recipeRoutes = require('./routes/recipeRoutes');
const path = require('path'); // Diperlukan untuk path file statis
const userRoutes = require('./routes/userRoutes');

const app = express();

app.use(cors());
app.use(express.json());

// Gunakan rute profil pengguna
app.use('/api/users', userRoutes);

// Setel direktori 'uploads' sebagai folder statis yang dapat diakses publik.
// Ini memungkinkan Anda mengakses gambar/video yang diunggah melalui URL seperti http://localhost:3000/uploads/namafile.png
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Gunakan rute registrasi
app.use('/register', registerRoutes);

// Gunakan rute resep
app.use('/recipes', recipeRoutes); // Menghubungkan semua rute resep di bawah prefiks '/recipes'

// Port server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server berjalan di port ${PORT}`);
});