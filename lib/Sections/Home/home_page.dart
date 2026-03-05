import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ngo_web/Sections/Home/Be%20a%20contributor.dart';
import 'package:ngo_web/Sections/Home/joinAsMember.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:responsive_builder/responsive_builder.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizing) {
        switch (sizing.deviceScreenType) {
          case DeviceScreenType.desktop:
            return const HomeDesktop();
          default:
            return const _MobileLayout();
        }
      },
    );
  }
}

/// ================= DESKTOP ===================== ///

class HomeDesktop extends StatelessWidget {
  const HomeDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      height: height,
      color: AllColors.fourthColor,
      padding: const EdgeInsets.only(left: 80, right: 40, top: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// ================= LEFT SIDE =================
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── "Ju Ju !" ──
                Text(
                  'Ju Ju !',
                  style: GoogleFonts.inter(
                    color: AllColors.primaryColor,
                    fontSize: 90,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),

                const SizedBox(height: 16),

                // ── Tagline ──
                Text(
                  "Jawdaw Re Jaat togai, Hangarai Gat Togai !",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AllColors.primaryColor,
                  ),
                ),

                const SizedBox(height: 8),

                // ── Subtitle ──
                Text(
                  "Supporting Students, Preserving culture and building unity.",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AllColors.primaryColor,
                  ),
                ),

                const SizedBox(height: 28),

                // ── Buttons ──
                Row(
                  children: [
                    // Join as Member — filled
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AllColors.fifthColor,
                        foregroundColor: AllColors.fourthColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const MembershipRequestDialog(),
                        );
                      },
                      child: Text(
                        "Join as Member",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Be a contributor — outlined
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AllColors.fifthColor,
                        side: BorderSide(
                          color: AllColors.fifthColor,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const ComingSoonDialog(),
                        );
                      },
                      child: Text(
                        "Be a contributor",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// ================= RIGHT SIDE =================
          Expanded(
            flex: 5,
            child: SizedBox(
              height: height,
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('homepage')
                    .doc('banner_image')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 60,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "No image uploaded yet",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final imageUrl = data['imageUrl'] as String;

                  return Image.network(
                    imageUrl,
                    width: width * 0.45,
                    height: height,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomRight,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= MOBILE ===================== ///

class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final navbarHeight = 70.0;

    return SizedBox(
      height: height - navbarHeight, // ← exact remaining screen height
      child: Container(
        width: double.infinity,
        color: AllColors.fourthColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 100),

                  Text(
                    'Ju Ju !',
                    style: GoogleFonts.inter(
                      color: AllColors.primaryColor,
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Jawdaw Re Jaat togai, Hangarai Gat Togai !",
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AllColors.primaryColor,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Supporting Students, Preserving culture and building unity.",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AllColors.primaryColor,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Buttons ──
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AllColors.fifthColor,
                          foregroundColor: AllColors.fourthColor,
                          elevation: 0,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        // Join as Member button onPressed
                        onPressed: () {
                          showGeneralDialog(
                            context: context,
                            barrierDismissible: false,
                            barrierColor: Colors.black54,
                            transitionDuration: const Duration(
                              milliseconds: 280,
                            ),
                            pageBuilder: (_, __, ___) =>
                                const MembershipMobile(),
                            transitionBuilder: (context, anim, _, child) {
                              return SlideTransition(
                                position:
                                    Tween<Offset>(
                                      begin: const Offset(0, 1),
                                      end: Offset.zero,
                                    ).animate(
                                      CurvedAnimation(
                                        parent: anim,
                                        curve: Curves.easeOut,
                                      ),
                                    ),
                                child: child,
                              );
                            },
                          );
                        },
                        child: Text(
                          "Join as Member",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AllColors.fifthColor,
                          side: BorderSide(
                            color: AllColors.fifthColor,
                            width: 1.5,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const ComingSoonDialog(),
                          );
                        },
                        child: Text(
                          "Be a contributor",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Image fills ALL remaining space ──
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('homepage')
                    .doc('banner_image')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 60,
                        color: Colors.grey.shade400,
                      ),
                    );
                  }
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final imageUrl = data['imageUrl'] as String;

                  return Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 60,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
