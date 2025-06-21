// routes/loginRoutes.js
const express = require('express');
const router = express.Router();
const loginController = require('../controllers/loginController');

// Route untuk login
router.post('/', loginController.login);

module.exports = router;