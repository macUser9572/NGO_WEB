import 'package:flutter/material.dart';
import 'package:bangalore_chakma_society/Page/footer.dart';
import 'package:bangalore_chakma_society/Sections/Home/About%20us/Events/Event_page.dart';
import 'package:bangalore_chakma_society/Sections/Home/About%20us/Events/Members/StudentBody/Contact/contact_page.dart';
import 'package:bangalore_chakma_society/Sections/Home/About%20us/Events/Members/StudentBody/student_page.dart';
import 'package:bangalore_chakma_society/Sections/Home/About%20us/Events/Members/member_page.dart';
import 'package:bangalore_chakma_society/Sections/Home/About%20us/aboutus_page.dart';
import 'package:bangalore_chakma_society/Sections/Home/About%20us/aboutus_page2.dart';
import 'package:bangalore_chakma_society/Sections/Home/home_page.dart';
import 'package:bangalore_chakma_society/Sections/ourInitiatives.dart';
import 'package:bangalore_chakma_society/constraints/all_colors.dart';
import 'package:bangalore_chakma_society/widgets/app_drawer.dart';
import 'package:bangalore_chakma_society/widgets/navbar_desktop.dart';
import 'package:bangalore_chakma_society/widgets/navbar_mobile.dart';
import 'package:bangalore_chakma_society/widgets/scroll_helper.dart';
import 'package:bangalore_chakma_society/widgets/section_key.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final ScrollController _scrollController;
  bool _scheduledUpdate = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scheduledUpdate) return;
    _scheduledUpdate = true;

    Future.microtask(() {
      _scheduledUpdate = false;
      if (!mounted) return;

      final isMobile = MediaQuery.of(context).size.width < 768;
      final navbarHeight = isMobile ? 56.0 : 70.0;

      for (int i = sectionKeys.length - 1; i >= 0; i--) {
        final keyContext = sectionKeys[i].currentContext;
        if (keyContext == null) continue;

        final box = keyContext.findRenderObject() as RenderBox?;
        if (box == null || !box.hasSize) continue;

        final position = box.localToGlobal(Offset.zero);

        if (position.dy <= navbarHeight + 50) {
          context.read<ScrollState>().updateSection(i);
          break;
        }
      }
    });
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
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: isMobile ? const NavbarMobile() : const NavbarDesktop(),
          ),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:bangalore_chakma_society/Page/footer.dart';
// import 'package:bangalore_chakma_society/Sections/Home/About%20us/Events/Event_page.dart';
// import 'package:bangalore_chakma_society/Sections/Home/About%20us/Events/Members/StudentBody/Contact/contact_page.dart';
// import 'package:bangalore_chakma_society/Sections/Home/About%20us/Events/Members/StudentBody/student_page.dart';
// import 'package:bangalore_chakma_society/Sections/Home/About%20us/Events/Members/member_page.dart';
// import 'package:bangalore_chakma_society/Sections/Home/About%20us/aboutus_page.dart';
// import 'package:bangalore_chakma_society/Sections/Home/About%20us/aboutus_page2.dart';
// import 'package:bangalore_chakma_society/Sections/Home/home_page.dart';
// import 'package:bangalore_chakma_society/Sections/ourInitiatives.dart';
// import 'package:bangalore_chakma_society/constraints/all_colors.dart';
// import 'package:bangalore_chakma_society/widgets/app_drawer.dart';
// import 'package:bangalore_chakma_society/widgets/navbar_desktop.dart';
// import 'package:bangalore_chakma_society/widgets/navbar_mobile.dart';
// import 'package:bangalore_chakma_society/widgets/scroll_helper.dart';
// import 'package:bangalore_chakma_society/widgets/section_key.dart';
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

//     _scrollController.addListener(_onScroll);
//   }

//   void _onScroll() {
//     final scrollOffset = _scrollController.offset;

//     // Find which section is currently visible by checking each key's position
//     for (int i = sectionKeys.length - 1; i >= 0; i--) {
//       final keyContext = sectionKeys[i].currentContext;
//       if (keyContext == null) continue;

//       final box = keyContext.findRenderObject() as RenderBox?;
//       if (box == null) continue;

//       final position = box.localToGlobal(Offset.zero);
//       final isMobile = MediaQuery.of(context).size.width < 768;
//       final navbarHeight = isMobile ? 56.0 : 70.0;

//       // If section top is at or above the navbar bottom, it's the active section
//       if (position.dy <= navbarHeight + 50) {
//         context.read<ScrollState>().updateSection(i);
//         break;
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isMobile = MediaQuery.of(context).size.width < 768;

//     return Scaffold(
//       endDrawer: isMobile ? const AppDrawer() : null,
//       backgroundColor: AllColors.secondaryColor,
//       body: Stack(
//         children: [
//           // ── Scrollable Sections ──
//           SingleChildScrollView(
//             controller: _scrollController,
//             child: Column(
//               children: [
//                 // Space so first section isn't hidden under navbar
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
//                 ? const NavbarMobile()
//                 : const NavbarDesktop(),
//           ),
//         ],
//       ),
//     );
//   }
// }
