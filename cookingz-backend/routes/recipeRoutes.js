const express = require('express');
const router = express.Router();
const recipeController = require('../controllers/recipeController');
const upload = require('../middleware/upload'); // Impor middleware upload

// --- DEBUGGER TAMBAHAN UNTUK MEMASTIKAN ROUTE TERDAFTAR ---
console.log('DEBUG: recipeRoutes.js loaded.');
console.log('DEBUG: Registering POST / on /recipes route...');
// --- AKHIR DEBUGGER TAMBAHAN ---

// Rute untuk menambah resep baru (CREATE)
router.post(
  '/',
  upload.fields([
    { name: 'image', maxCount: 1 },
    { name: 'video', maxCount: 1 }
  ]),
  (req, res, next) => { // Tambahkan middleware kecil untuk logging
    console.log('DEBUG: addRecipe route hit!');
    next(); // Lanjutkan ke controller
  },
  recipeController.addRecipe // Kemudian panggil controller setelah upload
);

// Rute untuk mendapatkan detail resep berdasarkan ID (READ)
router.get('/:id', recipeController.getRecipeById);

// Rute untuk memperbarui resep berdasarkan ID (UPDATE)
router.put(
  '/:id',
  upload.fields([
    { name: 'image', maxCount: 1 },
    { name: 'video', maxCount: 1 }
  ]),
  recipeController.updateRecipe
);

// Rute untuk menghapus resep berdasarkan ID (DELETE)
router.delete('/:id', recipeController.deleteRecipe);

// --- DEBUGGER TAMBAHAN UNTUK MEMASTIKAN ROUTER DIEKSPOR ---
console.log('DEBUG: recipeRoutes router exported.');
// --- AKHIR DEBUGGER TAMBAHAN ---

module.exports = router;