import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

//==========================Desktop Layout====================
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;    return Container(
      width: double.infinity,
      height: height,
      color: AllColors.fourthColor,
      padding: const EdgeInsets.symmetric(horizontal: 80),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //======================Left Content=================
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Initiatives",
                    style: GoogleFonts.inter(
                      color: AllColors.primaryColor,
                      fontSize: 80,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    "We spearhead initiatives to support newcomers,\n"
                    "easing their transition into city life and addressing\n"
                    "common challenges.",
                    style: GoogleFonts.inter(
                      color: AllColors.primaryColor,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Health Insurance Adoption",
                    style: GoogleFonts.inter(
                      color: AllColors.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Awareness of Law and Justice",
                    style: GoogleFonts.inter(
                      color: AllColors.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Mental Health Support",
                    style: GoogleFonts.inter(
                      color: AllColors.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Education and Skill Programs",
                    style: GoogleFonts.inter(
                      color: AllColors.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Awareness of Chakma Culture and Religion",
                    style: GoogleFonts.inter(
                      color: AllColors.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Test Rig Software Development",
                    style: GoogleFonts.inter(
                      color: AllColors.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  //=====================Button==================
                    Positioned(
                    child: CustomButton(
                      label: "Know More",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 10,
                      ),
                      onPressed: () {
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          //===============================Right image=================
          Expanded(
            flex: 5,
            child: Align(
              alignment: Alignment.topRight,
              child: Transform.translate(
                offset: const Offset(30, 90),
                child: Image.asset(
                  "assets/image/ourimage.png",
                  width: 780,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= MOBILE LAYOUT =================
class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Mobile Layout ", style: GoogleFonts.inter(fontSize: 18)),
    );
  }
}
