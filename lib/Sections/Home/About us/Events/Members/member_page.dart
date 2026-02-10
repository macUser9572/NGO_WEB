import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'Member_List_page.dart';

class MemberPage extends StatelessWidget {
  const MemberPage({super.key});

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

// ========================== DESKTOP LAYOUT =========================
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: size.height,
      color: AllColors.secondaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 80),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= LEFT CONTENT =================
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.only(top: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Members",
                    style: GoogleFonts.inter(
                      color: AllColors.primaryColor,
                      fontSize: 80,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "The Headcount",
                    style: GoogleFonts.inter(
                      color: AllColors.thirdColor,
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 446,
                    child: Text(
                      "The number of participants is growing exponentially each year. Here’s a breakdown of the BCS community members in Bangalore.",
                      style: GoogleFonts.inter(
                        color: AllColors.thirdColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "1394+",
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AllColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: const [
                      _StatItem(label: "Men", value: "40%"),
                      SizedBox(width: 30),
                      _StatItem(label: "Women", value: "38%"),
                      SizedBox(width: 30),
                      _StatItem(label: "Children", value: "20%"),
                      SizedBox(width: 30),
                      _StatItem(label: "Others", value: "2%"),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // ================= BUTTON =================
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AllColors.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MembersListPage(),
                        ),
                      );
                    },
                    child: Text(
                      "View Members",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AllColors.secondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================= RIGHT IMAGE =================
          Expanded(
            flex: 5,
            child: Align(
              alignment: Alignment.topRight,
              child: Transform.translate(
                offset: const Offset(30, 190),
                child: Image.asset(
                  "assets/image/Memberpage.png",
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

// ================= STAT ITEM =================
class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14)),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AllColors.primaryColor,
          ),
        ),
      ],
    );
  }
}

// ================= MOBILE LAYOUT =================
class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Mobile Layout Coming Soon",
        style: GoogleFonts.inter(fontSize: 18),
      ),
    );
  }
}
