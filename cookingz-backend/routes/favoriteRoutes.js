// File: cookingz-backend/routes/favoriteRoutes.js

const express = require('express');
const router = express.Router();
const favoriteController = require('../controllers/favoriteController');

// TODO: Tambahkan middleware otentikasi di sini setelah dibuat
// Contoh: const authMiddleware = require('../middleware/auth');
// router.post('/:id/favorite', authMiddleware, favoriteController.toggleFavorite);
// router.get('/:id/favorite-status', authMiddleware, favoriteController.checkFavoriteStatus);

// Rute untuk menambah/menghapus resep dari favorit
router.post('/:id/favorite', favoriteController.toggleFavorite);

// Rute untuk mengecek status favorit resep
router.get('/:id/favorite-status', favoriteController.checkFavoriteStatus);

module.exports = router;