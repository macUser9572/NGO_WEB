import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    messageController.dispose();
    super.dispose();
  }

  // ================= FIRESTORE SUBMIT =================
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
      await FirebaseFirestore.instance
          .collection('contact_messages')
          .add({
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'message': messageController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSnackBar("Message sent successfully ✅");

      nameController.clear();
      phoneController.clear();
      emailController.clear();
      messageController.clear();
    } catch (e) {
      _showSnackBar("Failed to send message ❌");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
final width = MediaQuery.of(context).size.width;
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
                top: height * 0.15,
                left: width * 0.06,
                child: Container(
                  width: width * 0.38,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9F1E6),
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

                      _label("Your Name"),
                      _input(controller: nameController),

                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label("Contact Number"),
                                _input(controller: phoneController),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label("Mail"),
                                _input(controller: emailController),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),
                      _label("Your Message"),
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

                      SizedBox(
                        width: 100,
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AllColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          onPressed: isLoading ? null : _submitForm,
                          child: isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  "Send",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: AllColors.secondaryColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ================= RIGHT CONTENT =================
              Positioned(
                top: height * 0.20,
                right: width * 0.05,
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

                      _infoRow(Icons.email_outlined,
                          "BCS.Bangalore@gmail.com"),
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
                          color: AllColors.primaryColor,
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

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
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

class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contact Us")),
      body: const Center(
        child: Text(
          "Mobile layout coming soon",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
