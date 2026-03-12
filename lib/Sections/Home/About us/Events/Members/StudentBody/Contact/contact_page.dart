import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ngo_web/constraints/CustomButton.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ngo_web/constraints/all_colors.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizing) {
        switch (sizing.deviceScreenType) {
          case DeviceScreenType.desktop:
            return const _DesktopLayout();
          default:
            return const _MobileLayout();
        }
      },
    );
  }
}

// ============================== DESKTOP LAYOUT ==============================

class _DesktopLayout extends StatefulWidget {
  const _DesktopLayout({super.key});

  @override
  State<_DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<_DesktopLayout> {
  final TextEditingController nameController    = TextEditingController();
  final TextEditingController phoneController   = TextEditingController();
  final TextEditingController emailController   = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  bool isLoading = false;

  static const String _serviceId  = 'service_id_1';
  static const String _templateId = 'template_pfxf54s';
  static const String _publicKey  = 'L5HZmZFqQVCwcb7Q_';

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> _sendEmail() async {
    final response = await http.post(
      Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
      headers: {
        'Content-Type': 'application/json',
        'origin': 'http://localhost',
      },
      body: jsonEncode({
        'service_id':  _serviceId,
        'template_id': _templateId,
        'user_id':     _publicKey,
        'template_params': {
          'name':    nameController.text.trim(),
          'phone':   phoneController.text.trim(),
          'email':   emailController.text.trim(),
          'message': messageController.text.trim(),
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('EmailJS failed: ${response.body}');
    }
  }

  Future<void> _saveToFirestore() async {
    await FirebaseFirestore.instance.collection('contact_messages').add({
      'name':      nameController.text.trim(),
      'phone':     phoneController.text.trim(),
      'email':     emailController.text.trim(),
      'message':   messageController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _submitForm() async {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        emailController.text.isEmpty ||
        messageController.text.isEmpty) {
      _showSnackBar("Please fill all fields");
      return;
    }

    setState(() => isLoading = true);

    try {
      await Future.wait([
        _sendEmail(),
        _saveToFirestore(),
      ]);

      _showSnackBar("Message sent successfully ✅");

      nameController.clear();
      phoneController.clear();
      emailController.clear();
      messageController.clear();

    } catch (e) {
      _showSnackBar("Failed to send message ❌");
      debugPrint('Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width  = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: SizedBox(
        width: width,
        height: height,
        child: Container(
          color: AllColors.secondaryColor,
          child: Stack(
            children: [

              // ================= LEFT FORM =================
              Positioned(
                top:  height * 0.15,
                left: width  * 0.06,
                child: Container(
                  width: width * 0.38,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: AllColors.fourthColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Got anything for us ?",
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AllColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Drop your message and we get back to you.",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 25),

                      _label("Your Name", required: true),
                      _input(controller: nameController),

                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label("Contact Number", required: true),
                                _input(controller: phoneController),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label("Mail", required: true),
                                _input(controller: emailController),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),
                      _label("Your Message", required: true),
                      Container(
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: TextField(
                          controller: messageController,
                          maxLines: null,
                          expands: true,
                          decoration: const InputDecoration(
                            hintText: "Write your Message here",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),
                      CustomButton(
                        label: "Send",
                        fontWeight: FontWeight.w800,
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _submitForm,
                      ),
                    ],
                  ),
                ),
              ),

              // ================= RIGHT CONTENT =================
              Positioned(
                top:   height * 0.20,
                right: width  * 0.05,
                child: SizedBox(
                  width: width * 0.40,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Reach Us",
                        style: GoogleFonts.inter(
                          fontSize: 80,
                          fontWeight: FontWeight.w800,
                          color: AllColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Need help or have a question?",
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AllColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 40),

                      _infoRow(Icons.email_outlined, "varshinigowdav8@gmail.com"),
                      const SizedBox(height: 16),
                      _infoRow(Icons.phone_outlined, "+91 7892345671"),

                      const SizedBox(height: 30),
                      Text(
                        "Registered Office",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "B 501 Elegant Whispering Winds\n"
                        "Thalagattapura\n"
                        "Bangalore - 560109",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AllColors.thirdColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  // ================= HELPERS =================
  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Widget _label(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: text,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _input({required TextEditingController controller}) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
      ),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AllColors.primaryColor),
        const SizedBox(width: 12),
        Text(text, style: GoogleFonts.inter(fontSize: 15)),
      ],
    );
  }
}

// ============================== MOBILE LAYOUT ==============================

class _MobileLayout extends StatefulWidget {
  const _MobileLayout();

  @override
  State<_MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends State<_MobileLayout> {
  final TextEditingController nameController    = TextEditingController();
  final TextEditingController phoneController   = TextEditingController();
  final TextEditingController emailController   = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  bool isLoading = false;

  static const String _serviceId  = 'service_id_1';
  static const String _templateId = 'template_pfxf54s';
  static const String _publicKey  = 'L5HZmZFqQVCwcb7Q_';

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> _sendEmail() async {
    final response = await http.post(
      Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
      headers: {
        'Content-Type': 'application/json',
        'origin': 'http://localhost',
      },
      body: jsonEncode({
        'service_id':  _serviceId,
        'template_id': _templateId,
        'user_id':     _publicKey,
        'template_params': {
          'name':    nameController.text.trim(),
          'phone':   phoneController.text.trim(),
          'email':   emailController.text.trim(),
          'message': messageController.text.trim(),
        },
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('EmailJS failed: ${response.body}');
    }
  }

  Future<void> _saveToFirestore() async {
    await FirebaseFirestore.instance.collection('contact_messages').add({
      'name':      nameController.text.trim(),
      'phone':     phoneController.text.trim(),
      'email':     emailController.text.trim(),
      'message':   messageController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _submitForm() async {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        emailController.text.isEmpty ||
        messageController.text.isEmpty) {
      _showSnackBar("Please fill all fields");
      return;
    }

    setState(() => isLoading = true);

    try {
      await Future.wait([_sendEmail(), _saveToFirestore()]);
      _showSnackBar("Message sent successfully ✅");
      nameController.clear();
      phoneController.clear();
      emailController.clear();
      messageController.clear();
    } catch (e) {
      _showSnackBar("Failed to send message ❌");
      debugPrint('Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AllColors.secondaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [

          // ── Title ──
          Text(
            "Reach Us",
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AllColors.primaryColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Need help or have a question?",
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AllColors.primaryColor,
            ),
          ),

          const SizedBox(height: 16),

          // ── Form Card ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AllColors.fourthColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Got anything for us?",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AllColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Drop your message and we get back to you.",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),

                _label("Your Name", required: true),
                _input(controller: nameController),

                const SizedBox(height: 16),
                _label("Contact Number", required: true),
                _input(controller: phoneController),

                const SizedBox(height: 16),
                _label("Mail", required: true),
                _input(controller: emailController),

                const SizedBox(height: 16),
                _label("Your Message", required: true),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: TextField(
                    controller: messageController,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                      hintText: "Write your Message here",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                CustomButton(
                  label: "Send",
                  fontWeight: FontWeight.w800,
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _submitForm,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Contact Info ──
          _infoRow(Icons.email_outlined, "varshinigowdav8@gmail.com"),
          const SizedBox(height: 12),
          _infoRow(Icons.phone_outlined, "+91 7892345671"),

          const SizedBox(height: 16),
          Text(
            "Registered Office",
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "B 501 Elegant Whispering Winds\n"
            "Thalagattapura\n"
            "Bangalore - 560109",
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AllColors.thirdColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: text,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _input({required TextEditingController controller}) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
      ),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AllColors.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
