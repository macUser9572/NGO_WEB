import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

//////////////////////////////////////////////////////
/// ================= DESKTOP ===================== ///
//////////////////////////////////////////////////////

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
      padding: const EdgeInsets.only(left: 40, right: 40, top: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// ================= LEFT SIDE =================
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 120),

                Text(
                  'Ju Ju !',
                  style: GoogleFonts.inter(
                    color: AllColors.primaryColor,
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  "Jawdaw Re Jaat togai, Hangarai Gat Togai !",
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AllColors.primaryColor,
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: width > 900 ? 828 : width * 0.9,
                  child: Text(
                    "Bangalore Chakma Society (BCS) is a collective of individuals "
                    "from the Chakma community living in Bangalore. Every Chakma "
                    "residing in the city is considered a part of this community group. "
                    "Although not a formal organization with a fixed hierarchy, "
                    "BCS operates through mutual understanding, cooperation, and respect "
                    "among its members.\n",
                    style: GoogleFonts.inter(
                      color: AllColors.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: width > 900 ? 828 : width * 0.9,
                  child: Text(
                    "Most members are professionals working in corporate or government "
                    "sectors, contributing their skills and experience to support the "
                    "community's growth. The primary objective of BCS is to preserve, "
                    "promote, and celebrate Chakma culture and traditions within the "
                    "urban environment of Bangalore. The community also guides and "
                    "supports the student body, encouraging their active participation "
                    "in various events and initiatives organized by BCS.",
                    style: GoogleFonts.inter(
                      color: AllColors.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// ================= RIGHT SIDE =================
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [

                /// Align with "Ju Ju !"
                const SizedBox(height: 150),

                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('homepage')
                      .doc('banner_image')
                      .snapshots(),
                  builder: (context, snapshot) {

                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const SizedBox(
                        height: 400,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return SizedBox(
                        height: 400,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.image_outlined,
                                  size: 60,
                                  color: Colors.grey.shade400),
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
                        ),
                      );
                    }

                    final data =
                        snapshot.data!.data() as Map<String, dynamic>;
                    final imageUrl = data['imageUrl'] as String;

                    return Image.network(
                      imageUrl,
                      width: width * 0.35,
                      fit: BoxFit.contain,
                      loadingBuilder:
                          (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          height: 400,
                          child: Center(
                              child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder:
                          (context, error, stackTrace) {
                        return SizedBox(
                          height: 400,
                          child: Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 60,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
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
      backgroundColor: AllColors.primaryColor,
      appBar: AppBar(
        backgroundColor: AllColors.primaryColor,
        elevation: 0,
        title: Text(
          "BCS",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.center,
          children: [

            Text(
              "Ju Ju !",
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Colors.green.shade800,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Jawdaw Re Jaat togai, Hangarai Gat Togai !",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('homepage')
                  .doc('banner_image')
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData ||
                    !snapshot.data!.exists) {
                  return const SizedBox.shrink();
                }

                final data =
                    snapshot.data!.data() as Map<String, dynamic>;
                final imageUrl =
                    data['imageUrl'] as String;

                return Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
