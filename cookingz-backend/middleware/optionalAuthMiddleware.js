const jwt = require('jsonwebtoken');

const optionalAuthenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (token == null) {
    // Jika tidak ada token, tidak apa-apa. Lanjutkan saja ke langkah berikutnya.
    return next();
  }

  jwt.verify(token, process.env.JWT_SECRET || 'your_jwt_secret_key', (err, user) => {
    if (!err) {
      // Jika token valid, lampirkan data user ke request.
      req.user = user;
    }
    // Jika token tidak valid, kita abaikan saja dan tidak melampirkan data user.
    next();
  });
};

module.exports = optionalAuthenticateToken;