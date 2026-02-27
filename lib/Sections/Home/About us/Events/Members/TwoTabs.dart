import 'package:flutter/material.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/Members/Member_afterloginpage.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/Members/RequestMembership.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/Members/content_upload_page.dart';
import 'package:ngo_web/constraints/all_colors.dart';

class AfterLoginPage extends StatelessWidget {
  const AfterLoginPage({super.key});

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
              fontSize: 18, // increase more if needed
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),

            tabs: [
              Tab(text: "Add Member"),
              Tab(text: "Content Upload"),
              Tab(text:"RequestMembership"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AddMemberPageTab(),
            ContentUploadPageTab(),
            MembershipRequestPage    (),

          ],
        ),
      ),
    );
  }
}