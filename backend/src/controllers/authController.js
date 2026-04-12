// backend/src/controllers/authController.js
const AuthService = require('../services/authService');

class AuthController {
  static async register(req, res, next) {
    try {
      const { email, password } = req.body;

      if (!email || !password) {
        return res.status(400).json({ message: 'Email and password are required' });
      }

      const user = await AuthService.register(email, password);
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
      const { email, password } = req.body;

      if (!email || !password) {
        return res.status(400).json({ message: 'Email and password are required' });
      }

      const { token, user } = await AuthService.login(email, password);
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