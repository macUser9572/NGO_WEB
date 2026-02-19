import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ─────────────────────────────────────────────
// pubspec.yaml — make sure you have:
//   cloud_firestore: ^4.0.0
//   firebase_storage: ^11.0.0
//   cached_network_image: ^3.3.1
//   responsive_builder: ^0.7.0
// ─────────────────────────────────────────────

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
// URL HELPER — ensures Firebase Storage URLs work on Flutter Web
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
// SHARED EVENT CARD
// ─────────────────────────────────────────────
Widget _eventCard(dynamic imageUrl, dynamic title, {double height = 260}) {
  final String url = fixFirebaseUrl(imageUrl?.toString() ?? "");

  return Container(
    decoration: BoxDecoration(
      color: const Color(0xffdbe8e3),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // IMAGE
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: url.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: url,
                  height: height,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: height,
                    color: const Color(0xffdbe8e3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) {
                    debugPrint("❌ Image Error: $error | URL: $url");
                    return Container(
                      height: height,
                      width: double.infinity,
                      color: const Color(0xffdbe8e3),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image_outlined,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            "Image failed to load",
                            style:
                                TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : Container(
                  height: height,
                  color: const Color(0xffdbe8e3),
                  child: const Center(
                    child:
                        Icon(Icons.image_outlined, size: 48, color: Colors.grey),
                  ),
                ),
        ),

        const SizedBox(height: 15),

        // TITLE
        Padding(
          padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
          child: Text(
            title?.toString() ?? "",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 20,
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

          const SizedBox(height: 60),

          // FIRESTORE STREAM
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("events")
                .doc("upload_events")
                .snapshots(),
            builder: (context, snapshot) {
              // LOADING
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // ERROR — shows real error so you can debug
              if (snapshot.hasError) {
                debugPrint("❌ Firestore Error: ${snapshot.error}");
                return Center(
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 40),
                      const SizedBox(height: 10),
                      Text(
                        "Error: ${snapshot.error}",
                        style: GoogleFonts.inter(
                            fontSize: 14, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              // NO DATA
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Center(
                  child: Text(
                    "No Events Found.\nPlease upload events from the admin panel.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 16),
                  ),
                );
              }

              final data =
                  snapshot.data!.data() as Map<String, dynamic>;

              // Debug — check in Flutter console
              debugPrint("✅ Firestore data loaded");
              debugPrint("image1: ${data["image1"]}");
              debugPrint("image2: ${data["image2"]}");
              debugPrint("image3: ${data["image3"]}");
              debugPrint("image4: ${data["image4"]}");

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ROW 1
                  Row(
                    children: [
                      Expanded(
                          child: _eventCard(data["image1"], data["title1"])),
                      const SizedBox(width: 30),
                      Expanded(
                          child: _eventCard(data["image2"], data["title2"])),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // ROW 2
                  Row(
                    children: [
                      Expanded(
                          child: _eventCard(data["image3"], data["title3"])),
                      const SizedBox(width: 30),
                      Expanded(
                          child: _eventCard(data["image4"], data["title4"])),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // KEY INFORMATION
                  Text(
                    "Key Information",
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AllColors.primaryColor,
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: 900,
                    child: Text(
                      data["key_information"] ?? "",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        height: 1.6,
                        color: AllColors.primaryColor,
                      ),
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
              fontSize: 40,
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
                return Text(
                  "Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red),
                );
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Text("No Events Found");
              }

              final data =
                  snapshot.data!.data() as Map<String, dynamic>;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _eventCard(data["image1"], data["title1"], height: 200),
                  const SizedBox(height: 20),
                  _eventCard(data["image2"], data["title2"], height: 200),
                  const SizedBox(height: 20),
                  _eventCard(data["image3"], data["title3"], height: 200),
                  const SizedBox(height: 20),
                  _eventCard(data["image4"], data["title4"], height: 200),
                  const SizedBox(height: 30),

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
                      height: 1.6,
                      color: AllColors.primaryColor,
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


// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:ngo_web/constraints/all_colors.dart';
// import 'package:responsive_builder/responsive_builder.dart';

// class EventPage extends StatelessWidget {
//   const EventPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ResponsiveBuilder(
//       builder: (context, sizing) {
//         if (sizing.deviceScreenType == DeviceScreenType.desktop) {
//           return const _DesktopLayout();
//         } else {
//           return const _MobileLayout();
//         }
//       },
//     );
//   }
// }

// // ======================= DESKTOP =========================
// class _DesktopLayout extends StatelessWidget {
//   const _DesktopLayout();

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final height = MediaQuery.of(context).size.height;
//     return Container(
//       width: double.infinity,
//       color: AllColors.secondaryColor,
//       padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 80),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           //=================TITLE===================
//           Text(
//             "What We Do",
//             style: GoogleFonts.inter(
//               color: AllColors.primaryColor,
//               fontSize: 80,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           const SizedBox(height: 50),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               //===================LEFT SECTION================
//               // Expanded(
//               //   flex: 6,
//               //   child: Column(
//               //     crossAxisAlignment: CrossAxisAlignment.start,
//               //     children: [
//               //       //-------CardRow-------
//               //       Row(
//               //         children: const [
//               //           InfoCard(
//               //             image: "assets/image/Religion.png",
//               //             title: "Religion",
//               //           ),
//               //           SizedBox(width: 23),
//               //           InfoCard(
//               //             image: "assets/image/Culture_tradition.png",
//               //             title: "Culture tradition",
//               //           ),
//               //         ],
//               //       ),
//               //       const SizedBox(height: 5),
//               //       Text(
//               //         "Key Information",
//               //         style: GoogleFonts.inter(
//               //           color: AllColors.primaryColor,
//               //           fontSize: 24,
//               //           fontWeight: FontWeight.w700,
//               //         ),
//               //       ),
//               //       const SizedBox(height: 5),
//               //       SizedBox(
//               //         width: 700,
//               //         child: Text(
//               //           "The Chakma community joyfully celebrates Kathina Civara Dhana "
//               //           "and the vibrant Bizu Festival annually! Bizu, a lively three-day "
//               //           "New Year extravaganza, showcases Chakma traditions with rituals, "
//               //           "performances, and communal harmony every April. Since 2007, it's "
//               //           "been a time for feasting, dancing, singing, and exchanging "
//               //           "heartfelt wishes!",
//               //           style: GoogleFonts.inter(
//               //             fontSize: 16,
//               //             height: 1.6,
//               //             color: AllColors.primaryColor,
//               //           ),
//               //         ),
//               //       ),
//               //     ],
//               //   ),
//               // ),
//               const SizedBox(height: 300),
//               Expanded(
//                 flex: 5,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Events",
//                       style: GoogleFonts.inter(
//                         color: AllColors.primaryColor,
//                         fontSize: 32,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       "Discover our diverse range of activities and events designed to enrich our community",
//                       style: GoogleFonts.inter(
//                         fontSize: 18,
//                         height: 1.56,
//                         fontWeight: FontWeight.w400,
//                         color: AllColors.primaryColor,
//                       ),
//                     ),
//                     // const SizedBox(height: 30),
//                     // Row(
//                     //   children: const [
//                     //     InfoCard(
//                     //       image: "assets/image/Social_Services.png",
//                     //       title: "Social Services",
//                     //     ),
//                     //     SizedBox(width: 23),
//                     //     InfoCard(
//                     //       image: "assets/image/Educational_Initiatives.png",
//                     //       title: "Educational Initiatives",
//                     //     ),
//                     //   ],
//                     // ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// //============================ INFO CARD ========================
// // class InfoCard extends StatelessWidget {
// //   final String image;
// //   final String title;
// //   const InfoCard({super.key, required this.image, required this.title});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       width: 260,
// //       decoration: BoxDecoration(
// //         color: AllColors.fourthColor,
// //         borderRadius: BorderRadius.vertical(),
// //       ),
// //       child: Column(
// //         children: [
// //           ClipRRect(
// //             borderRadius: const BorderRadius.vertical(),
// //             child: Image.asset(
// //               image,
// //               width: 260,
// //               height: 260,
// //               fit: BoxFit.cover,
// //               errorBuilder: (context, error, stackTrace) {
// //                 return const SizedBox(height: 200);
// //               },
// //             ),
// //           ),
// //           Padding(
// //             padding: const EdgeInsets.symmetric(vertical: 14),
// //             child: Text(
// //               title,
// //               textAlign: TextAlign.center,
// //               style: GoogleFonts.inter(
// //                 fontSize: 20,
// //                 fontWeight: FontWeight.w600,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // ===================== MOBILE =====================
// class _MobileLayout extends StatelessWidget {
//   const _MobileLayout();

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(
//         child: Text(
//           'Mobile layout (add later)',
//           style: TextStyle(fontSize: 18),
//         ),
//       ),
//     );
//   }
// }
