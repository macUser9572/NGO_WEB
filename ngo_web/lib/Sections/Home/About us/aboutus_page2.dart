import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AboutusPage2 extends StatelessWidget {
  const AboutusPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizing) {
        if (sizing.deviceScreenType == DeviceScreenType.desktop) {
          return const _DesktopLayout();
        }
        return const _MobileLayout();
      },
    );
  }
}

// =============================== DESKTOP LAYOUT ===============================

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 80),
      color: AllColors.fourthColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= LEFT SIDE =================
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle("Vision"),
                const SizedBox(height: 10),
                _sectionText(
                  "To preserve and carry forward the\n"
                  "legacy of Chakma culture and\n"
                  "tradition in cities, while embracing\n"
                  "the changes of modern times.",
                ),
                const SizedBox(height: 80),
                _sectionTitle("Mission"),
                const SizedBox(height: 10),
                _sectionText(
                  "To empower the young generation to\n"
                  "learn, share their knowledge, and\n"
                  "develop into confident contributors\n"
                  "to society.",
                ),
              ],
            ),
          ),

          // ================= DIVIDER =================
          Container(
            height: 800,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 80),
            color: Colors.grey.shade400,
          ),

          // ================= RIGHT SIDE =================
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Values",
                  style: GoogleFonts.inter(
                    fontSize: 120,
                    fontWeight: FontWeight.w600,
                    color: AllColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Unity & Brotherhood",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AllColors.thirdColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Believe in growing not just as a community, but together with other cultures and identities, building bridges through respect, cooperation, and shared initiatives.",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: AllColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Cultural Preservation",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AllColors.thirdColor,
                  ),
                ),
                const SizedBox(height: 5),

                Text(
                  "Upholding and celebrating the rich heritage of Chakma culture.",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: AllColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Inclusiveness",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AllColors.thirdColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Creating a welcoming environment where every individual feels valued and heard.",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: AllColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Growth & Learning",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AllColors.thirdColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Encouraging continuous learning, knowledge-sharing, and personal development.",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: AllColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Service to Society",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AllColors.thirdColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Working collectively to uplift our community and contribute positively to the broader society.",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: AllColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          // Expanded(
          //   flex: 5,
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       _sectionTitle("Values"),
          //       const SizedBox(height: 20),
          //       _sectionText(
          //         "To empower the young generation to learn, "
          //         "share their knowledge, and develop into "
          //         "confident contributors to society.",
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  // ================= REUSABLE WIDGETS =================

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 130,
        fontWeight: FontWeight.w600,
        color: AllColors.primaryColor,
        height: 1,
      ),
    );
  }

  Widget _sectionText(String text) {
    return SizedBox(
      width: 480,
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 26,
          fontWeight: FontWeight.w400,
          color: AllColors.primaryColor,
          height: 1.5,
        ),
      ),
    );
  }
}

// =============================== MOBILE LAYOUT ===============================

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.fourthColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Vision",
              style: GoogleFonts.inter(
                fontSize: 120,
                fontWeight: FontWeight.w800,
                color: AllColors.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "To preserve and carry forward the legacy "
              "of Chakma culture and tradition.",
              style: GoogleFonts.inter(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:ngo_website/constraints/all_colors.dart';
// import 'package:responsive_builder/responsive_builder.dart';

// class AboutusPage2 extends StatelessWidget {
//   const AboutusPage2({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ResponsiveBuilder(
//       builder: (context, sizing) {
//         if (sizing.deviceScreenType == DeviceScreenType.desktop) {
//           return const _DesktopLayout();
//         }
//         return const _MobileLayout();
//       },
//     );
//   }
// }

// //=============================== DESKTOP LAYOUT ============================

// class _DesktopLayout extends StatelessWidget {
//   const _DesktopLayout({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: 900,
//       padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 80),
//       color: AllColors.fourthColor,
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // ================= LEFT SIDE =================
//           Expanded(
//             flex: 6,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // -------- Vision --------
//                 Text(
//                   "Vision",
//                   style: GoogleFonts.inter(
//                     fontSize: 130,
//                     fontWeight: FontWeight.w600,
//                     color: AllColors.primaryColor,
//                     height: 1,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 SizedBox(
//                   width: 480,
//                   child: Text(
//                     "To preserve and carry forward the legacy of Chakma culture and tradition in cities, while embracing the changes of modern times.",
//                     style: GoogleFonts.inter(
//                       fontSize: 25,
//                       fontWeight: FontWeight.w400,
//                       color: AllColors.primaryColor,
//                       height: 1.5,
//                     ),
//                   ),
//                 ),

//                 const Spacer(),

//                 // -------- Mission --------
//                 Text(
//                   "Mission",
//                   style: GoogleFonts.inter(
//                     fontSize: 130,
//                     fontWeight: FontWeight.w600,
//                     color: AllColors.primaryColor,
//                     height: 1,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 SizedBox(
//                   width: 480,
//                   child: Text(
//                     "To empower the young generation to learn, share their knowledge, and develop into confident contributors to society.",
//                     style: GoogleFonts.inter(
//                       fontSize: 26,
//                       fontWeight: FontWeight.w400,
//                       color: AllColors.primaryColor,
//                       height: 1.5,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // ================= RIGHT SIDE =================
//           Expanded(
//             flex: 5,
//             child: Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Values",
//                     style: GoogleFonts.inter(
//                       fontSize: 130,
//                       fontWeight: FontWeight.w600,
//                       color: AllColors.primaryColor,
//                       height: 1,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   SizedBox(
//                     width: 480,
//                     child: Text(
//                       "To empower the young generation to learn, share their knowledge, and develop into confident contributors to society.",
//                       style: GoogleFonts.inter(
//                         fontSize: 26,
//                         fontWeight: FontWeight.w400,
//                         color: AllColors.primaryColor,
//                         height: 1.5,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// //====================== MOBILE LAYOUT ==========================
// class _MobileLayout extends StatelessWidget {
//   const _MobileLayout();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AllColors.fourthColor,
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Vision",
//               style: GoogleFonts.inter(
//                 fontSize: 48,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//             const SizedBox(height: 12),
//             const Text("Mobile layout "),
//           ],
//         ),
//       ),
//     );
//   }
// }
