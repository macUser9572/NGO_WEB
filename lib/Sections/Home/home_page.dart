import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:responsive_builder/responsive_builder.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizing) {
        switch (sizing.deviceScreenType) {
          case DeviceScreenType.desktop:
            return const HomeDesktop();
          default:
            return const HomeMobile();
        }
      },
    );
  }
}

// ===================== DESKTOP =====================

class HomeDesktop extends StatelessWidget {
  const HomeDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      height: height,
      // color: AllColors.primaryColor,
      color: AllColors.fourthColor,
      padding: const EdgeInsets.only(left: 40, right: 40, top: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= LEFT COLUMN (Text) =================
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 120),
                Text(
                  'Ju Ju !',
                  style: GoogleFonts.inter(
                    color: AllColors.primaryColor,
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Jawdaw Re Jaat togai, Hangarai Gat Togai !",
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AllColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: width > 900 ? 828 : width * 0.9,
                  child: Text(
                    "Bangalore Chakma Society (BCS) is a collective of individuals from the Chakma community living in Bangalore. Every Chakma residing in the city is considered a part of this community group. Although not a formal organization with a fixed hierarchy, BCS operates through mutual understanding, cooperation, and respect among its members.\n",
                    style: GoogleFonts.inter(
                      color: AllColors.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: width > 900 ? 828 : width * 0.9,
                  child: Text(
                    "Most members are professionals working in corporate or government sectors, contributing their skills and experience to support the community’s growth. The primary objective of BCS is to preserve, promote, and celebrate Chakma culture and traditions within the urban environment of Bangalore. The community also guides and supports the student body, encouraging their active participation in various events and initiatives organized by BCS.",
                    style: GoogleFonts.inter(
                      color: AllColors.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ================= RIGHT COLUMN (Image) =================
          Expanded(
            flex: 4,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Image.asset(
                "assets/image/homeimage.png",
                width: MediaQuery.of(context).size.width * 0.95,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== MOBILE =====================

class HomeMobile extends StatelessWidget {
  const HomeMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.primaryColor,
      appBar: AppBar(
        backgroundColor: AllColors.primaryColor,
        elevation: 0,
        title: Row(
          children: [
            const SizedBox(width: 6),
            Text(
              "BCS",
              style: GoogleFonts.poppins(
                color: AllColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.menu, color: Colors.black),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            /// Title
            Text(
              "Ju Ju !",
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Colors.green.shade800,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            /// Subtitle
            Text(
              "Jadwar Re Jaat Cogi, Hangarai Gat Togi !",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            /// Description
            Text(
              "Bangalore Chakma Society (BCS) is a collective of individuals "
              "from the Chakma community living in Bangalore. Every Chakma "
              "residing in the city is considered a part of this community. "
              "Although not a formal organization with a fixed hierarchy, "
              "BCS operates through mutual understanding, cooperation, "
              "and respect among its members.\n\n"
              "Most members are professionals working in corporate or "
              "government sectors, contributing their skills and experience "
              "to support the community’s growth. The primary objective of "
              "BCS is to preserve, promote, and celebrate Chakma culture and "
              "traditions within the urban environment of Bangalore. "
              "The community also guides and supports students, encouraging "
              "their active participation in various events and initiatives "
              "organized by BCS.",
              style: GoogleFonts.poppins(
                fontSize: 13,
                height: 1.6,
                color: Colors.black87,
              ),
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 30),

            /// Image section
            Image.asset(
              "assets/image/homeimage.png",
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
