import 'package:bangalore_chakma_society/Sections/Home/adimagepage.dart';
import 'package:flutter/material.dart';
import 'package:bangalore_chakma_society/Sections/Home/About%20us/Events/Members/StudentBody/studentimagebackend.dart';
import 'package:bangalore_chakma_society/Sections/Home/About%20us/Events/upload_event.dart';
import 'package:bangalore_chakma_society/Sections/Home/About%20us/vediolink.dart';
import 'package:bangalore_chakma_society/Sections/Home/HomepageImageUpload.dart';
import 'package:bangalore_chakma_society/constraints/all_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_builder/responsive_builder.dart';

// ─────────────────────────────────────────────
//  RESPONSIVE ENTRY POINT
// ─────────────────────────────────────────────
class ContentUploadPageTab extends StatelessWidget {
  const ContentUploadPageTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizing) {
        if (sizing.deviceScreenType == DeviceScreenType.desktop) {
          return const _DesktopLayout();
        } else {
          return const _MobileLayout();
        }
      },
    );
  }
}

// ─────────────────────────────────────────────
//  DESKTOP LAYOUT
// ─────────────────────────────────────────────
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  static const List<_CardData> _cards = [
    _CardData(icon: Icons.home_outlined, label: "Homepage"),
    _CardData(icon: Icons.play_circle_outline_rounded, label: "Video"),
    _CardData(icon: Icons.image_outlined, label: "Events"),
    _CardData(icon: Icons.groups_outlined, label: "Student Body"),
    _CardData(icon: Icons.add_photo_alternate_outlined, label: "Announcement"),
  ];

  void _handleTap(BuildContext context, String label) {
    Widget dialog;
    switch (label) {
      case "Homepage":
        dialog = const HomepageUploadPopup();
        break;
      case "Video":
        dialog = const Videolink();
        break;
      case "Events":
        dialog = EventsUploadPage();
        break;
      case "Student Body":
        dialog = Studentimagebackend();
        break;
      case "Announcement":
      default:
        dialog = const Adimagepage();
        break;
    }
    showDialog(context: context, builder: (_) => dialog);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ──
            Text(
              "Content Upload",
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),

            // ── Cards ──
            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const int cardCount = 5;
                    const double minSpacing = 16.0;
                    const double maxSpacing = 60.0;
                    const double minCard = 120.0;
                    const double maxCard = 180.0;

                    // Try max card size first, shrink if needed
                    double spacing = maxSpacing;
                    double cardSize =
                        ((constraints.maxWidth - spacing * (cardCount - 1)) /
                                cardCount)
                            .clamp(minCard, maxCard);

                    // Recalculate spacing from actual card size
                    spacing =
                        ((constraints.maxWidth - cardSize * cardCount) /
                                (cardCount - 1))
                            .clamp(minSpacing, maxSpacing);

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(_cards.length, (i) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _UploadCard(
                                icon: _cards[i].icon,
                                label: _cards[i].label,
                                cardSize: cardSize,
                                onTap: () =>
                                    _handleTap(context, _cards[i].label),
                              ),
                              if (i < _cards.length - 1)
                                SizedBox(width: spacing),
                            ],
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MOBILE LAYOUT
// ─────────────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  void _handleTap(BuildContext context, String label) {
    Widget dialog;
    switch (label) {
      case "Homepage":
        dialog = const HomepageUploadPopup();
        break;
      case "Video":
        dialog = const Videolink();
        break;
      case "Events":
        dialog = EventsUploadPage();
        break;
      case "Student Body":
        dialog = Studentimagebackend();
        break;
      case "Announcement":
      default:
        dialog = const Adimagepage();
        break;
    }
    showDialog(context: context, builder: (_) => dialog);
  }

  @override
  Widget build(BuildContext context) {
    final cards = [
      _CardData(icon: Icons.home_outlined, label: "Homepage"),
      _CardData(icon: Icons.play_circle_outline_rounded, label: "Video"),
      _CardData(icon: Icons.image_outlined, label: "Events"),
      _CardData(icon: Icons.groups_outlined, label: "Student Body"),
      _CardData(
        icon: Icons.add_photo_alternate_outlined,
        label: "Announcement",
      ),
    ];

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ──
            Text(
              "Content Upload",
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 32),

            // ── Cards Grid ──
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: cards
                    .map(
                      (card) => _UploadCard(
                        icon: card.icon,
                        label: card.label,
                        onTap: () => _handleTap(context, card.label),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  CARD DATA MODEL
// ─────────────────────────────────────────────
class _CardData {
  final IconData icon;
  final String label;
  const _CardData({required this.icon, required this.label});
}

// ─────────────────────────────────────────────
//  UPLOAD CARD WIDGET
// ─────────────────────────────────────────────
class _UploadCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double cardSize;

  const _UploadCard({
    required this.icon,
    required this.label,
    required this.onTap,
    this.cardSize = 180,
  });

  @override
  State<_UploadCard> createState() => _UploadCardState();
}

class _UploadCardState extends State<_UploadCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.cardSize,
          height: widget.cardSize,
          decoration: BoxDecoration(
            color: AllColors.fourthColor,
            border: Border.all(
              color: _hovering ? AllColors.primaryColor : Colors.grey.shade300,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(4),
            boxShadow: _hovering
                ? [
                    BoxShadow(
                      color: AllColors.primaryColor.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: (widget.cardSize * 0.18).clamp(24, 36),
                color: AllColors.primaryColor,
              ),
              const SizedBox(height: 12),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: (widget.cardSize * 0.072).clamp(11, 14),
                  fontWeight: FontWeight.w400,
                  color: AllColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
