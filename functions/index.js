/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const sgMail = require("@sendgrid/mail");
const admin = require("firebase-admin");
const {defineSecret} = require("firebase-functions/params");
const functions = require("firebase-functions");

const SENDGRID_API_KEY = defineSecret("SENDGRID_API_KEY");

// Initialize Firebase Admin SDK
admin.initializeApp();

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

exports.sendEmail = onRequest(
    {secrets: [SENDGRID_API_KEY]},
    async (req, res) => {
      console.error("SendGrid error:", SENDGRID_API_KEY.value());
      sgMail.setApiKey(SENDGRID_API_KEY.value());
      if (req.method !== "POST") {
        return res.status(405).send("Method Not Allowed");
      }

      const {to, subject, text, html} = req.body;

      const msg = {
        to,
        from: "alerts@aidefender1000.com",
        subject,
        text,
        html: html || `<p>${text}</p>`,
      };

      try {
        await sgMail.send(msg);
        return res.status(200).send({success: true, message: "Email sent"});
      } catch (error) {
        console.error("SendGrid error:", error);
        return res.status(500).send({success: false, error: error.toString()});
      }
    });

exports.generateCustomToken = functions.https.onRequest(async (req, res) => {
  const uid = req.body.uid;

  if (!uid) {
    return res.status(400).json({error: "UID required"});
  }

  try {
    const customToken = await admin.auth().createCustomToken(uid);
    res.json({token: customToken});
  } catch (error) {
    console.error("Error creating custom token:", error);
    res.status(500).json({error: "Internal error"});
  }
});

