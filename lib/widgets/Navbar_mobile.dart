import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:ngo_web/widgets/scroll_helper.dart';
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
            GestureDetector(
              onTap: () => scrollToSection(context, 0),
              child: Row(
                children: [
                  SvgPicture.asset(
                    "assets/icons/CompanyLogo.svg",
                    height: 34,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "NGO",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AllColors.fifthColor,
                    ),
                  ),
                ],
              ),
            ),

            // ── Hamburger ──
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: AllColors.fifthColor),
                onPressed: () {
                  Scaffold.of(ctx).openEndDrawer(); // ← opens right
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}