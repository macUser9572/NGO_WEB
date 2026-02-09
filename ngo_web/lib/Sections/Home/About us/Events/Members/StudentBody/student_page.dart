import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          width: size.width,
          color: const Color(0xFFEFFFF6),
          // padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 80),
          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 80),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= LEFT CONTENT =================
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "BSCA",
                      style: TextStyle(
                        fontSize: 96,
                        fontWeight: FontWeight.w800,
                        color: AllColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Student Body",
                      style: TextStyle(
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
                        "The Bangalore Chakma Students’ Body operates as an integral part of the Bangalore Chakma "
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

              // ================= RIGHT IMAGE COLUMN =================
              Expanded(
                flex: 4,
                child: Column(
                  children: const [
                    _FixedImageCard(
                      image: "assets/image/photo1.png",
                      height: 100,
                    ),
                    SizedBox(height: 20),

                    _FixedImageCard(
                      image: "assets/image/photo2.png",
                      height: 250,
                    ),
                    SizedBox(height: 20),

                    _FixedImageCard(
                      image: "assets/image/photo3.png",
                      height: 250,
                    ),
                    SizedBox(height: 20),

                    _FixedImageCard(
                      image: "assets/image/Photo4.png",
                      height: 100,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= IMAGE CARD =================
class _FixedImageCard extends StatelessWidget {
  final String image;
  final double height;

  const _FixedImageCard({required this.image, required this.height});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Image.asset(image, fit: BoxFit.cover),
      ),
    );
  }
}

// ===================== MOBILE LAYOUT =====================
class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFFF6),
      appBar: AppBar(
        title: const Text("Student Body"),
        backgroundColor: AllColors.primaryColor,
      ),
      body: const Center(
        child: Text(
          "Mobile layout coming soon",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
