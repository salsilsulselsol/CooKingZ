// cookingz-backend/app.js atau server.js
const express = require('express');
const app = express();
const cors = require('cors');
const recipeRoutes = require('./routes/recipeRoutes');
const userRoutes = require('./routes/userRoutes'); // Pastikan ini diimpor
const favoriteRoutes = require('./routes/favoriteRoutes'); // <<<--- TAMBAHKAN INI
const registerRoutes = require('./routes/registerRoutes'); // Asumsi Anda punya rute registrasi
const categoryRoutes = require('./routes/categoryRoutes');
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

// Gunakan rute favorit
app.use('/recipes', favoriteRoutes);

// Gunakan rute category
app.use('/categories', categoryRoutes);


// Port server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server berjalan di port ${PORT}`);
});
