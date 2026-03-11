import 'package:flutter/material.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/Members/Member_afterloginpage.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/Members/RequestMembership.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/Members/content_upload_page.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:responsive_builder/responsive_builder.dart';


class AfterLoginPage extends StatelessWidget {
  const AfterLoginPage({super.key});

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
// ==================== AFTER LOGIN PAGE ====================
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AllColors.fourthColor,

          // ✅ Back Icon
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AllColors.thirdColor,
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AllColors.primaryColor,
            labelColor: AllColors.primaryColor,
            unselectedLabelColor: AllColors.thirdColor,

            // 🔥 Increased Font Size Here
            labelStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),

            tabs: [
              Tab(text: "Add Member"),
              Tab(text: "Content Upload"),
              Tab(text: "Request Membership"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AddMemberPageTab(),
            ContentUploadPageTab(),
            MembershipRequestPage(),
          ],
        ),
      ),
    );
  }
}
// ==================== MOBILE LAYOUT ====================
class _MobileLayout extends StatelessWidget {
  const _MobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AllColors.fourthColor,

          // ✅ Back Icon
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AllColors.thirdColor,
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AllColors.primaryColor,
            labelColor: AllColors.primaryColor,
            unselectedLabelColor: AllColors.thirdColor,

            labelStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),

            tabs: [
              Tab(text: "Add Member"),
              Tab(text: "Content Upload"),
              Tab(text: "Request Membership"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AddMemberPageTab(),
            ContentUploadPageTab(),
            MembershipRequestPage(),
          ],
        ),
      ),
    );
  }
}

