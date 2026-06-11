const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendChatNotification = functions.https.onCall(async (data, context) => {
    // التأكد من أن المستخدم مسجل الدخول
    if (!context.auth) {
        throw new functions.https.HttpsError(
            'unauthenticated',
            'You must be logged in to send notifications.'
        );
    }

    const { receiverToken, title, body, senderId, senderName, chatId } = data;

    // التأكد من وجود البيانات المطلوبة
    if (!receiverToken || !title || !body) {
        throw new functions.https.HttpsError(
            'invalid-argument',
            'Missing required fields: receiverToken, title, or body'
        );
    }

    // تجهيز الإشعار
    const payload = {
        notification: {
            title: title,
            body: body,
        },
        data: {
            senderId: senderId || '',
            senderName: senderName || '',
            chatId: chatId || '',
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
        android: {
            priority: 'high',
            notification: {
                sound: 'default',
                channelId: 'chat_channel',
            },
        },
        apns: {
            payload: {
                aps: {
                    sound: 'default',
                    'content-available': 1,
                },
            },
        },
    };

    try {
        // إرسال الإشعار
        await admin.messaging().sendToDevice(receiverToken, payload);
        console.log(`✅ Notification sent successfully to ${receiverToken.substring(0, 10)}...`);
        return { success: true, message: 'Notification sent' };
    } catch (error) {
        console.error('❌ Error sending notification:', error);
        
        // لو التوكن مش صالح، نحذفه من قاعدة البيانات
        if (error.code === 'messaging/invalid-registration-token' ||
            error.code === 'messaging/registration-token-not-registered') {
            try {
                const snapshot = await admin.firestore()
                    .collection('users')
                    .where('fcmToken', '==', receiverToken)
                    .get();
                
                snapshot.forEach((doc) => {
                    doc.ref.update({ fcmToken: null });
                });
                console.log('🗑️ Removed invalid token from database');
            } catch (firestoreError) {
                console.error('Error cleaning up token:', firestoreError);
            }
        }
        
        throw new functions.https.HttpsError(
            'internal', 
            'Failed to send notification: ' + error.message
        );
    }
});