// File: cookingz-backend/routes/userRoutes.js

const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

// TODO: Tambahkan middleware otentikasi di sini setelah dibuat
// Contoh: const authMiddleware = require('../middleware/auth');
// router.get('/me', authMiddleware, userController.getMyProfile);

// Rute untuk mendapatkan profil pengguna yang sedang login
router.get('/me', userController.getMyProfile);

// Rute untuk mendapatkan resep favorit pengguna yang sedang login
router.get('/me/favorites', userController.getMyFavoriteRecipes);

// Rute untuk mendapatkan profil pengguna berdasarkan ID
router.get('/:id', userController.getUserById);

// Rute untuk mendapatkan resep milik seorang user berdasarkan ID
router.get('/:id/recipes', userController.getUserRecipes);

module.exports = router;