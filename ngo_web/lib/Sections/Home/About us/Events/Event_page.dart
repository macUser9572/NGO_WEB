import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:responsive_builder/responsive_builder.dart';

class EventPage extends StatelessWidget {
  const EventPage({super.key});

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

// ======================= DESKTOP =========================
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AllColors.secondaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //=================TITLE===================
          Text(
            "What We Do",
            style: GoogleFonts.inter(
              color: AllColors.primaryColor,
              fontSize: 150,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 50),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //===================LEFT SECTION================
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //-------CardRow-------
                    Row(
                      children: const [
                        InfoCard(
                          image: "assets/image/Religion.png",
                          title: "Religion",
                        ),
                        SizedBox(width: 23),
                        InfoCard(
                          image: "assets/image/Culture_tradition.png",
                          title: "Culture tradition",
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Key Information",
                      style: GoogleFonts.inter(
                        color: AllColors.primaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: 700,
                      child: Text(
                        "The Chakma community joyfully celebrates Kathina Civara Dhana "
                        "and the vibrant Bizu Festival annually! Bizu, a lively three-day "
                        "New Year extravaganza, showcases Chakma traditions with rituals, "
                        "performances, and communal harmony every April. Since 2007, it's "
                        "been a time for feasting, dancing, singing, and exchanging "
                        "heartfelt wishes!",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          height: 1.6,
                          color: AllColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 300),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Events",
                      style: GoogleFonts.inter(
                        color: AllColors.primaryColor,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Discover our diverse range of activities and events designed to enrich our community",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        height: 1.56,
                        fontWeight: FontWeight.w400,
                        color: AllColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: const [
                        InfoCard(
                          image: "assets/image/Social_Services.png",
                          title: "Social Services",
                        ),
                        SizedBox(width: 23),
                        InfoCard(
                          image: "assets/image/Educational_Initiatives.png",
                          title: "Educational Initiatives",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//============================ INFO CARD ========================
class InfoCard extends StatelessWidget {
  final String image;
  final String title;
  const InfoCard({super.key, required this.image, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: AllColors.fourthColor,
        borderRadius: BorderRadius.vertical(),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(),
            child: Image.asset(
              image,
              width: 260,
              height: 260,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(height: 200);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== MOBILE =====================
class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Mobile layout (add later)',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
