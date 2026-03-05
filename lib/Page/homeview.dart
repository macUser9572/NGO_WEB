import 'package:flutter/material.dart';
import 'package:ngo_web/Page/footer.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/Event_page.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/Members/StudentBody/Contact/contact_page.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/Members/StudentBody/student_page.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/Members/member_page.dart';
import 'package:ngo_web/Sections/Home/About%20us/aboutus_page.dart';
import 'package:ngo_web/Sections/Home/About%20us/aboutus_page2.dart';
import 'package:ngo_web/Sections/Home/home_page.dart';
import 'package:ngo_web/Sections/ourInitiatives.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:ngo_web/widgets/app_drawer.dart';
import 'package:ngo_web/widgets/navbar_desktop.dart';
import 'package:ngo_web/widgets/navbar_mobile.dart';
import 'package:ngo_web/widgets/scroll_helper.dart';
import 'package:ngo_web/widgets/section_key.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final scrollOffset = _scrollController.offset;

    // Find which section is currently visible by checking each key's position
    for (int i = sectionKeys.length - 1; i >= 0; i--) {
      final keyContext = sectionKeys[i].currentContext;
      if (keyContext == null) continue;

      final box = keyContext.findRenderObject() as RenderBox?;
      if (box == null) continue;

      final position = box.localToGlobal(Offset.zero);
      final isMobile = MediaQuery.of(context).size.width < 768;
      final navbarHeight = isMobile ? 56.0 : 70.0;

      // If section top is at or above the navbar bottom, it's the active section
      if (position.dy <= navbarHeight + 50) {
        context.read<ScrollState>().updateSection(i);
        break;
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      endDrawer: isMobile ? const AppDrawer() : null,
      backgroundColor: AllColors.secondaryColor,
      body: Stack(
        children: [
          // ── Scrollable Sections ──
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // Space so first section isn't hidden under navbar
                SizedBox(height: isMobile ? 56 : 70),

                Container(key: sectionKeys[0], child: const HomePage()),
                Container(key: sectionKeys[1], child: const AboutusPage()),
                Container(key: sectionKeys[2], child: const AboutusPage2()),
                Container(key: sectionKeys[3], child: const EventPage()),
                Container(key: sectionKeys[4], child: const StudentPage()),
                Container(key: sectionKeys[5], child: const MemberPage()),
                Container(key: sectionKeys[6], child: const OurInitiatives()),
                Container(key: sectionKeys[7], child: const ContactPage()),
                const Footer(),
              ],
            ),
          ),

          // ── Sticky Navbar ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: isMobile
                ? const NavbarMobile()
                : const NavbarDesktop(),
          ),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:ngo_web/Page/footer.dart';
// import 'package:ngo_web/Sections/Home/About%20us/Events/Event_page.dart';
// import 'package:ngo_web/Sections/Home/About%20us/Events/Members/StudentBody/Contact/contact_page.dart';
// import 'package:ngo_web/Sections/Home/About%20us/Events/Members/StudentBody/student_page.dart';
// import 'package:ngo_web/Sections/Home/About%20us/Events/Members/member_page.dart';
// import 'package:ngo_web/Sections/Home/About%20us/aboutus_page.dart';
// import 'package:ngo_web/Sections/Home/About%20us/aboutus_page2.dart';
// import 'package:ngo_web/Sections/Home/home_page.dart';
// import 'package:ngo_web/Sections/ourInitiatives.dart';
// import 'package:ngo_web/constraints/all_colors.dart';
// import 'package:ngo_web/widgets/app_drawer.dart';
// import 'package:ngo_web/widgets/navbar_desktop.dart';
// import 'package:ngo_web/widgets/navbar_mobile.dart';
// import 'package:ngo_web/widgets/scroll_helper.dart';
// import 'package:ngo_web/widgets/section_key.dart';
// import 'package:provider/provider.dart';

// class HomeView extends StatefulWidget {
//   const HomeView({super.key});

//   @override
//   State<HomeView> createState() => _HomeViewState();
// }

// class _HomeViewState extends State<HomeView> {
//   late final ScrollController _scrollController;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();

//     _scrollController.addListener(() {
//       final height = MediaQuery.of(context).size.height;
//       final isMobile = MediaQuery.of(context).size.width < 768;

//       // On mobile sections are not full screen height,
//       // so we track by pixel offset differently
//       if (isMobile) {
//         // Estimate section index by dividing offset by average section height
//         final index =
//             (_scrollController.offset / (height * 0.8)).round().clamp(0, 7);
//         context.read<ScrollState>().updateSection(index);
//       } else {
//         final index =
//             (_scrollController.offset / height).round().clamp(0, 7);
//         context.read<ScrollState>().updateSection(index);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isMobile = MediaQuery.of(context).size.width < 768;

//     return Scaffold(
//       // ── Drawer only on mobile (opens from left) ──
//       drawer: isMobile ? const AppDrawer() : null,
//       backgroundColor: AllColors.secondaryColor,
//       body: Stack(
//         children: [
//           // ── Scrollable Sections ──
//           SingleChildScrollView(
//             controller: _scrollController,
//             child: Column(
//               children: [
//                 // Space so content doesn't hide under navbar
//                 SizedBox(height: isMobile ? 56 : 70),

//                 Container(key: sectionKeys[0], child: const HomePage()),
//                 Container(key: sectionKeys[1], child: const AboutusPage()),
//                 Container(key: sectionKeys[2], child: const AboutusPage2()),
//                 Container(key: sectionKeys[3], child: const EventPage()),
//                 Container(key: sectionKeys[4], child: const StudentPage()),
//                 Container(key: sectionKeys[5], child: const MemberPage()),
//                 Container(key: sectionKeys[6], child: const OurInitiatives()),
//                 Container(key: sectionKeys[7], child: const ContactPage()),
//                 const Footer(),
//               ],
//             ),
//           ),

//           // ── Sticky Navbar ──
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: isMobile
//                 ? const NavbarMobile()   // ← hamburger menu
//                 : const NavbarDesktop(), // ← full nav links
//           ),
//         ],
//       ),
//     );
//   }
// }