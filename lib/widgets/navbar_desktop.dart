import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:ngo_web/constraints/all_images.dart';
import 'package:ngo_web/widgets/scroll_helper.dart';
import 'package:provider/provider.dart';

class NavbarDesktop extends StatelessWidget {
  const NavbarDesktop({super.key});

  static const Map<int, int> _sectionToNav = {
    0: 0, // Home
    1: 1, // About
    2: 1, // About (sub-section)
    3: 3, // Events
    4: 4, // Student-Body
    5: 5, // Members
    6: 6, // Initiatives
    7: 7, // Reach us
    8: 7, // Reach us (sub-section)
  };

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20), // 🔥 Less spacing
      color: AllColors.fourthColor,
      child: Row(
        children: [
          _buildLogo(context),
          const Spacer(),
          _buildMenu(context),
        ],
      ),
    );
  }

  // ================= LOGO =================
  Widget _buildLogo(BuildContext context) {
    return InkWell(
      onTap: () => scrollToSection(context, 0),
      child: Row(
        children: [
          SizedBox(
            height: 30,
            width: 30,
            child: AllImages.greenlogo(),
          ),
          const SizedBox(width: 6),
          Text(
            'BCS',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AllColors.fifthColor,
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
        _navItem(context, 'Initiatives', 6),
        _navItem(context, 'Reach us', 7),
      ],
    );
  }

  // ================= MENU ITEM =================
  Widget _navItem(BuildContext context, String title, int index) {
    final current = context.watch<ScrollState>().currentSection;
    final bool isActive = _sectionToNav[current] == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4), // 🔥 Reduced gap
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => scrollToSection(context, index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? AllColors.fifthColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isActive
                  ? Colors.white
                  : AllColors.primaryColor.withOpacity(0.75), 
            ),
          ),
        ),
      ),
    );
  }
}
