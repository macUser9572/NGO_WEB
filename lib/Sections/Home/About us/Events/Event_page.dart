import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EventPage extends StatelessWidget {
  const EventPage({super.key});

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
// URL HELPER
// ─────────────────────────────────────────────
String fixFirebaseUrl(String url) {
  if (url.isEmpty) return url;
  if (url.contains('firebasestorage.googleapis.com') &&
      !url.contains('alt=media')) {
    return url.contains('?') ? '$url&alt=media' : '$url?alt=media';
  }
  return url;
}

// ─────────────────────────────────────────────
// IMAGE CARD — with dashed border + title below
// ─────────────────────────────────────────────
Widget _imageCard(dynamic imageUrl, dynamic title, {double height = 200}) {
  final String url = fixFirebaseUrl(imageUrl?.toString() ?? "");

  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // IMAGE
        ClipRRect(
          borderRadius: BorderRadius.zero,
          child: url.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: url,
                  height: height,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: height,
                    color: Colors.grey.shade100,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: height,
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: Icon(Icons.broken_image_outlined,
                          size: 40, color: Colors.grey),
                    ),
                  ),
                )
              : Container(
                  height: height,
                  color: Colors.grey.shade100,
                  child: const Center(
                    child: Icon(Icons.image_outlined,
                        size: 40, color: Colors.grey),
                  ),
                ),
        ),

        // TITLE
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: AllColors.fourthColor,
            borderRadius: BorderRadius.zero,
          ),
          child: Text(
            title?.toString() ?? "",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AllColors.primaryColor,
            ),
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────
// DESKTOP LAYOUT
// ─────────────────────────────────────────────
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 80),
      color: AllColors.secondaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PAGE TITLE
          Text(
            "What We Do",
            style: GoogleFonts.inter(
              fontSize: 80,
              fontWeight: FontWeight.w800,
              color: AllColors.primaryColor,
            ),
          ),

          const SizedBox(height: 50),

          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("events")
                .doc("upload_events")
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text("Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red)),
                );
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Center(
                  child: Text("No Events Found",
                      style: GoogleFonts.inter(fontSize: 16)),
                );
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── LEFT COLUMN ──────────────────────────
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _imageCard(
                                  data["image1"], data["title1"],
                                  height: 220),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _imageCard(
                                  data["image2"], data["title2"],
                                  height: 220),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Key Information
                        Text(
                          "Key Information",
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AllColors.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          data["key_information"] ?? "",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            height: 1.7,
                            color: AllColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 50),

                  // ── RIGHT COLUMN ─────────────────────────
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Events",
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AllColors.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Discover our diverse range of activities and events designed to enrich our community",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AllColors.primaryColor,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: _imageCard(
                                  data["image3"], data["title3"],
                                  height: 220),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _imageCard(
                                  data["image4"], data["title4"],
                                  height: 220),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MOBILE LAYOUT
// ─────────────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      color: AllColors.secondaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What We Do",
            style: GoogleFonts.inter(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: AllColors.primaryColor,
            ),
          ),

          const SizedBox(height: 30),

          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("events")
                .doc("upload_events")
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red));
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Text("No Events Found");
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: _imageCard(data["image1"], data["title1"],
                              height: 140)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _imageCard(data["image2"], data["title2"],
                              height: 140)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "Key Information",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AllColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data["key_information"] ?? "",
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        height: 1.6,
                        color: AllColors.primaryColor),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    "Events",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AllColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Discover our diverse range of activities and events designed to enrich our community",
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.5),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                          child: _imageCard(data["image3"], data["title3"],
                              height: 140)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _imageCard(data["image4"], data["title4"],
                              height: 140)),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
