import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'package:ngo_web/Sections/Home/About%20us/Events/Members/StudentBody/studentAdminpopuppage.dart';
import 'package:ngo_web/constraints/CustomButton.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:ngo_web/constraints/custom_text.dart';

// ====================== ENTRY POINT ======================
class StudentListPage extends StatelessWidget {
  const StudentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizing) {
        switch (sizing.deviceScreenType) {
          case DeviceScreenType.desktop:
            return const _DesktopLayout();
          default:
            return const _MobileLayout();
        }
      },
    );
  }
}

// ====================== DESKTOP LAYOUT ======================
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({super.key});

  Widget _memberStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Student_collection')
          .where('createdAt', isNull: false)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No Student found"));
        }
        return ListView.separated(
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final member = Member.fromFirestore(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
            return _DesktopMemberRow(member: member);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: AllColors.secondaryColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AllColors.thirdColor),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AllColors.thirdColor),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CustomButton(
              label: "Admin Login",
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Studentadminpopuppage(),
                );
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Student Members",
              style: GoogleFonts.inter(
                fontSize: 48,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              "Phone numbers and emails are hidden. Admin login required to view them.",
              style: GoogleFonts.inter(fontSize: 14),
            ),
            const SizedBox(height: 30),
            Expanded(child: _memberStream()),
          ],
        ),
      ),
    );
  }
}

// ====================== DESKTOP MEMBER ROW ======================
class _DesktopMemberRow extends StatelessWidget {
  final Member member;
  const _DesktopMemberRow({required this.member});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Avatar ──
          CircleAvatar(
            radius: 22,
            backgroundColor: AllColors.fourthColor,
            backgroundImage: member.photoUrl.isNotEmpty
                ? NetworkImage(member.photoUrl)
                : null,
            child: member.photoUrl.isEmpty
                ? Text(
                    member.name.isNotEmpty
                        ? member.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AllColors.primaryColor,
                    ),
                  )
                : null,
          ),

          const SizedBox(width: 16),

          Expanded(
            flex: 3,
            child: Text(
              member.name,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          Expanded(
            flex: 3,
            child: Row(
              children: [
                SvgPicture.asset("assets/icons/PhoneCall.svg",
                    height: 20, width: 20),
                const SizedBox(width: 6),
                Text("***********", style: CustomText.memberBodyColor),
              ],
            ),
          ),

          Expanded(
            flex: 4,
            child: Row(
              children: [
                SvgPicture.asset("assets/icons/mail.svg",
                    height: 20, width: 20),
                const SizedBox(width: 6),
                Text("***********", style: CustomText.memberBodyColor),
              ],
            ),
          ),

          Expanded(
            flex: 3,
            child: Row(
              children: [
                SvgPicture.asset("assets/icons/collageicon.svg",
                    height: 20, width: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    member.collage,
                    overflow: TextOverflow.ellipsis,
                    style: CustomText.memberBodyColor,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 3,
            child: Row(
              children: [
                SvgPicture.asset("assets/icons/couseicon.svg",
                    height: 20, width: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    member.course,
                    overflow: TextOverflow.ellipsis,
                    style: CustomText.memberBodyColor,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 3,
            child: Row(
              children: [
                SvgPicture.asset("assets/icons/place.svg",
                    height: 20, width: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    member.place,
                    overflow: TextOverflow.ellipsis,
                    style: CustomText.memberBodyColor,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 3,
            child: Row(
              children: [
                SvgPicture.asset("assets/icons/SignIn.svg",
                    height: 20, width: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    member.checkIn,
                    overflow: TextOverflow.ellipsis,
                    style: CustomText.memberBodyColor,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 3,
            child: Row(
              children: [
                SvgPicture.asset("assets/icons/SignOut.svg",
                    height: 20, width: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    member.checkOut,
                    overflow: TextOverflow.ellipsis,
                    style: CustomText.memberBodyColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ====================== MOBILE LAYOUT ======================
class _MobileLayout extends StatelessWidget {
  const _MobileLayout({super.key});

  Widget _memberStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Student_collection')
          .where('createdAt', isNull: false)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No Student found"));
        }
        return ListView.separated(
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final member = Member.fromFirestore(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
            return _MobileMemberCard(member: member);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: AllColors.secondaryColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AllColors.thirdColor),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AllColors.thirdColor),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CustomButton(
              label: "Admin Login",
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Studentadminpopuppage(),
                );
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              "Student Members",
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AllColors.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Phone numbers and emails are hidden. Admin login required to view them.",
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AllColors.thirdColor,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _memberStream()),
          ],
        ),
      ),
    );
  }
}
// ====================== MOBILE MEMBER CARD ======================
class _MobileMemberCard extends StatelessWidget {
  final Member member;
  const _MobileMemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // 1. Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: AllColors.fourthColor,
            backgroundImage: member.photoUrl.isNotEmpty
                ? NetworkImage(member.photoUrl)
                : null,
            child: member.photoUrl.isEmpty
                ? Text(
                    member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AllColors.primaryColor,
                    ),
                  )
                : null,
          ),

          const SizedBox(width: 12),

          // 2. Info Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [

                // Row 1 — Name
                Text(
                  member.name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AllColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),

                // Row 2 — Phone + Email
                Row(
                  children: [
                    SvgPicture.asset("assets/icons/PhoneCall.svg",
                        height: 16, width: 16),
                    const SizedBox(width: 4),
                    Text("***********", style: CustomText.memberBodyColor),
                    const SizedBox(width: 60),
                    SvgPicture.asset("assets/icons/mail.svg",
                        height: 16, width: 16),
                    const SizedBox(width: 4),
                    Text("***********", style: CustomText.memberBodyColor),
                  ],
                ),
                // Row 3 — College + Course

                const SizedBox(height: 4),
                Row(
                  children: [
                    SvgPicture.asset("assets/icons/collageicon.svg",
                    height: 16,width: 16),
                    const SizedBox(width: 4),
                    Text(member.collage,style:CustomText.memberBodyColor),
                    const SizedBox(width: 129),
                    SvgPicture.asset("assets/icons/couseicon.svg",
                    height: 16,width: 16),
                    const SizedBox(width: 4),
                    Text(member.course,style: CustomText.memberBodyColor),

                  ],
                ),
               
                const SizedBox(height: 4),

                // Row 4 — Place
                Row(
                  children: [
                    SvgPicture.asset("assets/icons/place.svg",
                        height: 16, width: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        member.place,
                        overflow: TextOverflow.ellipsis,
                        style: CustomText.memberBodyColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Row 5 — Check In + Check Out
                Row(
                  children: [
                    SvgPicture.asset("assets/icons/SignIn.svg",
                        height: 16, width: 16),
                    const SizedBox(width: 4),
                    Text(member.checkIn, style: CustomText.memberBodyColor),
                    const SizedBox(width: 60),
                    SvgPicture.asset("assets/icons/SignOut.svg",
                        height: 16, width: 16),
                    const SizedBox(width: 4),
                    Text(member.checkOut, style: CustomText.memberBodyColor),
                  ],
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
// ====================== MEMBER MODEL ======================
class Member {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String collage;
  final String course;
  final String place;
  final String checkIn;
  final String checkOut;
  final String photoUrl;

  Member({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.collage,
    required this.course,
    required this.place,
    required this.checkIn,
    required this.checkOut,
    required this.photoUrl,
  });

  factory Member.fromFirestore(String id, Map<String, dynamic> data) {
    return Member(
      id: id,
      name: data['name']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      collage: data['collage']?.toString() ?? '',
      course: data['course']?.toString() ?? '',
      place: data['state']?.toString() ?? data['place']?.toString() ?? '',
      checkIn: data['arrivalDate'] is Timestamp
          ? _formatDate(data['arrivalDate'])
          : '',
      checkOut: data['exitDate'] is Timestamp
          ? _formatDate(data['exitDate'])
          : '',
      photoUrl: data['photoUrl']?.toString() ?? '',
    );
  }

  static String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }
}

