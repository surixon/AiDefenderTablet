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
const sgMail = require("@sendgrid/mail");
const logger = require("firebase-functions/logger");
const functions = require("firebase-functions");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// Access the API key from the config
const SENDGRID_API_KEY = functions.config().sendgrid.key;
sgMail.setApiKey(SENDGRID_API_KEY);

exports.helloWorld = onRequest((request, response) => {
  logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

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

exports.sendEmail = onRequest(async (req, res) => {
  try {
    // Parse the incoming request body
    const {toEmail, subject, message} = req.body;

    // Prepare email message
    const msg = {
      to: toEmail,
      from: "alerts@aidefender1000.com",
      subject: subject,
      text: message,
    };

    console.error("Request sending email:", msg);

    // Send email via SendGrid
    await sgMail.send(msg);
    // Send success response
    res.status(200).json({success: true, message: "Email sent successfully!"});
  } catch (error) {
    console.error("Error sending email:", error);
    res.status(500).json({success: false, message: error.message});
  }
});
