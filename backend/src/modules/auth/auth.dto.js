const { z } = require('zod');

const mobileSchema = z
  .string()
  .regex(/^[6-9]\d{9}$/, 'Mobile number must be 10 digits starting with 6-9');

const genderSchema = z.enum(['MALE', 'FEMALE', 'OTHER']);

const captchaSchema = z.object({
  captchaToken: z.string().min(1),
  captchaAnswer: z.string().min(1),
});

const registerIndianSchema = z.object({
  body: z
    .object({
      registrationType: z.literal('INDIAN'),
      mobileNumber: mobileSchema,
      fullName: z.string().min(2).max(100),
      fatherName: z.string().min(2).max(100),
      aadhaarNumber: z.string().regex(/^\d{12}$/, 'Aadhaar must be 12 digits'),
      email: z.string().email(),
      gender: genderSchema,
      profileImageUrl: z.string().url().optional(),
    })
    .merge(captchaSchema),
});

const registerNriSchema = z.object({
  body: z
    .object({
      registrationType: z.literal('NRI'),
      mobileNumber: mobileSchema,
      fullName: z.string().min(2).max(100),
      fatherName: z.string().min(2).max(100),
      passportNumber: z.string().min(6).max(20),
      email: z.string().email(),
      gender: genderSchema,
      profileImageUrl: z.string().url().optional(),
    })
    .merge(captchaSchema),
});

const registerSchema = z.object({
  body: z.discriminatedUnion('registrationType', [
    registerIndianSchema.shape.body,
    registerNriSchema.shape.body,
  ]),
});

const sendOtpSchema = z.object({
  body: z
    .object({
      mobileNumber: mobileSchema,
    })
    .merge(captchaSchema),
});

const verifyOtpSchema = z.object({
  body: z.object({
    mobileNumber: mobileSchema,
    otp: z.string().length(6, 'OTP must be 6 digits'),
  }),
});

const refreshTokenSchema = z.object({
  body: z.object({
    refreshToken: z.string().min(1),
  }),
});

const createTicketSchema = z.object({
  body: z.object({
    districtId: z.string().uuid(),
    tehsilId: z.string().uuid(),
    projectId: z.string().uuid(),
    remarks: z.string().min(10).max(2000),
  }),
});

const updateStatusSchema = z.object({
  params: z.object({ id: z.string().uuid() }),
  body: z.object({
    status: z.enum(['OPEN', 'ASSIGNED', 'IN_PROGRESS', 'RESOLVED', 'CLOSED', 'REOPENED']),
    priority: z.enum(['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']).optional(),
  }),
});

const assignTicketSchema = z.object({
  params: z.object({ id: z.string().uuid() }),
  body: z.object({
    agentId: z.string().uuid(),
  }),
});

const addCommentSchema = z.object({
  params: z.object({ id: z.string().uuid() }),
  body: z.object({
    message: z.string().min(1).max(2000),
  }),
});

const createDistrictSchema = z.object({
  body: z.object({ name: z.string().min(2).max(100) }),
});

const createTehsilSchema = z.object({
  body: z.object({
    districtId: z.string().uuid(),
    name: z.string().min(2).max(100),
  }),
});

const createProjectSchema = z.object({
  body: z.object({
    tehsilId: z.string().uuid(),
    name: z.string().min(2).max(100),
    description: z.string().max(500).optional(),
  }),
});

const registerDeviceSchema = z.object({
  body: z.object({
    fcmToken: z.string().min(1),
    platform: z.enum(['ANDROID', 'WEB', 'IOS']),
  }),
});

module.exports = {
  registerSchema,
  sendOtpSchema,
  verifyOtpSchema,
  refreshTokenSchema,
  createTicketSchema,
  updateStatusSchema,
  assignTicketSchema,
  addCommentSchema,
  createDistrictSchema,
  createTehsilSchema,
  createProjectSchema,
  registerDeviceSchema,
};
