// cookingz-backend/routes/discoveryRoutes.js
const express = require('express');
const router = express.Router();
const discoveryController = require('../controllers/discoveryController');


router.get('/search', discoveryController.searchRecipes); 

router.get('/:id', discoveryController.getHomeData); 

router.get('/trending-recipes', discoveryController.getAllTrendingRecipes); // <<< TAMBAHKAN INI: Untuk semua resep trending

module.exports = router;