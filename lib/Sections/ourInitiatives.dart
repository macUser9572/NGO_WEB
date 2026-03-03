
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/Sections/Home/Be%20a%20contributor.dart';
import 'package:ngo_web/constraints/CustomButton.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:responsive_builder/responsive_builder.dart';

class OurInitiatives extends StatelessWidget {
  const OurInitiatives({super.key});

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

// ========================== DESKTOP LAYOUT ==========================
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> initiatives = [
      "Health Insurance Adoption",
      "Awareness of Law and Justice",
      "Mental Health Support",
      "Education and Skill Programs",
      "Awareness of Chakma Culture and Religion",
      "Test Rig Software Development",
    ];

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        color: AllColors.fourthColor,
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 80),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= LEFT SIDE =================
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Initiatives",
                    style: GoogleFonts.inter(
                      color: AllColors.primaryColor,
                      fontSize: 70,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "We spearhead initiatives to support newcomers,\n"
                    "easing their transition into city life and addressing\n"
                    "common challenges.",
                    style: GoogleFonts.inter(
                      color: AllColors.primaryColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Bullet Points
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: initiatives.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "• ",
                              style: GoogleFonts.inter(
                                color: AllColors.primaryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                item,
                                style: GoogleFonts.inter(
                                  color: AllColors.primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 30),

                  CustomButton(
                    label: "Know More",
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 10,
                    ),
                    onPressed: () {
                       showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const ComingSoonDialog(),
                        );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(width: 40),

            // ================= RIGHT SIDE IMAGE =================
            Expanded(
              flex: 5,
              child: Center(
                child: Image.asset(
                  "assets/image/OurInitiatives.png",
                  width: 550,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      "Image not found. Check pubspec.yaml",
                      style: TextStyle(color: Colors.red),
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

// ========================== MOBILE LAYOUT ==========================
class _MobileLayout extends StatelessWidget {
  const _MobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AllColors.fourthColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            "Initiatives",
            style: GoogleFonts.inter(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: AllColors.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Image.asset(
            "assets/image/OurInitiatives.png",
            width: 300,
            errorBuilder: (context, error, stackTrace) {
              return const Text("Image not found");
            },
          ),
        ],
      ),
    );
  }
}// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:ngo_web/constraints/CustomButton.dart';
// import 'package:ngo_web/constraints/all_colors.dart';
// import 'package:responsive_builder/responsive_builder.dart';

// class OurInitiatives extends StatelessWidget {
//   const OurInitiatives({super.key});

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

// //==========================Desktop Layout====================
// class _DesktopLayout extends StatelessWidget {
//   const _DesktopLayout({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final height = MediaQuery.of(context).size.height;
//     final List<String> initiatives = [
//       "Health Insurance Adoption",
//       "Awareness of Law and Justice",
//       "Mental Health Support",
//       "Education and Skill Programs",
//       "Awareness of Chakma Culture and Religion",
//       "Test Rig Software Development",
//     ];

//     return SingleChildScrollView(
//       child: Container(
//         height: height,
//         width: double.infinity,
//         color: AllColors.fourthColor,
//         padding: const EdgeInsets.symmetric(horizontal: 80),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             //======================Left Content=================
//             Expanded(
//               flex: 6,
//               child: Padding(
//                 padding: const EdgeInsets.only(top: 60),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Initiatives",
//                       style: GoogleFonts.inter(
//                         color: AllColors.primaryColor,
//                         fontSize: 80,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                     Text(
//                       "We spearhead initiatives to support newcomers,\n"
//                       "easing their transition into city life and addressing\n"
//                       "common challenges.",
//                       style: GoogleFonts.inter(
//                         color: AllColors.primaryColor,
//                         fontSize: 25,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),

//                     const SizedBox(height: 20),

//                     //================== Bullet Points ==================
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: initiatives.map((item) {
//                         return Padding(
//                           padding: const EdgeInsets.only(bottom: 10),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "•  ",
//                                 style: GoogleFonts.inter(
//                                   color: AllColors.primaryColor,
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Text(
//                                   item,
//                                   style: GoogleFonts.inter(
//                                     color: AllColors.primaryColor,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       }).toList(),
//                     ),

//                     const SizedBox(height: 20),

//                     //=====================Button==================
//                     CustomButton(
//                       label: "Know More",
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 28,
//                         vertical: 10,
//                       ),
//                       onPressed: () {},
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             //===============================Right image=================
//             Expanded(
//               flex: 5,
//               child: Align(
//                 alignment: Alignment.topRight,
//                 child: Transform.translate(
//                   offset: const Offset(30, 90),
//                   child: Image.asset(
//                     "assets/image/OurInitiatives.png",
//                     // "assets/image/ourimage.png",
//                     width: 780,
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ================= MOBILE LAYOUT =================
// class _MobileLayout extends StatelessWidget {
//   const _MobileLayout({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         "Mobile Layout",
//         style: GoogleFonts.inter(fontSize: 18),
//       ),
//     );
//   }
// }
