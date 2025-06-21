// cookingz-backend/middleware/authMiddleware.js
const jwt = require('jsonwebtoken');
require('dotenv').config();

const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (token == null) {
        return res.status(401).json({ status: 'error', message: 'Token tidak tersedia atau format tidak valid.' });
    }

    jwt.verify(token, process.env.ACCESS_TOKEN_SECRET, (err, user) => {
        if (err) {
            return res.status(403).json({ status: 'error', message: 'Token tidak valid atau kadaluarsa.' });
        }
        req.userId = user.id;
        next();
    });
};

module.exports = authenticateToken;