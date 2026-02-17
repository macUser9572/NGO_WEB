import 'package:flutter/material.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/Members/Member_afterloginpage.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/Members/content_upload_page.dart';
import 'package:ngo_web/constraints/all_colors.dart';

class AfterLoginPage extends StatelessWidget {
  const AfterLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AllColors.fourthColor,
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: AllColors.primaryColor,
            labelColor: AllColors.primaryColor,
            unselectedLabelColor: AllColors.thirdColor,
            tabs: [
              Tab(text: "Add Member"),
              Tab(text: "Content Upload"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AddMemberPageTab(),      
            ContentUploadPageTab(),  
          ],
        ),
      ),
    );
  }
}
