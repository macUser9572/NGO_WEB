import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AboutusPage extends StatelessWidget {
  const AboutusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizing) {
        if (sizing.deviceScreenType == DeviceScreenType.desktop) {
          return const _AboutDesktop();
        } else {
          return const _MobileLayout();
        }
      },
    );
  }
}

// ===================== DESKTOP =====================
class _AboutDesktop extends StatelessWidget {
  const _AboutDesktop();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
  child: Container(
    width: double.infinity,
    height: height,
    color: AllColors.secondaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 80),
    child: Stack(
      children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT TEXT
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.only(top: 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "About us",
                        style: GoogleFonts.inter(
                          color: AllColors.primaryColor,
                          fontSize: 80,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 820,
                        child: Text(
                          "The Bangalore Chakma Society (BCS) represents the collective journey, resilience, and unity of the Chakma and Buddhist communities who have made Bengaluru their home. The roots of this journey trace back to the early arrivals of Chakma individuals in the city, beginning with pioneers who came as students and professionals and went on to build successful careers laying a proud foundation for the community.",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            height: 1.6,
                            color: AllColors.thirdColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 820,
                        child: Text(
                          "While small groups of Chakma individuals visited or stayed briefly in the 1990s, the true groundwork of BCS began to take shape around 2007, when a growing number of students and working professionals settled in Bangalore. Even during these early years, community members came together informally to celebrate culture, religion, and shared identity.",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            height: 1.6,
                            color: AllColors.thirdColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 60),

              // RIGHT VIDEO
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.only(top: 160),
                  child: Container(
                    height: height * 0.6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.play_arrow, size: 48),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // BUTTON
          SizedBox(height: 70),
          Positioned(
            left: 0,
            bottom: 170,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AllColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
                elevation: 0,
              ),

              child: const Text(
                'Read More about BCS',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

// ===================== MOBILE =====================
class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('about Page1')),
      body: Center(
        child: Text(
          'This is the mobile layout',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
