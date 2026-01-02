const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

/**
 * Send notification to all tokens registered for a user.
 * @param {string} userId - The ID of the user to send to.
 * @param {object} payload - The notification payload.
 * @return {Promise<void>}
 */
async function sendToUser(userId, payload) {
    const tokensSnap = await admin.firestore()
        .collection(`users/${userId}/fcmTokens`)
        .get();

    if (tokensSnap.empty) return null;

    const tokens = tokensSnap.docs.map((doc) => doc.id);

    const response = await admin.messaging().sendToDevice(tokens, payload);

    // Clean up invalid tokens
    const tokensToRemove = [];
    response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
            if (error.code === "messaging/invalid-registration-token" ||
                error.code === "messaging/registration-token-not-registered") {
                tokensToRemove.push(tokensSnap.docs[index].ref.delete());
            }
        }
    });

    // Also Log to Firestore for the Notification Screen
    // We parse the inner string payload to store it as a proper map object
    let parsedPayload = {};
    try {
        parsedPayload = JSON.parse(payload.data.payload);
    } catch (e) {
        parsedPayload = payload.data;
    }

    await admin.firestore().collection(`users/${userId}/notifications`).add({
        payload: parsedPayload,
        read: false,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    return Promise.all(tokensToRemove);
}

/**
 * Triggers when a new order is updated or created to send a notification.
 * This respects the user's 'orders' notification setting.
 */
exports.onOrderUpdate = functions.firestore
    .document("orders/{orderId}")
    .onWrite(async (change, context) => {
        // If the document is deleted, do nothing
        if (!change.after.exists) return null;

        const orderData = change.after.data();
        const userId = orderData.userId;

        // 1. Get user settings
        const settingsSnap = await admin.firestore()
            .doc(`users/${userId}/settings/notifications`)
            .get();

        const settings = settingsSnap.data() || {
            systemNotifications: true,
            offers: true,
            orders: true,
        };

        if (!settings.orders) {
            console.log("User disabled order notifications");
            return null;
        }

        // 2. Prepare Payload
        const payload = {
            notification: {
                title: "Order Update",
                body: `Your order status changed to ${orderData.status}`,
            },
            data: {
                payload: JSON.stringify({
                    type: "order",
                    entityId: context.params.orderId,
                    route: "OrderHistory",
                    title: "Order Update",
                    body: `Your order status changed to ${orderData.status}`,
                }),
            },
        };

        // 3. Get Tokens and Send
        return sendToUser(userId, payload);
    });

/**
 * General Broadcast Notification for Offers
 */
exports.onNewOffer = functions.firestore
    .document("offers/{offerId}")
    .onCreate(async (snap, context) => {
        const offer = snap.data();

        const payload = {
            notification: {
                title: "New Offer!",
                body: offer.title,
                // Support for image in notification
                image: offer.imageUrl || "",
            },
            data: {
                payload: JSON.stringify({
                    type: "offer",
                    entityId: context.params.offerId,
                    route: "OffersView",
                    title: "New Offer!",
                    body: offer.title,
                    image: offer.imageUrl || "",
                }),
            },
        };

        // We use Topics for broadcast
        return admin.messaging().sendToTopic("offers", payload);
    });
