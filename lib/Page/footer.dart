import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:ngo_web/constraints/all_images.dart';
import 'package:ngo_web/widgets/scroll_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  static const Map<String, int> _sectionFor = {
    'Home': 0,
    'About Us': 1,
    'Event': 3,
    'Student Body': 4,
    'Members': 5,
    'Initiatives': 6,
    'Reach us': 7,
  };

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1000;

    return Container(
      width: double.infinity,
      color: AllColors.secondaryColor,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1300),
          child: isDesktop ? _desktopLayout(context) : const SizedBox(),
        ),
      ),
    );
  }

  //======================== Desktop Footer ==========================
  Widget _desktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 4, child: _leftContent()),
        Container(
          height: 300,
          width: 1,
          color: const Color.fromARGB(255, 206, 205, 205),
          margin: const EdgeInsets.symmetric(horizontal: 97),
        ),
        Expanded(flex: 4, child: _rightContent(context)),
      ],
    );
  }

  //========================= LEFT CONTENT ===========================
  Widget _leftContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              color: AllColors.secondaryColor,
              height: 48,
              width: 48,
              child: AllImages.greenlogo(),
            ),
            const SizedBox(width: 10),

            Text(
              "BCS",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AllColors.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          "Jawdaw Re Jaat togai\n Hangarai Gat Togai !",
          style: GoogleFonts.inter(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: AllColors.primaryColor,
          ),
        ),
        const SizedBox(height: 120),
        Text(
          "© 2025 BCS Trust – All rights reserved.",
          style: GoogleFonts.inter(fontSize: 13, color: AllColors.thirdColor),
        ),
      ],
    );
  }

  //========================= RIGHT CONTENT ==========================
  Widget _rightContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Key Links",
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AllColors.primaryColor,
          ),
        ),
        const SizedBox(height: 20),
        _menuItem(context, "Home"),
        _menuItem(context, "About Us"),
        _menuItem(context, "Event"),
        _menuItem(context, "Student Body"),
        _menuItem(context, "Members"),
        _menuItem(context, "Initiatives"),
        _menuItem(context, "Reach us"),
        const SizedBox(height: 20),
        // Row(
        //   children: [
        //     MouseRegion(
        //       cursor: SystemMouseCursors.click,
        //       child: GestureDetector(
        //         onTap: () => _launchUrl(""),
        //         child: SvgPicture.asset(
        //           "assets/icons/LinkedinLogo.svg",
        //           width: 30,
        //           height: 30,
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget _menuItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            final int? section = _sectionFor[text];
            if (section == null) return;
            scrollToSection(context, section);
          },
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  //========================= URL LAUNCHER ===========================
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}
