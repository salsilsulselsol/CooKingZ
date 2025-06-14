// cookingz-backend/routes/reviewRoutes.js
const express = require('express');
const router = express.Router();
const reviewController = require('../controllers/reviewController');

// Rute untuk menambahkan ulasan ke resep tertentu
// Contoh: POST /api/recipes/123/reviews
router.post('/:id/reviews', reviewController.addReview);

// Rute untuk mendapatkan semua ulasan untuk resep tertentu
// Contoh: GET /api/recipes/123/reviews
router.get('/:id/reviews', reviewController.getReviewsByRecipeId);

module.exports = router;