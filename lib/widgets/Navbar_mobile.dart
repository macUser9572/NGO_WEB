import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bangalore_chakma_society/Sections/Home/About%20us/Events/Members/adminloginpop_memberpage.dart';
import 'package:bangalore_chakma_society/Sections/Home/NewsPaper.dart';
import 'package:bangalore_chakma_society/constraints/all_colors.dart';
import 'package:bangalore_chakma_society/widgets/scroll_helper.dart';
import 'package:google_fonts/google_fonts.dart';

class NavbarMobile extends StatelessWidget {
  const NavbarMobile({super.key});

  @override
  Widget build(BuildContext context) {
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

            // ── Newspaper Icon + Admin Icon + Hamburger ──
            Row(
              children: [
                _buildNewspaperIcon(context), // ✅ Fixed: now called here
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
          child: SvgPicture.asset(
            "assets/icons/adminicon.svg",
            height: 20,
            width: 20,
          ),
        ),
      ),
    );
  }

  // ── Newspaper Icon ──
  Widget _buildNewspaperIcon(BuildContext context) {
    return Tooltip(
      message: "News Paper",
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => const Newspaper(),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: SvgPicture.asset(
            "assets/icons/Newspaper.svg",
            height: 20,
            width: 20,
          ),
        ),
      ),
    );
  }
}
