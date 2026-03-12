import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/Members/adminloginpop_memberpage.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:ngo_web/widgets/scroll_helper.dart';
import 'package:google_fonts/google_fonts.dart';

class NavbarMobile extends StatelessWidget {
  const NavbarMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).padding.top + 50;

    return SafeArea(
      bottom: false,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: AllColors.fourthColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            // ── Logo ──
            Row(
              children: [
                InkWell(
                  onTap: () {
                    scrollToSection(context, 0);
                    if (Scaffold.of(context).isEndDrawerOpen) {
                      Navigator.of(context).pop();
                    }
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        "assets/icons/CompanyLogo.svg",
                        height: 34,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "BCS",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AllColors.fifthColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Admin Icon + Hamburger ──
            Row(
              children: [
                _buildAdminIcon(context),
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu, color: AllColors.fifthColor),
                    onPressed: () {
                      Scaffold.of(ctx).openEndDrawer();
                    },
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }

  // ── Admin Icon ──
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
          child: Image.asset(
            "assets/image/adminlogo.png",
            height: 20,
            width: 20,
          ),
        ),
      ),
    );
  }
}
