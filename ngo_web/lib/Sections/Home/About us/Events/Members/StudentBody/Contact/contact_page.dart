import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:responsive_builder/responsive_builder.dart';

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

//================================DESKTOPLAYOUT===========================

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Container(
          color: AllColors.fourthColor,
          child: Stack(
            children: [
              // LEFT FORM
              Positioned(
                top: size.height * 0.15,
                left: size.width * 0.06,
                child: Container(
                  width: size.width * 0.38,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Color(0xFFD9F1E6),
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
                      _input(),

                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [_label("Contact Number"), _input()],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [_label("Mail"), _input()],
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
                        child: const TextField(
                          maxLines: null,
                          expands: true,
                          decoration: InputDecoration(
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
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
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

              // RIGHT CONTENT (YOUR EXISTING SECTION)
              Positioned(
                top: size.height * 0.20,
                right: size.width * 0.05,
                child: SizedBox(
                  width: size.width * 0.40,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Reach Us",
                        style: GoogleFonts.inter(
                          fontSize: 130,
                          fontWeight: FontWeight.w800,
                          color: AllColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Need help or have a question?",
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AllColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 40),

                      _infoRow(Icons.email_outlined, "BCS.Bangalore@gmail.com"),
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

                      // Row(
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     SvgPicture.asset(
                      //       'assets/icons/Signpost.svg',
                      //       width: 20,
                      //       height: 20,
                      //       colorFilter: const ColorFilter.mode(
                      //         Colors.black87,
                      //         BlendMode.srcIn,
                      //       ),
                      //     ),
                      //     const SizedBox(width: 10),
                      //     Expanded(
                      //       child: Text(
                      //         "B 501 Elegant Whispering Winds\n"
                      //         "Thalagattapura\n"
                      //         "Bangalore - 560109",
                      //         style: GoogleFonts.inter(
                      //           fontSize: 14,
                      //           height: 1.5,
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      Text(
                        "B 501 Elegant Whispering Winds\n"
                        "Thalagattapura\n"
                        "Bangalore - 560109",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
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

  // -------- Helpers --------

  static Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  static Widget _input() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
      ),
      child: const TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }

  static Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AllColors.primaryColor),
        const SizedBox(width: 12),
        Text(text, style: GoogleFonts.inter(fontSize: 15)),
      ],
    );
  }
}

//======================MOBILELAYOUT==========================

class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contact Page')),
      body: Center(
        child: Text(
          'This is the mobile layout',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
