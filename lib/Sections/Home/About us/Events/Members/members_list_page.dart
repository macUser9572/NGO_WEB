import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/Members/adminloginpop_memberpage.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Assume these already exist in your project
// import 'all_colors.dart';
// import 'admin_login_popup.dart';

class MembersListPage extends StatelessWidget {
  const MembersListPage({super.key});

  // ================= FIREBASE STREAM =================
  Widget membersStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Member_collection') // ✅ correct collection
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
          return const Center(child: Text("No members found"));
        }

        return ListView.separated(
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final data =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;

            final member = Member.fromMap(data);
            return _memberRow(member);
          },
        );
      },
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.secondaryColor,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: AllColors.secondaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AllColors.thirdColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AllColors.thirdColor),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(right: 24),
        child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: AllColors.primaryColor,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // ✅ Square
      ),
    ),
    onPressed: () {
      showDialog(
        context: context,
        builder: (_) => const AdminLoginPopup(),
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

      // ================= BODY =================
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "BCS Members",
              style: GoogleFonts.inter(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            /// 🔥 FIREBASE DATA
            Expanded(child: membersStream()),
          ],
        ),
      ),
    );
  }

  // ================= MEMBER ROW =================
  Widget _memberRow(Member member) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: member.image.isNotEmpty
                ? NetworkImage(member.image)
                : null,
            child: member.image.isEmpty ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 20),

          SizedBox(width: 120, child: Text(member.name)),
          const SizedBox(width: 10),

          const Icon(Icons.phone, size: 18),
          const SizedBox(width: 6),
          SizedBox(width: 110, child: Text("***********")),

          const SizedBox(width: 20),
          const Icon(Icons.public, size: 18),
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
}

// ================= MEMBER MODEL =================
class Member {
  final String id;
  final String name;
  final String phone;
  final String place;
  final String checkIn;
  final String checkOut;
  final String image;

  Member({
    required this.id,
    required this.name,
    required this.phone,
    required this.place,
    required this.checkIn,
    required this.checkOut,
    required this.image,
  });

  factory Member.fromMap(Map<String, dynamic> data) {
    return Member(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      place: data['state'] ?? data['place'] ?? '',
      checkIn: data['arrivalDate'] != null
          ? (data['arrivalDate'] as Timestamp).toDate().toString().split(' ')[0]
          : '',
      checkOut: data['exitDate'] != null
          ? (data['exitDate'] as Timestamp).toDate().toString().split(' ')[0]
          : '',
      image: data['image'] ?? '',
    );
  }

  factory Member.fromFirestore(String id, Map<String, dynamic> data) {
    return Member.fromMap({...data, 'id': id});
  }
}
