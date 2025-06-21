// cookingz-backend/routes/discoveryRoutes.js
const express = require('express');
const router = express.Router();
const discoveryController = require('../controllers/discoveryController');

router.get('/', discoveryController.getHomeData); 
router.get('/search', discoveryController.searchRecipes); 

module.exports = router;