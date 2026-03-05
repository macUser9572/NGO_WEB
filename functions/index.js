const {onCall, HttpsError} = require("firebase-functions/v2/https");
const nodemailer = require("nodemailer");

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "varshinigowdav8@gmail.com",
    pass: "lzolvnjunechkvfx",
  },
});

exports.sendMembershipEmail = onCall(async (request) => {
  // ✅ In Firebase Functions v2, data is at request.data
  const {email, name, status} = request.data;

  console.log("Received request.data:", request.data);
  console.log("Email:", email, "| Name:", name, "| Status:", status);

  if (!email || email.trim() === "") {
    console.error("No email provided! Full request.data:", request.data);
    throw new HttpsError("invalid-argument", "Recipient email is required");
  }

  let subject;
  let message;

  if (status === "approved") {
    subject = "Membership Approved 🎉";
    message = `Hello ${name},\n\nYour membership request has been successfully approved. We’re happy to have you with us.`;
  } else {
    subject = "Membership Rejected";
    message = `Hello ${name},\n\nA representative will reach out to you shortly. Thank you for your understanding..`;
  }

  try {
    await transporter.sendMail({
      from: "varshinigowdav8@gmail.com",
      to: email,
      subject: subject,
      text: message,
    });

    console.log("Email sent successfully to:", email);
    return {success: true};
  } catch (error) {
    console.error("Mail Error:", error);
    throw new HttpsError("internal", "Email sending failed: " + error.message);
  }
});