const path = require('path');
const fs = require('fs');
const multer = require('multer');
const { v4: uuidv4 } = require('uuid');
const config = require('../config');

const uploadDir = path.resolve(config.upload.dir);
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, uploadDir),
  filename: (_req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    cb(null, `${uuidv4()}${ext}`);
  },
});

function fileFilter(_req, file, cb) {
  const ext = path.extname(file.originalname).toLowerCase();
  if (
    config.upload.allowedMimeTypes.includes(file.mimetype) &&
    config.upload.allowedExtensions.includes(ext)
  ) {
    cb(null, true);
  } else {
    cb(new Error('Invalid file type. Allowed: jpg, jpeg, png, pdf'));
  }
}

const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: config.upload.maxFileSizeMb * 1024 * 1024 },
});

function mapUploadedFiles(files, baseUrl) {
  return (files || []).map((f) => ({
    fileName: f.originalname,
    fileUrl: `${baseUrl}/uploads/${f.filename}`,
    fileSize: f.size,
  }));
}

module.exports = { upload, mapUploadedFiles };
