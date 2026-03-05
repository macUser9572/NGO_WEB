
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/Sections/Home/Be%20a%20contributor.dart';
import 'package:ngo_web/constraints/CustomButton.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:responsive_builder/responsive_builder.dart';

class OurInitiatives extends StatelessWidget {
  const OurInitiatives({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizing) {
        if (sizing.deviceScreenType == DeviceScreenType.desktop) {
          return const _DesktopLayout();
        } else {
          return const _MobileLayout();
        }
      },
    );
  }
}

// ========================== DESKTOP LAYOUT ==========================
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> initiatives = [
      "Health Insurance Adoption",
      "Awareness of Law and Justice",
      "Mental Health Support",
      "Education and Skill Programs",
      "Awareness of Chakma Culture and Religion",
      "Test Rig Software Development",
    ];

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        color: AllColors.fourthColor,
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 80),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= LEFT SIDE =================
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Initiatives",
                    style: GoogleFonts.inter(
                      color: AllColors.primaryColor,
                      fontSize: 70,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "We spearhead initiatives to support newcomers,\n"
                    "easing their transition into city life and addressing\n"
                    "common challenges.",
                    style: GoogleFonts.inter(
                      color: AllColors.primaryColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Bullet Points
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: initiatives.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "• ",
                              style: GoogleFonts.inter(
                                color: AllColors.primaryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                item,
                                style: GoogleFonts.inter(
                                  color: AllColors.primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 30),

                  CustomButton(
                    label: "Know More",
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 10,
                    ),
                    onPressed: () {
                       showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const ComingSoonDialog(),
                        );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(width: 40),

            // ================= RIGHT SIDE IMAGE =================
            Expanded(
              flex: 5,
              child: Center(
                child: Image.asset(
                  "assets/image/OurInitiatives.png",
                  width: 550,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      "Image not found. Check pubspec.yaml",
                      style: TextStyle(color: Colors.red),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================== MOBILE LAYOUT ==========================
class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Initiatives Page"),
      ),
      body: const Center(
        child: Text(
          "Mobile layout coming soon",
          style: TextStyle(fontSize: 18,color: AllColors.fifthColor),
        ),
      ),
    );
  }
}
