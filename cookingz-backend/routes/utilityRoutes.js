// cookingz-backend/routes/utilityRoutes.js
const express = require('express');
const router = express.Router();
const utilityController = require('../controllers/utilityController');
// authenticateToken akan dipasang di server.js untuk semua rute di sini

// --- Rute untuk Jadwal Makan (Meal Schedules) ---

// GET semua jadwal makan untuk user yang sedang login
router.get('/get_meal-schedules/:id', utilityController.getMealSchedules);

// POST jadwal makan baru
router.post('/meal-schedules', utilityController.addMealSchedule);

// DELETE dengan dua parameter: jadwal dan user
router.delete('/meal-schedules/:id/:user_id', utilityController.deleteMealSchedule);



// --- Rute untuk Notifikasi ---

// GET semua notifikasi untuk user yang sedang login
router.get('/notifications', utilityController.getNotifications);

// PUT (update) notifikasi menjadi sudah dibaca berdasarkan ID
router.put('/notifications/:id/read', utilityController.markNotificationAsRead);

module.exports = router;