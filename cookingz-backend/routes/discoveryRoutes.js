// cookingz-backend/routes/discoveryRoutes.js

const express = require('express');
const router = express.Router();
const discoveryController = require('../controllers/discoveryController');
const optionalAuthMiddleware = require('../middleware/optionalAuthMiddleware'); // Pastikan ini di-import

// <<< PERBAIKAN UTAMA ADA DI SINI >>>

// Rute yang spesifik (fixed string) harus selalu didefinisikan SEBELUM rute dinamis.
router.get('/search', discoveryController.searchRecipes); 
router.get('/trending-recipes', optionalAuthMiddleware, discoveryController.getAllTrendingRecipes);

// Rute dinamis (dengan parameter :id) diletakkan di bagian paling bawah dari grupnya.
router.get('/:id', optionalAuthMiddleware, discoveryController.getHomeData); 

module.exports = router;