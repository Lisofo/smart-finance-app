// backend/src/controllers/authController.js
const AuthService = require('../services/authService');
const {
  validateEmailPasswordRegister,
  validateEmailPasswordLogin,
} = require('../utils/validation');

class AuthController {
  static async register(req, res, next) {
    try {
      const { email, password } = req.body || {};
      const v = validateEmailPasswordRegister(email, password);
      if (!v.ok) {
        return res.status(400).json({ message: v.error });
      }

      const user = await AuthService.register(v.email, v.password);
      res.status(201).json({ message: 'User registered successfully', user });
    } catch (error) {
      if (error.message === 'User already exists') {
        return res.status(409).json({ message: error.message });
      }
      next(error);
    }
  }

  static async login(req, res, next) {
    try {
      const { email, password } = req.body || {};
      const v = validateEmailPasswordLogin(email, password);
      if (!v.ok) {
        return res.status(400).json({ message: v.error });
      }

      const { token, user } = await AuthService.login(v.email, v.password);
      res.status(200).json({ message: 'Login successful', token, user });
    } catch (error) {
      if (error.message === 'Invalid credentials') {
        return res.status(401).json({ message: error.message });
      }
      next(error);
    }
  }
}

module.exports = AuthController;
