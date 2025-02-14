/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
admin.initializeApp();

// Define the Cloud Function
exports.sendNotification = onRequest(async (req, res) => {
  try {
    // Extract token, title, and body from the request
    const {token, title, body, data, android, apns} = req.body;

    // Validate request payload
    if (!token || !title || !body) {
      return res.status(400).json({
        error: "Missing required fields: token, title, body",
      });
    }

    // Create the notification message
    const message = {
      notification: {
        title: title,
        body: body,
      },
      token: token,
      data: data,
      android: android,
      apns: apns,
    };

    // Send the notification
    await admin.messaging().send(message);

    // Respond with success
    return res.status(200).json({
      success: true,
      message: "Notification sent successfully",
    });
  } catch (error) {
    // Log and respond with error
    console.error("Error sending notification:", error);
    return res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

