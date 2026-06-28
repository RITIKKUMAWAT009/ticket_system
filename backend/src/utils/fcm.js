const config = require('../config');
const logger = require('./logger');

let admin = null;

function initFirebase() {
  if (config.fcm.disabled) {
    logger.info('FCM is disabled');
    return null;
  }

  try {
    const adminSdk = require('firebase-admin');
    if (!adminSdk.apps.length) {
      const serviceAccount = require(config.fcm.serviceAccountPath);
      adminSdk.initializeApp({
        credential: adminSdk.credential.cert(serviceAccount),
      });
    }
    admin = adminSdk;
    logger.info('Firebase Admin initialized');
    return admin;
  } catch (error) {
    logger.warn('Firebase Admin init failed — push notifications disabled', {
      error: error.message,
    });
    return null;
  }
}

async function sendPushNotification(fcmToken, title, body, data = {}) {
  if (!admin || config.fcm.disabled) {
    logger.debug('FCM skipped', { title, body });
    return null;
  }

  try {
    const message = {
      token: fcmToken,
      notification: { title, body },
      data: Object.fromEntries(
        Object.entries(data).map(([k, v]) => [k, String(v)])
      ),
    };
    return await admin.messaging().send(message);
  } catch (error) {
    logger.error('FCM send failed', { error: error.message, token: fcmToken });
    return null;
  }
}

module.exports = { initFirebase, sendPushNotification };
