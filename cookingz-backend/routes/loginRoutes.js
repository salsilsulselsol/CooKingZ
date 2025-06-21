// routes/loginRoutes.js
const express = require('express');
const router = express.Router();
const loginController = require('../controllers/loginController');

// Route untuk login
router.post('/', loginController.login);

// Route untuk mendapatkan profile user (memerlukan token)
router.get('/profile', loginController.verifyToken, loginController.getProfile);

module.exports = router;