//// cookingz-backend/app.js atau server.js
//const express = require('express');
//const app = express();
//const cors = require('cors');
//const recipeRoutes = require('./routes/recipeRoutes');
//const reviewRoutes = require('./routes/reviewRoutes'); // Tetap diimpor
//
//// Middleware
//app.use(cors());
//app.use(express.json());
//app.use('/uploads', express.static('uploads'));
//
//// Gunakan route
//app.use('/recipes', recipeRoutes); // Route resep utama Anda
//
//// Pasang reviewRoutes sebagai sub-route dari recipeRoutes
//// Ini akan membuat endpoint seperti POST /recipes/:id/reviews dan GET /recipes/:id/reviews
//// Pastikan baris ini diletakkan SETELAH `app.use('/recipes', recipeRoutes);` jika Anda juga menggunakan router resep
//app.use('/recipes/:id/reviews', reviewRoutes); // <-- PENTING: Perubahan di sini!
//
//// Middleware penanganan error global
//app.use((err, req, res, next) => {
//  console.error(err.stack);
//  res.status(500).send('Terjadi Kesalahan di Server!');
//});
//
//const PORT = process.env.PORT || 3000;
//app.listen(PORT, () => {
//  console.log(`Server berjalan di port ${PORT}`);
//});

// cookingz-backend/app.js atau server.js
const express = require('express');
const app = express();
const cors = require('cors'); // Jika belum ada, pastikan Anda menginstal: npm install cors
const recipeRoutes = require('./routes/recipeRoutes');
const path = require('path'); // Diperlukan untuk path file statis


app.use(cors());
app.use(express.json());

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