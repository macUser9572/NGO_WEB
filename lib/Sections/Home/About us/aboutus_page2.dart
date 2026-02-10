import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/constraints/all_colors.dart';

class AboutusPage2 extends StatelessWidget {
  const AboutusPage2({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height,
      color: const Color(0xFFEFFAF4), // light green background
      padding: const EdgeInsets.symmetric(horizontal: 80),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ================= LEFT SIDE =================
          Expanded(
            flex: 5,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _leftTitle("Vision"),
                  const SizedBox(height: 12),
                  _leftText(
                    "To preserve and carry forward the legacy of Chakma culture and\n""tradition in cities, while embracing the changes of modern times.",
                  ),
                  const SizedBox(height: 60),
                  _leftTitle("Mission"),
                  const SizedBox(height: 12),
                  _leftText(
                    "To empower the young generation to learn, share their knowledge,\n"
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
            color: Colors.grey.shade400,
          ),

          // ================= RIGHT SIDE =================
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.only(left: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _valuesTitle("Values"),
                  const SizedBox(height: 24),

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

  // ================= LEFT STYLES =================

  Widget _leftTitle(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: 80,
        fontWeight: FontWeight.w800,
        color: AllColors.primaryColor,
      ),
    );
  }

  Widget _leftText(String text) {
    return SizedBox(
      width: 320,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 16,
          height: 1.6,
          color: AllColors.primaryColor,
        ),
      ),
    );
  }

  // ================= RIGHT STYLES =================

  Widget _valuesTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 80,
        fontWeight: FontWeight.w800,
        color:AllColors.primaryColor,
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
          const SizedBox(height: 6),
          SizedBox(
            width: 520,
            child: Text(
              description,
              style: GoogleFonts.inter(
                fontSize: 16,
                height: 1.6,
                color: AllColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
