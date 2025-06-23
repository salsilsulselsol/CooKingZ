// routes/notificationRoutes.js (Contoh)
const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController'); // <<< SESUAIKAN PATH INI

router.get('/notifications/:userId', notificationController.getUserNotifications);

module.exports = router;