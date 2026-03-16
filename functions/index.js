const {onCall, HttpsError} = require("firebase-functions/v2/https");
const nodemailer = require("nodemailer");

exports.sendMembershipEmail = onCall(async (request) => {
  const {email, name, status} = request.data;

  console.log("Received request.data:", request.data);
  console.log("Email:", email, "| Name:", name, "| Status:", status);

  if (!email || email.trim() === "") {
    console.error("No email provided! Full request.data:", request.data);
    throw new HttpsError("invalid-argument", "Recipient email is required");
  }

  // ✅ Create transporter INSIDE the function (not at module level)
  // This avoids cold-start auth caching issues in Cloud Functions
  const transporter = nodemailer.createTransport({
    host: "smtp.zoho.in",   // ✅ Use .in if your account is on Zoho India
    port: 465,
    secure: true,
    auth: {
      user: "admin@bangalorechakmasociety.org",
      pass: "i8uUpMnZXQf1",  // ✅ App Password, not account password
    },
    tls: {
      rejectUnauthorized: false,
    },
  });

  let subject;
  let message;

  if (status === "approved") {
    subject = "Membership Approved 🎉";
    message = `Hello ${name},\n\nYour membership request has been successfully approved. We're happy to have you with us.\n\nRegards,\nBangalore Chakma Society`;
  } else {
    subject = "Membership Rejected";
    message = `Hello ${name},\n\nA representative will reach out to you shortly. Thank you for your understanding.\n\nRegards,\nBangalore Chakma Society;`;
  }

  try {
    await transporter.sendMail({
      from: '"Bangalore Chakma Society" <admin@bangalorechakmasociety.org>',
      replyTo: "admin@bangalorechakmasociety.org",
      to: email,
      subject: subject,
      text: message,
    });

    console.log("✅ Email sent successfully to:", email);
    return {success: true};
  } catch (error) {
    console.error("❌ Mail Error:", error);
    throw new HttpsError("internal", "Email sending failed: " + error.message);
  }
});