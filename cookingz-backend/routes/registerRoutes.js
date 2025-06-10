// routes/registerRoutes.js
const express = require('express');
const router = express.Router(); // Menggunakan Router dari Express
const registerController = require('../controllers/registerController'); // Import controller (nama baru)

// Definisikan rute registrasi
router.post('/', registerController.register); // Menggunakan '/' karena prefiks akan ditangani di server.js

module.exports = router;