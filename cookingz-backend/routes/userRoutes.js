// File: cookingz-backend/routes/userRoutes.js

const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const authenticateToken = require('../middleware/authMiddleware');
const optionalAuthenticateToken = require('../middleware/optionalAuthMiddleware');
const upload = require('../middleware/upload');

// --- Rute yang membutuhkan autentikasi (hanya bisa diakses oleh user yang login) ---

// GET profil pengguna yang sedang login
router.get('/me', authenticateToken, userController.getMyProfile);

// GET resep favorit pengguna yang sedang login
router.get('/me/favorites', authenticateToken, userController.getMyFavoriteRecipes);

// PUT (update) profil pengguna yang sedang login (membutuhkan autentikasi dan upload file opsional)
router.put('/me', authenticateToken, upload.single('profile_picture'), userController.updateMyProfile);

router.get('/latest', userController.getAllLatestUsers); // <<< TAMBAHKAN INI

// POST untuk follow user lain
router.post('/:id/follow', authenticateToken, userController.followUser);

// POST untuk unfollow user lain
router.post('/:id/unfollow', authenticateToken, userController.unfollowUser);

// DELETE akun pengguna (membutuhkan autentikasi)
router.delete('/:id', authenticateToken, userController.deleteUser); // <<< DELETE USER DENGAN AUTH

// --- Rute publik (bisa diakses tanpa login, tapi req.userId tidak akan ada) ---

// GET profil pengguna berdasarkan ID (profil publik)
router.get('/:id', optionalAuthenticateToken, userController.getUserById);

// GET resep milik seorang user berdasarkan ID (resep publik user)
router.get('/:id/recipes', userController.getUserRecipes);

// GET daftar pengguna yang DIIKUTI oleh user dengan :id
router.get('/:id/following', optionalAuthenticateToken, userController.getFollowingList);

// GET daftar PENGGIKUT dari user dengan :id
router.get('/:id/followers', optionalAuthenticateToken, userController.getFollowersList);

module.exports = router;