
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ngo_web/Sections/Home/About%20us/Events/Members/Member_afterloginpage.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/Members/StudentBody/studentAdminpopuppage.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/Members/adminloginpop_memberpage.dart';
import 'package:ngo_web/constraints/all_colors.dart';

class StudentListPage extends StatelessWidget {
  const StudentListPage({super.key});

  // ================== Firebase stream ======================
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
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AllColors.primaryColor,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const Studentadminpopuppage(),
                );
              },
              child: Text(
                "Admin Login",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AllColors.secondaryColor,
                ),
              ),
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
              "To give the phone number login as an admin",
              style: GoogleFonts.inter(fontSize: 14),
            ),
            const SizedBox(height: 30),

            // FIREBASE DATA
            Expanded(child: memberStream()),
          ],
        ),
      ),
    );
  }
}

//==================== MEMBER ROW =====================
Widget _memberRow(Member member) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundImage:
              member.image.isNotEmpty ? NetworkImage(member.image) : null,
          child: member.image.isEmpty ? const Icon(Icons.person) : null,
        ),
        const SizedBox(width: 20),

        SizedBox(width: 120, child: Text(member.name)),
        const SizedBox(width: 10),

        const Icon(Icons.phone, size: 18),
        const SizedBox(width: 6),
        const SizedBox(width: 110, child: Text("***********")),

        const SizedBox(width: 20),
        const Icon(Icons.school, size: 18),
        const SizedBox(width: 6),
        SizedBox(width: 120, child: Text(member.collage)),

        const SizedBox(width: 20),
        const Icon(Icons.book, size: 18),
        const SizedBox(width: 6),
        SizedBox(width: 120, child: Text(member.course)),

        const SizedBox(width: 20),
        const Icon(Icons.place, size: 18),
        const SizedBox(width: 6),
        SizedBox(width: 120, child: Text(member.place)),

        const SizedBox(width: 20),
        const Icon(Icons.login, size: 18),
        const SizedBox(width: 6),
        Text(member.checkIn),

        const SizedBox(width: 30),
        const Icon(Icons.logout, size: 18),
        const SizedBox(width: 6),
        Text(member.checkOut),
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
  final String image;

  Member({
    required this.id,
    required this.name,
    required this.phone,
    required this.collage,
    required this.course,
    required this.place,
    required this.checkIn,
    required this.checkOut,
    required this.image,
  });

  factory Member.fromFirestore(String id, Map<String, dynamic> data) {
    return Member(
      id: id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      collage: data['collage'] ?? '',
      course: data['course'] ?? '',
      place: data['state'] ?? data['place'] ?? '',
      checkIn: data['arrivalDate'] != null
          ? (data['arrivalDate'] as Timestamp)
              .toDate()
              .toString()
              .split(' ')[0]
          : '',
      checkOut: data['exitDate'] != null
          ? (data['exitDate'] as Timestamp)
              .toDate()
              .toString()
              .split(' ')[0]
          : '',
      image: data['image'] ?? '',
    );
  }
}
