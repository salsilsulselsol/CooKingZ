// cookingz-backend/routes/discoveryRoutes.js
const express = require('express');
const router = express.Router();
const discoveryController = require('../controllers/discoveryController');

router.get('/', discoveryController.getHomeData); 
router.get('/search', discoveryController.searchRecipes); 
router.get('/trending-recipes', discoveryController.getAllTrendingRecipes); // <<< TAMBAHKAN INI: Untuk semua resep trending

module.exports = router;