import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:ngo_web/constraints/all_images.dart';
import 'package:ngo_web/widgets/scroll_helper.dart';
import 'package:provider/provider.dart';

class NavbarDesktop extends StatelessWidget {
  const NavbarDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double navHeight = (width * 0.06).clamp(64, 80);
    final double horizontalPadding = (width * 0.05).clamp(20, 40);

    return Container(
      height: navHeight,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      color: AllColors.fourthColor,
      child: Row(
        children: [_buildLogo(context), const Spacer(), _buildMenu(context)],
      ),
    );
  }

  // ================= LOGO =================
  Widget _buildLogo(BuildContext context) {
    return InkWell(
      onTap: () => scrollToSection(context, 0),
      child: Row(
        children: [
          SizedBox(height: 46, width: 46, child: AllImages.greenlogo()),
          const SizedBox(width: 8),
          Text(
            'BCS',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AllColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // ================= MENU =================
  Widget _buildMenu(BuildContext context) {
    return Row(
      children: [
        _navItem(context, 'Home', 0),

        _navItem(context, 'About', 1),

        _navItem(context, 'Events', 3),
        _navItem(context, 'Student-Body', 4),

        _navItem(context, 'Members', 5),
        _navItem(context, "Initiatives", 6),
        _navItem(context, 'Reach us', 7),
      ],
    );
  }

  // ================= MENU ITEM =================
  Widget _navItem(BuildContext context, String title, int index) {
  final current = context.watch<ScrollState>().currentSection;

  final bool isActive =
      (index == 0 && current == 0) ||                  // Home
      (index == 1 && (current == 1 || current == 2)) ||// About
      (index == 2 && current == 3) ||                  // Events
      (index == 3 && current == 4) ||                  // Student-Body
      (index == 4 && current == 5) ||                  // Members
      (index == 5 && current == 6) ||                  // Extra (if any)
      (index == 6 && current == 7) ||                  // Initiatives
      (index == 7 && current == 8);                    // ✅ Reach us

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: () => scrollToSection(context, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AllColors.primaryColor,
          ),
        ),
      ),
    ),
  );
}
}
