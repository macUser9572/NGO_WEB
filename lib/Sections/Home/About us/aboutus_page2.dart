import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AboutusPage2 extends StatelessWidget {
  const AboutusPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizing) {
        if (sizing.deviceScreenType == DeviceScreenType.desktop) {
          return const _AboutDesktop2();
        } else {
          return const _MobileLayout();
        }
      },
    );
  }
}

// ===================== DESKTOP LAYOUT =====================
class _AboutDesktop2 extends StatelessWidget {
  const _AboutDesktop2();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      height: height,
      color: AllColors.fourthColor,
      padding: const EdgeInsets.symmetric(horizontal: 80),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ================= LEFT SIDE (Vision & Mission) =================
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _leftTitle("Vision"),
                  const SizedBox(height: 0),
                  _leftText(
                    "To preserve and carry forward the legacy of Chakma culture and "
                    "tradition in cities, while embracing the changes of modern times.",
                  ),
                  const SizedBox(height: 80),
                  _leftTitle("Mission"),
                  const SizedBox(height: 0),
                  _leftText(
                    "To empower the young generation to learn, share their knowledge, "
                    "and develop into confident contributors to society.",
                  ),
                ],
              ),
            ),
          ),

          // ================= DIVIDER =================
          Container(
            height: 600,
            width: 1,
            color: Colors.grey.shade300,
          ),

          // ================= RIGHT SIDE (Values) =================
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.only(left: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _valuesTitle("Values"),
                  const SizedBox(height: 10),
                  _valueItem(
                    "Unity & Brotherhood",
                    "Believe in growing not just as a community, but together with other cultures and identities, building bridges through respect, cooperation, and shared initiatives.",
                  ),
                  _valueItem(
                    "Cultural Preservation",
                    "Upholding and celebrating the rich heritage of Chakma culture.",
                  ),
                  _valueItem(
                    "Inclusiveness",
                    "Creating a welcoming environment where every individual feels valued and heard.",
                  ),
                  _valueItem(
                    "Growth & Learning",
                    "Encouraging continuous learning, knowledge-sharing, and personal development.",
                  ),
                  _valueItem(
                    "Service to Society",
                    "Working collectively to uplift our community and contribute positively to the broader society.",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _leftTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 80,
        fontWeight: FontWeight.w800,
        color: AllColors.primaryColor,
        height: 1.1,
      ),
    );
  }

  Widget _leftText(String text) {
    return SizedBox(
      width: 350,
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 16,
          height: 1.4,
          color: AllColors.primaryColor,
        ),
      ),
    );
  }

  Widget _valuesTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 80,
        fontWeight: FontWeight.w800,
        color: AllColors.primaryColor,
        height: 1.1,
      ),
    );
  }

  Widget _valueItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AllColors.primaryColor,
            ),
          ),
          const SizedBox(height: 0),
          SizedBox(
            width: 800,
            child: Text(
              description,
              style: GoogleFonts.inter(
                fontSize: 16,
                height: 1.5,
                color: AllColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== MOBILE LAYOUT =====================
class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AllColors.fourthColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Vision ──
          Text(
            "Vision",
            style: GoogleFonts.inter(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: AllColors.primaryColor,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "To preserve and carry forward the legacy of Chakma culture and "
            "tradition in cities, while embracing the changes of modern times.",
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.5,
              color: AllColors.primaryColor,
            ),
          ),

          const SizedBox(height: 25),

          // ── Mission ──
          Text(
            "Mission",
            style: GoogleFonts.inter(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: AllColors.primaryColor,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "To empower the young generation to learn, share their knowledge, "
            "and develop into confident contributors to society.",
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.5,
              color: AllColors.primaryColor,
            ),
          ),

          const SizedBox(height: 25),

          // ── Divider ──
          Divider(color: Colors.grey.shade300, thickness: 1),

          const SizedBox(height: 25),

          // ── Values ──
          Text(
            "Values",
            style: GoogleFonts.inter(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: AllColors.primaryColor,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),

          _mobileValueItem(
            "Unity & Brotherhood",
            "Believe in growing not just as a community, but together with other cultures and identities, building bridges through respect, cooperation, and shared initiatives.",
          ),
          _mobileValueItem(
            "Cultural Preservation",
            "Upholding and celebrating the rich heritage of Chakma culture.",
          ),
          _mobileValueItem(
            "Inclusiveness",
            "Creating a welcoming environment where every individual feels valued and heard.",
          ),
          _mobileValueItem(
            "Growth & Learning",
            "Encouraging continuous learning, knowledge-sharing, and personal development.",
          ),
          _mobileValueItem(
            "Service to Society",
            "Working collectively to uplift our community and contribute positively to the broader society.",
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _mobileValueItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AllColors.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.5,
              color: AllColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}