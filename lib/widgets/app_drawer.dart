import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:ngo_web/widgets/scroll_helper.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _navigate(BuildContext context, int index) {
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 300), () {
      scrollToSection(context, index);
    });
  }

  @override
  Widget build(BuildContext context) {
    // ── Read current active section ──
    final currentSection = context.watch<ScrollState>().currentSection;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [

          // ── Header ──
          Container(
            width: double.infinity,
            color: AllColors.fifthColor,
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/icons/CompanyLogo.svg",
                  height: 48,
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  placeholderBuilder: (_) => const Icon(
                    Icons.account_balance,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "NGO",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // ── Menu Items ──
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _item(context, "Home",            0, currentSection),
                _item(context, "About Us",        1, currentSection),
                _item(context, "Events",          3, currentSection),
                _item(context, "Student Body",    4, currentSection),
                _item(context, "Members",         5, currentSection),
                _item(context, "Our Initiatives", 6, currentSection),
                _item(context, "Contact",         7, currentSection),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    String label,
    int index,
    int currentSection,
  ) {
    final bool isActive = currentSection == index;

    return InkWell(
      onTap: () => _navigate(context, index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          // ── Highlight active item ──
          color: isActive
              ? AllColors.fifthColor.withOpacity(0.08)
              : Colors.transparent,
          border: Border(
            // ── Left accent bar on active item ──
            left: BorderSide(
              color: isActive ? AllColors.fifthColor : Colors.transparent,
              width: 4,
            ),
            bottom: BorderSide(color: Colors.grey.shade100),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AllColors.fifthColor : Colors.black87,
          ),
        ),
      ),
    );
  }
}