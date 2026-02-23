import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/Members/StudentBody/Student_list_page.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:responsive_builder/responsive_builder.dart';

class StudentPage extends StatelessWidget {
  const StudentPage({super.key});

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

// ====================== DESKTOP LAYOUT ======================
class _DesktopLayout extends StatefulWidget {
  const _DesktopLayout();

  @override
  State<_DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<_DesktopLayout> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  final List<Map<String, dynamic>> _slides = [
    {"image": "assets/image/photo1.png"},
    {"image": "assets/image/photo2.png"},
    {"image": "assets/image/photo3.png"},
    {"image": "assets/image/photo4.png"},
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Container(
        width: width,
        height: height,
        color: AllColors.fourthColor,
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 80),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= LEFT CONTENT =================
            Expanded(
              flex: 5, // reduced from 6
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "BSCA",
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.w800,
                      color: AllColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Student Body",
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AllColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 720,
                    child: Text(
                      "The student body serves as a unifying platform that brings students together, "
                      "creating an environment where everyone can learn, grow, and thrive. It leads "
                      "student-driven activities, supports new initiatives, and ensures that every student "
                      "feels included, represented, and heard. Through these efforts, the community becomes "
                      "stronger, more cohesive, and better connected.\n"
                      "The student body also aims to collaborate with other Northeastern student organizations, "
                      "fostering shared learning, cultural exchange, and collective initiatives. It actively "
                      "participates in addressing student concerns and resolving issues as a united voice.\n"
                      "The Bangalore Chakma Students' Body operates as an integral part of the Bangalore Chakma "
                      "Society and functions under the guidance and supervision of senior members.",
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.7,
                        color: AllColors.thirdColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AllColors.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StudentListPage(),
                        ),
                      );
                    },
                    child: Text(
                      "Student Members",
                      style: GoogleFonts.inter(
                        color: AllColors.secondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 60),

            // ================= RIGHT IMAGE CAROUSEL =================
            Expanded(
              flex: 5, // increased from 4
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  // ── Carousel ──
                  Expanded(
                    child: CarouselSlider(
                      carouselController: _carouselController,
                      options: CarouselOptions(
                        height: 580,
                        viewportFraction: 1.0,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 3),
                        autoPlayAnimationDuration:
                            const Duration(milliseconds: 600),
                        autoPlayCurve: Curves.easeInOut,
                        enlargeCenterPage: false,
                        scrollDirection: Axis.vertical,
                        onPageChanged: (index, reason) {
                          setState(() => _currentIndex = index);
                        },
                      ),
                      items: _slides.map((slide) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            slide["image"]!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ── Controls OUTSIDE to the RIGHT ──
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      // Up / Prev arrow
                      GestureDetector(
                        onTap: () => _carouselController.previousPage(),
                        child: Icon(
                          Icons.keyboard_arrow_up_rounded,
                          color: AllColors.primaryColor,
                          size: 24,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Vertical dots
                      ..._slides.asMap().entries.map((entry) {
                        final isActive = entry.key == _currentIndex;
                        return GestureDetector(
                          onTap: () =>
                              _carouselController.animateToPage(entry.key),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            width: 8,
                            height: isActive ? 24 : 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AllColors.primaryColor
                                  : AllColors.primaryColor.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 10),

                      // Down / Next arrow
                      GestureDetector(
                        onTap: () => _carouselController.nextPage(),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AllColors.primaryColor,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}

// ===================== MOBILE LAYOUT =====================
class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Mobile Layout", style: GoogleFonts.inter(fontSize: 18)),
    );
  }
}