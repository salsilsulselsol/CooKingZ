// cookingz-backend/routes/forgotPasswordRoutes.js
const express = require('express');
const router = express.Router();
const forgotPasswordController = require('../controllers/forgotPasswordController');

// Route to send OTP
// Rute untuk mengirim OTP
router.post('/send-otp', forgotPasswordController.sendOtp);

// Route to verify OTP
// Rute untuk memverifikasi OTP
router.post('/verify-otp', forgotPasswordController.verifyOtp);

// Route to reset password
// Rute untuk mereset kata sandi
router.post('/reset-password', forgotPasswordController.resetPassword);

module.exports = router;