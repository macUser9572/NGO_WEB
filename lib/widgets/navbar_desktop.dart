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
          SizedBox(height: 32, width: 32, child: AllImages.greenlogo()),
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
}// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:ngo_web/constraints/all_colors.dart';
// import 'package:ngo_web/constraints/all_images.dart';
// import 'package:ngo_web/widgets/scroll_helper.dart';
// import 'package:provider/provider.dart';

// class NavbarDesktop extends StatelessWidget {
//   const NavbarDesktop({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final double navHeight = (width * 0.06).clamp(64, 80);
//     final double horizontalPadding = (width * 0.05).clamp(20, 40);

//     return Container(
//       height: navHeight,
//       padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
//       color: AllColors.fourthColor,
//       child: Row(
//         children: [_buildLogo(context), const Spacer(), _buildMenu(context)],
//       ),
//     );
//   }

//   // ================= LOGO =================
//   Widget _buildLogo(BuildContext context) {
//     return InkWell(
//       onTap: () => scrollToSection(context, 0),
//       child: Row(
//         children: [
//           SizedBox(height: 32, width:32, child: AllImages.greenlogo()),
//           const SizedBox(width: 8),
//           Text(
//             'BCS',
//             style: GoogleFonts.inter(
//               fontSize: 24,
//               fontWeight: FontWeight.w600,
//               color: AllColors.primaryColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ================= MENU =================
//   Widget _buildMenu(BuildContext context) {
//     return Row(
//       children: [
//         _navItem(context, 'Home', 0),
//         _navItem(context, 'About', 1),
//        _navItem(context, 'Events', 3),
//         _navItem(context, 'Student-Body', 4),
//         _navItem(context, 'Members', 5),
//         _navItem(context, "Initiatives", 6),
//         _navItem(context, 'Reach us', 7),
//       ],
//     );
//   }

//   // ================= MENU ITEM =================
 
//   Widget _navItem(BuildContext context, String title, int index) {
//   final current = context.watch<ScrollState>().currentSection;
//     final bool isActive = 
//   (index == 0 && current == 0) ||
//   (index == 1 && (current == 1 || current == 2)) ||
//   (index == 3 && current == 3) ||
//   (index == 4 && current == 4) ||
//   (index == 5 && current == 5) ||
//   (index == 6 && current == 6) ||  
//   (index == 7 && current == 7) ||
//   (index == 7 && current == 8);

//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 8),
//     child: InkWell(
//       borderRadius: BorderRadius.circular(40),
//       onTap: () => scrollToSection(context, index),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 250),
//         padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
//         decoration: BoxDecoration(
//           color: isActive ? Colors.white : Colors.transparent,
//           borderRadius: BorderRadius.circular(40),
//         ),
//         child: Text(
//           title,
//           style: GoogleFonts.inter(
//             fontSize: 18,
//             fontWeight: FontWeight.w500,
//             color: AllColors.primaryColor,
//           ),
//         ),
//       ),
//     ),
//   );
// }
// }
