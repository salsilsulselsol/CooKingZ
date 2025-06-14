// cookingz-backend/app.js atau server.js
const express = require('express');
const app = express();
const cors = require('cors');
const recipeRoutes = require('./routes/recipeRoutes');
const userRoutes = require('./routes/userRoutes'); // Pastikan ini diimpor
const favoriteRoutes = require('./routes/favoriteRoutes'); // <<<--- TAMBAHKAN INI
const registerRoutes = require('./routes/registerRoutes'); // Asumsi Anda punya rute registrasi
const path = require('path');

app.use(cors());
app.use(express.json());

// Setel direktori 'uploads' sebagai folder statis yang dapat diakses publik.
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Gunakan rute registrasi
app.use('/register', registerRoutes); // Pastikan `registerRoutes` didefinisikan atau diimpor

// Gunakan rute resep
app.use('/recipes', recipeRoutes);

// Gunakan rute pengguna
app.use('/users', userRoutes);

// Gunakan rute favorit (<<<--- TAMBAHKAN INI)
// Menghubungkan rute favorit di bawah prefiks '/recipes'
// Sehingga endpoint menjadi POST /recipes/:id/favorite dan GET /recipes/:id/favorite-status
app.use('/recipes', favoriteRoutes);

// Port server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server berjalan di port ${PORT}`);
});
