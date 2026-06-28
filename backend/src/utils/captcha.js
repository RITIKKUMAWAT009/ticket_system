const crypto = require('crypto');
const config = require('../config');

const captchaStore = new Map();

function generateCaptcha() {
  const a = Math.floor(Math.random() * 10) + 1;
  const b = Math.floor(Math.random() * 10) + 1;
  const answer = String(a + b);
  const token = crypto.randomBytes(16).toString('hex');

  captchaStore.set(token, {
    answer,
    expiresAt: Date.now() + config.captcha.expiryMinutes * 60 * 1000,
  });

  return {
    captchaToken: token,
    captchaQuestion: `${a} + ${b} = ?`,
  };
}

function verifyCaptcha(token, answer) {
  const entry = captchaStore.get(token);
  if (!entry) return false;
  captchaStore.delete(token);
  if (Date.now() > entry.expiresAt) return false;
  return entry.answer === String(answer).trim();
}

function generateOtp() {
  const length = config.otp.length;
  let otp = '';
  for (let i = 0; i < length; i++) {
    otp += Math.floor(Math.random() * 10);
  }
  return otp;
}

function getOtpExpiry() {
  return new Date(Date.now() + config.otp.expiryMinutes * 60 * 1000);
}

module.exports = {
  generateCaptcha,
  verifyCaptcha,
  generateOtp,
  getOtpExpiry,
};
