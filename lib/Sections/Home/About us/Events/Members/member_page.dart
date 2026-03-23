import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bangalore_chakma_society/constraints/CustomButton.dart';
import 'package:bangalore_chakma_society/constraints/all_colors.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Member_List_page.dart';

class MemberPage extends StatelessWidget {
  const MemberPage({super.key});

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

// ====================== MEMBER CIRCLE BUBBLE ======================
class _MemberBubble extends StatelessWidget {
  final String name;
  final String photoUrl;
  final double size;

  const _MemberBubble({
    required this.name,
    required this.photoUrl,
    this.size = 72,
  });

  static const List<Color> _palette = [
    Color(0xFFD6EAF8),
    Color(0xFFD5F5E3),
    Color(0xFFFEF9E7),
    Color(0xFFF9EBEA),
    Color(0xFFE8DAEF),
    Color(0xFFE8F8F5),
    Color(0xFFFDEBD0),
  ];

  @override
  Widget build(BuildContext context) {
    final Color bg = name.isNotEmpty
        ? _palette[name.codeUnitAt(0) % _palette.length]
        : _palette[0];
    final double fontSize = (size * 0.35).clamp(8.0, 28.0);

    return Tooltip(
      message: name,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bg,
          boxShadow: [
            BoxShadow(
              color: Colors.blueGrey.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: photoUrl.isNotEmpty
            ? Image.network(
                photoUrl,
                fit: BoxFit.cover,
                loadingBuilder: (ctx, child, prog) {
                  if (prog == null) return child;
                  return Center(
                    child: SizedBox(
                      width: size * 0.4,
                      height: size * 0.4,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AllColors.primaryColor,
                      ),
                    ),
                  );
                },
                errorBuilder: (ctx, e, s) => _initial(fontSize),
              )
            : _initial(fontSize),
      ),
    );
  }

  Widget _initial(double fontSize) => Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: AllColors.primaryColor,
          ),
        ),
      );
}

// ====================== BUBBLE SIZE FROM COUNT ======================
double _sizeForCount(int count, {required bool isDesktop}) {
  if (count <= 2)  return isDesktop ? 110.0 : 80.0;
  if (count <= 5)  return isDesktop ? 90.0  : 66.0;
  if (count <= 10) return isDesktop ? 72.0  : 54.0;
  if (count <= 20) return isDesktop ? 58.0  : 44.0;
  if (count <= 40) return isDesktop ? 48.0  : 36.0;
  if (count <= 70) return isDesktop ? 38.0  : 28.0;
  return isDesktop ? 30.0 : 22.0;
}

// ====================== CONCENTRIC CIRCLE LAYOUT ======================

double _canvasSizeFor({required int count, required double size}) {
  if (count == 0) return 200;
  final double step = size * 1.45;
  int placed = 0, r = 0, totalRings = 0;
  while (placed < count) {
    final int cap = r == 0 ? 1 : 6 * r;
    final int take = count - placed < cap ? count - placed : cap;
    placed += take;
    totalRings++;
    r++;
  }
  final double outerR = step * (totalRings - 1);
  return (outerR + size) * 2;
}

List<Offset> _concentricPositions({
  required int count,
  required double size,
  required double cx,
  required double cy,
}) {
  if (count == 0) return [];

  final double step = size * 1.45;

  final List<int> rings = [];
  int remaining = count, r = 0;
  while (remaining > 0) {
    final int cap = r == 0 ? 1 : 6 * r;
    final int take = remaining < cap ? remaining : cap;
    rings.add(take);
    remaining -= take;
    r++;
  }

  final List<Offset> result = [];
  for (int ring = 0; ring < rings.length; ring++) {
    final int n = rings[ring];
    if (ring == 0) {
      result.add(Offset(cx - size / 2, cy - size / 2));
      continue;
    }
    final double ringR = step * ring;
    for (int i = 0; i < n; i++) {
      final double angle = -pi / 2 + (2 * pi * i / n);
      result.add(Offset(
        cx + ringR * cos(angle) - size / 2,
        cy + ringR * sin(angle) - size / 2,
      ));
    }
  }
  return result;
}

// ====================== MEMBER BUBBLES WIDGET ======================
class _MemberBubblesWidget extends StatelessWidget {
  final bool isDesktop;
  final bool isMobile;

  const _MemberBubblesWidget({
    this.isDesktop = true,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Member_collection')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No members yet',
                style: GoogleFonts.inter(color: AllColors.thirdColor)),
          );
        }

        final docs = snapshot.data!.docs;
        final int count = docs.length;
        final double size = _sizeForCount(count, isDesktop: isDesktop);
        final double canvasSize = _canvasSizeFor(count: count, size: size);

        final rand = Random(42);
        final List<int> order = List.generate(count, (i) => i)..shuffle(rand);

        return LayoutBuilder(builder: (context, constraints) {
          final double parentWidth = constraints.maxWidth;

          final double cx = canvasSize / 2;
          final double cy = canvasSize / 2;

          final List<Offset> positions = _concentricPositions(
            count: count,
            size: size,
            cx: cx,
            cy: cy,
          );

          final Widget stack = SizedBox(
            width: canvasSize,
            height: canvasSize,
            child: Stack(
              children: List.generate(count, (i) {
                final doc = docs[order[i]].data() as Map<String, dynamic>;
                return Positioned(
                  left: positions[i].dx,
                  top: positions[i].dy,
                  child: _MemberBubble(
                    name: doc['name']?.toString() ?? '',
                    photoUrl: doc['photoUrl']?.toString() ?? '',
                    size: size,
                  ),
                );
              }),
            ),
          );

          if (isMobile) {
            return SizedBox(
              width: parentWidth,
              height: canvasSize,
              child: ClipRect(
                child: OverflowBox(
                  maxWidth: double.infinity,
                  alignment: Alignment.center,
                  child: stack,
                ),
              ),
            );
          } else {
            // Desktop: centred inside the column
            return SizedBox(
              width: parentWidth,
              height: canvasSize,
              child: Center(child: stack),
            );
          }
        });
      },
    );
  }
}

// ========================== DESKTOP LAYOUT =========================
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: height),
        color: AllColors.secondaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 80),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- LEFT ----
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.only(top: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Members",
                      style: GoogleFonts.inter(
                        color: AllColors.primaryColor,
                        fontSize: 80,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "The Headcount",
                      style: GoogleFonts.inter(
                        color: AllColors.thirdColor,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 446,
                      child: Text(
                        "The number of participants is growing exponentially "
                        "each year. Here's a breakdown of the BCS community "
                        "members in Bangalore.",
                        style: GoogleFonts.inter(
                            color: AllColors.thirdColor, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 30),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("Member_collection")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return _buildStats(0, 0, 0, 0, 0);
                        }
                        int total = snapshot.data!.docs.length;
                        int male = 0, female = 0, children = 0, others = 0;
                        for (var doc in snapshot.data!.docs) {
                          final d = doc.data() as Map<String, dynamic>;
                          final g =
                              (d['gender'] ?? '').toString().toLowerCase();
                          if (g == 'male') male++;
                          else if (g == 'female') female++;
                          else if (g == 'children') children++;
                          else others++;
                        }
                        return _buildStats(
                            total, male, female, children, others);
                      },
                    ),
                    const SizedBox(height: 40),
                    CustomButton(
                      label: "View Members",
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MembersListPage())),
                    ),
                  ],
                ),
              ),
            ),

            // ---- RIGHT: BUBBLES ----
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(top: 100, left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Member_collection')
                          .snapshots(),
                      builder: (context, snapshot) {
                        final count = snapshot.data?.docs.length ?? 0;
                        return Center(
                          child: Text(
                            "$count Members",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AllColors.thirdColor,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const _MemberBubblesWidget(
                      isDesktop: true,
                      isMobile: false,
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

  Widget _buildStats(
      int total, int male, int female, int children, int others) {
    return Row(
      children: [
        _StatItem(label: "Total", value: total.toString()),
        const SizedBox(width: 30),
        _StatItem(label: "Men", value: male.toString()),
        const SizedBox(width: 30),
        _StatItem(label: "Women", value: female.toString()),
        const SizedBox(width: 30),
        _StatItem(label: "Children", value: children.toString()),
        const SizedBox(width: 30),
        _StatItem(label: "Others", value: others.toString()),
      ],
    );
  }
}

// ================= STAT ITEM =================
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14)),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AllColors.primaryColor,
          ),
        ),
      ],
    );
  }
}

// ================= MOBILE LAYOUT =================
class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AllColors.secondaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Members",
              style: GoogleFonts.inter(
                  color: AllColors.primaryColor,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  height: 1)),
          const SizedBox(height: 8),
          Text("The Headcount",
              style: GoogleFonts.inter(
                  color: AllColors.thirdColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Text(
            "The number of participants is growing exponentially each year. "
            "Here's a breakdown of the BCS community members in Bangalore.",
            style:
                GoogleFonts.inter(color: AllColors.thirdColor, fontSize: 12),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("Member_collection")
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildStats(0, 0, 0, 0, 0);
              }
              int total = snapshot.data!.docs.length;
              int male = 0, female = 0, children = 0, others = 0;
              for (var doc in snapshot.data!.docs) {
                final d = doc.data() as Map<String, dynamic>;
                final g = (d['gender'] ?? '').toString().toLowerCase();
                if (g == 'male') male++;
                else if (g == 'female') female++;
                else if (g == 'children') children++;
                else others++;
              }
              return _buildStats(total, male, female, children, others);
            },
          ),
          const SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Member_collection')
                .snapshots(),
            builder: (context, snapshot) {
              final count = snapshot.data?.docs.length ?? 0;
              return Text(
                "$count Members",
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AllColors.thirdColor),
              );
            },
          ),
          const SizedBox(height: 12),
          const _MemberBubblesWidget(
            isDesktop: false,
            isMobile: true,
          ),
          const SizedBox(height: 20),
          CustomButton(
            label: "View Members",
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const MembersListPage())),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(
      int total, int male, int female, int children, int others) {
    return Wrap(
      spacing: 24,
      runSpacing: 16,
      children: [
        _StatItem(label: "Total", value: total.toString()),
        _StatItem(label: "Men", value: male.toString()),
        _StatItem(label: "Women", value: female.toString()),
        _StatItem(label: "Children", value: children.toString()),
        _StatItem(label: "Others", value: others.toString()),
      ],
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:bangalore_chakma_society/constraints/CustomButton.dart';
// import 'package:bangalore_chakma_society/constraints/all_colors.dart';
// import 'package:responsive_builder/responsive_builder.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'Member_List_page.dart';

// class MemberPage extends StatelessWidget {
//   const MemberPage({super.key});

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

// // ========================== DESKTOP LAYOUT =========================
// class _DesktopLayout extends StatelessWidget {
//   const _DesktopLayout();

//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;

//     return SingleChildScrollView(
//       child: Container(
//         width: double.infinity,
//         height: height,
//         color: AllColors.secondaryColor,
//         padding: const EdgeInsets.symmetric(horizontal: 80),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ================= LEFT CONTENT =================
//             Expanded(
//               flex: 6,
//               child: Padding(
//                 padding: const EdgeInsets.only(top: 120),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Members",
//                       style: GoogleFonts.inter(
//                         color: AllColors.primaryColor,
//                         fontSize: 80,
//                         fontWeight: FontWeight.w800,
//                         height: 1,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       "The Headcount",
//                       style: GoogleFonts.inter(
//                         color: AllColors.thirdColor,
//                         fontSize: 32,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     SizedBox(
//                       width: 446,
//                       child: Text(
//                         "The number of participants is growing exponentially each year. Here’s a breakdown of the BCS community members in Bangalore.",
//                         style: GoogleFonts.inter(
//                           color: AllColors.thirdColor,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 30),

//                     // ================= FIRESTORE COUNTS =================
//                     StreamBuilder<QuerySnapshot>(
//                       stream: FirebaseFirestore.instance
//                           .collection("Member_collection")
//                           .snapshots(),
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return const CircularProgressIndicator();
//                         }

//                         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                           return _buildStats(0, 0, 0, 0, 0);
//                         }

//                         int total = snapshot.data!.docs.length;
//                         int male = 0;
//                         int female = 0;
//                         int children = 0;
//                         int others = 0;

//                         for (var doc in snapshot.data!.docs) {
//                           final raw = doc.data();

//                           if (raw == null) continue;

//                           final Map<String, dynamic> data =
//                               Map<String, dynamic>.from(raw as Map);
//                           final gender = (data['gender'] ?? '')
//                               .toString()
//                               .toLowerCase();

//                           if (gender == 'male') {
//                             male++;
//                           } else if (gender == 'female') {
//                             female++;
//                           } else if (gender == 'children') {
//                             children++;
//                           } else {
//                             others++;
//                           }
//                         }

//                         return _buildStats(
//                           total,
//                           male,
//                           female,
//                           children,
//                           others,
//                         );
//                       },
//                     ),

//                     const SizedBox(height: 40),

//                     // ================= BUTTON =================
//                     CustomButton(
//                       label: "View Members",
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => const MembersListPage(),
//                           ),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // ================= RIGHT IMAGE =================
//             Expanded(
//               flex: 5,
//               child: Align(
//                 alignment: Alignment.topRight,
//                 child: Transform.translate(
//                   offset: const Offset(30, 90),
//                   child: Image.asset(
//                     "assets/image/Memberpage.png",
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

//   // ================= STATS BUILDER =================
//   Widget _buildStats(
//     int total,
//     int male,
//     int female,
//     int children,
//     int others,
//   ) {
//     return Row(
//       children: [
//         _StatItem(label: "Total", value: total.toString()),
//         const SizedBox(width: 30),
//         _StatItem(label: "Men", value: male.toString()),
//         const SizedBox(width: 30),
//         _StatItem(label: "Women", value: female.toString()),
//         const SizedBox(width: 30),
//         _StatItem(label: "Children", value: children.toString()),
//         const SizedBox(width: 30),
//         _StatItem(label: "Others", value: others.toString()),
//       ],
//     );
//   }
// }

// // ================= STAT ITEM =================
// class _StatItem extends StatelessWidget {
//   final String label;
//   final String value;

//   const _StatItem({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: GoogleFonts.inter(fontSize: 14)),
//         const SizedBox(height: 6),
//         Text(
//           value,
//           style: GoogleFonts.inter(
//             fontSize: 22,
//             fontWeight: FontWeight.w700,
//             color: AllColors.primaryColor,
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ================= MOBILE LAYOUT =================
// class _MobileLayout extends StatelessWidget {
//   const _MobileLayout();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       color: AllColors.secondaryColor,
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 70),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // ── Title ──
//           Text(
//             "Members",
//             style: GoogleFonts.inter(
//               color: AllColors.primaryColor,
//               fontSize: 32,
//               fontWeight: FontWeight.w800,
//               height: 1,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             "The Headcount",
//             style: GoogleFonts.inter(
//               color: AllColors.thirdColor,
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             "The number of participants is growing exponentially each year. "
//             "Here's a breakdown of the BCS community members in Bangalore.",
//             style: GoogleFonts.inter(
//               color: AllColors.thirdColor,
//               fontSize: 12,
//             ),
//           ),

//           const SizedBox(height: 16),

//           // ── Firestore Stats (MOVED UP) ──
//           StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance
//                 .collection("Member_collection")
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                 return _buildStats(0, 0, 0, 0, 0);
//               }

//               int total = snapshot.data!.docs.length;
//               int male = 0, female = 0, children = 0, others = 0;

//               for (var doc in snapshot.data!.docs) {
//                 final data = Map<String, dynamic>.from(doc.data() as Map);
//                 final gender =
//                     (data['gender'] ?? '').toString().toLowerCase();
//                 if (gender == 'male') male++;
//                 else if (gender == 'female') female++;
//                 else if (gender == 'children') children++;
//                 else others++;
//               }

//               return _buildStats(total, male, female, children, others);
//             },
//           ),

//           const SizedBox(height: 16),

//           // ── Image (MOVED DOWN) ──
//           ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Image.asset(
//               "assets/image/Memberpage.png",
//               width: double.infinity,
//               fit: BoxFit.cover,
//             ),
//           ),

//           const SizedBox(height: 16),

//           // ── Button ──
//           CustomButton(
//             label: "View Members",
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const MembersListPage(),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStats(
//       int total, int male, int female, int children, int others) {
//     return Wrap(
//       spacing: 24,
//       runSpacing: 16,
//       children: [
//         _StatItem(label: "Total", value: total.toString()),
//         _StatItem(label: "Men", value: male.toString()),
//         _StatItem(label: "Women", value: female.toString()),
//         _StatItem(label: "Children", value: children.toString()),
//         _StatItem(label: "Others", value: others.toString()),
//       ],
//     );
//   }
// }