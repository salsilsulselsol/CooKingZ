const express = require('express');
const router = express.Router();
const categoryController = require('../controllers/categoryController');

// Rute untuk mendapatkan semua kategori
router.get('/', categoryController.getAllCategories);

// Rute BARU: Mendapatkan resep berdasarkan ID Kategori
// Endpoint ini akan menjadi GET /categories/:categoryId/recipes
router.get('/:categoryId/recipes', categoryController.getRecipesByCategoryId);

module.exports = router;