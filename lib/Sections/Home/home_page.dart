import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
            return const HomeMobile();
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
                      onPressed: () {},
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

//////////////////////////////////////////////////////
/// ================= MOBILE ====================== ///
//////////////////////////////////////////////////////

class HomeMobile extends StatelessWidget {
  const HomeMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.fourthColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Ju Ju ──
                  Text(
                    "Ju Ju !",
                    style: GoogleFonts.inter(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      color: AllColors.primaryColor,
                      height: 1,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Tagline ──
                  Text(
                    "Jawdaw Re Jaat togai, Hangarai Gat Togai !",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AllColors.primaryColor,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ── Subtitle ──
                  Text(
                    "Supporting Students, Preserving culture and building unity.",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AllColors.primaryColor,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Buttons ──
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AllColors.fifthColor,
                          foregroundColor: AllColors.fourthColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {},
                        child: Text(
                          "Join as Member",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AllColors.fifthColor,
                          side: BorderSide(
                            color: AllColors.fifthColor,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {},
                        child: Text(
                          "Be a contributor",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Banner Image ──
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('homepage')
                  .doc('banner_image')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const SizedBox.shrink();
                }
                final data = snapshot.data!.data() as Map<String, dynamic>;
                final imageUrl = data['imageUrl'] as String;
                return Image.network(
                  imageUrl,
                  width: double.infinity,
                  fit: BoxFit.contain,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
