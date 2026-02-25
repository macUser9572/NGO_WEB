import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/Members/adminloginpop_memberpage.dart';
import 'package:ngo_web/constraints/CustomButton.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:ngo_web/constraints/custom_text.dart';

class MembersListPage extends StatelessWidget {
  const MembersListPage({super.key});

  // ================= FIREBASE STREAM =================
  Widget membersStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Member_collection')
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
            child: CustomButton(
              label: "Admin Login",
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const AdminLoginPopup(),
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
              "BCS Members",
              style: GoogleFonts.inter(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
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
          // ── Avatar with SVG fallback ──
          member.image.isNotEmpty
              ? CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(member.image),
                )
              : SvgPicture.asset(
                  "assets/icons/user.svg",
                  width: 32,
                  height: 32,
                ),

          const SizedBox(width: 12),

          // ── Name ──
          Expanded(flex: 3, child: Text(member.name , style: GoogleFonts.inter(fontSize: 16,fontWeight:FontWeight.w500,color: Colors.black))),

          // ── Phone (masked) ──
          Expanded(
            flex: 3,
            child: Row(
              children:  [
                SvgPicture.asset("assets/icons/PhoneCall.svg", height: 32,width: 32,),
                SizedBox(width: 6),
                Expanded(child: Text("***********" , style: CustomText.memberBodyColor,)),
              ],
            ),
          ),

          // ── Place ──
          Expanded(
            flex: 4,
            child: Row(
              children: [
                SvgPicture.asset("assets/icons/place.svg", height: 32,width: 32,),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(member.place, overflow: TextOverflow.ellipsis, style: CustomText.memberBodyColor,),
                ),
              ],
            ),
          ),

          // ── Check In ──
          Expanded(
            flex: 3,
            child: Row(
              children: [
               SvgPicture.asset("assets/icons/SignIn.svg", height: 32,width: 32,),
                const SizedBox(width: 6),
                Expanded(child: Text(member.checkIn, style: CustomText.memberBodyColor,)),
              ],
            ),
          ),

          // ── Check Out ──
          Expanded(
            flex: 3,
            child: Row(
              children: [
                SvgPicture.asset("assets/icons/SignOut.svg", height: 32,width: 32,),
                const SizedBox(width: 6),
                Expanded(child: Text(member.checkOut, style: CustomText.memberBodyColor,)),
              ],
            ),
          ),
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
