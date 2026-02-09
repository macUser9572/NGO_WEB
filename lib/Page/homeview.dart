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

    _scrollController.addListener(() {
      final height = MediaQuery.of(context).size.height;
      final index = (_scrollController.offset / height).round().clamp(0, 7);

      context.read<ScrollState>().updateSection(index);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const AppDrawer(),
      backgroundColor: AllColors.secondaryColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
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
          const Positioned(top: 0, left: 0, right: 0, child: NavbarDesktop()),
        ],
      ),
    );
  }
}
