import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ngo_web/Sections/Home/About%20us/Events/Members/Member_afterloginpage.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/Members/StudentBody/studentAdminpopuppage.dart';
import 'package:ngo_web/constraints/CustomButton.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:ngo_web/constraints/custom_text.dart';

class StudentListPage extends StatelessWidget {
  const StudentListPage({super.key});

  // ================== FIREBASE STREAM ======================
  Widget memberStream() {
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
            return _memberRow(member);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.secondaryColor,

      // =================== APP BAR ===================
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

      // =================== BODY ===================
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Student Members",
              style: GoogleFonts.inter(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Phone numbers are hidden. Admin login required to view them.",
              style: GoogleFonts.inter(fontSize: 14),
            ),
            const SizedBox(height: 30),

            Expanded(child: memberStream()),
          ],
        ),
      ),
    );
  }
}

// ================= MEMBER ROW =================
Widget _memberRow(Member member) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        // ── Avatar — fetches photoUrl from Firebase ──
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

        // ── Name ──
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

        // ── Phone (masked) ──
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

        // ── College ──
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

        // ── Course ──
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

        // ── Place ──
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

        // ── Check In ──
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

        // ── Check Out ──
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

// ================= MEMBER MODEL =================
class Member {
  final String id;
  final String name;
  final String phone;
  final String collage;
  final String course;
  final String place;
  final String checkIn;
  final String checkOut;
  final String photoUrl; // ✅ renamed from 'image'

  Member({
    required this.id,
    required this.name,
    required this.phone,
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
      collage: data['collage']?.toString() ?? '',
      course: data['course']?.toString() ?? '',
      place: data['state']?.toString() ?? data['place']?.toString() ?? '',
      checkIn: data['arrivalDate'] is Timestamp
          ? _formatDate(data['arrivalDate'])
          : '',
      checkOut: data['exitDate'] is Timestamp
          ? _formatDate(data['exitDate'])
          : '',
      photoUrl: data['photoUrl']?.toString() ?? '', // ✅ correct field name
    );
  }

  static String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }
}
