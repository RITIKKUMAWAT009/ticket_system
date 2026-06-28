const prisma = require('../../utils/prisma');
const { generateOtp, getOtpExpiry, verifyCaptcha } = require('../../utils/captcha');
const { generateTokenPair, verifyRefreshToken } = require('../../utils/jwt');
const logger = require('../../utils/logger');

class AuthRepository {
  async findByMobile(mobileNumber) {
    return prisma.user.findUnique({ where: { mobileNumber } });
  }

  async findByEmail(email) {
    return prisma.user.findUnique({ where: { email } });
  }

  async findByAadhaar(aadhaarNumber) {
    return prisma.user.findUnique({ where: { aadhaarNumber } });
  }

  async findByPassport(passportNumber) {
    return prisma.user.findUnique({ where: { passportNumber } });
  }

  async findById(id) {
    return prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        mobileNumber: true,
        fullName: true,
        fatherName: true,
        email: true,
        aadhaarNumber: true,
        passportNumber: true,
        gender: true,
        role: true,
        profileImageUrl: true,
        createdAt: true,
      },
    });
  }

  async createUser(data) {
    return prisma.user.create({ data });
  }

  async createOtpSession(
    mobileNumber,
    otp,
    userId = null,
  ) {
    console.log("CREATING OTP:", mobileNumber, otp);
    await prisma.otpSession.deleteMany({
      where: {
        mobileNumber,
        verified: false,
      },
    });

    return prisma.otpSession.create({
      data: {
        mobileNumber,
        otp: String(otp),
        expiresAt: getOtpExpiry(),
        userId,
      },
    });
  }

  async findValidOtp(mobileNumber, otp) {
    return prisma.otpSession.findFirst({
      where: {
        mobileNumber,
        otp,
        verified: false,
        expiresAt: { gt: new Date() },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async markOtpVerified(id) {
    return prisma.otpSession.update({
      where: { id },
      data: { verified: true },
    });
  }
}

class AuthService {
  constructor(repository = new AuthRepository()) {
    this.repository = repository;
  }

  async register(data) {
    const { captchaToken, captchaAnswer, registrationType, ...userData } = data;

    if (!verifyCaptcha(captchaToken, captchaAnswer)) {
      const error = new Error('Invalid or expired captcha');
      error.status = 400;
      throw error;
    }

    const existingMobile = await this.repository.findByMobile(userData.mobileNumber);
    if (existingMobile) {
      const error = new Error('Mobile number already registered');
      error.status = 409;
      throw error;
    }

    const existingEmail = await this.repository.findByEmail(userData.email);
    if (existingEmail) {
      const error = new Error('Email already registered');
      error.status = 409;
      throw error;
    }

    if (registrationType === 'INDIAN') {
      const existingAadhaar = await this.repository.findByAadhaar(userData.aadhaarNumber);
      if (existingAadhaar) {
        const error = new Error('Aadhaar number already registered');
        error.status = 409;
        throw error;
      }
    }

    if (registrationType === 'NRI') {
      const existingPassport = await this.repository.findByPassport(userData.passportNumber);
      if (existingPassport) {
        const error = new Error('Passport number already registered');
        error.status = 409;
        throw error;
      }
    }

    const createData = {
      mobileNumber: userData.mobileNumber,
      fullName: userData.fullName,
      fatherName: userData.fatherName,
      email: userData.email,
      gender: userData.gender,
      profileImageUrl: userData.profileImageUrl || null,
      role: 'CITIZEN',
      aadhaarNumber: registrationType === 'INDIAN' ? userData.aadhaarNumber : null,
      passportNumber: registrationType === 'NRI' ? userData.passportNumber : null,
    };

    const user = await this.repository.createUser(createData);

    const otp = generateOtp();
    await this.repository.createOtpSession(user.mobileNumber, otp, user.id);

    logger.info('User registered, OTP sent', { mobile: user.mobileNumber });
    if (process.env.NODE_ENV !== 'production') {
      logger.debug('OTP for development', { mobile: user.mobileNumber, otp });
    }

    return {
      message: 'Registration successful. OTP sent to mobile number.',
      mobileNumber: user.mobileNumber,
      ...(process.env.NODE_ENV !== 'production' && { otp }),
    };
  }

  async sendOtp(data) {
    const { mobileNumber, captchaToken, captchaAnswer } = data;

    if (!verifyCaptcha(captchaToken, captchaAnswer)) {
      const error = new Error('Invalid or expired captcha');
      error.status = 400;
      throw error;
    }

    const user = await this.repository.findByMobile(mobileNumber);
    if (!user) {
      const error = new Error('Mobile number not registered');
      error.status = 404;
      throw error;
    }

    const otp = generateOtp();
    await this.repository.createOtpSession(mobileNumber, otp, user.id);

    logger.info('OTP sent', { mobile: mobileNumber });
    if (process.env.NODE_ENV !== 'production') {
      logger.debug('OTP for development', { mobile: mobileNumber, otp });
    }

    return {
      message: 'OTP sent successfully',
      ...(process.env.NODE_ENV !== 'production' && { otp }),
    };
  }

  async verifyOtp(data) {
    const { mobileNumber } = data;
    const otp = String(data.otp);


    const session = await this.repository.findValidOtp(mobileNumber, otp);
    console.log("OPT <><><> ", session);
    if (!session) {
      const error = new Error('Invalid or expired OTP');
      error.status = 400;
      throw error;
    }

    await this.repository.markOtpVerified(session.id);

    const user = await this.repository.findByMobile(mobileNumber);
    const tokens = generateTokenPair(user);

    return {
      message: 'OTP verified successfully',
      user: {
        id: user.id,
        mobileNumber: user.mobileNumber,
        fullName: user.fullName,
        email: user.email,
        role: user.role,
      },
      ...tokens,
    };
  }

  async refresh(refreshToken) {
    try {
      const decoded = verifyRefreshToken(refreshToken);
      const user = await this.repository.findById(decoded.sub);
      if (!user) {
        const error = new Error('User not found');
        error.status = 401;
        throw error;
      }
      return generateTokenPair(user);
    } catch {
      const error = new Error('Invalid refresh token');
      error.status = 401;
      throw error;
    }
  }

  async getMe(userId) {
    const user = await this.repository.findById(userId);
    if (!user) {
      const error = new Error('User not found');
      error.status = 404;
      throw error;
    }
    return user;
  }
}

module.exports = { AuthRepository, AuthService };
