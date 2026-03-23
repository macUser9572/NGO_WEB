import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bangalore_chakma_society/Sections/Home/About%20us/Events/Members/adminloginpop_memberpage.dart';
import 'package:bangalore_chakma_society/Sections/Home/NewsPaper.dart';
import 'package:bangalore_chakma_society/constraints/all_colors.dart';
import 'package:bangalore_chakma_society/widgets/scroll_helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavbarDesktop extends StatelessWidget {
  const NavbarDesktop({super.key});

  static const Map<int, int> _sectionToNav = {
    0: 0,
    1: 1,
    2: 1,
    3: 3,
    4: 4,
    5: 5,
    6: 6,
    7: 7,
    8: 7,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: AllColors.fourthColor,
      child: Row(
        children: [
          _buildLogo(context),
          const Spacer(),
          _buildMenu(context),
          const SizedBox(width: 12),
          _buildNewspaperIcon(context),
          const SizedBox(width: 12),
          _buildAdminIcon(context),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return InkWell(
      onTap: () => scrollToSection(context, 0),
      child: Row(
        children: [
          SvgPicture.asset("assets/icons/CompanyLogo.svg", height: 32, width: 32),
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

  Widget _buildMenu(BuildContext context) {
    return Row(
      children: [
        _navItem(context, 'Home', 0),
        _navItem(context, 'About Us', 1),
        _navItem(context, 'Events', 3),
        _navItem(context, 'Student Body', 4),
        _navItem(context, 'Members', 5),
        _navItem(context, 'Initiatives', 6),
        _navItem(context, 'Reach us', 7),
      ],
    );
  }
 Widget _buildNewspaperIcon(BuildContext context){
  return Tooltip(
    message: "New Paper",
    child: InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        showDialog(
          context: context, 
          builder: (_) => const Newspaper()
          );
      },
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: SvgPicture.asset("assets/icons/Newspaper.svg", height: 24, width: 24),

        ),
    ),
  );
 }
  Widget _buildAdminIcon(BuildContext context) {
    return Tooltip(
      message: "Admin Login",
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => const AdminLoginPopup(),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: SvgPicture.asset("assets/icons/adminicon.svg", height: 24, width: 24),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, String title, int index) {
    // ✅ Fixed: use ScrollState instead of scrollToSection
    final current = context.watch<ScrollState>().currentSection;
    final bool isActive = _sectionToNav[current] == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => scrollToSection(context, index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AllColors.fifthColor : Colors.transparent,
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
