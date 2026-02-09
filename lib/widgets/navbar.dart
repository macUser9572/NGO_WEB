import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/widgets/scroll_helper.dart';
import 'package:provider/provider.dart';
import 'nav_models.dart';

class NavBarButton extends StatelessWidget {
  final NavItem item;
  const NavBarButton({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    final double buttonHeight = (width * 0.045).clamp(30, 40);
    final double buttonWidth = (width * 0.07).clamp(80, 100);
    final double fontSize = (width * 0.012).clamp(14, 18);

    return Consumer<ScrollController>(
      builder: (context, scrollController, _) {
        final currentScroll = scrollController.hasClients
            ? scrollController.offset
            : 0.0;

        final sectionIndex = ((currentScroll / size.height) + 0.5)
            .floor()
            .clamp(0, kSectionCount - 1);

        final isActive = navIndexForSection(sectionIndex) == item.index;

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () =>
                scrollToSection(context, sectionIndexForNav(item.index)),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: width * 0.005),
              height: buttonHeight,
              width: buttonWidth,
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    top: isActive ? 0 : buttonHeight,
                    bottom: isActive ? 0 : -buttonHeight,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFD0E2FB),
                        borderRadius: BorderRadius.circular(60),
                      ),
                    ),
                  ),
                  Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: GoogleFonts.inter(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w500,
                        color: isActive
                            ? const Color(0xFF4CAF50)
                            : Colors.white,
                      ),
                      child: Text(item.title),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
