const { generateCaptcha, verifyCaptcha, generateOtp } = require('../../src/utils/captcha');
const { generateTokenPair, verifyAccessToken } = require('../../src/utils/jwt');

describe('Captcha Utils', () => {
  test('generates and verifies captcha', () => {
    const { captchaToken, captchaQuestion } = generateCaptcha();
    expect(captchaToken).toBeDefined();
    expect(captchaQuestion).toMatch(/\d+ \+ \d+ = \?/);

    const parts = captchaQuestion.match(/(\d+) \+ (\d+)/);
    const answer = String(parseInt(parts[1], 10) + parseInt(parts[2], 10));
    expect(verifyCaptcha(captchaToken, answer)).toBe(true);
  });

  test('rejects invalid captcha answer', () => {
    const { captchaToken } = generateCaptcha();
    expect(verifyCaptcha(captchaToken, 'wrong')).toBe(false);
  });

  test('generates 6-digit OTP', () => {
    const otp = generateOtp();
    expect(otp).toMatch(/^\d{6}$/);
  });
});

describe('JWT Utils', () => {
  const user = { id: 'user-123', role: 'CITIZEN', mobileNumber: '9876543210' };

  test('generates and verifies token pair', () => {
    const { accessToken, refreshToken } = generateTokenPair(user);
    expect(accessToken).toBeDefined();
    expect(refreshToken).toBeDefined();

    const decoded = verifyAccessToken(accessToken);
    expect(decoded.sub).toBe(user.id);
    expect(decoded.role).toBe(user.role);
  });
});
