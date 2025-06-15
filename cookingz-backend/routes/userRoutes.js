// File: cookingz-backend/routes/userRoutes.js

const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const upload = require('../middleware/upload');

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

// Rute untuk mendapatkan daftar pengguna yang DIIKUTI oleh user dengan :id
router.get('/:id/following', userController.getFollowingList);

// Rute untuk mendapatkan daftar PENGGIKUT dari user dengan :id
router.get('/:id/followers', userController.getFollowersList);

router.post('/:id/follow', userController.followUser);
router.post('/:id/unfollow', userController.unfollowUser);

// Rute untuk memperbarui profil pengguna yang sedang login
router.put('/me', upload.single('profile_picture'), userController.updateMyProfile);

module.exports = router;