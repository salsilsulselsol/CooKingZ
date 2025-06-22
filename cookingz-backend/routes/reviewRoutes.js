// File: cookingz-backend/routes/reviewRoutes.js

const express = require('express');
const router = express.Router();
const reviewController = require('../controllers/reviewController');

// Catatan: Middleware autentikasi TIDAK diterapkan di sini
// karena user_id diambil langsung dari body/query frontend.
// Ini memiliki IMPLIKASI KEAMANAN yang serius.

// POST /reviews - Menambahkan ulasan baru
router.post('/', reviewController.addReview);

// GET /reviews/:recipeId - Mendapatkan semua ulasan untuk resep tertentu
router.get('/:recipeId', reviewController.getReviewsByRecipeId);

// DELETE /reviews/:reviewId - Menghapus ulasan tertentu
router.delete('/:reviewId', reviewController.deleteReview);

module.exports = router;