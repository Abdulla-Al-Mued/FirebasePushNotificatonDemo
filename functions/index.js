const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendNewUserNotification = functions.firestore
  .document('notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const notification = snap.data();
    
    if (!notification.tokens || notification.tokens.length === 0) {
      console.log('No tokens to send notifications to');
      return null;
    }
    
    const message = {
      notification: {
        title: notification.title,
        body: notification.body
      },
      tokens: notification.tokens
    };
    
    try {
      const response = await admin.messaging().sendMulticast(message);
      console.log(`${response.successCount} messages were sent successfully`);
      return { success: true, count: response.successCount };
    } catch (error) {
      console.log('Error sending message:', error);
      return { error: error.message };
    }
  });