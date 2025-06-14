// cookingz-backend/routes/recipeRoutes.js
const express = require('express');
const router = express.Router();
const recipeController = require('../controllers/recipeController');
const upload = require('../middleware/upload'); // Impor middleware upload

// Rute untuk menambah resep baru (CREATE)
router.post(
  '/',
  // Gunakan upload.fields() untuk menangani banyak file dengan nama field berbeda
  // 'image' adalah nama field untuk gambar (max 1 file)
  // 'video' adalah nama field untuk video (max 1 file)
  upload.fields([
    { name: 'image', maxCount: 1 },
    { name: 'video', maxCount: 1 }
  ]),
  recipeController.addRecipe // Kemudian panggil controller setelah upload
);

// Rute untuk mendapatkan detail resep berdasarkan ID (READ)
router.get('/:id', recipeController.getRecipeById);

// Rute untuk memperbarui resep berdasarkan ID (UPDATE)
router.put(
  '/:id',
  upload.fields([
    { name: 'image', maxCount: 1 }, // Gambar baru (jika diganti)
    { name: 'video', maxCount: 1 }  // Video baru (jika diganti)
  ]),
  recipeController.updateRecipe
);

// Rute untuk menghapus resep berdasarkan ID (DELETE)
router.delete('/:id', recipeController.deleteRecipe);

module.exports = router;