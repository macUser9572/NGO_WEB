import 'package:flutter/material.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/Members/StudentBody/studentimagebackend.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/upload_event.dart';
import 'package:ngo_web/Sections/Home/About%20us/vediolink.dart';
import 'package:ngo_web/Sections/Home/HomepageImageUpload.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class ContentUploadPageTab extends StatelessWidget {
  const ContentUploadPageTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Title
            Text(
              "Content Upload",
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),

            /// Cards centered in remaining space
            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    /// Homepage Card
                    _UploadCard(
                      icon: Icons.home_outlined,
                      label: "Homepage",
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => const HomepageUploadPopup(),
                        );
                      },
                    ),

                    const SizedBox(width: 60),

                    /// Video Card
                    _UploadCard(
                      icon: Icons.play_circle_outline_rounded,
                      label: "Video",
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => const Videolink(),
                        );
                      },
                    ),

                    const SizedBox(width: 60),

                    /// Events Card
                    _UploadCard(
                      icon: Icons.image_outlined,
                      label: "Events",
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => EventsUploadPage(),
                        );
                      },
                    ),

                    const SizedBox(width: 60),

                    /// Student Body Card
                    _UploadCard(
                      icon: Icons.groups_outlined,
                      label: "Student Body",
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => Studentimagebackend(),
                        );
                      },
                    ),

                  ],
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
// UPLOAD CARD WIDGET
// ─────────────────────────────────────────────
class _UploadCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _UploadCard({
    required this.icon,
    required this.label,
    required this.onTap,
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
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            color: AllColors.fourthColor,
            border: Border.all(
              color: _hovering
                  ? AllColors.primaryColor
                  : Colors.grey.shade300,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(4),
            boxShadow: _hovering
                ? [
                    BoxShadow(
                      color: AllColors.primaryColor.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 32,
                color: AllColors.primaryColor,
              ),
              const SizedBox(height: 12),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 13,
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